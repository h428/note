

# 1. Centos 7 安装

- 此处使用的 rabbit-mq 版本为 3.17，其要求的 Erlang 的版本最低为 22.x
- [参考文档](https://www.rabbitmq.com/install-rpm.html)

## 1.1 在线安装 Erlang, socat, logrotate

- 使用的是 rabbit-mq 提供的最小的能使 rabbit-mq 运行起来的 Erlang 版本
- 编辑 `/etc/yum.repos.d/rabbitmq_erlang.repo` 文件，填入下述内容
```conf
# In /etc/yum.repos.d/rabbitmq_erlang.repo
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/6/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_erlang-source]
name=rabbitmq_erlang-source
baseurl=https://packagecloud.io/rabbitmq/erlang/el/6/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
```
- 执行 `yun clear all`, `yum makecache`，然后执行 `yum install erlang` 进行安装即可
- `yum install socat logrotate` 安装
- 速度很慢可以考虑走代理

## 1.2 安装 rabbit-mq

- 首先下载最新的 rpm 包 : rabbitmq-server-3.7.17-1.el7.noarch.rpm
- 然后根据官方文档的说明导入最新的安装包对应的签名 : `rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc`
- 安装 : `yum install rabbitmq-server-3.8.0-1.el7.noarch.rpm`
- 设置自启动 : `chkconfig rabbitmq-server on`
- 启动服务 : `/sbin/service rabbitmq-server start`
- 停止服务 : `/sbin/service rabbitmq-server stop`

# 2. 五种消息模型

- rabbit-mq 提供了 6 种消息模型，但第 6 种其实是 rpc，并不是 mq，因此此处略过，主要介绍常见的 5 中
- 五种消息模型分别为 : simple queue, work queue, fanout, direct, topics
- 其实 fanout, direct, topics 都属于发布/订阅(publish/subscribe) 模型，只不过进行路由的方式不同（即使用不同策略的交换机）

## 2.1 基本消息模型 simple

- 最简单的消息模型，生产者将消息发送到队列，消费者从队列中获取消息
- 