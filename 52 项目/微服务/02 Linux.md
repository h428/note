
# 1. Linux 目录结构

- `bin` : 存放二进制可执行文件(ls, cat, mkdir 等)
- `boot` : 存放用于系统启动引导时的各种文件
- `dev` : 用于存放设备文件
- `etc` : 存放系统配置文件
- `home` : 存放所有用户文件的根目录
- `lib` : 存放各种程序运行所需要的共享库文件，或系统函数库等
- `mnt` : 系统管理员安装临时文件系统的安装点
- `opt` : 额外安装的可选应用包所放置的位置，或一些大型文件
- `proc` : 虚拟文件系统，存放当前内存的映射
- `root` : 超级用户目录
- `sbin` : 存放只有 root 才能使用的二进制可执行文件
- `tmp` : 存放各种临时文件
- `usr` : 存放各种系统应用程序，比较重要的目录 `/usr/local` 是常用的软件手动安装目录
- `var` : 用于存放运行时需要改变数据的文件
- 其中 `bin`, `usr`, `var` 是比较重要的目录

# 2. 常用命令

## 2.1 文件与目录

- ls, cd, mkdir, touch, cat, mv, pwd
- echo : 
    - `echo "hello, world" > test.txt`
    - `echo "hello, linux" >> test.txt`
- find : 在当前目录查找 : `find -name "*test*"`
- grep : 管道命令，可用于查找，`cat test.txt | grep linux`
- tree : 列出目录结构
- ln : 建立软链接
- more : 分页显示文本内容
- head : 显示文件开头
- tail : 显示文件结尾

## 2.2 系统管理

- `stat` : 显示指定文件的相关信息，比 ls 命令显示内容更多
- `who` : 显示在线登录用户
- `hostname` : 主机名
- `uname` : 显示系统信息，常用参数有 `-a, -r`
- `top` : 显示当前系统中耗费资源最多的进程，即 Linux 下的任务管理器
- `ps` : 显示瞬间进程状态
- `du` : 显示文件或目录已使用的磁盘空间总量，常用参数为 `-h`
- `df` : 显示整个文件系统磁盘空间的使用情况，常用参数为 `-h`
- `free` : 显示内存和交换空间的使用情况，常用参数为 `-h`
- `ipconfig` : 查看网络接口信息，好像已过时，使用 `ip addr show` 替代
- `ping` : 测试网络连通性
- `netstat` : 显示进程的网络状态信息
- `kill` : 杀死进程，`kill -9 pid`
- `reboot` 或 `shutdown -r now` : 重启
- `shutdown -h now` : 关机

## 2.3 压缩命令

- `tar [-cxzjvf]`
    - `-c` : 建立一个文档文件
    - `-x` : 解开一个归档文件
    - `-z` : 是否使用 gzip
    - `-j` : 是否使用 bzip2
    - `-v` : 压缩过程中显示文件
    - `-f` : 使用档名，在 f 之后要立即解档名
    - `-tf` : 查看归档文件里面的文件
- 压缩 : `tar -zcvf test.tar.gz test\`
- 解压缩 : `tar -zxvf test.tar.gz`

## 2.4 apt 命令

- `apt-get install 软件包名` : 按行在哪个软件包
- `apt-get remove 软件包名` : 删除软件包
- `apt-get update` : 更新软件包列表
- `apt-get upgrade` : 更新系统（千万别更新）

## 2.5 用户、用户组、权限

- 组分为私有组和标准组，当创建一个用户没有设置组时，则会默认将用户放到同名的私有组中
- 当创建一个用户可以选定一个标准组，如果一个用户同时属于多个组，登录后所属的组为主组，其他的为附加组


## 2.5.1 账户系统文件

- 相关文件 :`/etc/passwd, /etc/shadow, /etc/group, /etc/gshadow`
- id， whoami, groups, su
- useradd

## 2.5.2 权限

- `ll` 可查看包括权限的详细信息 `-rwxrwxrwx`，10 个字符
- 第一个描述是文件还是目录，后面的 rwx 分别描述拥有者、所在组、其他人的权限
- 还有数字对应，`0` 表示无权限，`rwx` 则分别对应 4, 2, 1

# 3. Linux 安装基本环境

- Java, Maven, Tomcat, MySQL 安装参考 java 笔记