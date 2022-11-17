- [命令大全](https://www.runoob.com/linux/linux-command-manual.html)

# 系统（系统管理、系统设置）

- 查看内核版本：`cat /proc/version` 或 `uname -a` 或 `uname -r`
- 查看系统版本：
  - RedHat 系：`cat /etc/redhat-release`
  - 网上说 `cat /etc/issue`，`lsb_release -a` 适用所有发行版本，但我在 CentOS 7.2.1511 上无法查看，其他 Linux 发行版未验证

# 网络

## 防火墙

**Centos 7**

- 查看防火墙状态：`firewall-cmd --state`
- 停止防火墙：`systemctl stop firewalld.service`
- 开启防火墙：`systemctl start firewalld.service`
- 禁止防火墙开机自启动：`systemctl disable firewalld.service`
- 允许防火墙开机自启动：`systemctl enable firewalld.service`
- 利用 systemctl 查看防火墙状态：`systemctl status firewalld.service`
- 查看生效的网卡的名称：`firewall-cmd --get-active-zones`
- 查看已经开放的端口：`netstat -anp`
- 查看是定端口是否开放：`firewall-cmd --query-port=8080/tcp`，no 表示为开放
- 开放指定端口：`firewall-cmd --add-port=8080/tcp --permanent`，提示 success 表示设置成功
- 永久开放 8080 端口：`firewall-cmd --zone=public --add-port=8080/tcp --permanent`
- 关闭指定端口：`firewall-cmd --permanent --remove-port=8080/tcp`
- 重新载入配置：`firewall-cmd --reload`，执行设置后（例如上条的开放、关闭端口），需要执行该命令重新载入配置以生效
- 查看 8080 端口是否开启：`firewall-cmd --query-port=8080/tcp`

**Ubuntu**

- ubuntu 一般使用 ufw 管理防火墙
- 安装 ufw：`apt-get install ufw`
- 开放端口：`ufw allow 8080`
- 查看防火墙情况：`sudo ufw status`

## 端口

- 查看指定端口占用情况：`lsof -i tcp:80`
- 列出所有端口：`netstat -ntlp`
- 杀死指定端口：`kill -9 $(lsof -i tcp:8080 -t)`

# 用户与权限

## 用户

### 新建用户

- 新建用户命令：`useradd 选项 用户名`
  - -c：comment，指定一段注释性描述
  - -d：指定用户主目录，如果不存在可以使用 -m 选项创建主目录
  - -g：指定用户组，主组
  - -G：指定用户所属的附加组
  - -s：指定用户登录的 Shell
  - -u：指定用户的用户号，如果同时有 -o 选项，可以重复使用其他用户的标识号
- 命令举例：
  - `useradd -m sam` 创建一个名为 sam 的用户，主目录为 /home/sam，不存在该用户目录会自动创建
  - `useradd -s /bin/sh -g group –G adm,root gem` 创建一个名为 gem 的用户，属于 group 用户组，同时又属于 adm, root 用户组，其中 group 为主组
- 增加用户账号就是在 /etc/passwd 文件中为新用户增加一条记录，同时更新其他系统文件如 /etc/shadow, /etc/group 等
- Linux 提供了集成的系统管理工具 userconf，它可以用来对用户账号进行统一管理

### 删除用户

- 删除用户命令：`userdel 选项 用户名`
  - -r：将用户的主目录一起删除
- 举例：`userdel -r sam` 删除用户 sam，同时删除其主目录
- 删除用户账号就是要将 /etc/passwd，/etc/shadow，/etc/group 等文件中的该用户记录删除，必要时还删除用户的主目录

### 修改用户

- 修改用户账号就是根据实际情况更改用户的有关属性，如用户号、主目录、用户组、登录 Shell 等
- 修改用户命令：`usermod 选项 用户名`
  - -c，-d，-m，-g，-G，-u，-o，这些选项的含义与 useradd 命令一样
  - 另外，有些系统可以使用选项 -l 指定新用户名
- 举例：`usermod -s /bin/ksh -d /home/z –g developer sam` 修改用户 sam 设置，改为使用 /bin/ksh 登录，用户目录变更为 /home/z，用户组变更为 developer

### 密码管理

- 用户在刚创建时没有密码，默认被系统锁定，无法使用，必须为其指定密码后才可以使用
- 指定用户密码：`passwd 选项 用户名`
  - -l：禁用账号
  - -u：解锁账号
  - -d：使账号没有密码，这样就无法登录了
  - -f：强迫用户下次登录时修改密码
- 普通用户也是使用 passwd 修改密码，但需要输入原密码：

```bash
passwd
Old password:******
New password:*******
Re-enter new password:*******
```

- 超级用户可以直接指定密码，无需知道原密码：

```bash
passwd sam
New password:*******
Re-enter new password:*******
```

## 用户组

## 补充内容

用户具备 sudo 权限，想基于 SSH 修改 root 文件时，可以对指定目录执行下列命令：

```
sudo setfacl -R -m u:用户名:rwx /path/to/directory目标目录
```

# 备份压缩

# 软件安装与管理

## rpm

## yum

- rpm 的安装十分繁琐，需要自己解决依赖性问题，基于该原因，推出了 yum，yum 最重要的就是解决了 rpm 的互相依赖的问题
- yum 是一个在 Fedora 和 RedHat 以及 SUSE 中的 Shell 前端软件包管理器，yum 基于 rpm，从指定的服务器下载 rpm 包并且自动安装，可以自动处理 rpm 包之间的依赖关系，并且一次安装所有依赖的软件包，无需频繁地下载，安装
- yum 还提供了查找、安装、更新、删除某一个、一组甚至是全部软件包的命令，且比 rpm 更加简洁
- 语法格式：`yum 选项 操作 包名`，例如 `yum -y install tree`
- 常用命令：
  - 列出所有课更新的软件清单：`yum check-update`
  - 更新所有软件：`yum update`，千万不要在生产环境执行该命令
  - 仅更新指定的软件：`yum update 包名`
  - 列出所有可安装的软件：`yum list`
  - 卸载指定软件包：`yum remove 包名`
  - 查找软件包：`yum search 包名`
  - 清除缓存命令：
    - 清除缓存目录下的软件包：`yum clean packages`
    - 清除缓存目录下的 headers：`yum clean headers`
    - 清除缓存补录下的旧 headers：`yum clean oldheaders`
    - 清除缓存目录下的软件包以及旧的 headers：`yum clean, yum clean all,(= yum clean packages; yum clean oldheaders)`
    - 生成缓存：`yum makecache`
- 配置 yum 源参考 [Linux 初始配置](Linux%20初始配置.md)

# 文件文档（文件管理、文件编辑、文件传输）

# 磁盘（磁盘管理、磁盘维护）

- `df -h`

# 设备管理

# 补充

- 使用 scp 拷贝文件：`scp 本机文件 root@192.168.25.42:/xxx/`


# 场景操作

## sudo 用于使用编辑器远程开发无法保存 root 用户文件问题

可以使用下列命令为用户添加对应文件夹的处理权，后面就可以保存
```bash
sudo setfacl -R -m -u:用户名:rwx /目标路径
```