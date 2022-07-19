

# 1. 基于 Docker 安装 fastdfs

## 1.1 环境准备与概述

- 所有组件版本和视频保持一致，其中 libfastcommon.tar.gz 视频中没有提到具体版本，采用 github 当前最新，已确定能够正常整合
- [libfastcommon.tar.gz](https://github.com/happyfish100/libfastcommon/archive/V1.0.39.tar.gz) : fastdfs 依赖的组件
- [fastdfs-5.11.tar.gz](https://github.com/happyfish100/fastdfs/archive/V5.11.tar.gz) : fastdfs
- [nginx-1.13.6.tar.gz](http://nginx.org/download/nginx-1.13.6.tar.gz)
- [fastdfs-nginx-module_v1.16.tar.gz](https://sourceforge.net/projects/fastdfs/files/FastDFS%20Nginx%20Module%20Source%20Code/)
- 以 `/root/docker/fastdfs` 为工作目录，进行安装，若有需要可自行调整，无影响

## 1.2 docker-compose.yml

- 在 `/root/docker/fastdfs` 文件夹编写 `docker-compose.yml` 如下 :
```yml
version: '3.1'
services:
  fastdfs:
    build: fastdfs
    restart: always
    container_name: fastdfs
    volumes:
      - storage:/fastdfs/storage
    network_mode: host
volumes:
    storage:
```
- 其中，`build: fastdfs` 表示进行构建镜像操作，构建镜像的文件夹在 `fastdfs`，因此还要创建 `/root/docker/fastdfs/fastdfs` 目录，用于构建镜像

## 1.3 镜像与 Dockerfile

- 在 `/root/docker/fastdfs/fastdfs` 下编写 Dockerfile
```docker
FROM ubuntu:xenial
MAINTAINER topsale@vip.qq.com

# 设置 DNS，否则可能无法 apt update，若失败请尝试重启 docker（视频源脚本无该句）
RUN echo "nameserver 218.85.157.99" | tee /etc/resolv.conf > /dev/null
# 更新数据源
WORKDIR /etc/apt
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' > sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> sources.list
RUN apt-get update

# 安装依赖
RUN apt-get install make gcc libpcre3-dev zlib1g-dev --assume-yes


# 复制工具包
ADD fastdfs-5.11.tar.gz /usr/local/src
ADD fastdfs-nginx-module_v1.16.tar.gz /usr/local/src
ADD libfastcommon.tar.gz /usr/local/src
ADD nginx-1.13.6.tar.gz /usr/local/src

# 安装 libfastcommon
WORKDIR /usr/local/src/libfastcommon
RUN ./make.sh && ./make.sh install

# 安装 FastDFS
WORKDIR /usr/local/src/fastdfs-5.11
RUN ./make.sh && ./make.sh install

# 配置 FastDFS 跟踪器
ADD tracker.conf /etc/fdfs
RUN mkdir -p /fastdfs/tracker

# 配置 FastDFS 存储
ADD storage.conf /etc/fdfs
RUN mkdir -p /fastdfs/storage

# 配置 FastDFS 客户端
ADD client.conf /etc/fdfs

# 配置 fastdfs-nginx-module
ADD config /usr/local/src/fastdfs-nginx-module/src

# FastDFS 与 Nginx 集成
WORKDIR /usr/local/src/nginx-1.13.6
RUN ./configure --add-module=/usr/local/src/fastdfs-nginx-module/src
RUN make && make install
ADD mod_fastdfs.conf /etc/fdfs

WORKDIR /usr/local/src/fastdfs-5.11/conf
RUN cp http.conf mime.types /etc/fdfs/

# 配置 Nginx
ADD nginx.conf /usr/local/nginx/conf

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /
EXPOSE 8888
CMD ["/bin/bash"]
```

- 从上述 Dockerfile 中可以看到涉及 fastdfs 和 nginx 的多个配置文件以及源码，我们需要一一准备他们，所有配置文件的原版可从源码中复制，并做对应修改，
    - client.conf : fastdfs 的客户端配置文件
    - config : fastdfs-nginx-module 的配置文件
    - entrypoint.sh : Dockerfile 中的额外脚本，允许用户自行自己想要的内容
    - fastdfs-5.11.tar.gz : fastdfs 源码，用于编译和构建 fastdfs
    - fastdfs-nginx-module_v1.16.tar.gz : fastdfs 的 nginx 组件源码
    - libfastcommon.tar.gz : fastdfs 依赖的环境
    - mod_fastdfs.conf : fastdfs-nginx-module 配置文件
    - nginx-1.13.6.tar.gz : nginx 源码，但不是从 github 下载的，我用 github 下载的会找不到 `./configure` 而导致脚本执行失败
    - nginx.conf : nginx 配置文件
    - storage.conf : fastdfs 存储节点配置
    - tracker.conf : fastdfs 跟踪器配置
- 在 `/root/docker/fastdfs/fastdfs` 下准备上述所有文件，构建镜像时需要

## 1.4 配置文件

- 原版文件请从源码中复制，下面只记录改动部分
- config, nginx.conf 是整个文件，可以直接使用

### 1.4.1 tracker.conf

- 修改跟踪器存储路径
```conf
base_path=/fastdfs/tracker
```

### 1.4.2 storage.conf

- 修改存储节点存储路径、跟踪器地址、以及端口

```conf
base_path=/fastdfs/storage
store_path0=/fastdfs/storage
tracker_server=192.168.25.31:22122
http.server_port=8888
```

### 1.4.3 client.conf

- 修改客户端配置中的相关路径、地址
```conf
base_path=/fastdfs/tracker
tracker_server=192.168.25.31:22122
```

### 1.4.4 config

- 主要修改路径
```conf
# 修改前
CORE_INCS="$CORE_INCS /usr/local/include/fastdfs /usr/local/include/fastcommon/"
CORE_LIBS="$CORE_LIBS -L/usr/local/lib -lfastcommon -lfdfsclient"

# 修改后
CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
CORE_LIBS="$CORE_LIBS -L/usr/lib -lfastcommon -lfdfsclient"
```

- 删除前面的分支，整份文件的样子为 :
```conf
ngx_addon_name=ngx_http_fastdfs_module
HTTP_MODULES="$HTTP_MODULES ngx_http_fastdfs_module"
NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/ngx_http_fastdfs_module.c"
CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
CORE_LIBS="$CORE_LIBS -L/usr/lib -lfastcommon -lfdfsclient"
CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64 -DFDFS_OUTPUT_CHUNK_SIZE='256*1024' -DFDFS_MOD_CONF_FILENAME='\"/etc/fdfs/mod_fastdfs.conf\"'"
```

### 1.4.5 mod_fastdfs.conf

- fastdfs-nginx-module 配置文件
```conf
connect_timeout=10
tracker_server=192.168.25.31:22122
url_have_group_name = true
store_path0=/fastdfs/storage
```

### 1.4.6 nginx.conf

- nginx 配置文件

```conf
user  root;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    server {
        listen       8888;
        server_name  localhost;

        location ~/group([0-9])/M00 {
            ngx_fastdfs_module;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

## 1.4.7 entrypoint.sh 并添加执行权限

```bash
#!/bin/sh
/etc/init.d/fdfs_trackerd start
/etc/init.d/fdfs_storaged start
/usr/local/nginx/sbin/nginx -g 'daemon off;'
```

## 1.5 启动容器

- 在 `/root/docker/fastdfs` 下执行 `docker-compose up -d`


# 2. 测试上传

- 执行 `docker exec -it fastdfs /bin/bash` 进入容器
- 执行 `/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /usr/local/src/fastdfs-5.11/INSTALL` 测试文件上传
- 可得到一个形如 `group1/M00/00/00/wKhLi1oHVMCAT2vrAAAeSwu9TgM3976771` 的地址
- 打开浏览器，访问 `http://192.168.25.31:8888/group1/M00/00/00/wKhLi1oHVMCAT2vrAAAeSwu9TgM3976771` 查看能否正常查看或下载文件，可以则说明 fastdfs 搭建成功