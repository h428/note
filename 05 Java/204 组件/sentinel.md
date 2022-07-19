


# 安装

- client 直接通过 maven 引入即可

## sentinel dashboard 安装并设置开机启动

- 去 github 下载所需的 sentinel dashboard 版本，此处选择 [sentinel-dashborad-1.8](https://github.com/alibaba/Sentinel/releases/download/v1.8.0/sentinel-dashboard-1.8.0.jar)
- 将 sentinel dashboard 移动到 /usr/local/sentinel-dashboard/ 目录，同时在该目录下创建 boot 目录
- 在 boot 目录下创建 start.sh 和 stop.sh，内容如下：
```sh
#!/bin/bash
nohup /usr/local/jdk/bin/java -Dserver.port=7777 -Dcsp.sentinel.dashboard.server=localhost:7777 -Dproject.name=sentinel-dashboard -jar /usr/local/sentinel-dashboard/sentinel-dashboard-1.8.0.jar > /usr/local/sentinel-dashboard/boot/nohup.out 2>&1 &

#!/bin/bash
kill -9 $(lsof -i tcp:7777 -t)
```
- 为这两个文件添加执行权限：`chmod +x /usr/local/sentinel-dashboard/boot/start.sh /usr/local/sentinel-dashboard/boot/stop.sh`
- 编辑 `vim /etc/systemd/system/sentinel-dashboard.service` 文件内容如下：
```conf
[Unit]
Description=sentinel-dashboard
After=network.target
 
[Service]
Type=forking
ExecStart=/usr/local/sentinel-dashboard/boot/start.sh
ExecStop=/usr/local/sentinel-dashboard/boot/stop.sh
PrivateTmp=true

[Install]  
WantedBy=multi-user.target
```