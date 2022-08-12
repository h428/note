

# 1. 三大要素

## 1.1 容器与镜像

- 三大要素 : 容器、镜像、仓库
- 容器是镜像的实例，可以从一个镜像创建多个容器实例
- 容器可以被启动、开始、停止、删除，可以将容器看做是一个集装箱，集成在 docker 环境（鲸鱼）上
- 每个容器都是相互隔离、保证安全的平台
- 可以将容器看做是一个建议版的 Linux 环境（包括 root 用户权限，进程工具、用户空间和网络空间等）和运行在其中的应用程序

## 1.2 仓库

- 仓库用于存放镜像，类似 github
- 仓库 (Repository) 和仓库注册服务器 (Registry) 是有区别的，仓库注册服务器上存放着多个仓库，每个仓库中又包含多个镜像，每个镜像有不同的标签 (tag)
- 仓库分为公开库和私有库，最大的公开库是 [Docker Hub](https://hub.docker.com)，国内也有对应的镜像

## 1.3 总结

- Docker 本身是一个容器运行载体或称之为管理引擎
- 我们把整个开发文件打包成一个可交付的环境，这个环境就是 image 镜像文件，即前面的镜像的概念
- Docker 利用这个 image 镜像环境，实例化 image 镜像实例，即为容器，一个 image 镜像文件可以生成多个实例，从而可以快速部署


# 2. Docker 安装

- 安装 docker 强烈建议使用 Centos 7 以上，根据[官方教程](https://docs.docker.com/install/linux/docker-ce/centos/)进行安装
- [阿里云教程](https://www.alibabacloud.com/help/zh/doc-detail/60742.htm)

## 2.1 Centos 7.2

- 先安装 devicemapper 用于设置 docker 相关的 repo : `sudo yum install -y yum-utils device-mapper-persistent-data lvm2`
- 配置 repo，注意不能采用官网源而要采用阿里云，否则会很慢 : `yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo`，其会在 `/etc/yum.repos.d` 生成一个相关源供安装 docker 时使用
- 安装 : `yum install docker-ce docker-ce-cli containerd.io`
- 验证 : `docker version`
- 运行 : `systemctl start docker`
- 测试 : `docker info`
- 下载并安装 docker-composed，添加 x 权限，复制到 `/usr/bin` 以添加到 PATH 中


## 2.2 Ubuntu 16.04

- 略

## 2.3 配置阿里源

- 首先登录阿里云，拿到个人的 Docker Hub 的加速地址 `https://sh2e3evc.mirror.aliyuncs.com`
- 执行下述命令快速配置，实际上就是编写 `/etc/docker/daemon.json` 文件，添加镜像后重启
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://sh2e3evc.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```
- 执行 `docker info` 查看镜像是否生效

# 3. Docker 常用命令

## 3.1 帮助命令

- `docker version` : 查看版本
- `docker info` 更加详细的信息
- `docker --help` : 类似 Linux 的 man，介绍 docker 命令

## 3.2 镜像命令

- `docker images` : 列出本地的所有镜像，相关参数有 `-a, -q,--gigests,--no-trunc`，
可以组合，例如 `-qa`
    - `docker images -a` : 列出本地所有镜像（含中间映像层）
    - `docker images -q` : 只显示镜像 ID
    - `docker images --digests` : 显示镜像的摘要信息
    - `docker images --no-trunc` : 显示完整的镜像 id 信息
- `docker search 名称` : 去 Docker Hub 查找镜像，相关参数有 `-s, --no-trunc, --automated`
    - `docker search -s 30 tomcat` : 列出收藏数不小于指定值的镜像
    - `docker search --no-trunc tomcat` : 显示完整的说明信息
    - `docker search --automated tomcat` : 只列出自动构建的类型，很少用
- `docker pull 镜像名[:tag]` : 下载镜像
    - `docker pull tomcat` : 默认下载最新版，等价于 `docker pull tomcat:latest`
- `docker rmi 镜像名或镜像 id` : 删除指定镜像
    - `docker rmi hello-world` : 默认删除最新的版本，等价于 `docker rmi hello-world:latest`，但一般会删除失败
    - `docker rmi -f hello-world` : 强制删除
    - `docker rmi -f hello-world nginx` : 同时删除多个
    - `docker rmi -f $(docker images -qa)` : 删除所有镜像
- `docker commit` : 提交容器副本使其成为一个新的镜像
    - `docker commit -m="提交信息" -a="作者" 容器ID 新的镜像名:[标签名]`
- `docker push`

## 3.3 容器命令

- 以 centos 为例子讲解，首先执行 `docker pull centos` 获取镜像
- `docker run [选项] IMAGE [命令] [参数]` : 新建并启动容器
    - `--name=容器新名字` : 为容器指定名称
    - `-d` : 后台运行容器，并返回容器 id，即启动守护式容器
    - `-i` : 以交互模式运行容器，通常与 `-t` 同时使用
    - `-t` : 为容器重新分配一个伪输入终端，通常与 `-i` 同时使用
    - `-P` : 随机端口映射
    - `-p` : 指定端口映射，有以下四种格式
        - `ip:hostPort:containerPort`
        - `ip:containerPort`
        - `hostPort:containerPort`，最常用
        - `containerPort`

### 3.3.1 容器基本操作

- `docker run -it imageId/唯一名称` : 根据镜像启动一个容器，例如 `docker run -it centos`
- `docker run -it --name hao centos` : 运行并指定名称为 hao
- `docker run -d --name tt -p 8080:8080 tomcat` : 以 8080 为端口， tt 为名称运行 tomcat
- `docker ps` 查看正在运行的 docker 容器
    - `docker ps -a` : 展示所有可用容器，包括正在运行的和历史运行过的
    - `docker ps -l` : 展示最近创建的容器
    - `docker ps -n 3` : 展示最近创建的 3 个容器
    - `docker ps -q` : 展示正在运行的容器 id，可配合其他参数使用，如 `docker os -aq` 展示所有容器的 id
    - `docker ps --no-trunc` : 会展示完整的 id 不会截断
- `exit` : 退出容器并停止
- `ctrl + P + Q` : 容器不停止退出
- `docker start 容器id或容器名` : 启动容器，例如 `docker stop hao`
- `docker restart 容器id或容器名` : 重启容器
- `docker stop 容器id或容器名` : 停止容器
- `docker kill 容器id或容器名` : 强制停止容器
- `docker rm 容器id或容器名` : 删除容器
    - `docker rm -f 容器id或容器名` : 强制删除正在运行的容器
    - `docker rm -f $(docker ps -aq)` : 一次性删除所有容器，或者利用管道批量删除 `docker ps -a -q | xargs docker rm`
- `docker top id` : 查看容器进程
- `docker logs id` : 查看容器日志

### 3.3.2 进阶

- `docker run -d imageId/唯一名称` : 根据镜像在后台启动一个容器，例如 `docker run -d centos`，但由于没有对应的前台进程，该容器会立马退出，可以使用 `docker ps -a` 查看其状态
- **重要 : Docker 容器要在后台持续运行，其就必须有一个前台进程**
- 容器运行的命令如果不是那些一直挂起的命令(比如 top, tail, 或 tomcat)，就是会自动退出的，因此建议将要运行的程序以前台进程的形式运行
- `docker run -d --name hhh centos  /bin/sh -c "while true;do echo hello hao;sleep 2;done"` : 运行 centos 容器并每两秒打印 hao
- `docker logs -f -t --tail 容器id或名称` : 查看容器日志
    - `-t` : 打印时加入时间戳
    - `-f` : 跟随最新的日志显示
    - `--tail` : 数字显示最后多少条
- `docker top 容器id或名称` : 查看容器内运行的进程
- `docker inspect 容器id或名称` : 查看容器内部细节，以 json 形式返回
- `docker exec -it 容器id或名称 bashShell` 或 `docker attach 容器id或名称` : 进入正在运行的容器并以命令行交互
- attach 直接进入容器启动命令的终端，不会启动新的进程; exec 是在容器打开新的终端，并且可以启动新的进程，二者都需要原容器正在运行才可以进入容器，但区别是，经测试，`docker exec` 在 exit 后，原容器会继续存在，而 `docker attach` 在 exit 后就会停止
- `docker exec -t hhh ls -l /tmp` : 直接对容器执行命令
- `docker exec -t hhh /bin/bash` : 执行容器的 /bin/bash 命令，相当于直接进入容器
- `docker cp 容器id或名称:容器路径 宿主机路径` : 从容器内拷贝文件到宿主机上，例如 `docker cp h1:/tmp/yum.log /root`
- 设置实例随 docker 启动而启动：`docker update 实例名称 --restart=always`


### 3.3.3 综合练习

- `docker run -it -p 8888:8080 --name t1 tomcat` : 下载并启动 tomcat，名称为 t1
- `docker exec -it t1 /bin/bash` : 进入 tomcat 所在容器(attach 好像不行)
- `rm -rf webapps/docs/` : 删除 tomcat 文档，然后访问，确定文档页面 404
- `docker commit -a="hao" -m="del tomcat docs" t1 hao/tomcat:1.0` : 将删除后的容器重新 commit 为一个镜像，名称为 hao/tomcat，版本 1.0
- `docker rm -f $(docker ps -aq)` : 然后删除所有容器实例
- `docker run -d --name t2 -p 7777:8080 hao/tomcat:1.0` : 以 7777 为端口运行自己打包的 tomcat 镜像，名称为 t2
- 访问 7777 端口的页面，确认文档页面 404，说明我们的修改成功提交到镜像，并可以多次复用
- `docker run -d --name t3 -p 7788:8080 tomcat` : 以 7788 运行官方的 tomcat，名称为 t3，文档能正常访问

# 4. 容器数据卷 (volume, bind)

- 见数据卷笔记

# 5. DockerFile

## 5.1 DockerFile 概述

- DockerFile 是用来构建 Docker 镜像的构建文件，是由一系列命令和参数构成的脚本
- 构建大致包含下述三个步骤 :
    - 编写 DockerFile 文件，必须符合文件规范
    - 执行 `docker build` 将 DockerFile 转化为自定义镜像
    - `docker run` 运行得到的自定义镜像
- 上述步骤有点类似 maven build, jar, java -jar 的步骤

## 5.2 DockerFile 解析过程

### 5.2.1 基础知识

- 每条保留字命令都必须为大写字母，且后面要跟随至少一个参数
- 指定按照从上到下顺序执行
- `#` 表示注释
- 每条指令都会创建一个新的镜像层，并对镜像进行提交

### 5.2.2 Docker 执行 DockerFile 的大致流程

- docker 从基础镜像运行一个容器
- 执行一条指令并对容器做出修改
- 执行类似 `docker commit` 的操作提交一个新的镜像层
- docker 再基于刚提交的镜像运行一个新容器
- 执行 DockerFile 中的下一条指令直到所有指令都执行完成

## 5.3 DockerFile 标准命令

- FROM : 基础镜像，当前新镜像是基于哪个镜像
- MAINTAINER : 镜像维护者的姓名和邮箱地址
- RUN : 容器构建时需要运行的命令
- EXPOSE : 当前容器对外暴露出的端口
- WORKDIR : 指定在创建容器后，终端登录进来后的默认工作目录，一个落脚点
- ENV : 用来在构建镜像过程中设置环境变量，可以在后续的其他指令中使用
- ADD : 将宿主机目录下的文件拷贝进镜像且 ADD 命令会自动处理 URL 和解压 tar 压缩包
- COPY : 类似 ADD，拷贝文件和目录到镜像中，将从构建上下文目录中 <源路径> 的文件/目录复制到新的一层的镜像内的 <目标路径> 位置
- VOLUME : 容器数据卷，用于数据保存和持久化工作
- CMD : 指定一个容器启动时要运行的命令，只有最后一个生效，会被 `docker run` 之后的参数替换
- ENTRYPOINT : 指定一个容器启动时要运行的命令，类似 CMD
- ONBUILD : 当有 DockerFile 继承该 DockerFile 继续构建时，需要额外执行的命令，相当于一个监听器


## 5.4 案例

- scratch 是基础镜像，Docker Hub 中 99% 的镜像都是通过在 base 镜像中安装和配置需要的软件构建出来的，有点类似 java 中的 Object 类

### 5.4.1 自定义 mycentos 镜像

- 查看 Docker Hub 中默认的 centos 镜像状况
- 编写 CentosDockerFile 文件，想让自定义的 centos 带有 vim, ifconfig，并设置登录后的路径
```docker
from centos
MAINTAINER hao<Lyinghao@126.com>

# 设置环境变量和默认路径
ENV mypath /usr/local  
WORKDIR $mypath

# 安装需要的软件
RUN yum -y install vim
RUN yum -y install net-tools

# 暴露 80 端口
EXPOSE 80

# 执行其他命令（不生效）
CMD echo $mypath
CMD echo "build success"

# 启动命令
CMD /bin/bash
```
- 构建 : `docker build -f /myDocker/CentosDockerFile -t hao/centos:1.0 .` 
- 运行 : `docker run -it --name hc1 hao/centos:1.0`，确定默认进入的是 `/usr/local` 目录，以及可以执行 `vim, ifconfig` 命令
- `docker history 镜像id` 列出镜像的变更历史

### 5.4.2 CMD 和 ENTRYPOINT 区别

**CMD**

- 注意 DockerFile 中可以有多个 CMD 指定，但只有最后一个生效，而且 CMD 会被 docker run 之后的参数替换
- 以 tomcat 为例，其最后一行是 `CMD ["catalina.sh", "run"]`，我们在执行 `docker run -it -p 7777:8080 tomcat` 时不指定额外参数，则默认执行默认 CMD，启动 tomcat
- 但我们若启动时，额外提供一条命令 `ls -l`，相当于在 DockerFile 尾部追加了一条命令 `CMD ls -l`，由于 CMD 只执行最后的一句，这将导致默认的 CMD 不执行，从而导致 tomcat 不会自动启动 `docker run -it -p 7777:8080 tomcat ls -l`

**ENTRYPOINT**

- ENTRYPOINT 也是用于指定容器启动时要执行的命令，但和 CMD 不同的是它将不会被覆盖，而是会往该命令内继续追加参数或
- `docker run` 之后的参数会被当做参数传递给 ENTRYPOINT，之后形成新的命令组
- 编写下列 DockerFile (CurlDockerFile)
```docker
FROM centos
RUN  yum install -y curl
CMD ["curl", "-L", "tool.lu/ip"]
```
- 构建 : `docker build -f /myDocker/CurlDockerFile -t myip .`
- 运行 : `docker run -it myip` 可以看到 ip
- 但我们如果想添加额外参数，比如 `curl -i`，但 `-i` 会被默认当做 CMD，从而替换原有 CMD 从而导致错误，此时，我们需要使用 ENTRYPOINT 完成该功能
- 修改 CurlDockerFile 为下述内容
```docker
FROM centos
RUN  yum install -y curl
ENTRYPOINT ["curl", "-L", "tool.lu/ip"]
```
- 重新构建 : `docker build -f CurlDockerFile -t  myip2 .`
- 运行 : `docker run -it myip2`
- 测试添加参数 : `docker run -it myip2 -i`


### 5.4.3 ONBUILD

- 编写 FatherDockerFile 文件如下 :
```docker
FROM centos
RUN  yum install -y curl
CMD ["curl", "-L", "tool.lu/ip"]
ONBUILD RUN echo "father image on build ------ 886"
```
- 构建 : `docker build -f FatherDockerFile -t myip_father .`
- 然后编写 SonDockerFile 文件如下 :
```docker
FROM myip_father
CMD ["curl", "-L", "tool.lu/ip"]
```
- 构建 : `docker build -f SonDockerFile -t myip_son .`

### 5.4.4 ADD 与 COPY

**构建自定义 tomcat**

- 创建 `mkdir -p /hao/tomcat7/` 目录，用于存放 DockerFile 和待拷贝的文件
- 在该目录下创建 `touch c.txt`
- 将 jdk 和 tomcat 安装的压缩包拷贝进该目录
- 在该目录下编写 Dockerfile 文件，名字就叫 Dockerfile
```docker
FROM centos
MAINTAINER hao<Lyinghao@126.com>
# 把宿主机当前上下文的 c.txt拷贝到容器的 /usr/local 路径下
COPY c.txt /usr/local/cincontainer.txt
# 把 java 与 tomcat 添加到容器中
ADD jdk-8u91-linux-x64.tar.gz /usr/local
ADD apache-tomcat-7.0.47.tar.gz /usr/local
# 安装 vim 编辑器
RUN yum -y install vim
# 设置工作访问时的 WORKDIR 路径，即登录默认落脚点
ENV MYPATH /usr/local
WORKDIR $MYPATH
# 配置 java 与 tomcat 环境变量
ENV JAVA_HOME /usr/local/jdk1.8.0_91
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_HOME /usr/local/apache-tomcat-7.0.47
ENV CATALINA_BASE /usr/local/apache-tomcat-7.0.47
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/lib:$CATALINA_HOME/bin
# 容器运行时监听端口
EXPOSE 8080
# 启动时运行 tomcat
# ENTRYPOINT ["/usr/local/apache-tomcat-7.0.47/bin/startup.sh"]
# CMD ["/usr/local/apache-tomcat-7.0.47/bin/startup.sh", "run"]
CMD /usr/local/apache-tomcat-7.0.47/bin/startup.sh && tail -F /usr/local/apache-tomcat-7.0.47/bin/logs/catalina.out
```
- 构建 : `docker build -t hao/tomcat7 .`，默认使用当前路径下的名称为 Dockerfile 的文件
- 运行 : `docker run -d -p 9080:8080 --name ht7 -v /hao/tomcat7/webapps:/usr/local/apache-tomcat-7.0.47/webapps -v /hao/tomcat7/logs:/usr/local/apache-tomcat-7.0.47/logs --privileged=true hao/tomcat7`，同时映射 test 项目和 logs 两个数据卷
- 验证 : 访问对应端口，验证 tomcat 运行正常
- 新建 index.html，写入 `Hello, Docker`，确保能访问
- 重启前面的容器，并访问对应端口 `docker restart ht7`


# 6. Docker Compose

- Docker Compose 是一种用于通过使用单个命令创建和启动 Docker 应用程序的工具，可以使用它来配置应用程序的服务
- 它提供以下命令来管理应用程序的整个生命周期 :
    - 启动、停止和重建服务
    - 查看运行服务的状态
    - 流式运行服务的日志输出
    - 在服务上运行一次性命令
- Docker Compose 安装 :
    - 从 github 下载 Docker Compose
    - 将其命名为 `docker-compose` 添加执行权限，并移动到 `/usr/bin` 下
- 要实现 Docker Compose，需要包括以下步骤：
    - 确保 docker-compose 在 PATH 中
    - 在 `docker-compose.yml` 文件中提供和配置服务名称，以便他们可以在隔离的环境中一起运行
    - 运行 `docker-compose`，`compose` 将启动并运行整个应用程序

## 6.1 Docker Compose 运行 Tomcat

- 正常情况下，要启动 Tomcat，要使用 `docker run` 命令并附带些许参数，例如 `docker run --name tomcat -d -p 8080:8080 tomcat`
- 我们可以利用 docker-compose 进行启动，首先编写 `docker-compose.yml` 如下 :
```yml
version: '3'
services:
  tomcat:
    restart: always
    image: tomcat
    container_name: tomcat
    ports:
      - 8080:8080
```
- 然后，在当前目录下执行 `docker-compose up` 启动容器
- 删除对应容器可直接在当前目录下执行 `docker-compose down`
- 其他命令 :
    - `docker-compose up -d` : 后台运行
    - `docker-compose start` : 启动
    - `docker-compose stop` : 停止
    - `docker-compose down` : 停止并移除容器
- Tomcat 样例 2 :
```yml
version: '3'
services:
  tomcat:
    restart: always
    image: tomcat
    container_name: tomcat
    ports:
      - 8080:8080
    volumes:
      - /hao/tomcat/webapps:/usr/local/tomcat/webapps
    environment:
      TZ: Asia/Shanghai
volumes:
  test:
```
- 注意，新版的 docker 当在 volumes 中指定宿主机的绝对路径时，将自动变为 bind mount，而不再是数据卷 volume，因此要使用数据卷，不能使用路径，而只能给一个名字，所有的数据卷存储在 `/var/lib/docker/volumes/` 下

## 6.2 Docker Compose 运行 MySQL

- 先清除数据卷 : `docker volume rm mysql_mysql-data`
- 同理，创建 `docker-compose.yml` 文件，并填入下述内容 :
```yml
version: '3'
services:
  mysql:
    restart: always
    image: mysql:5.7.21
    container_name: mysql
    ports:
      - 3306:3306
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: root
    command:
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_general_ci
      --lower_case_table_names=1
      --max_allowed_packet=128M
      --explicit_defaults_for_timestamp=true
      --sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_AUTO_CREATE_USER
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```
- 注意 mysql 5.8 移除 NO_AUTO_CREATE_USER 模式，若使用 5.8 需要删除

## 6.3 集成部署应用程序

- 创建 anno 目录，并编写集成部署文件
```yml
version: '3'
services:
  mysql:
    restart: always
    image: mysql:5.7.21
    container_name: mysql
    ports:
      - 3306:3306
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: root
    command:
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_general_ci
      --lower_case_table_names=1
      --max_allowed_packet=128M
      --explicit_defaults_for_timestamp=true
      --sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_AUTO_CREATE_USER
    volumes:
      - data:/var/lib/mysql
      - conf:/etc/mysql

  tomcat:
    restart: always
    image: tomcat
    container_name: tomcat
    ports:
      - 8080:8080
    volumes:
      - webapps:/usr/local/tomcat/webapps
    environment:
      TZ: Asia/Shanghai

volumes:
  webapps:
  data:
  conf:
```
- 清除 : `docker-compose down`
- 数据清除 : `docker volume rm $(docker volume ls -q)`
- 编写 mycustom.cnf
```
[mysqld]
character-set-server=utf8mb4

[mysql]
default-character-set=utf8mb4
```
- 编写自动插入数据的脚本 `setup.sh` : 
```bash
#!/bin/sh
echo "begin insert data..."
sleep 15
mysql -uroot -proot < /etc/mysql/maven.sql
echo "setup success..."
```
- 启动容器 : `docker-compose up -d`
- 移动文件到数据卷
```bash
cp setup.sh /var/lib/docker/volumes/anno_conf/_data/
cp maven.sql /var/lib/docker/volumes/anno_conf/_data/
cp mycustom.cnf /var/lib/docker/volumes/anno_conf/_data/conf.d/
```
- 执行脚本插入数据 : `docker exec mysql /bin/sh /etc/mysql/setup.sh`
- 进入容器数据库 : `docker exec -it mysql mysql -uroot -proot`
- 克隆 ssm-anno 项目，修改 db.properties 的 localhost 为 mysql 的容器名，此处就是 mysql，docker 能自动进行通信，然后执行 `mvn clean package -Dmaven.test.skip=true` 得到 SSM.war
- 复制到数据卷 webapps 中，启动并访问对应地址，看能否取到数据库中的数据（注意这个项目不满足 restful 风格，url 带有 get，刚开始被坑了，有机会重构一下 Template 项目）


# 8. Docker 常用安装

- 旧步骤，仍然保留，推荐基于 docker-compose 进行安装
- 总体步骤为 : 搜索镜像、拉取镜像、查看镜像、启动镜像、停止容器、移除容器

## 8.1 安装 tomcat

- docker hub 上查找 tomcat 镜像 : `docker search tomcat`
- 从 docker hub 上拉去 tomcat 镜像到本地 : `docker pull tomcat`
- 查看是否拉取镜像成功 : `docker images`
- 运行容器 : `docker run -it -p 8080:8080 tomcat`

## 8.2 安装 mysql

**MySQL 5.7**

- docker hub 上查找 mysql 镜像 : `docker search mysql`
- 拉取 mysql 5.7 镜像 : `docker pull mysql:5.7`
- 运行容器：
```bash
docker run -p 12345:3306 \
--name mysql \
-v /volume/mysql/conf:/etc/mysql \
-v /volume/mysql/logs:/var/log/mysql \
-v /volume/mysql/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=root \
-d mysql:5.7
```
- 连接到客户端 : `docker exec -it mysql mysql -uroot -proot`
- 创建数据库和表，插入数据
- 在本机使用类似 Navicat 之类的工具以 12345 端口连接数据库，验证可以成功连接
- 数据备份 : `docker exec mysql sh -c 'exec mysqldump --all-databases -uroot -proot' > /hao/mysql/all-databases.sql`
- 配置 MySQL 默认编码，在 conf 数据卷下创建 my.cnf 文件，填入下述内容
```conf
[client]
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
init_connect='SET collation connection = utf8_unicode_ci'
init_connect='SET NAMES utf8'
character_set_server=utf8
collation-server=utf8_unicode_ci
skip-character-set-client-handshake
skip-name-resolve
```


## 8.3 安装 Redis

- 从 docker hub 拉取 5.0 版本 : `docker pull redis:5.0`
- 首先在宿主机创建 redis.conf 配置文件，否则数据卷映射会默认变为目录：
```
mkdir -p /volume/redis/conf
touch /volume/redis/conf/redis.conf
```
- 运行 redis 5.0 实例，指定实例 Redis 的配置文件为 /usr/local/redis/conf/redis.conf 并将其通过数据卷映射到宿主机的 /volume/redis/conf/redis.conf，同时
```bash
docker run -p 6379:6379 \
--name redis \
-v /volume/redis/data:/data \
-v /volume/redis/conf/redis.conf:/usr/local/redis/conf/redis.conf \
-d redis:5.0 \
redis-server /usr/local/redis/conf/redis.conf --appendonly yes
```
- 测试连接 redis : `docker exec -it id redis-cli` 并写入数据
- 验证持久化文件生成 : `cat /volume/redis/data/appendonly.aof`，可通过重启 redis 实例查看数据是否仍然存在

**方式二**

- 上述通过 docker 指令参数的方式直接开启 Redis 的 aof 持久化，也可以省略该参数，直接在 redis.conf 中添加 `appendonly yes` 开启持久化，大致步骤如下所示
```bash
docker run -p 6379:6379 \
--name redis \
-v /volume/redis/data:/data \
-v /volume/redis/conf/redis.conf:/usr/local/redis/conf/redis.conf \
-d redis:5.0 \
redis-server /usr/local/redis/conf/redis.conf

# 修改宿主机的 /volume/redis/conf/redis.conf，添加 appendonly yes 配置
vim /volume/redis/conf/redis.conf
```


# 9. 其他

## 9.1 推送本地镜像到阿里云

- `docker commit -m="提交信息" -a="作者" 容器ID 新的镜像名:[标签名]`
- 执行 `docker commit -m="dubbo-admin 2.5.3 in tomcat 7.0.57" -a="hao" 428d09b819b7 dubbo-admin` 生成 dubbo-admin 镜像
- 

## 9.2 配置远程连接

- 编辑配置 : `vim /usr/lib/systemd/system/docker.service` (ubuntu 是 `vim /lib/systemd/system/docker.service`)
- 找到 ExecStart，在尾部添加 -H tcp://0.0.0.0:2375
- 重启 docker
```bash
systemctl daemon-reload
systemctl start docker
```
- 开放端口 : `firewall-cmd --zone=public --add-port=2375/tcp --permanent` (ubuntu 使用 ufw allow)
- 本机测试 : `curl http://localhost:2375/verion`
- 浏览器访问 : `http://ip:2375/verion`