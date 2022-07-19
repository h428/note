[TOC]

# 组合where子句

- 可以使用逻辑操作符(AND、OR)组合where子句
- `select prod_id, prod_price, prod_name from products where vend_id = 1003 and prod_price <= 10;`
- `select prod_name, prod_price from products where vend_id = 1002 or vend_id = 1003`
- and先于or进行计算，可使用括号更改优先级

# in操作符

- in操作符用来指定条件范围
- `select prod_name, prod_price from products where vend_id in(1002, 1003) order by prod_name;`
- in操作符更加直观，次序更容易管理，且一般比or执行得更快，而且还可以包含其他select语句（子查询）

# in操作符的优点

1. 在使用长的合法选项时，IN操作符的语法更清楚且更直观
2. 在使用IN时，计算的次序更容易管理（因为使用的操作符更少）
3. IN操作符一般比OR操作符清单执行更快
4. IN的最大优点是可以包含其他SELECT语句（子查询），使得能够更动态地建立where子句

# not操作符

- not操作符用于否定它之后所跟的任何条件
- `select prod_name, prod_price from products where vend_id not in(1002, 1003) order by prod_name;`
- MySQL支持使用NOT对IN、BETWEEN和EXISTS子句取反，这与多数其他DBMS允许使用NOT对各种条件取反有很大差别

