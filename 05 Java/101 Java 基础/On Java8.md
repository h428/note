

# 函数式编程

- 函数式编程的意义：可以合并咸鱼代码来生成新功能而不是从头编写所有的内容
- OO（object oriented）是抽象数据，FP（functional programming）是抽象行为
- 纯粹的函数式语言在安全性方面更进一步，它强加了额外的约束，即所有数据必须是不可变的：设置一次，永不改变

## 新旧对比

- 传递函数式接口新对象的方式：普通类对象、匿名内部类、Lambda 表达式、方法引用，其中后两种是 Java 8 引入的


## Lambda 表达式

- Java8 引入了 lambda 表达式作为一种新的编写函数的方式，其在 jvm 中的本质为匿名内部类
- 例子：使用 lambda 表达式定义整数求和函数
```java
// 使用 lambda 表达式定义 int 求和函数
IntBinaryOperator sum = (left, right) -> left + right;
// 使用该求和函数
System.out.println(sum.applyAsInt(1, 2)); // 结果为：3
```
- lambda 表达式编写的函数支持递归，但递归的变量必须是类对象的 field 或者静态变量，因为 lambda 表达式只能接受局部常量，而不能接受局部变量作为参数（和匿名内部类一致）

## 方法引用

- 使用双冒号 `::` 声明方法引用，一般用于将目标方法绑定到指定的函数式接口
- 例子：将 Integer::sum 绑定到 IntBinaryOperator 接口以实现求和
```java
// 使用方法引用将 Integer::sum 绑定到函数式接口
IntBinaryOperator sum = Integer::sum;
// 使用该求和函数
System.out.println(sum.applyAsInt(1, 2)); // 结果为：3
```