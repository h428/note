

# 1. MySQL

- 先讲一下配置问题，在 docker 中，mysql 5.7 允许多 cnf 文件配置，相关配置文件主要在 /etc/mysql 这个目录下
- 首先是根配置文件，分别是 /etc/mysql/my.cnf -> /etc/alternatives/my.cnf -> /etc/mysql/mysql.cnf 这三个文件，它们按照分别按照顺序由前者软链接指向后者，因此实际上这三个文件本质上是一个文件（不信的话可以为其中一个添加空行然后查看另外两个是否同步），他们的内容如下：
```cnf
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```
- 上述配置表名，这个文件主要引入 /etc/mysql/conf.d/ 和 /etc/mysql/mysql.conf.d/ 这两个目录中的配置，只要在这两个目录中的后缀为 .cnf 的配置文件都会生效，5.7 通过这种方式来支持多 cnf 配置，
- 因此我们需要自定义的配置，只需在这两个目录下创建 cnf 文件并添加配置即可

## 1.1 直接使用命令行

- 先准备数据库文件 maven.sql，注意这一份数据库文件里包含建库语句和选择指定数据库的语句，以在使用脚本执行时能自动选择指定数据库并插入数据
```sql
drop database if exists maven;
create database maven character set utf8mb4 collate utf8mb4_general_ci;
use maven;
--- 建表语句省略，参 maven.sql
```
- 官方镜像默认会导致中文乱码，因此还需要一些额外配置，我们准备自定义的 code.cnf 文件
```cnf
[client]
default-character-set=utf8mb4

[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
```
- 由于直接使用命令行，一般会将多个命令行写在一个 sh 脚本文件中统一执行，并方便修改，但不知为什么我**直接执行 sh 脚本会出错**，但自己手动按顺序执行又没问题
```sh
#! /bin/bash

docker rm -f demo_db
docker volume rm demo_db_conf demo_db_logs demo_db_mysql
docker run -p 3306:3306 --name demo_db -v demo_db_conf:/etc/mysql/conf.d -v demo_db_logs:/logs -v demo_db_mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=maven --restart=always -d mysql:5.7
docker cp code.cnf demo_db:/etc/mysql/mysql.conf.d/
docker cp maven.sql demo_db:/
docker restart demo_db
```
- 前两句为删除已有容器实例，然后重新运行一个容器实例，名为 demo_db
- `docker cp maven.sql db:/` 将当前目录的 maven.sql 拷贝到容器的根目录
- 启动后（写成 sh 脚本好像会出错），需要稍等一会儿，执行下述命令验证以及插入数据 : 
```
docker exec -it demo_db mysql -uroot -proot
show variables like 'char%';

docker exec -i demo_db mysql -uroot -proot < maven.sql
```
- 需要注意，上述运行 mysql 的容器名称为 demo_db，运行着 spring boot 项目的容器在连接数据库时需要用到这个名称，而且在启动 spring boot 容器实例时要告诉它这个名称
- 部署 boot-ssm 使用到的数据库的容器名就是 demo_db，即 boot-ssm 的 application-prod.yml 中配置内容，而且启动 spring boot 的容器实例时也要使用 `--link demo_db` 选项告知该名称



## 1.2 利用 Dockerfile （推荐）

**方式一**

- 编写 Dockerfile 如下：
```Dockerfile
from mysql:5.7
COPY code.cnf /etc/mysql/conf.d/
COPY maven.sql /

CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]
```
- code.cnf 文件如下：
```
[client]
default-character-set=utf8mb4

[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
```
- 构建镜像：`docker build . -t demo_db`
- 清空数据卷（可选）：`docker volume rm demo_db_conf demo_db_logs demo_db_mysql`
- 运行容器：`docker run -p 3306:3306 --name demo_db -v demo_db_conf:/etc/mysql/conf.d -v demo_db_logs:/var/log/mysql -v demo_db_mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root --restart=always -d demo_db`
- 启动后，稍等一会儿，可以进入容器的 mysql `docker exec -it demo_db mysql -uroot -proot`，然后执行 `show variables like 'char%';`查看
- 导入数据（也可以把导入数据这一步放到 Dockerfile 中不过这样需要编排 sh 脚本，在脚本中创建库，导入数据等，略麻烦）：
```
docker exec -i demo_db mysql -uroot -proot < maven.sql
```


## 1.3 利用 docker-composed


## 1.4 备份


# 2. Spring Boot

- 参考 boot-ssm 项目笔记的部署部分，注意要先部署上述数据库，容器名称为 demo_db

# 3. redis

- 先准备 redis.conf 配置文件
- 注意 redis.conf 的相关配置 :
    - 注释掉 `bind 127.0.0.1` 否则只有本机才能连接
    - `protected-mode yes` 改为 `protected-mode no` 否则只有本机才能连接
    - 注释掉 `daemonize yes` 否则容器无法启动

## 3.1 通过 Dockerfile

- 直接在当前目录准备 redis.conf : `wget http://download.redis.io/redis-stable/redis.conf`
- 编写 Dockerfile 文件 :
```
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
```
- 构建镜像 : `docker build . -t my-redis`
- 运行实例 :
```
docker run -d -p 6379:6379 \
    --privileged=true \
    -v redis_data:/data \
    --name redis my-redis \
    --restart=always \
    --appendonly yes
```
- 测试连接和写入 : `docker exec -it redis redis-cli`
- 可以使用客户端验证能否连接成功以及正常写入

## 3.2 直接通过命令


- 先在当前目录下准备配置文件 redis.conf
- 直接执行下列命令启动容器，两个 -v 分别映射数据和配置文件（使用 redis 3.2 无法启动，最新版可以） :
```
docker run --name redis -p 6379:6379 -d --restart=always redis:latest redis-server --appendonly yes

docker run -d -p 6379:6379 \
    --privileged=true \
    -v redis_data:/data \
    -v $PWD/redis.conf:/usr/local/etc/redis/redis.conf \
    --name redis redis \
    redis-server /usr/local/etc/redis/redis.conf \
    --restart=always \
    --appendonly yes
```
- 测试连接和写入 : `docker exec -it redis redis-cli`
- 可以使用客户端验证能否连接成功以及正常写入