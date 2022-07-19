
# 1. 项目概述

## 1.1 项目介绍

- com.demo.ssm:boot-ssm 是基于 spring boot 2.1.9.RELEASE 的 spring boot 项目 demo
- 该项目采用 web mvc 三层架构，包含了一个项目基本的常用组件

## 1.2 子包介绍

- 项目以 com.demo.ssm 为前缀，子包包含 : bean, cfg, component, controller, plug, service
- bean : 本项目用到的一些辅助类，例如常量值，aop 权限校验，ThreadLocal 等
- cfg : 配置类，如 ajax 跨域，swagger-ui 配置等
- component : 组件，主要是一些 web 组件，如 interceptor, handler 等
- controller : 控制器
- plug : 插件，其实就是工具，此处为 Excel 解析示例，对应的数据格式参考 resources/data.xlsx
- service : 服务层

## 1.3 pom 介绍

- 大多数依赖版本通过 spring boot 2.1.9.RELEASE 控制，少数 spring boot 未定义的依赖版本才自定义
- 本项目依赖 com.demo.base:base-component 中的各个组件，如 mapper, entity, dto 等内容

# 2. 项目构建

- web mvc 三层架构，细节略

# 3. 基于 docker 的部署


## 3.1 docker 服务端配置

- [参考链接](https://mp.weixin.qq.com/s/lWJ0zj568XObOsZg_URf_A)
- 配置 docker 的远程连接接口 : 
    - 先编辑配置文件 `vim /usr/lib/systemd/system/docker.service` (ubuntu 是 `vim /lib/systemd/system/docker.service`)
    - 查找 ExecStart，在尾部添加 `-H tcp://0.0.0.0:2375`
- 重启 docker :
```bash
systemctl daemon-reload
systemctl restart docker
```
- 开放端口 : `firewall-cmd --zone=public --add-port=2375/tcp --permanent` (ubuntu 使用 ufw : `ufw allow 2375`)
- 查看端口监听 : `netstat -tnlp |grep 2375`
- 本机测试 : `curl 127.0.0.1:2375/info`
- 浏览器测试 : 访问 `ip:2375/info` , http://129.211.3.194:2375/info

## 3.2 idea 配置

- 安装 Docker 插件，重启
- 添加连接远程 docker 的配置，测试能否连接上，连接不上可能是防火墙的问题
- 注意对于云服务器还有安全组策略要开放
- 连接成功后，可以到镜像、容器等内容，并可以方便操作和删除

## 3.3 基于 docker 部署 spring boot 项目


- 首先要基于 docker 部署数据库，部署教程参考笔记 : docker 部署常用组件


- 首先在 spring boot 项目的 src/main 下创建 docker 目录，并编写 Dockerfile 文件如下：
```Dockerfile
FROM openjdk:8-jdk-alpine
ADD *.jar app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar", "spring.profiles.active=prod"]
```
- 如果在服务器直接通过源码构建则使用 `mvn clean package docker:build -Dmaven.test.skip=true` 其会自动构建项目，生成 jar 并将 jar 拷贝至 src/main/docker 目录下，并配合该目录下的 Dockerfile 构建镜像（要求服务器宿主机同时具有 java, maven, docker 环境）
- 建议利用 idea 的 docker 插件直接将项目部署到远程 docker 镜像，十分方便（服务器只需要安装 docker，项目的构建在本地进行）
- 下面是在 idea 中利用 docker 插件直接部署到服务器，插件窗口显示的构建命令
```
docker build -t boot_ssm:1.0 . && docker run -p 8080:8080 -v /logs/boot:/logs --name demo_boot --link demo_db --restart=always boot_ssm:1.0 
```
- 第一个命令应该是构建镜像，spring boot 的 docker 插件会把 install 后的 jar 拷贝到 src/main/docker 下（install 后可以在 docker 目录下看到 jar 包），然后根据 Dockerfile 中的 `ADD *.jar app.jar` 为将 jar 拷贝进容器，根据第三行，容器在启动时会执行 jar 包，因而启动项目
- 第二个命令就是启动构建的镜像了
- 需要注意对于基于 docker 运行时，连接的数据库也是使用 docker 实例，此时连接名应该为前面的 demo_db，因此要在启动 spring boot 的 docker 实例时要把这个名称告诉它，使用 `--link demo_db:demo_db` 或简写 `--link demo_db` 告诉它

