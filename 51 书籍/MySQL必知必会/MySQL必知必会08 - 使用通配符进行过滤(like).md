

# like操作符

- 要在搜索子句中使用通配符，必须使用like操作符
like指示MySQL后跟的搜索模式利用通配符匹配
- %表示任意字符出现任意次数
- `select prod_id, prod_name from products where prod_name like 'jet%';` //找出所有词以jet开头的产品
- 是否区分大小写与MySQL的配置方式有关，默认忽略大小写
- select prod_id, prod_name from products where prod_name like '%anvil%'; //搜索名称包含anvil的行
- 注意%能匹配0个字符，但是不能匹配NULL
- 尾空格可能会干扰通配符匹配，解决这个问题是在搜索模式最后附加一个%或者使用函数

- "_"匹配单个字符
- `select prod_id, prod_name from products where prod_name like '_ton anvil';`
- "_"总是匹配一个字符，不能多也不能少

# 通配符技巧

- 通配符搜索的处理一般要比其他搜索所花时间长
- 不要过度使用通配符，如果使用其他操作符能达到相同目的，应该使用其他操作符
- 在确实需要使用通配符时，除非绝对有必要，否则不要把它们用在搜索模式的开始处
- 把通配符放置于搜索模式的开始处，搜索起来是最慢的
- 仔细注意通配符的位置，放错地方可能得不到想要的数据
