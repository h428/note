
# 安装

## 从源码安装

- 我们基于源码安装，安装依赖 jdk 和 maven 环境，详细要求参考[官网](https://rocketmq.apache.org/docs/quick-start/)，此处选择 [4.8 版本](https://www.apache.org/dyn/closer.cgi?path=rocketmq/4.8.0/rocketmq-all-4.8.0-source-release.zip)
- 执行 `unzip rocketmq-all-4.8.0-source-release.zip` 解压，并进入目录 `cd rocketmq-all-4.8.0-source-release`
- 执行 `mvn -Prelease-all -DskipTests clean install -U` 进行构建
- 构建完毕后，rocketmq 在 `cd distribution/target/rocketmq-4.8.0/rocketmq-4.8.0` 下，建议将该目录移动到 `/usr/local` 下统一管理 `mv rocketmq-4.8.0 rocketmq && mv rocketmq/ /usr/local/`
- rocketmq 分为两步，先启动 mqnamesrv 再启动 mqbroker，且启动 mqbroker 时要告诉其 mqnamesrv 的地址和端口，默认为 localhost:9876
- 需要注意的是，rocketmq 默认设置的内存大小偏大，如果在虚拟机或者小内存机子上，内存超出了物理机大小将导致启动失败，此时我们需要设置虚拟机参数，mqnameser 和 mqbroker 对应的脚本分别为 runserver.sh 和 runbroker.sh，在脚本内部搜索 JAVA_OPT 找到对应的参数进行设置即可，我的 2G 内存的虚拟机修改如下：
```sh
# namesrv
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
# broker
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MaxMetaspaceSize=100m"
```
- 分别启动 namesrv 和 broker
```bash
nohup bin/mqnamesrv &
# 注意要加 -n 参数不然可能导致 broker 连不上 nameserver 而出错
nohup bin/mqbroker -n localhost:9876 &

# 查看日志
tail -f ~/logs/rocketmqlogs/namesrv.log
tail -f ~/logs/rocketmqlogs/broker.log
```
- 检查已连接到 nameserver 的 broker 列表：`/usr/local/rocketmq/bin/mqadmin clusterList -n localhost:9876`


## 设置开启启动

- 首先创建 boot 文件夹：`mkdir boot && cd boot`
- 编辑启动脚本：`vim start.sh`
```sh
#!/bin/bash
export JAVA_HOME=/usr/local/jdk
nohup /usr/local/rocketmq/bin/mqnamesrv > /usr/local/rocketmq/boot/nameserver.log 2>&1 &
nohup /usr/local/rocketmq/bin/mqbroker -n localhost:9876 > /usr/local/rocketmq/boot/broker.log 2>&1 &
```
- 编辑关闭脚本：`vim stop.sh`
```sh
#!/bin/bash
/usr/local/rocketmq/bin/mqshutdown broker
/usr/local/rocketmq/bin/mqshutdown namesrv
```
- 为启动和关闭脚本添加执行权限：`chmod +x /usr/local/rocketmq/boot/start.sh /usr/local/rocketmq/boot/stop.sh`
- 我们基于 systemd 设置自启动，因此编辑 `vim /etc/systemd/system/rocketmq.service`
```conf
[Unit]
Description=rocketmq
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/rocketmq/boot/start.sh
ExecStop=/usr/local/rocketmq/boot/stop.sh
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 刷新配置并开启自启动：
```bash
systemctl daemon-reload \
    && systemctl enable rocketmq.service \
    && systemctl start rocketmq.service \
    && systemctl status rocketmq.service
```