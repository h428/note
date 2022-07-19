

# 安装

## 下载与编译

- 访问[官网](https://redis.io/)，选择一个合适的稳定版，此处选择当前最新版 6.0.8：`wget https://download.redis.io/releases/redis-6.0.8.tar.gz`
- CentOS 7 默认安装的 gcc 版本为 4.8.5，无法编译 redis，需要升级
```bash
yum -y install centos-release-scl
yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
scl enable devtoolset-7 bash
```
- 需要注意的是 scl 命令启用只是临时的，退出 shell 或重启就会恢复原系统 gcc 版本，需要长期使用的话需要将命令追加到 /etc/profile：
```bash
echo "source /opt/rh/devtoolset-7/enable" >> /etc/profile
```
- 解压后，进入 redis 目录，执行 `make PREFIX=/usr/local/redis install` 进行安装，若失败，下次执行前要先使用 `make distclean` 清除
- 特别注意，最好设置 PREFIX=/usr/local/redis

## redis.conf 配置与启动

- 对于刚安装完的 redis，我们需要对 redis.conf 进行配置，并在启动时提供给 redis-server，否则可能只有本机能连接，程序连接不上
- 对于 redis.conf 主要涉及下列配置更改
```conf
# 注释掉本机绑定，否则只有本机才能连接 redis
# bind 127.0.0.1
# 关闭保护模式，否则同样只有本机才能连接
protected-mode no
# 设置 redis 端口，默认 6379，无需修改则不动
port 6379
# 设置 redis 支持后台模式，若设置为 no，shell 的退出将导致 redis 的退出
# redis 默认 daemonize 为 no，退出界面则结束进程，
# 我们要安装 redis 服务，因此要设置 redis 以守护进程方式启动：`daemonize yes`
daemonize yes
```
- 准备好配置文件 redis.conf，配置文件建议放置在安装目录下的 conf，例如 conf/6379/redis.conf, conf/6380/redis.conf 以便于统一管理
- 测试启动：`/usr/local/redis/bin/redis-server /usr/local/redis/conf/6379/redis.conf`，使用 netstat 可以看见相关进程即可
- 也可以使用客户端尝试连接：`/usr/local/redis/bin/redis-cli`

## 使用 systemctl 设置自启动


- 基于 systemctl 配置自启动，则准备 `vim /etc/systemd/system/redis.service`，内容使用官方提供的 utils 下的多实例样本，按自己需求修改 redis-server 和 redios.conf 的位置：
```conf
[Unit]
Description=redis
AssertPathExists=/usr/local/redis/conf/6379/redis.conf

[Service]
Type=forking
Type=forking
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/6379/redis.conf
ExecStop=kill -9 $(lsof -i tcp:6379 -t)

[Install]
WantedBy=multi-user.target
```

- 刷新配置，自启动并启动：`systemctl daemon-reload && systemctl enable redis.service && systemctl start redis.service && systemctl status redis.service`

## 旧版自启动

- 进入 `cd utils` 目录，使用官方提供的脚本 `./install_server.sh` 安装服务和自启动
- 需要注意在使用 systemd 的系统改脚本会报错，注释掉下面的内容即可：
```bash
#bail if this system is managed by systemd
#_pid_1_exe="$(readlink -f /proc/1/exe)"
#if [ "${_pid_1_exe##*/}" = systemd ]
#then
#       echo "This systems seems to use systemd."
#       echo "Please take a look at the provided example service unit files in this directory, and adapt and install them. Sorry!"
#       exit 1
#fi
```
- 成功安装后，默认的配置文件如下，如果指定了 PREFIX 则位于 PREFIX 对应的目录下：
```
Port           : 6379
Config file    : /etc/redis/6379.conf
Log file       : /var/log/redis_6379.log
Data dir       : /var/lib/redis/6379
Executable     : /usr/local/bin/redis-server
Cli Executable : /usr/local/bin/redis-cli
```
- 修改配置文件：
```conf
# 注释掉只允许本机启动
# bind 127.0.0.1
# 以守护进程方式运行
daemonize yes
# 关闭保护模式，否则只允许本机连接
protected-mode no
```
- 重启 redis，启动方式：`/usr/local/bin/redis-server /etc/redis/6379.conf`