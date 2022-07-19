
# 安装教程

- [ss安装](https://teddysun.com/358.html)
- [bbr参考](https://teddysun.com/489.html)
- [客户端下载](https://github.com/shadowsocks/shadowsocks-windows/releases)


# Debian下shadowsocks-libev一键安装(Ubuntu可用)

- 使用 root 用户登录，执行下述命令
```bash
wget --no-check-certificate -O shadowsocks-libev-debian.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-libev-debian.sh
chmod +x shadowsocks-libev-debian.sh
./shadowsocks-libev-debian.sh 2>&1 | tee shadowsocks-libev-debian.log
```
- 安装完成有如下提示
```
Congratulations, Shadowsocks-libev server install completed!
Your Server IP        :your_server_ip
Your Server Port      :your_server_port
Your Password         :your_password
Your Encryption Method:your_encryption_method

Welcome to visit:https://teddysun.com/358.html
Enjoy it!
```
- 卸载命令：`./shadowsocks-libev-debian.sh uninstall`
- 配置文件在 `/etc/shadowsocks-libev/config.json` 下，可以停止服务后，修改文件再重启以修改端口，密码，加密方式等

**其他更改状态命令**

- 启动：/etc/init.d/shadowsocks start
- 停止：/etc/init.d/shadowsocks stop
- 重启：/etc/init.d/shadowsocks restart
- 查看状态：/etc/init.d/shadowsocks status


## Centos 6 7 测试

```bash
yum -y install wget
```

- 使用 root 用户登录，执行下述命令
```bash
wget --no-check-certificate -O shadowsocks-libev.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-libev.sh
chmod +x shadowsocks-libev.sh
./shadowsocks-libev.sh 2>&1 | tee shadowsocks-libev.log
```


## BBR

- 使用 root 用户登录，执行下述命令：
```bash
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
```
- 安装完成后，脚本会提示需要重启 VPS，输入 y 并回车后重启
- 重启完成后，进入 VPS，验证一下是否成功安装最新内核并开启 TCP BBR，输入以下命令 `uname -r` 查看内核版本，显示为最新版就表示 OK 了
- 使用下述三条命令查看相关参数的返回值：
    - `sysctl net.ipv4.tcp_available_congestion_control` 返回值一般为 `net.ipv4.tcp_available_congestion_control = bbr cubic reno` 或者 `net.ipv4.tcp_available_congestion_control = reno cubic bbr`
    - `sysctl net.ipv4.tcp_congestion_control` 返回值一般为 `net.ipv4.tcp_congestion_control = bbr`
    - `net.core.default_qdisc = fq` 返回值一般为 `net.core.default_qdisc = fq`
- 使用命令 `lsmod | grep bbr` 查看 bbr 相关进程，可能有的 vps 不显示


# 魔改 bbr

- Centos 7 可用

```bash
wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
chmod +x tcp.sh
./tcp.sh
```