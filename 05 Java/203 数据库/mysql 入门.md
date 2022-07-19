

# 连接数据库

- 首先确认 mysql 安装成功，此时可能未启动，可使用 `netstat -ntlp` 查看是否有 3306 端口（默认），没有则未启动
- Centos 7.2 下使用 `systtemctl start mysqld.service` 启动 mysqld 服务，使用 `systemctl status mysqld.service` 查看 mysqld 服务状态
- 使用 `mysql -uroot -p` 连接数据库，会要求输入密码，输入密码后即可进入数据库


# 建库建表


## 建库

- 可使用 `show databases` 查看目前存在哪些数据库
- 使用 `create database` 建库，对于 mysql，一般建议间建库时手动指定编码为 utf8mb4
```sql
drop database if exists mall;
create database mall character set utf8mb4 collate utf8mb4_general_ci;
```

## 建表

- 首先进入要操作的数据库：`use mall;`
- 查看当前数据库所有数据表：`show tables;`
- 建表语句：
```sql
drop table if exists user;
create table user(
    id bigint primary key comment '主键',
    email varchar(128) not null comment '电子邮箱',
	user_name varchar(32) not null comment '用户名',
	user_pass char(64) not null comment '密码',
    salt char(64) not null comment '盐值',
	height double not null default 0 comment '身高',
    avatar varchar(128) not null default '' comment '头像', 
    score int not null default 0 comment '评分', 
    birthday date not null default '1900-01-01' comment '出生日期',
	create_time timestamp not null default current_timestamp comment '注册时间',
    update_time datetime not null default current_timestamp on update current_timestamp comment '上次更新时间',
	last_login_time datetime not null default now() comment '上次登录时间',
    status tinyint not null default 0 comment '状态',
    role_id bigint not null default 0 comment '角色 id',
	deleted bit not null default 0 comment '删除标记',
    delete_time timestamp not null default 0 comment '删除时间',
	constraint unq_email unique(email),
    constraint unq_user_name unique(user_name)
);
```


## 执行 sql 文件