

# 1. windows

## 1.1 mysql 5.6 多实例

- 进入 mysql 安装（复制）根目录的 bin 下，在该目录下执行 `.\mysqld.exe install MySQL-3380 --defaults-file="D:\All\Server\mysql\3380\data\my.ini"`
    - `D:\All\Server\mysql\3380` 是 mysql 安装目录
    - `D:\All\Server\mysql\3380\data\my.ini` 是该目录下的 mysql 的配置文件，端口即在配置文件中进行设置
    - MySQL-3380 为安装后的服务名
    - 删除系统服务 `sc delete MySQL-3380`
    - 可以使用相对路径，每次只需修改服务名字和配置文件，然后在 bin 下安装服务即可完成数据库实例的快速安装 `.\mysqld.exe install MySQL-3381 --defaults-file="..\data\my.ini"`


## 1.2 MySQL 5.7.26 安装（以 3306 端口为例）

**新实例安装**

- 解压 zip 文件到 `D:\all\server\mysql\3306`，接下来称该目录为根目录，相对目录都是基于该目录
- 在根目录新建 `my.ini` 文件，并填入下述配置，注意不要创建 data 文件夹，而是运行时自动创建
```ini
[client]
port=3306
default-character-set=utf8
[mysqld]
# 设置mysql的安装目录
basedir=D:/all/server/mysql/3306
# 设置mysql的数据目录
datadir=D:/all/server/mysql/3306/data
character_set_server=utf8
sql_mode=NO_ENGINE_SUBSTITUTION,NO_AUTO_CREATE_USER
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
explicit_defaults_for_timestamp=true
```
- 以管理员权限在 CMD 下进入 `bin` 目录，执行 `mysqld -install` 安装服务，默认服务名称为 `MySQL`
- 执行 `mysqld --initialize-insecure` 进行初始化工作，此时 MySQL 应该已经安装并初始化完毕
- 执行 `net start mysql` 启动 MySQL 服务，之后便可以执行 `mysql -uroot -p` 进行登录，默认密码为空
- 如果密码不对，可以尝试在  `data/DESKTOP-PB5DAU8.err` 日志中找到临时密码
- 执行 `alter user 'root'@'localhost' identified by 'root';` 修改密码


# 2. Centos 安装 mysql

## 2.1 Centos 7.2 利用 yum 源安装 mysql 5.7

- [参考教程](https://www.jianshu.com/p/1dab9a4d0d5f)
- 下载 mysql 源 : `wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm`
- 安装 mysql 源 : `yum localinstall mysql57-community-release-el7-11.noarch.rpm`
- 检查 mysql 源是否安装成功 : `yum repolist enabled | grep "mysql.*-community.*"`，如果能看到 3 行一般就是成功
- 安装 mysql 5.7 : `yum install -y mysql-community-server`
- 启动 mysql 服务，Centos 7 下开关服务使用 `systemctl start/stop` : `systemctl start mysqld`
- 查看 mysql 服务状态 : `systemctl status mysqld`
- 设置开机启动 : `systemctl enable mysqld`
- 重新载入配置 : `systemctl daemon-reload`
- mysql 安装完成之后，生成的默认密码在 `/var/log/mysqld.log` 文件中，使用 grep 命令找到日志中的密码 : `grep 'temporary password' /var/log/mysqld.log`
- 登录后，必须先设置一次新密码才能做后续操作，比如修改密码强度
```bash
shell> mysql -uroot -p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!'; 
```

**密码强度修改**

- [参考地址](https://blog.csdn.net/kuluzs/article/details/51924374)
- mysql 5.7 默认安装了密码安全检查插件（validate_password），默认密码检查策略要求密码必须包含：大小写字母、数字和特殊符号，并且长度不能少于8位。否则会提示 ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
- 查看密码强度相关的变量 : `SHOW VARIABLES LIKE 'validate_password%';`，参数解释自行百度或查看上面文档
- 修改密码强度 :
```sql
set global validate_password_policy=0;
set global validate_password_mixed_case_count=0;
set global validate_password_number_count=0;
set global validate_password_special_char_count=0;
set global validate_password_length=3;
SHOW VARIABLES LIKE 'validate_password%';
```
- 修改简单密码 : `SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');`

**开放远程连接**

```sql
use mysql;
update user set host = '%' where user = 'root';
select host, user from user;
flush privileges;
```

**只安装 client**

```bash
# 安装 rpm 源
rpm -ivh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# 通过 yum 搜索，确认能看到 mysql 相关软件
yum search mysql-community
# 本句系统版本安装 mysql 客户端
yum install mysql-community-client.x86_64 -y
```


## 2.2 Centos 7.2 下载 rmp-bundle 包后离线安装

- 卸载原有 mariaDB：
```bash
rpm -qa | grep -i maria
rpm -e mariadb-libs-5.5.44-2.el7.centos.x86_64 --nodeps
```
- 拷贝 bundle 包到 linux 环境，解压 bundle 包获得各个 rmp 包，主要是安装 mysql-server 和 mysql-client，但他们依赖一定的第三方包以及 bundle 中相关 rmp 包
```sh
mkdir mysql && tar -xf mysql-5.7.30-1.el7.x86_64.rpm-bundle.tar -C mysql/
```
- 安装第三方依赖
```bash
yum -y install libaio.so.1 libgcc_s.so.1 libstdc++.so.6 libncurses.so.5 --setopt=protected_multilib=false \
&& yum update libstdc++-4.4.7-4.el6.x86_64
```
- 解压 rmp-bundle 包并安装，注意 rmp 包有依赖顺序，因此要按序安装：
```bash
rpm -ivh mysql-community-common-5.7.30-1.el7.x86_64.rpm \
&& rpm -ivh mysql-community-libs-5.7.30-1.el7.x86_64.rpm \
&& rpm -ivh mysql-community-client-5.7.30-1.el7.x86_64.rpm \
&& rpm -ivh mysql-community-server-5.7.30-1.el7.x86_64.rpm
```
- 安装完成后，启动、密码修改、设置强度等和 2.1 保持一致

# 3. Ubuntu 安装 MySQL 5.7


## 2.3 docker 安装 mysql 5.7

- 参考 docker 笔记