

- [参考地址](https://www.jianshu.com/p/7aeeb4f9a8c9)

# 1. 安装

- 服务部署在 Linux，破解可以基于 Windows，不知道是否可以基于 linux
- 准备下述文件 : 
    - confluence_keygen.jar
    - atlassian-confluence-5.4.4-x64.bin
    - Confluence-5.4.4-language-pack-zh_CN.jar
    - 51CTO下载-confluence5.1-crack.zip
    - mysql-connector-java-5.1.32-bin.jar

- 安装 confluence :
```
chmod +x atlassian-confluence-5.4.4-x64.bin
./atlassian-confluence-5.4.4-x64.bin
```
- 执行bin文件后，会经历三个确认
```
第一个，是否确认安装。【o】
第二个，选择安装方式，默认、自定义、升级现有的。【1】
第三个，确认安装。【i】
注：此时，安装已完成，不应该出现任何错误
```
- 然后访问 ip:8090 端口，获取到 Server ID，破解要用到

# 2. 破解

- 此处在 windows 下破解，要求已配置 java 环境
- 首先停止服务 `/etc/init.d/confluence stop`
- 解压 confluence5.1-crack.zip 后，将 `/opt/atlassian/confluence/confluence/WEB-INF/lib` 下的 atlassian-extras-2.4.jar 下载到本地并覆盖
- 运行 `java -jar confluence_keygen.jar` 启动破解工具
- 填写名称、邮箱、组织、前面的 Server ID
- 点击 patch 选择刚刚下载到本地的 atlassian-extras-2.4.jar
- 点击 .gen 生成 key 值并复制
- 此时，文件夹下会有两个文件 atlassian-extras-2.4.jar 和atlassian-extras-2.4.bak，将破解后的 atlassian-extras-2.4.jar 复制回服务器的 /opt/atlassian/confluence/confluence/WEB-INF/lib/ 下并启动 wiki

# 3. 配置

- 使用 mysql 作为数据库，因此将 mysql 连接驱动拷贝到 /opt/atlassian/confluence/confluence/WEB-INF/lib 目录下
- 注意此处使用驱动版本为 `mysql-connector-java-5.1.32-bin.jar`， 5.8 可能无法使用，驱动版本和 mysql 版本可能有一定关系，此处选择 mysql 5.7
- 重启 wiki 服务 : `/etc/init.d/confluence restart`

**mysql创建库**

- 根据博客，5.4.4版本的confluence，貌似对mysql的存储引擎有要求，需要是InnoDB，注意查看验证 : `show variables like '%storage_engine%';`
- 执行下述命令 : 
```
mysql -uroot -p
create database wiki character set UTF8;
grant all on wiki.* to wiki_user@"%" identified by "wiki_password";
```

**继续配置 confluence**

- 重新访问 8090 端口，粘贴生成的 key，并点击 Production Installation 
- 选择 mysql，点击 External Database
- 点击 DIrect JDBC，填写数据库连接信息后点击 Next :
```
jdbc:mysql://127.0.0.1:3306/wiki?useUnicode=true&characterEncoding=UTF8
```
- 之后点击 Empty Site
- 之后点击 Manage users and groups within confluence
- 配置管理员账户
- 然后点击 further configuration

**汉化插件**

- 登录 wiki，点击设置按钮中的 add-on，然后在界面上选择 Upload Add on，即上传插件
- 选择我们的 `Confluence-5.4.4-language-pack-zh_CN.jar` 上传，重启即可

**校验文件内容**

- `vim /var/atlassian/application-data/confluence/confluence.cfg.xml`
- 确保数据库连接信息中的 `&` 正确，为 `&amp;`

