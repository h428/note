
# 1 C# 简介

## 1.1 .Net Framework 含义

- .Net Framework 是微软为了在 Windows 上开发应用程序而创建的一个通用平台，目前最新版本为 4.7

## 1.2 C# 含义

- C# 是运行在 .Net 平台上的语言之一，从 C/C++ 演变而来，是微软专门为 .Net 平台创建的

## 1.3 VS2017

- VS 2017 产品介绍

# 2 编写 C # 程序

## 2.1 VS2017 开发环境

- 主要介绍 VS 2017 的安装过程，如何勾选所需的内容
- 介绍 VS 2017 的基本布局，以及各个选项卡的功能：工具栏 Toolbox、解决方案资源管理器 Solution Explorer、团队资源管理器 Team Explorer 以及属性窗口 Properties，相关选项卡可以使用 `视图 - 选项卡` 的方式切换出来
- 介绍 `视图 - 错误列表 Error List` 窗口

## 2.2 控制台应用程序

- 介绍如何创建基于 C# 的控制台应用程序 ConsoleApp
- 介绍该程序下各个窗口的作用：Solution Explorer、Properties 和 Error List
```C#
namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
            Console.ReadKey();
        }
    }
}
```

## 2.3 桌面应用程序

- 介绍如何基于 WPF 创建桌面应用程序的 demo
- 简单介绍 Toolbox 的用法
- 简单介绍 xaml 的 demo 以及对应的界面展示

# 3 变量和表达式

## 3.1 C# 的基本语法

- 介绍基本语法、注释的格式

## 3.2 C# 控制台应用程序的基本结构

- 介绍 `Hello World` 程序的基本结构
- 介绍 #region 的折叠用法

## 3.3 变量

- 介绍定义变量的方式
- 介绍支持的变量类型以及取值范围
- 介绍变量的命名规则
- 介绍字面值对应的类型
- 介绍二进制和十六进制字面值
- 数字字面值支持以 _ 分隔以增强可读性
- 介绍字符串字面值以及对应的转义字符，Unicode 值等

## 3.4 表达式

- 表达式可按操作数分为一元、二元、三元三类
- 介绍数学运算符
- 入门使用 Console.ReadLine() 进行输入，以及使用 Convert 进行字符串和其他格式之间的转换
- 介绍赋值运算符
- 介绍运算符优先级
- 介绍名称空间 namespace，类似 Java 的包


# 4 流程控制

## 4.1 布尔逻辑

- 介绍比较运算符： `==, !=, >, <, >=, <=` 6 个
- 介绍布尔运算符： `&&, ||, !, ^`
- 介绍运算符优先级

## 4.2 分支

- 介绍三元运算符
- 介绍 if 语句
- 介绍 switch 语句

## 4.3 循环

- 介绍循环的写法，包括 do while, while 和 for 三种
- 介绍循环的中断，包括 break, continue 和 return 三种


# 5 变量的更多内容

## 5.1 类型转换

- 介绍数值类型的隐式转换
- 介绍强制类型转换
- 介绍使用 Convert 实现常见类型之间的互转

## 5.2 复杂的变量类型

- 介绍枚举的定义和基本用法
- 介绍结构的定义和基本用法
- 介绍数组的定义和基本用法
- 介绍 foreach 循环
- 介绍多维数组以及初始化

## 5.3 字符串的处理

- 介绍字符串的遍历以及常用的处理函数

# 6 函数

## 6.1 定义和使用函数

- 介绍函数定义方式
- 介绍返回值和 return
- 介绍参数，包括形参 parameter 和实参 argument
- 介绍可变参数 params 关键字
- 介绍引用类型 ref 关键字
- 介绍输出参数 out 关键字
- 介绍元组的定义和使用

## 6.2 变量的作用域

- 介绍局部变量的作用域
- 介绍全局变量
- 介绍局部函数：在函数内部定义函数，增强可读性，只能在函数内部使用

## 6.3 Main() 函数

- 介绍 Main 函数的入参，返回值
- 介绍 VS 如何提供 Main 的 args

## 6.4 结构函数

- 介绍结构体的函数，类似类


## 6.5 函数的重载

- 介绍函数的重载

## 6.6 委托

- 介绍委托的定义和绑定方式：
```C#
internal class Program
{
    /**
        * 声明一个入参为两个 double，返回值为一个 double 的委托；
        * 委托可以看成一种接口，因此可以使用委托创建实例，创建时需要进行绑定
        */
    delegate double Fun(double p, double q);

    /**
        * 定义 double 求和
        */
    static double Sum(double n1, double n2)
    {
        return n1 + n2;
    }

    /**
        * 定义 double 求平均
        */
    static double Avg(double n1, double n2)
    {
        return (n1 + n2) / 2;
    }
    
    public static void Main(string[] args)
    {

        // 调用参数
        double n1 = 3, n2 = 5;

        // 实例化委托并绑定到合法的函数
        Fun sum = Sum;
        Fun avg = Avg;

        // 使用委托进行调用
        Console.WriteLine(sum(n1, n2));
        Console.WriteLine(avg(n1, n2));
    }
}
```

# 7 调试和错误处理

## 7.1 Visual Studio 中的调试

- 介绍调试 VS 的工具
- 介绍 C# 自带的 Debug 和 Trace

## 7.2 错误处理

- 介绍 try catch finally 用法
- 支持使用 when 关键字对异常做过滤
- 介绍双 ?? 控制合并操作符

# 8 面向对象编程简介（概念）

## 8.1 面向对象编程的含义

- 介绍 OOP 的基础术语：属性、字段、方法，注意属性和字段的区别
- 介绍一切皆对象
- 介绍对象的生命周期：构造与析构
- 介绍静态成员与类实例成员

## 8.2 OOP 技术

- 介绍接口，以及特殊的 IDisposable 接口用法
- 介绍继承的特性
- 介绍多态的特性，注意 C# 的多态必须自己使用 virtual 和 override 声明，不是自动具备多态的
- 介绍对象之间的其他关系：包含、集合
- 介绍运算符重载
- 介绍时间
- 介绍引用类型和值类型

## 8.3 桌面应用程序中的 OOP

- 窗体、控件都涉及到 OOP 技术，和 OOP 中的概念一一对应
- 例如 MainWindow, Button 都是对象

# 9 定义类（代码）

## 9.1 C# 中的类定义

- 使用 class 关键字定义类，同时介绍修饰符 public 和 internal 的区别
- 介绍 abstract 和 sealed 的作用
- 介绍继承的写法
- 使用 interface 定义接口

## 9.2 System.Object

- C# 也为单根继承结构，System.Object 提供一些基础的必备方法

## 9.3 构造函数和析构函数

- 介绍构造函数和析构函数
- 介绍调用父类和本类的构造函数的方式
- 介绍涉及到继承和组合时的构造和析构顺序

## 9.4 Visual Studio 中的 OOP 工具

- 介绍 VS 中的几个 OOP 相关的窗口：类视图、对象浏览器、类图等

## 9.5 类库项目

- 类库项目为 .dll 程序集，其他项目添加对类库项目的引用后就可以访问它的内容
- 介绍如何创建和引用类库

## 9.6 接口和抽象类

- 介绍单根继承结构，但可以实现多个接口

## 9.7 结构类型

- 介绍结构和类的区别：结构是值类型，而类是引用类型
- 结构自带深拷贝

## 9.8 前度和深度复制

- 介绍深拷贝与 MemberwiseClone() 方法

# 10 定义类成员

## 10.1 成员定义

- 介绍 public, private, internal, protected 修饰符的区别
- 介绍如何定义类的字段
- 介绍只读字段与 readonly 关键字
- 介绍静态字段与 static 关键字
- 介绍如何类的定义方法
- 介绍定义方法相关的修饰符关键字：virtual, abstract, override, extern
- 注意 C# 不是自动具备多态，必须自己使用 virtual 或者 abstract 声明后才具备多态，且覆盖时必须声明 override 关键字
- 介绍如何定义属性，即 get/set 关键字对应的属性块
- 属性更加类似方法，也可以使用 virtual, override, abstract 关键字，但字段不可以
- 介绍元组的解构
- 介绍自动属性

## 10.2 类成员的其他主题

- 使用 new 关键字隐藏基类的方法，类似 override，但允许隐藏父类的非 virtual 方法
- 使用 base 关键字调用被覆盖或隐藏的基本方法
- 介绍 this 关键字
- 介绍内部类

## 10.3 接口的实现

- 使用 interface 定义接口，且其所有方法都是公共的，不能定义成员（可以有属性）
- 介绍如何实现接口

## 10.4 部分类定义

- 可以使用 partial 进行部分类定义，将一个类的定义放在多个文件中

## 10.5 部分方法定义

- 介绍如何进行部分方法定义，将同一个方法的声明和实现分开

## 10.6 示例应用程序

- 略

## 10.7 Call Hierarchy 窗口


# 集合、比较和转换

## 集合

- 介绍 System.Collection 下的各个集合相关的接口和类
- 常见的接口包括：IEnumerable, ICollection, IList, IDctionary
- 数组 System.Array 实现了 IList, ICollection, IEnumerable（对应 foreach 语法） 接口
- 集合 System.Collection.ArrayList 实现了 IList, ICollection, IEnumerable 接口，但实现方式比 System.Array 更复杂
- 介绍如何基于 System.Collections.CollectionBase 自定义集合
- 介绍如何为自定义集合编写索引符
- 介绍哈希表：IDictionary 接口和 DictionaryBase 基类
- 介绍迭代器 IEnumerable 接口与 foreach 循环