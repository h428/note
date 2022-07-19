
- MySQL仅支持正则表达式的一个子集，注意不是全部正则表达式
- 使用regexp指定正则表达式（位于where子句之后）
- `select prod_name from products where prod_name regexp '1000' order by prod_name;`
- `select prod_name from products where` 
- `prod_name regexp '.000' order by prod_name;`
- LIKE匹配整个列，如果被匹配的文本在列值中出现，但不匹配整个列值，LIKE是不会返回对应的行的
- regexp在列值内进行匹配，如果被匹配的文本在列值中出现（部分匹配即可），regexp会找到它（注意Java中的正则表达式默认是整个字符串匹配，相当于默认加上^开头和$结尾）
- `select prod_name from products where prod_name regexp '1000' order by prod_name; //找到JetPack 1000`
- `select prod_name from products where prod_name like '1000' order by prod_name; //找不到JetPack 1000`
- regexp也能用来匹配整个列值，使用^和$定位符即可
- `select prod_name from products where prod_name regexp '^Jet.*1$' order by prod_name;`
- regexp默认不区分大小写，若要区分大小写，请使用binary关键字
- `select prod_name from products where prod_name regexp binary 'JetPack .000' order by prod_name;`

- 进行or匹配：`select prod_name from products where prod_name regexp '1000|2000' order by prod_name;`

- 匹配几个字符：`select prod_name from products where prod_name regexp '[123] Ton' order by prod_name;`
- 相当于： 1 Ton | 2 Ton | 3 Ton
- 取反字符集： [^123]
- 匹配范围：`select prod_name from products where prod_name regexp '[1-5] Ton' order by prod_name;`

- `匹配特殊字符，必须使用\\进行转义（理论上是一个\，但MySQL需要解释一个\，因此\也需要转义，即\\，Java也需要两个\）`
- `select vend_name from vendors where vend_name regexp '\\.' order by vend_name; //匹配包含.的列`
- `\或\\?	多数正则表达式使用单个反斜杠转义特殊字符，以便能使用这些字符本身，但MySQL要求两个反斜杠（MySQL自己解释一个，正则表达式库解释另一个）`
- `\\f	换页`
- `\\n	换行`
- `\\r	回车`
- `\\t	制表`
- `\\v	纵向制表`
- `\\\	\本身，前两个\\是转义`

> 预定义字符类

```
[:alnum:]	任意字母和数字，同[a-zA-Z0-9]
[:alpha:]	任意字母，同[a-zA-Z]
[:blank:]	空格个制表，同[\\t]
[:cntrl:]	ASCII控制字符（ASCII 0-31和127）
[:digit:]	任意数字，同[0-9]
[:graph:]	与[:print:]相同，但不包括空格
[:lower:]	任意小写字符，同[a-z]
[:print:]	任意可打印字符
[:punct:]	既不在[:alnum:]又不在[:cntrl:]中的任意字符
[:space:]	包括空格在内的任意空白符，同[\\f\\n\\r\\t\\v]
[:upper:]	任意大写字母，同[A-Z]
[:xdigit:]	任意十六进制数字，同[a-fA-F0-9]
```

匹配多个实例

```
*	0或多个匹配
+	1或多个匹配（等于{1,}）
?	0个或1个匹配（等于{1,}）
{n}	指定数目的匹配
{n,}	不少于指定书目的匹配
{n,m}	匹配数目的范围（m不超过255）
```

- `select prod_name from products where prod_name regexp '\\([0-9] sticks?\\)' order by prod_name; //匹配包含形如 (1 sticks)的列，?表示可以没有s`

- `select prod_name from products where prod_name regexp '[[:digit:]]{4}'; //匹配包含4个数字的列，等价于以下正则：`
- `-[0-9]{4}`
- `-[0-9][0-9][0-9][0-9]`


定位符

用于匹配特定位置的文本


- ^	文本的开始
- $	文本的结尾
- [[:<:]]	词的开始 //暂时不知如何使用，猜测用法 - `select prod_name from products where prod_name regexp '[[:<:]]1000[[:>:]]';`
- `[[:>:]]	词的结尾 //暂时不知如何使用`

- `select prod_name from products where prod_name regexp '^[0-9\\.]'; //这里表示易0-9或.开头的列`

- `注意，^有两种用法，放在集合的开头用于否定集合[^xxx]，或者放再串开始处表示开头`
- `利用定位符，通过^开始每个表达式，$结束每个表达式，可以使REGEXP的作用与LIKE一样`
- `select prod_name from products where prod_name regexp '^J.*[^1]000$';`

正则表达式测试

- 可以在不使用数据库表的情况用select测试正则表达式

- regexp总是返回0（没有匹配）或1（匹配）

- select 'hello' regexp '[0-9]'; //返回0

正则表达式内容

- .在正则表达式中表示任意一个字符
- []指定匹配的几个字符（字符集）
- [^xxx]否定字符集
- [0-9]指定匹配范围，相当于[0123456789]，[a-z]同理