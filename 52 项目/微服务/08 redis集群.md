

# 1. 安装

- 以 `/root/docker/redis/` 为工作目录
- 在当前目录下创建 `docker-compose.yml`，配置 redis 集群
```yml
version: '3.1'
services:
  master:
    image: redis:3
    ports:
      - 6379:6379

  slave:
    image: redis:3
    ports:
      - 6380:6379
    command: redis-server --slaveof redis-master 6379
    links:
      - master:redis-master

  sentinel:
    build: sentinel
    ports:
      - 26379:26379
    environment:
      - SENTINEL_DOWN_AFTER=5000
      - SENTINEL_FAILOVER=5000    
    links:
      - master:redis-master
      - slave
```
- 同时，创建 sentinel 目录，在目录内提供 Dockerfile 以构建 sentinel 镜像 :
```docker
FROM redis:3

MAINTAINER Lusifer <topsale@vip.qq.com>

EXPOSE 26379
ADD sentinel.conf /etc/redis/sentinel.conf
RUN chown redis:redis /etc/redis/sentinel.conf
ENV SENTINEL_QUORUM 2
ENV SENTINEL_DOWN_AFTER 30000
ENV SENTINEL_FAILOVER 180000
COPY sentinel-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/sentinel-entrypoint.sh
ENTRYPOINT ["sentinel-entrypoint.sh"]
```
- 构建镜像时需要提供下述配置文件：
- `sentinel.conf` :
```conf
# Example sentinel.conf can be downloaded from http://download.redis.io/redis-stable/sentinel.conf

port 26379

dir /tmp

sentinel monitor mymaster redis-master 6379 $SENTINEL_QUORUM

sentinel down-after-milliseconds mymaster $SENTINEL_DOWN_AFTER

sentinel parallel-syncs mymaster 1

sentinel failover-timeout mymaster $SENTINEL_FAILOVER
```
- `sentinel-entrypoint.sh` :
```
#!/bin/sh

sed -i "s/\$SENTINEL_QUORUM/$SENTINEL_QUORUM/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_DOWN_AFTER/$SENTINEL_DOWN_AFTER/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_FAILOVER/$SENTINEL_FAILOVER/g" /etc/redis/sentinel.conf

exec docker-entrypoint.sh redis-server /etc/redis/sentinel.conf --sentinel
```