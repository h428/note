

- 如无特殊备注，默认为 linux 环境

# 1. 基础

## 1.1 Java SE

- 下载 open jdk 17：`wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz`
- 具有全局权限则编辑 `sudo vim /etc/profile`，没有则配置当前用户的 `vim .bashrc`
```bash
# Java Env
export JAVA_HOME=/usr/local/jdk
# export JRE_HOME=/usr/local/jdk/jre
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```
- 执行 `source /etc/profile` 使配置生效
- 然后执行 `java -version` 和 `which java` 进行验证

## 1.2 Maven

- 下载 maven：`wget https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz`
- 首先解压 maven 到 `/usr/local` 下：`unzip apache-maven-3.3.9-bin.tar.gz -d /usr/local/`
- 之后编辑 `/etc/profile/`，导入环境变量
```bash
# Maven Env
export MAVEN_HOME=/usr/local/maven
export PATH=$MAVEN_HOME/bin:$PATH
```
- 进入 conf 目录，编辑 `settings.xml` 文件，修改镜像为阿里云镜像
```xml
<mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>https://maven.aliyun.com/nexus/content/repositories/central/</url>
    <mirrorOf>central</mirrorOf>        
</mirror>
```
- 同时配置默认编译版本为 1.8，找到 profiles 块添加下述配置
```xml
<profiles>
    <profile>
        <id>jdk-1.8</id>

        <activation>
        <activeByDefault>true</activeByDefault>>
        <jdk>1.8</jdk>
        </activation>

        <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
        </properties>
    </profile>
</profiles>
```
- 安装 idea 常用插件：lombox，mybatisx

# 2. 常用


## 2.1 Tomcat

- tomcat 版本要和 jdk 版本对应，如果是 jdk7 就用 tomcat7，如果是 jdk8 就用 tomcat8
- 先配置 Java 开发环境，然后解压 tomcat 到 `/usr/local` 下，运行 startup.sh 即可

## 2.2 MySQL

**ubuntu 16.04**

- `apt install mysql-server` 并配置密码为 root
- `vim /etc/mysql/my.cnf` 或 `vim /etc/mysql/mysql.conf.d/mysqld.cnf` 取消本机绑定，注释掉 `bind-address = 127.0.0.1`
- 登录 mysql，执行 `grant all privileges on *.* to 'root'@'%' identified by 'root';`，对所有 ip 授权

## 2.9 zookeeper

- 使用 zookeeper-3.4.8, jdk 为 1.8.0_91
- 注意配置 zookeeper 之前必须配置好 Java 开发环境，并且已经设置了 JAVA_HOME 变量
- 先解压 zookeeper
- 进入 `conf` 目录，将 `zoo_sample.cfg` 重命名为 `zoo.cfg`
- 如果需要修改 dataDir，可编辑 `zoo.cfg` 修改 dataDir，例如此处设置为 `/var/data/zookeeper`，注意该目录必须存在
- 然后执行 `bin` 目录下的 `zkServer.cmd` 或 `zkServer.sh`
- `zkServer.sh start`, `zkServer.sh status`



