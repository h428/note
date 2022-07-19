

# 进程与端口

- 查看所有端口情况：`netstat -ano`
- 查看占用某端口的进程列表：`netstat -ano | findstr "端口号"`
- 查看所有进程情况：`tasklist`
- 根据pid查看进程：`tasklist|findstr "进程号"`
- 关闭进程：`taskkill -PID <进程号> -F`
- 定时一小时关机：`shutdown -s -t 3600`
- 删除系统服务 `sc delete MySQL-3380`