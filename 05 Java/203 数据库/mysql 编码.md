
- 查看编码：`show variables like 'character%';`
- 先讲一下配置问题，mysql 5.7 允许多 cnf 文件配置，相关配置文件主要在 /etc/mysql 这个目录下
- 首先是根配置文件，分别是 /etc/mysql/my.cnf -> /etc/alternatives/my.cnf -> /etc/mysql/mysql.cnf 这三个文件，它们按照分别按照顺序由前者软链接指向后者，因此实际上这三个文件本质上是一个文件（不信的话可以为其中一个添加空行然后查看另外两个是否同步），他们的内容如下：
```cnf
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```
- 上述配置表名，这个文件主要引入 /etc/mysql/conf.d/ 和 /etc/mysql/mysql.conf.d/ 这两个目录中的配置，只要在这两个目录中的后缀为 .cnf 的配置文件都会生效，5.7 通过这种方式来支持多 cnf 配置，
- 因此我们需要自定义的配置，只需在这两个目录下创建 cnf 文件并添加配置即可

**设置编码**

- 官方镜像默认会导致中文乱码，因此还需要一些额外配置，我们准备自定义的 code.cnf 文件
```cnf
[client]
default-character-set=utf8mb4

[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
```
- 将其复制到 `/etc/mysql/conf.d/` 或者 `/etc/mysql/mysql.conf.d/` 下，重启 mysql 服务
- 重新进入