

# 安装

## seata-server 安装

- 由于 seata 在 1.3 之后才支持联合主键，我们此处采用 1.3.0 版本
- 下载 seata-server 安装包：`wget https://github.com/seata/seata/archive/v1.3.0.tar.gz`
- 由于可能需要一些配置和脚本，因此我们还需要下载源码包，`wget https://github.com/seata/seata/archive/v1.3.0.tar.gz`但只会使用其中几个文件，生产环境只需拷贝对应文件即可

- 我们采用 Spring Cloud Alibaba 技术栈，让 seata 以微服务形式启动，使用 nacos 作为注册中心，因此配置都使用 nacos 相关配置
- 首先，解压源码包，并进入 seata-1.3.0/script/config-center，编辑 config.txt 文件，根据需要开启分布式事务的微服务名称配置文件，其他内容暂时保持不变
```conf
service.vgroupMapping.auth-service=default
service.vgroupMapping.base-user-service=default
service.vgroupMapping.hub-service=default
service.vgroupMapping.hub-user-service=default
service.vgroupMapping.open-service=default
```
- 由于我们采用的 nacos，我们需要把相关配置配置到注册中心 nacos 中去，因此我们进入 nacos 目录，执行脚本向注册中心写入配置，使用 -h 参数配置注册中心地址，我这里为虚拟机地址 `192.168.25.42`
```java
sh nacos-config.sh -h 192.168.25.42
```
- 写入完成后，进入 nacos 注册中心，检查配置是否导入成功
- 解压 seata-server：`tar -zxf seata-server-1.3.0.tar.gz -C /usr/local`，然后进入 /usr/local/seata 目录
- 可以删除修改 conf/registry，由于我们使用 nacos，可以删除其他不必要的配置项，保留最精简的配置，配置 nacos 类型以及对应的注册中心地址即可
```conf
registry {
  type = "nacos"

  nacos {
    application = "seata-server"
    serverAddr = "127.0.0.1:8848"
    group = "SEATA_GROUP"
    namespace = ""
    cluster = "default"
    username = ""
    password = ""
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "nacos"

  nacos {
    serverAddr = "127.0.0.1:8848"
    namespace = ""
    group = "SEATA_GROUP"
    username = ""
    password = ""
  }
}
```
- 我们前面已经导入了配置并在 config 中使用 nacos，因此 file.conf 不再起作用，无需修改，相当于原来在 file.conf 中需要配置的内容全部从 nacos 配置中心中读取
- 对于导入的配置中，我们暂时使用的是 store.mode=file，因此无需额外准备数据库
- 先直接启动测试一下看下能否在 nacos 中看到对应的 service：`/usr/local/seata/bin/seata-server.sh`，有时可能需要使用 -h 参数配置注册中心地址，启动后进入 nacos 控制台检查服务并确认地址为子网地址无误
- 启动 seata-server，由于默认 seata-server.sh 会阻塞，会导致配置自启动时出问题，我们使用 nohup 启动，并将输出重定向到 /usr/local/seata/bin/nohup.out 中
```bash
kill -9 $(lsof -i tcp:8091 -t)
nohup /usr/local/seata/bin/seata-server.sh > /usr/local/seata/bin/nohup.out 2>&1 &
# nohup /usr/local/seata/bin/seata-server.sh -h lab-main -p 8091 > /usr/local/seata/bin/nohup.out 2>&1 &
```
- 然后进入 nacos 查看对应服务是否注册成功，能看到对应的服务说明注册完成

## 配置 seata 开机自启动

- 由于 seata 是阻塞的，且不提供关闭指令，我们需要编写启动和关闭脚本
- 编写 `vim /usr/local/seata/boot/start.sh`：
```sh
#!/bin/bash
export JAVA_HOME=/usr/local/jdk
nohup /usr/local/seata/bin/seata-server.sh > /usr/local/seata/boot/nohup.out 2>&1 &
```
- 编写 `vim /usr/local/seata/boot/stop.sh`：
```sh
#!/bin/bash
kill -9 $(lsof -i tcp:8091 -t)
```
- 为这两个脚本都添加执行权限:`chmod +x /usr/local/seata/boot/start.sh /usr/local/seata/boot/stop.sh`
- 同样利用 systemctl，我们编辑 `vim /etc/systemd/system/seata.service`：
```conf
[Unit]
Description=seata
Requires=nacos.service

[Service]
Type=forking
ExecStart=/usr/local/seata/boot/start.sh
ExecStop=/usr/local/seata/boot/stop.sh
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 刷新配置并启动
```sh
systemctl daemon-reload \
&& systemctl enable seata.service \
&& systemctl start seata.service \
&& systemctl status seata.service
```

# AT 模式

## 数据表 undo_log

- 我们采用 AT Model，需要在每一个业务库中添加数据表 undo_log，用于 Seata 的分布式事务信息的存储以及回滚
```sql
-- for AT mode you must to init this sql for you business database. the seata server not need it.
CREATE TABLE IF NOT EXISTS `undo_log`
(
    `branch_id`     BIGINT(20)   NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(100) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8 COMMENT ='AT transaction mode undo table';
```

## 微服务配置

- 需要引入 Seata 并配置数据源代理，详细整合此处省略，可参考 spring-boot-seata 项目