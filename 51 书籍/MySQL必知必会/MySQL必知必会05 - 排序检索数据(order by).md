[TOC]

# 子句

SQL语句由子句构成，有些子句是必须的，有的是可选的

# 排序

- order by可选子句可用于排序检索的数据
- `select prod_name from products order by prod_name;`
- 通常排序的列包含在检索的列中，但是用非检索的列排序是完全合法的

# 按多个列排序

`select prod_id, prod_price, prod_name from products order by prod_price, prod_name;`

# 指定排序方向

- 排序默认是升序的（asc），使用desc关键字声明降序排序
`select prod_id, prod_price, prod_name from products order by prod_price desc`;
- 可以定义多个列排序
- `select prod_id, prod_price, prod_name from products order by prod_price desc, prod_name;`
- MySQL的字典排序中，A被视为与a相同，如果有需求，可要求数据库管理员改变这种行为

# 组合使用order by和limit

- limit用于限制返回的结果集，因此是在排序之后再返回
- `select prod_price from products order by prod_price desc limit 1;` //找到一个列中最高或最低的值
- prod_price desc保证降序，limit 1保证返回一行

# 位置问题

- order by子句位于from子句之后
- limit子句位于order by子句之后