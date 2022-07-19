
# 0. 相关机器

- vm1 : `192.168.25.31 ubuntu1`, zookeeper 集群
- vm2 : `192.168.25.32 ubuntu2`, redis 集群
- vm3 : `192.168.25.33 ubuntu3`, solr
- vm4 : `192.168.25.34 ubuntu4`, docker 私服
- vm5 : `192.168.25.35 ubuntu5`, 专门用于构建和 push 镜像到私服
- vm6 : `192.168.25.36 ubuntu6`, 运行 service 工程
- vm7 : `192.168.25.37 ubuntu7`, 运行 web 工程

# 1. 私服搭建


- 在 vm4 搭建 Docker 私服服务端 
```yml
version: '3.1'
services:
  registry:
    image: registry
    restart: always
    container_name: registry
    ports:
      - 5000:5000
    volumes:
      - data:/var/lib/registry
volumes:
    data:
```
- 若搭建有误可清除后重建
```
docker-compose down 
docker volume rm registry_data
```
- 浏览器测试访问 : `http://192.168.25.34:5000/v2/` 
- 查看已有镜像 : `http://192.168.25.34:5000/v2/_catalog`

# 2. 客户端配置私服地址

- 使用 vm5 作为构建客户端，为其添加私服地址，然后测试镜像的构建与上传
- 修改 `vim /lib/systemd/system/docker.service` 文件，在 ExecStart 尾部添加 `--insecure-registry 192.168.25.34:5000`
- 重启 docker
```
systemctl daemon-reload
service docker restart
```
- 测试镜像的下载与上传
```
## 拉取一个镜像
docker pull nginx

## 查看全部镜像
docker images

## 标记本地镜像并指向目标仓库（ip:port/image_name:tag，该格式为标记版本号）
docker tag nginx 192.168.25.34:5000/nginx

## 提交镜像到仓库
docker push 192.168.25.34:5000/nginx
```
- 执行 `curl -XGET http://192.168.25.34:5000/v2/_catalog` 验证镜像上传成功，或直接浏览器打开对应地址
- 删除并拉取私服镜像
```bash
# 删除本地镜像
docker rmi nginx
docker rmi 192.168.25.34:5000/nginx

# 拉取私服镜像
docker pull 192.168.25.34:5000/nginx
```

# 3. 容器化部署

- 本地运行可以直接使用 `java -jar xxx.jar` 运行对应工程的 jar 包
- 对于开发阶段，往往会进行持续集成和持续交付进行自动部署，而对于生产环境，为了稳妥起见，往往需要手动部署，这是十分繁琐的工作，但有了容器已经能大大地方便我们的操作
- 容器化部署主要依赖下述内容 :
    - jar 包 : java 工程打包成的 jar 包
    - Dockerfile : 利用 jar 包构建镜像，供生产环境使用
    - docker-compose.yml : 一般不会直接 docker run 而是提供该文件让生产环境执行，保持命令的一致性 
- 容器化部署一般有两个步骤：
    - 使用一台专门用于构建的服务器，其利用 Dockerfile 和 jar 包构建镜像，并上传镜像到 docker 私服
    - 生产环境从私服拉取镜像，并使用 docker run 或 docker-compose 运行即可
- 其中 jar 的生成有两种方式，一是本地打包完毕直接将 jar 上传到服务器，二是上传源码直接在服务器构建 jar，前者需要服务器需要有 java, maven 环境，推荐使用后者
- Dockerfile 一般要用到 jar 以 ADD 到容器中，或者利用 Spring Boot 的 docker:build 插件（基于 maven）自动构建

# 4. 部署具体操作

- 源码的 docker 文件夹已提供 Dockerfile 和 docker-compose.yml 文件，可复制使用
- 执行 mymvn.bat 会在本机自动构建，并生成 build 文件夹，脚本会自动将 jar 包和 Dockerfile 拷贝到该目录
- 压缩 build 目录，上传到 vm5，解压并进入各个工程分别构建镜像，然后到 vm6, vm7 中分别部署
- 部署前请先确保 vm1, vm2, vm3 中的各组件正常启动，vm5, vm6, vm7 配置好 docker 私服地址

## 3.1 部署 gaming-server-service-redis

- 在 vm5 进入 `build/gaming-server-service-redis` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-redis .
docker push 192.168.25.34:5000/gaming-server-service-redis
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-redis` 并运行对应的 docker-compose 文件


## 3.1 部署 gaming-server-service-redis

- 在 vm5 进入 `build/gaming-server-service-redis` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-redis .
docker push 192.168.25.34:5000/gaming-server-service-redis
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-redis` 并运行对应的 docker-compose 文件

## 3.2 部署 gaming-server-service-search

- 在 vm5 进入 `build/gaming-server-service-search` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-search .
docker push 192.168.25.34:5000/gaming-server-service-search
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-search` 并运行对应的 docker-compose 文件

## 3.3 部署 gaming-server-service-admin

- 在 vm5 进入 `build/gaming-server-service-admin` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-admin .
docker push 192.168.25.34:5000/gaming-server-service-admin
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-admin` 并运行对应的 docker-compose 文件

## 3.4 部署 gaming-server-service-channel

- 在 vm5 进入 `build/gaming-server-service-channel` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-channel .
docker push 192.168.25.34:5000/gaming-server-service-channel
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-channel` 并运行对应的 docker-compose 文件

## 3.5 部署 gaming-server-service-article

- 在 vm5 进入 `build/gaming-server-service-article` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-service-article .
docker push 192.168.25.34:5000/gaming-server-service-article
```
- 在 vm6 执行 `docker pull 192.168.25.34:5000/gaming-server-service-article` 并运行对应的 docker-compose 文件

## 3.6 部署 gaming-server-web-admin

- 在 vm5 进入 `build/gaming-server-web-admin` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-web-admin .
docker push 192.168.25.34:5000/gaming-server-web-admin
```
- 在 vm7 执行 `docker pull 192.168.25.34:5000/gaming-server-web-admin` 并运行对应的 docker-compose 文件

## 3.7 部署 gaming-server-api

- 在 vm5 进入 `build/gaming-server-api` 文件夹，构建并提交镜像 :
```
docker build -t 192.168.25.34:5000/gaming-server-api .
docker push 192.168.25.34:5000/gaming-server-api
```
- 在 vm7 执行 `docker pull 192.168.25.34:5000/gaming-server-api` 并运行对应的 docker-compose 文件