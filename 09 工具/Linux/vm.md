

# VM NAT 模式通信配置

- NAT 模式在 host-only 的基础上引入了连接外网的功能，使得虚拟机也能连接外网，且宿主机网络情况的变化不会对虚拟机产生影响，十分适合学习和实验环境
- NAT 模式主要利用 VMnet8 这张虚拟网卡来完成虚拟机和宿主机之间的通信
- 使用 NAT 模式，你首先要定义一个子网网段，该网段可用于宿主机和虚拟机、虚拟机和虚拟机之间的通信，本笔记的例子采用的是 `192.168.25.0` 这个子网网段
- 在上面的基础上，所有的虚拟机以及宿主机都要设置为该网段的一个 IP，虚拟机就是直接设置网卡 IP，而对于宿主机就是设置 VMnet 8 这块网卡的 IP，这样所有虚拟机的请求会通过该网网关转发到该网卡，然后本机进一步请求，以实现上网的目的
- 注意关闭宿主机和虚拟机的防火墙


## VM 软件中的步骤

- 首先确定一个网段让虚拟机使用，比如我选择 `192.168.25.0` 这个子网
- 打开 VM 软件的网络编辑器，选择 VMnet8，然后设置对应的子网段，并且点击 NAT 设置，在里面设置网段的基本信息
- 有一个要注意的地方，网关我们习惯上使用 .1 但在虚拟机中默认将网关设置为 .2 而宿主机设置为 .1 这里注意一下
```bash
子网IP : 192.168.25.0
子网掩码 : 255.255.255.0
默认网关 : 192.168.25.2  # 网关习惯上设置为 .1，但 VM 默认设置为 2，.1 分配给宿主机
```

## 宿主机设置

- NAT 模式下，宿主机使用 VMnet8 这张虚拟网卡完成通信，VMnet8 网卡相当于宿主机在该网段的一个地址
- 因此，编辑 VMnet 8，设置下述内容
```bash
IP : 192.168.25.1 # 这就是宿主机在子网中的 IP（当然也可以是其他的，但默认是 .1）
掩码 : 255.255.255.255
默认网关 : 空着
DNS1 : 不配或配置本地可用真实 DNS
DNS2 : 不配或配置本地可用真实 DNS
```

## 虚拟机配置

- 虚拟机只要使用 `192.168.25.0` 网段的 IP 即可，注意别占用网关的 `192.168.25.2` 和宿主机 IP `192.168.25.1` 即可
- 比如我可以将其中一台虚拟机设置为 `192.168.25.42`，注意 DNS 配置为真实可用 DNS

# VM 克隆

- 首先，右键虚拟机 -> 管理 -> 克隆，确保克隆之前可以查看 
- 设置虚拟机 MAC 地址重新生成
- 启动系统，输入 ifconfig 发现 eth0 网卡没了，系统给你新建了个 eth1 网卡，若想换回原有的 eth0 网卡，需要进行如下操作
- 克隆后记得修改主机名以及 host 文件

## Ubuntu 18.04

- 输入 `ip addr show` 查看网卡信息，发现该版本 ubuntu 可以自动识别 mac 地址的变化，无需额外操作，只需修改 ip 即可
- 执行 `sudo gedit /etc/netplan/01-network-manager-all.yaml` 修改网络配置信息，只需修改 ip 地址，例如修改为 `192.168.25.12`，其他配置不变
- 验证该机子和同一网段中的其他机子、宿主机可以通信


## CentOS 6.7

- 首先确保克隆之前原系统已经可以使用 nmcli 命令，否则无法查看 eth1 的 UUID，这样无法进行修改
- 执行下述内容安装 nmcli
```bash
yum provides "*/nmcli" # 看下这个命令所属的软件包，结果为 NetworkManager
yum -y install NetworkManager # 安装 NetworkManager
service NetworkManager start # 启动 NetworkManager
nmcli con # 查询UUID
```
- 执行 `vim /etc/udev/rules.d/70-persistent-net.rules` 编辑文件
- 把 NAME="eth0″ 的这一行注释掉
- 把 NAME=”eth1″ 的这一行，把 NAME=”eth1″ 改为 NAME=”eth0″，同时记录 MAC 地址（应该和前面随机生成的那个一致）
- 执行 `nmcli con` 查看网卡 eth1 的 UUID
- 然后编辑 `vim /etc/sysconfig/network-scripts/ifcfg-eth0`，将里面的 UUID 和 MAC 地址都改为新的，然后重启系统即可，这样 eth0 即可正常工作

## Centos 7.2

- 克隆前先注释掉 `vim /etc/sysconfig/network-scripts/ifcfg-eth0` 中的 MAC 地址和 UUID ，最好修改下 hostname，然后进行克隆
- 执行 `vim /etc/hostname` 修改主机名称，建议按照 `centos_1` 这样的格式
- 执行 `vim /etc/sysconfig/network-scripts/ifcfg-eth0` 修改 ip 地址
- 执行 `service network restart` 重启网络服务，并验证是否能和其他机器进行通信


