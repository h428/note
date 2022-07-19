[TOC]

# where子句

- 使用where子句指定搜索条件（过滤条件）
- `select prod_name, prod_pricefrom products where prod_price = 2.50`
- 数据也可以在应用程序过滤，此时数据库返回超过实际所需的数据，而且影响性能
- 如果有order by，应该让order by位于where之后

# where子句操作符

```
=	等于
<>或!=	不等于
<	小于
<=	小于等于
>	大于
>=	大于等于
between	在指定的两个值之间（闭区间）
```

- select prod_name, prod_price from products where prod_price < 10; //列出价格小于10的商品
- select prod_name, prod_price from products where prod_price <= 10; //列出价格小于等于10的商品

# 不匹配检查（!=、<>）

- `select vend_id, prod_name from products where vend_id <> 1003;` //列出不是由供应商制造的所有产品
- 或 `select prod_name, prod_price from products where prod_price != 10`
- 单引号用来限定字符串，如果将值与串类型的列进行比较，则需要引号，与数值列比较不需要

# 范围值检查（between ... and ...）

- `select prod_name, prod_price from products where prod_price between 5 and 10;`
- 注意包括5和10，是闭区间

# 空值检查

- 注意null != null，null的检查要使用is
- `select cust_id from customers where cust_email is null;`
- 


