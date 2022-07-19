
# 安装

## 下载与安装

- 下载 nacos：`https://github.com/alibaba/nacos/releases/download/1.2.1/nacos-server-1.2.1.tar.gz`
- 解压：`tar -zxf nacos-server-1.2.1.tar.gz -C /usr/local/`
- 我们解压到 /usr/local/ 目录下，解压完即安装完成，相关命令都在 bin 目录下

**配置自启动**

- 创建 service 文件：`vim /etc/systemd/system/nacos.service`，并填入下述内容：
```conf
[Unit]
Description=nacos
After=network.target
 
[Service]
Type=forking
ExecStart=/usr/local/nacos/bin/startup.sh -m standalone
ExecReload=/usr/local/nacos/bin/shutdown.sh
ExecStop=/usr/local/nacos/bin/shutdown.sh
PrivateTmp=true

[Install]  
WantedBy=multi-user.target
```
- 修改 startup.sh 脚本，设置 JAVA_HOME 为 /usr/local/jdk：
```bash
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/usr/local/jdk
# [ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/usr/java
# [ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/opt/taobao/java
# [ ! -e "$JAVA_HOME/bin/java" ] && unset JAVA_HOME
```
- 刷新配置并启动：
```sh
systemctl daemon-reload \
    && systemctl enable nacos.service \
    && systemctl start nacos.service \
    && systemctl status nacos.service
```