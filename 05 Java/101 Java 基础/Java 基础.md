→ 基本数据类型
8 种基本数据类型：整型、浮点型、布尔型、字符型

整型中 byte、short、int、long 的取值范围

什么是浮点型？什么是单精度和双精度？为什么不能用浮点型表示金额？

→ 自动拆装箱
什么是包装类型、什么是基本类型、什么是自动拆装箱

Integer 的缓存机制

→ String
字符串的不可变性

JDK 6 和 JDK 7 中 substring 的原理及区别、

replaceFirst、replaceAll、replace 区别、

String 对“+”的重载、字符串拼接的几种方式和区别

String.valueOf 和 Integer.toString 的区别、

switch 对 String 的支持

字符串池、常量池（运行时常量池、Class 常量池）、intern

→ 熟悉 Java 中各种关键字
transient、instanceof、final、static、volatile、synchronized、const 原理及用法

→ 集合类
常用集合类的使用、ArrayList 和 LinkedList 和 Vector 的区别 、SynchronizedList 和 Vector 的区别、HashMap、HashTable、ConcurrentHashMap 区别、

Set 和 List 区别？Set 如何保证元素不重复？

Java 8 中 stream 相关用法、apache 集合处理工具类的使用、不同版本的 JDK 中 HashMap 的实现的区别以及原因

Collection 和 Collections 区别

Arrays.asList 获得的 List 使用时需要注意什么

Enumeration 和 Iterator 区别

fail-fast 和 fail-safe

CopyOnWriteArrayList、ConcurrentSkipListMap

→ 枚举
枚举的用法、枚举的实现、枚举与单例、Enum 类

Java 枚举如何比较

switch 对枚举的支持

枚举的序列化如何实现

枚举的线程安全性问题

→ IO
字符流、字节流、输入流、输出流、

同步、异步、阻塞、非阻塞、Linux 5 种 IO 模型

BIO、NIO 和 AIO 的区别、三种 IO 的用法与原理、netty

→ 反射
反射与工厂模式、反射有什么用

Class 类、java.lang.reflect.*

→ 动态代理
静态代理、动态代理

动态代理和反射的关系

动态代理的几种实现方式

AOP

→ 序列化
什么是序列化与反序列化、为什么序列化、序列化底层原理、序列化与单例模式、protobuf、为什么说序列化并不安全


→ 注解
元注解、自定义注解、Java 中常用注解使用、注解与反射的结合

Spring 常用注解

→ JMS
什么是 Java 消息服务、JMS 消息传送模型

→ JMX
java.lang.management.*、 javax.management.*

→ 泛型
泛型与继承、类型擦除、泛型中 KTVE? object 等的含义、泛型各种用法

限定通配符和非限定通配符、上下界限定符 extends 和 super

List<Object> 和原始类型 List 之间的区别? 

List<?> 和 List<Object> 之间的区别是什么?

→ 单元测试
junit、mock、mockito、内存数据库（h2）

→ 正则表达式
java.lang.util.regex.*

→ 常用的 Java 工具库
commons.lang、commons.*...、 guava-libraries、 netty

→ API & SPI
API、API 和 SPI 的关系和区别

如何定义 SPI、SPI 的实现原理

→ 异常
异常类型、正确处理异常、自定义异常

Error 和 Exception

异常链、try-with-resources

finally 和 return 的执行顺序

→ 时间处理
时区、冬令时和夏令时、时间戳、Java 中时间 API

格林威治时间、CET,UTC,GMT,CST 几种常见时间的含义和关系

SimpleDateFormat 的线程安全性问题

Java 8 中的时间处理

如何在东八区的计算机上获取美国时间

→ 编码方式
Unicode、有了 Unicode 为啥还需要 UTF-8

GBK、GB2312、GB18030 之间的区别

UTF8、UTF16、UTF32 区别

URL 编解码、Big Endian 和 Little Endian

如何解决乱码问题

→ 语法糖
Java 中语法糖原理、解语法糖

语法糖：switch 支持 String 与枚举、泛型、自动装箱与拆箱、方法变长参数、枚举、内部类、条件编译、 断言、数值字面量、for-each、try-with-resource、Lambda 表达式