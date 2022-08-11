
- 本笔记使用的 Linux 为 Centos 7.2-64, Centos 6.7、Ubuntu Server 16.04-amd64, Ubuntu Desktop 18.04
- 用于克隆的机子，至少应该完成下述配置
    - 配置好网卡姓名和网络，
    - 换源, vim, ssh, lrzsz
    - docker
    - java, mvn

# 配置网络与换源

## 安装 vm-tools

- 在 VM 中选择安装 VM Tools
- 把 VMwareTools-10.0.6-3595377.tar.gz 拷贝到 Home 并解压 `tar -zxvf ...`
- 执行 `sudo ./wmware-install.pl ` 安装

## 配置网络

- 克隆相关请先查看 vm 笔记
- hosts 文件配置：
```hosts
192.168.25.10 c10
192.168.25.11 c11
192.168.25.12 c12
192.168.25.13 c13
```

**Centos 7.2**

- 查看目录 `/etc/sysconfig/network-scripts/` 下的文件，可发现Centos 7 网卡换名，默认不再是 `ifcfg-eth0`
- 为了习惯，修改对应文件名称为 `ifcfg-eth0`，建议重装时设置，装完后更改名称较为麻烦
- `vim /etc/sysconfig/network-scripts/ifcfg-eth0`
- 配置如下信息，（最后4行）
```conf
TYPE="Ethernet"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
NAME="eth0"
DEVICE="eth0"
ONBOOT="yes"
IPADDR="192.168.25.41"
PREFIX="24"
GATEWAY="192.168.25.2"
DNS1="218.85.157.99"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
IPV6_PRIVACY="no"
```
- 使用命令 `systemctl restart network.service` 或 `service network restrat` 重启网络服务
- ping 宿主机测试是否正常
- ping 百度测试是否正常
- 厦门移动 DNS 211.138.156.66


**Ubuntu 16.04**

- 执行 `vim /etc/default/grub`，修改如下设置 `GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"`
- 然后执行 `grub-mkconfig -o /boot/grub/grub.cfg` 并重启确认网卡名称修改为 eth 0
- 编辑 `vim /etc/network/interfaces` 网络配置文件，添加如下配置
```conf
auto eth0
iface eth0 inet static
address 192.168.25.31
netmask 255.255.255.0
gateway 192.168.25.2
dns-nameservers 218.85.157.99
```
- 执行 `ip addr flush eth0` 和 `systemctl restart networking.service` 刷新网络配置，并验证能否 ping 同宿主机

**Ubuntu 18.04**

- ubuntu 18 取消 `ifconfig` 命令，使用 `ip addr show` 查看网卡，默认情况下包含一个 `lo` 网卡和 `ens33` 以太网卡
- 执行 `sudo vim /etc/default/grub`，修改如下设置 `GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"`
- 然后执行 `grub-mkconfig -o /boot/grub/grub.cfg` 并重启确认网卡名称修改为 eth0
- ubuntu 18 使用 netplan 进行网络配置，其读取 `/etc/netplan/` 目录下的 *.yaml 文件，作为网络配置，根据不同的版本，yaml 文件的名称可能不同，例如 desktop 版本的文件名为 `01-network-manager-all.yaml`，如果不存在可以尝试使用 `sudo netplan generate` 生成 yaml 文件
- 修改上述文件 `sudo gedit /etc/netplan/01-network-manager-all.yaml`，加入下述配置：
```yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: no
      dhcp6: no
      addresses: [192.168.25.11/24]
      gateway4: 192.168.25.2
      nameservers:
        addresses: [218.85.157.99]
```
- 移动的 dns 设置为 211.138.156.66
- 执行 `sudo netplan apply` 应用网络配置
- 网络配置采用的是 192.168.25.1 网段，宿主机以及网卡的设置请参考笔记 [vm相关](./vm相关.md)
- 配置完毕验证宿主机和客户机网络互通，且能正常访问百度


## 换源

### Centos 更换 yum 源, erel 源

- 首先进入到 `cd /etc/yum.repos.d` 目录，创建 `mkdir repo_bak` 目录，用于存放原有备份文件 `mv *.repo repo_bak`
- 执行 `wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo` 从阿里云下载文件
- 执行 `yum clean all` 清除缓存，并执行 `yum makecache` 重新生成缓存
- 执行 `yum -y install epel-release` 安装 epel，会在当前目录生成两个 repo 文件
- 备份原有 `mv epel.repo repo_bak/` 文件
- 执行 `wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo` 从阿里云下载文件
- 执行 `yum clean all` 清除缓存，并执行 `yum makecache` 重新生成缓存
- 执行 `yum repolist enabled` 查看可用源

### Ubuntu 更换 apt 源

- 首先备份软件源配置文件 `cp /etc/apt/sources.list /etc/apt/sources.list.bak`
- 谷歌搜索[清华源](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)，然后修改源，`sudo gedit /etc/apt/sources.list`，使用 gedit 方便粘贴，配置下述内容：
```conf
# ubuntu 18.04 LTS 清华源
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
```
- 查看是否修改成功 `cat /etc/apt/sources.list` 并执行软件列表的更新 `sudo apt-get update`

# 安装基本工具

- 安装命令，centos 使用 `yum -y install ...`, ubuntu 使用 `apt install ...`
- 下面的命令可能用 ubuntu 的或 yum 的，具体体统需要自行转化

## 基础部件

**vim**
```bash
sudo apt-get remove vim-common
sudo apt-get install vim
```
- 配置参考 vim 笔记

**ssh**
- 安装 ssh : `sudo apt-get install openssh-server`
- 配置允许 root 远程登录 : 
    - 编辑配置文件 `sudo vim /etc/ssh/sshd_config`
    - 查找设置项 `#PermitRootLogin prohibit-password`（可使用尾行模式查找字符串 `:/PermitRootLogin`），执行 `yy` 复制一行，按 `p` 粘贴，然后取消注释，并将其设置为`PermitRootLogin yes`，
- 然后重启 ssh 服务，`service ssh restart`，然后使用 x-shell 测试是否成功


**使用 x-Shell 传输文件**

- 虚拟机首先安装需要的工具 `sudo apt install lrzsz`
- 安装完成后则可以使用 rz 上传到虚拟机， sz 文件名下载宿主机


## 常用

- docker 和 docker-compose : 见 docker 笔记


# 系统配置

## 开机自启动


### Centos 7


#### 利用 /etc/rc.d/rc.local 以及自定义脚本

- 先说大致原则，对于比较正式的服务类型的服务自启动，可以在 `/etc/systemd/system` 下编写对应的 xxx.service 文件后，利用 systemctl 管理自启动
- 对于一些比较平凡的启动命令，例如 `java -jar ...` 等，可以将这些命令统一放在一个可执行 sh 脚本中，并设置 `/etc/rc.d/rc.local` 在开机时执行对应启动脚本即可
- 我们分别以 nacos 和 sentinel 为例讲解两种不同的设置自启动方法，nacos 利用 systemctl 而 sentinel 利用自启动脚本
- 在当前用户目录创建自启动文件夹以及对应的自启动文件 `vim ~/boot/boot.sh`，并填入需要开机自启动的命令
```bash
#!/bin/bash
source /etc/profile

nohup java -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dproject.name=sentinel-dashboard -jar /usr/local/sentinel-dashboard/sentinel-dashboard-1.7.0.jar > /logs/boot-sentinel-dashboard.log 2>&1 &
```
- 为该文件添加执行权限
- 在 centos 7 中，`/etc/rc.d/rc.local` 文件的权限被降低了，开机的时候执行在自己的脚本是不能起动一些服务的，执行下面的命令可以文件标记为可执行的文件：`chmod +x /etc/rc.d/rc.local`
- 然后打开 `/etc/rc.d/rc.local`文件，在最后面添加如下脚本
```bash
/root/boot/boot.sh
```
- 这样，我们自定义的自启动脚本就会在开机的时候执行了，以后其他的自启动相关起名写在 boot.sh 中即可

#### 利用 systemctl

- 创建 systemctl 能管理文件： `vim /etc/systemd/system/nacos.service`，并填入下述内容：
```conf
[Unit]
Description=nacos
After=network.target
 
[Service]
Type=forking
ExecStart=/usr/local/nacos/bin/startup.sh -m standalone
ExecReload=/usr/local/nacos/bin/shutdown.sh
ExecStop=/usr/local/nacos/bin/shutdown.sh
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 文件内容解释：
```conf
[Unit]:服务的说明
Description:描述服务
After:描述服务类别

[Service]服务运行参数的设置
Type=forking是后台运行的形式
ExecStart为服务的具体运行命令
ExecReload为重启命令
ExecStop为停止命令
PrivateTmp=True表示给服务分配独立的临时空间
注意：启动、重启、停止命令全部要求使用绝对路径

[Install]服务安装的相关设置，可设置为多用户
```
- 只经过上述配置在启动时可能会报 javac 找不到异常，其会在特定的位置找 javac，好像识别不到我们自己配置的 JAVA_HOME 和 Path,因此我们需要创建一个软链接：`ln -s /usr/local/jdk/bin/javac /usr/bin/`
- 刷新配置：`systemctl daemon-reload`
- 开机自启动：`systemctl enable nacos.service`
- 手动启动 nacos：`systemctl start nacos.service`

#### 利用自定义脚本以及 systemctl

- 若启动过程可能涉及较为复杂的多条命令，可将启动命令写进一个 sh 脚本中，为脚本添加执行权限，然后 ExecStart 配置对应脚本即可，关闭同理
- 我们以 seata 为例说明该种方式，由于 seata-server.sh 是阻塞的，且不提供关闭指令，我们需要编写启动和关闭脚本
- 编写 `vim /etc/boot/seata/startup.sh`：
```sh
#!/bin/bash
nohup /usr/local/seata/bin/seata-server.sh -h 192.168.25.43 -p 8091 > /usr/local/seata/bin/nohup.out 2>&1 &
```
- 编写 `vim /etc/boot/seata/stop.sh`：
```sh
#!/bin/bash
kill -9 $(lsof -i tcp:8091 -t)
```
- 为这两个脚本都添加执行权限:`chmod 700 /etc/boot/seata/startup.sh /etc/boot/seata/stop.sh`
- 同样利用 systemctl，我们编辑 `vim /etc/systemd/system/seata.service`：
```conf
[Unit]
Description=seata
After=network.target

[Service]
Type=forking
ExecStart=/etc/boot/seata/startup.sh
ExecReload=/etc/boot/seata/stop.sh
ExecStop=/etc/boot/seata/stop.sh
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 刷新配置并启动
```sh
systemctl daemon-reload
systemctl enable seata.service
systemctl start seata.service
systemctl status seata.service
```


# 常用配置

## 常见 alias

```sh
alias ns="netstat -ntlp"
```

## 远程 SSH 登录

- [参考链接](https://hyjk2000.github.io/2012/03/16/how-to-set-up-ssh-keys/)
- 首先进入服务器（虚拟机）的当前用户的 `.ssh` 目录 : `cd ~/.ssh`
- `ssh-keygen` 命令，-t rsa 设置算法，-C Lyinghao@126.com 设置邮箱，-f lyh 可设置文件名
- 在该目录生成密钥对，一般建议利用 `-f` 选项更名，`ssh-keygen -t rsa -f vm_ubuntu`，其会生成两个文件，其中带 `.pub` 的为公钥，此外可以使用 `-C` 选项设置用户名，用作 git 时很常用
- 将公钥的内容添加到 `authorized_keys` 中，即 `cat vm_ubuntu.pub >> authorized_keys`，以用于授权远程登录
- 修改 authorized_keys 权限为 600 : `sudo chmod 600 authorized_keys`
- 修改 .ssh 目录全为为 700 : `sudo chmod 700 ~/.ssh`
- 将私钥下载到本地，则可以利用 X-Shell 之类的工具进行免密远程登录
- 若无法登录可能还需要如下额外设置，编辑文件 `sudo vim /etc/ssh/sshd_config`，进行如下设置：
    - RSAAuthentication yes
    - PubkeyAuthentication yes
    - PermitRootLogin yes (Root 是否允许通过 SSH 进行登录)
    - PasswordAuthentication no (禁用密码登录， 可选)
- 然后重启 ssh 服务，`sudo service sshd restart`


## 多机的 SSH 免密登录

- 策略 1：所有的机子维护相同的 id_rsa 和 id_rsa.pub，每台机器的 authorized_keys 添加一个 id_rsa.pub，由于密钥对相同，则自动使用 id_rsa 链接
- 策略 2：每台机子维护自己的 id_rsa 和 id_rsa.pub，每台机器的 authorized_keys 添加所有机器 id_rsa.pub，这样连接其他机器时会自动采用 id_rsa 自动连接
- 策略 3：前面两种每台机器都默认采用自己 id_rsa 来免密登录其他机器，不够灵活，第三种为每台机子维护自己的 xxx 和 xxx.pub，并利用 config 配置指定连接对应机器时采用的私钥 xxx
- 例如下列 config 配置表示当连接指定机器时采用对应的私钥，HostName 可以是域名或者 IP 地址
```conf
# lab-n1
Host lab-main
  HostName xxxxx
  PreferredAuthentications publickey
  User root
  IdentityFile ~/.ssh/lab-main
```



## 默认启动命令行而不是图形界面

- 命令行 `sudo systemctl set-default multi-user.target` 
- 图形界面 `sudo systemctl set-default graphical.target`
- 命令行下进入图形界面可输入 `sudo lightdm start`
- `ctrl+alt+F7` 可进行二者的互相切换


# 其他配置

## 安装基本软件

- [搜狗输入法](https://blog.csdn.net/lupengCSDN/article/details/80279177)
- [谷歌浏览器](https://blog.csdn.net/HelloZEX/article/details/80762705)





## 其他操作

**利用宿主机翻墙**

- 首先宿主机必须已经安装好翻墙软件 shadowsocks，并且设置其允许来自局域网的连接
- 然后打开 ubuntu 的设置，选择 Network 的 Network Proxy，设置代理类型为 Manual，把所有的代理都 ip 都填上宿主机的地址（这是 192.168.25.1），端口选择小飞机中的端口（一般是 1080）
- 访问谷歌，测试能否正常访问
- 这种配置方式会让整个虚拟机都走代理，并让宿主机的小飞机做第一次分流

**利用谷歌浏览器的 SwitchyOmega 插件翻墙(推荐)**

- 同样要求宿主机已经安装好翻墙软件 shadowsocks，并且设置其允许来自局域网的连接
- 设置 SwitchyOmega，代理服务器填写宿主机的 ip，端口仍然为 1080
- 访问谷歌查看是否能正常访问

**命令行临时设置代理**

```bash
export http_proxy="socks5://127.0.0.1:1080" && export https_proxy="socks5://127.0.0.1:1080"
export http_proxy="socks5://192.168.25.1:10808" && export https_proxy="socks5://192.168.25.1:10808"
```

## 配置 VS Code 的 Remote SSH

- [官方教程](https://code.visualstudio.com/docs/remote/ssh#_getting-started)
- 首先按照 远程 SSH 登录 中的步骤，在服务器生成密钥对，并将私钥拷贝到本地，公钥添加到 authorized_keys 中
- VS Code 安装 Remote SSH 插件，然后左下角出现个图标，可用于配置
- 把相关私钥拷贝到 `~/.ssh/` 目录下，并在该目录下创建 config 文件，config 文件用于配置远程服务端，配置样例大致如下
```conf
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host vm-ubuntu
HostName 192.168.25.11
User hao
IdentityFile ~/.ssh/vm_ubuntu

Host vm-ubuntu-2
HostName 192.168.25.12
User hao
IdentityFile ~/.ssh/vm_ubuntu_2

Host lab312
HostName xxxxx
User lyh
IdentityFile ~/.ssh/lab312
```
- 配置完后，进行连接，若有提示点 continue，然后会在服务端进行下载，下载失败重试几次，直至成功
