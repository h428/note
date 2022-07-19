
# 连接数据库

连接到MySQL，需要提供以下信息
    
1. 主机名（计算机名） —— 如果是连接本地的MySQL服务器，则为localhost
2. 端口（默认为3306）
3.一个合法的用户名
4.用户名密码（如果需要）

# 数据库操作

## 选择数据库 - use

- use 数据库名; //选择目标数据库


## 展示数据库、表信息 - show

- show databases;	//展示可用数据库
- select database(); //展示当前使用的数据库
- show tables;	//展示当前数据库可用表格
- show columns from 表名;	//查看指定表的列信息，和下面两个语句等价
- desc 表名;
- describe 表名; 
- show create table 表名;	//查看建表语句

## 展示其他信息

- show status;	//用于展示广泛的服务器状态信息（服务器的一些参数信息）
- show grants;	//显示授权用户（所有用户或特定用户）的安全权限
- show errors;	//显示服务器错误信息
- show warnings;	//显示服务器警告信息

## 使用帮助

例如想知道show的更多信息，可以使用help show;