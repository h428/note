

# 1. 概述


# 2. zookeeper 集群

- 在 `zookeeper` 目录下，创建 `docker-compose.yml` : 
```yml
version: '3.1'
services:
  zoo1:
    image: zookeeper:3.4.11
    restart: always
    hostname: zoo1
    ports:
      - 2181:2181
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
    volumes:
      - data1:/data
      - datalog1:/datalog

  zoo2:
    image: zookeeper:3.4.11
    restart: always
    hostname: zoo2
    ports:
      - 2182:2181
    environment:
      ZOO_MY_ID: 2
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
    volumes:
      - data2:/data
      - datalog2:/datalog

  zoo3:
    image: zookeeper:3.4.11
    restart: always
    hostname: zoo3
    ports:
      - 2183:2181
    environment:
      ZOO_MY_ID: 3
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
    volumes:
      - data3:/data
      - datalog3:/datalog

volumes:
  data1:
  datalog1:
  data2:
  datalog2:
  data3:
  datalog3:
```
- 清除
```
docker-compose down
docker volume rm zookeeper_data1 zookeeper_datalog1 zookeeper_data2 zookeeper_datalog2 zookeeper_data3 zookeeper_datalog3
docker-compose up -d
```

# 3. 基于 docker 部署 dubbo-admin-2.5.3.war

- 首先，创建 `dubbo_admin` 文件夹，创建 `docker-compose.yml`
```yml
version: '3'
services:
  tomcat:
    restart: always
    image: tomcat:7.0.57
    container_name: dubbo_admin
    ports:
      - 8080:8080
    volumes:
      - webapps:/usr/local/tomcat/webapps

volumes:
  webapps:
```
- 解压 : `unzip dubbo-admin-2.5.3.war -d monitor` 并修改 dubbo 注册中心配置
- 清除工作 : 
```
docker-compose down
docker volume rm dubbo_admin_webapps
```
- 启动容器 `docker-compose up -d`，建议另开一个终端查看日志 `docker logs -f dubbo_admin`
- 复制 : `cp -r monitor/ /var/lib/docker/volumes/dubbo_admin_webapps/_data/` 查看日志，并访问 `ip:8080/monitor` 

- 可以以利用别人提供好的的镜像快速搭建 `https://hub.docker.com/r/chenchuxin/dubbo-admin/`
```
docker run -d \
-p 8080:8080 \
-e dubbo.registry.address=zookeeper://192.168.25.31:2181 \
-e dubbo.admin.root.password=root \
-e dubbo.admin.guest.password=guest \
chenchuxin/dubbo-admin
```