

# 安装

## es 安装

- 以 es 6.3.0 为例介绍安装，先准备三个文件 `elasticsearch-6.3.0.tar.gz, elasticsearch-analysis-ik-6.3.0.zip, kibana-6.3.0-windows-x86_64.zip`
- 或者 6.8 版本：
- 其中 `kibana-6.3.0-windows-x86_64.zip` 为方便 windows 下使用的客户端，可以不安装直接使用 restful 接口请求
- es 不能以 root 用户安装，因此建议专门创建一个用户启动 es，此处用户名密码都为 elasticsearch
```bash
useradd -m es
passwd es
# 设置密码也为 es
```
- 解压 `tar -zxf elasticsearch-6.3.0.tar.gz` 到用户目录
- es 依赖 java 环境，我们编辑 `conf/jvm.options`，设置虚拟机参数，此处为将默认的 1g 内存设置到 512m，若不改动则无需设置
- 编辑 `conf/elasticsearch.yml`，主要设置数据目录、日志目录、可访问 ip
```yml
path.data: /home/es/es/data # 数据目录位置
path.logs: /home/es/es/logs # 日志目录位置
network.host: 0.0.0.0 # 绑定到0.0.0.0，允许任何ip来访问
```
- 创建我们配置的数据目录：`mkdir /home/es/es/data /home/es/es/logs`
- es 默认占用 9200 和 9300 端口，-
    - 9300：集群节点间通讯接口
    - 9200：客户端访问接口

- 执行 `bin/elasticsearch` 启动，然后访问 9200 端口 `curl localhost:9200`，可以看到 json 串则表示启动成功

## 解决安装问题

- 所有错误修改完毕，一定要重启你的 Xshell终端，否则配置无效

### 文件权限不足

- 问题描述：`[1]: max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]`
- 因为我们使用的是 elasticsearch 用户而不是 root 用户，因而文件权限不足
- 我们使用 root 用户修改配置文件：`vim /etc/security/limits.conf`，添加下列内容：
```conf
* soft nofile 65536

* hard nofile 131072

* soft nproc 4096

* hard nproc 4096
```


### 进程虚拟内存不足

- 问题描述：`[3]: max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]`
- vm.max_map_count：限制一个进程可以拥有的VMA(虚拟内存区域)的数量
- 我们修改配置文件 `vim /etc/sysctl.conf`，添加下列内容：
```conf
vm.max_map_count=655360
```
- 然后执行命令：`sysctl -p` 重新载入配置，然后重启终端并重启 es 服务


## 安装 ik 分词器用于中文分词

- 我们解压 `unzip elasticsearch-analysis-ik-6.3.0.zip -d ik-analyzer` 到 plugins 目录下，并重命名为 ik-analyzer
- 重新启动 es，测试分词插件是否安装成功，下面为 kibana 语法，可以直接使用 rest 接口测试：
```json
POST _analyze
{
  "analyzer": "ik_max_word",
  "text":     "我是中国人"
}
```
- 直接使用 curl 测试分词：
```
curl -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"analyzer":"ik_max_word","text":"我是中国人"}' localhost:9200/_analyze
```


## 配置开机启动

- 我们基于 systemctl 配置开机自启动
- 由于 es 的启动命令是阻塞的，且不提供关闭指令，我们最好编写启动和关闭脚本
- 在 es 下创建启动目录 `mkdir boot`
- 创建启动文件：`vim start.sh`
```sh
#!/bin/bash
export JAVA_HOME=/usr/local/jdk
nohup /home/es/es/bin/elasticsearch > /home/es/es/boot/nohup.out 2>&1 &
```
- 创建关闭文件：`vim stop.sh`
```sh
#!/bin/bash
kill -9 $(lsof -i tcp:9200 -t)
```
- 为这两个脚本添加执行权限：`chmod +x /home/es/es/boot/start.sh /home/es/es/boot/stop.sh`
- 退回 root 用户，同样利用 systemctl，我们编辑 `vim /etc/systemd/system/elasticsearch.service`，特别注意的是要配置用户，不能使用默认的 root：
```conf
[Unit]
Description=elasticsearch
After=network.target

[Service]
Type=forking
User=es
LimitNOFILE=100000
LimitNPROC=100000
ExecStart=/home/es/es/boot/start.sh
ExecStop=/home/es/es/boot/stop.sh
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 刷新配置并启动
```sh
systemctl daemon-reload \
&& systemctl enable elasticsearch.service \
&& systemctl start elasticsearch.service \
&& systemctl status elasticsearch.service
```

## 集群搭建

- 配置基于 6.8.13，其他版本可能有细微区别
- 准备三台机子，此处为 c11, c12, c13，对应的 ip 分别为 192.168.25.11, 192.168.25.12, 192.168.25.13，并在 /etc/hosts 中配置好
- 安装步骤和前面的单击安装步骤一直，只需修改 config/elasticsearch.yml 文件中的部分内容即可：
```yml
# 集群名称，所有实例的集群名称必须一致，该名称在 spring boot 中配置时会用到
cluster.name: my-application
# 节点名称，同个集群中的节点名称必须不同，此处为别为 node-11, node-12, node-13
node.name: node-11
# 数据和日志目录，若不存在记得体检创建对应目录
path.data: /home/es/es/data
path.logs: /home/es/es/logs
# 外部允许访问的 ip，一般会配置为 0.0.0.0 或只允许本机访问
# 注意外部访问 es 节点默认通过 9200 端口，而 es 集群内部，节点之间的通信默认通过 9300 端口，因此此处的配置不影响内部节点通信
network.host: 0.0.0.0
# 防止 "split brain"，暂时不知什么意思，官方建议配置为 节点总数 / 2 + 1，我们有 3 个节点因此配置为 2
discovery.zen.minimum_master_nodes: 2
# 设置 3 个节点启动后才执行初始恢复，即全部启动后再初始恢复
gateway.recover_after_nodes: 3
```
- 基于 systemctl 配置自启动步骤和前面一致，此处省略
- 完成配置后，可以打包成 tar.gz 文件并使用 scp 拷贝到对应的机子，解压，修改 node.name 即可
```bash
# 传输文件
scp es.tar.gz es@c12:/home/es
# 传输目录
scp -r es/ es@c13:/home/es
```
- 部署完成后，使用 `curl localhost:9200/_cat/health?v` 检查集群节点数


# 入门