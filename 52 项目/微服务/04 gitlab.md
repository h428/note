
# 1. 安装

- 基于 Docker Compose 安装 gitlab，首先编写下述 `docker-compose.yml` 文件，由于比较大，安装至 lab312 服务器 :
```yml
version: '3'
services:
    gitlab:
      image: 'twang2218/gitlab-ce-zh:11.1.4'
      restart: always
      hostname: '121.192.180.202'
      container_name: gitlab
      environment:
        TZ: 'Asia/Shanghai'
        GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://121.192.180.202:17000'
          gitlab_rails['time_zone'] = 'Asia/Shanghai'
          gitlab_rails['gitlab_shell_ssh_port'] = 17001
          unicorn['port'] = 12181
          nginx['listen_port']=17000
      ports:
        - '17000:17000'
        - '12181:443'
        - '17001:22'
      volumes:
        - config:/etc/gitlab
        - data:/var/opt/gitlab
        - logs:/var/log/gitlab
volumes:
    config:
    data:
    logs:
```
- 用 12181 是借用该端口，管理员只给我开了几个端口
- 安装失败可用下述命令清除重新安装
```
docker-compose down
docker volume rm gitlab_config gitlab_data gitlab_logs
```