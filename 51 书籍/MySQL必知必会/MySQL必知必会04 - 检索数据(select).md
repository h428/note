[TOC]

# 检索一列或多列

- select 列名1 [,列名2] [,列名3]... from 表名
- select prod_name from products;
- select prod_id, prod_name, prod_price from products;
- 多条SQL语句必须使用分号（;）分隔
- MySQL不要求在单条SQL语句后加分号，但加上总没有坏处；此外，如果在mysql命令行中，必须加上分号来结束SQL语句
- SQL语句不区分大小写，因袭SELECT与select是相同的
- 建议对SQL关键字使用大写，表名和列名使用小写

# 检索所有列

- select * from products;
- 不建议使用，除非实在需要所有的列，否则避免使用通配符
- 使用通配符会降低检索和应用程序的性能
- 使用*的一个好处是能检测出名字未知的列

# 消除重复行

- select distinct vend_id from products;
- distinct要放在所有列名前面，用于消除值重复的行
- select distinct vend_id,prod_price from products; //观察与前一句的区别
- 注意distinct作用于所有列而不仅是它前置的列
- select count(distinct vend_id) from products; //统计指定列不重复的行数

# 限制结果

- limit关键字课限制结果，可用于mysql的分页查询
- select prod_name from products limit 5; //限制返回的行数不超过5行
- select prod_name from products limit 5,4; //限制返回从行5开始的4行数据
- 注意检索出来的结果第一行为行0而不是行1， limit 1,1将返回第二行
- 因此，`select prod_name from products limit 0,5;`等价于`select prod_name from products limit 5;`
- 行数不够时，limit将只能返回它能够返回的那么多行
- MySQL5支持limit的一种替代语法：limit 4 offset 3;表示从行3开始取4行，就像limit 3,4一样
- `select prod_name from products limit 4 offset 5;` 等价于 `select prod_name from products limit 5,4;`

# 查询时可以使用全限定的表名和列名

`select products.prod_name from products;`
`select products.prod_name from crashcourse.products;`