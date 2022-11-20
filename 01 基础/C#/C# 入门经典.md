# 1 C# 简介

## 1.1 .Net Framework 含义

- .Net Framework 是微软为了在 Windows 上开发应用程序而创建的一个通用平台，目前最新版本为 4.7

## 1.2 C# 含义

- C# 是运行在 .Net 平台上的语言之一，从 C/C++ 演变而来，是微软专门为 .Net 平台创建的

## 1.3 VS2017

- VS 2017 产品介绍

# 2 编写 C# 程序

## 2.1 VS2017 开发环境

要使用 C# 进行开发，必须安装 .Net 开发环境，同时安装一个 IDE。本书选择的 IDE 是 VS 2017 社区版，在其安装过程同时会安装 .Net 环境，主要勾选下列组件

- Windows - Universal Windows Platform development
- Windows - .Net desktop develpment(.Net Framework 4.7 development tools)
- 其他工具集 - .Net Core

书里还勾选了下面两个组件，但是我们不打算学习 ASP 和 AZure，可以不必勾选

- Web & Cloud - ASP.NET and web debelopment
- Web & Cloud - Azure development

> 注意，IDE 可以不选择 VS 2017，比如可以选择 Jetbrains Rider，但不管选择哪个 IDE，都需要安装 .NET 平台才能正常编译并执行 C#，如果直接安装 Rider 且其没有提供 .NET 安装，可以先安装 VS 2017 并选择上 .NET，然后再使用 Rider 进行开发

VS 2017 的基本布局和常规 IDE 应用类似，但在入门开发阶段，主要有下述选项卡需要熟悉，这几个选项卡都可以使用 `视图 - xx 选项卡` 的方式切换出来

- 工具箱 Toolbox
- 解决方案资源管理器 Solution Explorer
- 团队资源管理器 Team Explorer
- 属性窗口 Properties
- 错误列表 Error List

## 2.2 控制台应用程序

选择 `File | New | Project` 菜单项，选择 `控制台应用程序(.Net Framework)`，然后输入项目名称和选择位置，即可创建一个控制台应用程序。注意我们输入的项目名称会作为 namespace 存在，因此建议选择大驼峰命名法，此处我们输入 ConsoleApp 作为项目名称，其会生成一个空架子，我们键入下述代码：

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

我们可以点击菜单栏下方的快速工具栏中的其中按钮，即可运行该项目，也可以使用快捷键 F5 或 Ctrl + F5（会保留控制台窗口）运行项目。

### 2.2.1 Solution Explorer 窗口

采用 C# 布局的情况下，解决方案资源管理器（Solution Explorer）默认位于右上角，若被关闭了可以使用 `视图 | 解决方案资源管理器` 菜单栏调出该窗口，该窗口主要展示当前项目的目录结构，以及相关类、文件等资源的存放位置。

该面板处一般还有另一个常用的 `类视图` 窗口，若被关闭了同样可以使用 `视图 | 类视图` 调出对应窗口，类视图主要以类的形式查看项目中的类，部分开发场景十分方便。同时单击底部的选项卡可以完成两个窗口之间的切换。

### 2.2.2 Properties 窗口

采用 C# 布局的情况下，属性窗口（Properties）默认位于右下方，在解决方案资源管理器的下方，若被关闭了可以使用 `视图 | 属性窗口` 菜单栏调过该窗口，该窗口主要展示选择了其他窗口的一些具体信息，比如选择了解决方案资源管理器，属性窗口就会展示其相关属性，如果选择类视图，又会具体展示类视图的属性。在后续的 GUI 编程中，可能还会展示相关控件的属性，且对属性的修改会影响到代码。

### 2.2.3 Error List 窗口

当程序没有错误，错误列表（Error List）默认不会展示。若运行程序时发生编译错误，则会弹出错误列表窗口，告知当前工程的错误，修正错误后错误列表窗口中则不再有错误但不会自动关闭窗口，可以自己手动关掉。此外还可以使用 `视图 | 错误列表` 手动对应窗口

## 2.3 桌面应用程序

依次点击 `文件 | 新建 | 项目` 菜单栏，选择 `WPF 应用(.Net Framework)` 模板，输入项目名称，即可创建一个桌面应用程序。同样地项目名称也会作为 namespace，因此建议采用大驼峰，我们此处输入 WpfApp。

对于一个桌面应用，在 C# 中是使用 xaml 文件来描述 UI 布局的，因此若打开的是一个 xaml 文件，则会在上方展示 UI，在下方展示其对应的 xml 布局代码。同时，一个 xaml 文件一般会关联到一个同名的 .cs 类，主要用于编写该窗口初始化、事件处理等代码。

如果打开的 xaml 文件，在左侧的工具箱窗口还会展示常用的 UI 控件，可以将其拖拽到 UI 界面上，IDE 会自动生成对应的 XML 代码，当然也可以遵照规范直接在 xaml 中键入代码，同样会在 UI 界面上展示出对应的控件。

当鼠标选择了某一控件后，右侧的属性窗口会展示该控件具备的属性，C# 为标准控件定义了大量属性，包括布局、样式等；此外，在选中空间后，在属性窗口单击 `闪电` 按钮可以切换到事件窗口，可以看到该组件上定义的大量标准事件，并为其添加处理函数，可以通过 `设置` 和 `闪电` 按钮分别切换到属性窗口或事件窗口。

- 介绍如何基于 WPF 创建桌面应用程序的 demo
- 简单介绍 Toolbox 的用法
- 简单介绍 xaml 的 demo 以及对应的界面展示

# 3 变量和表达式

## 3.1 C# 的基本语法

介绍基本语法、注释的格式，和 C 语言基本没什么区别，可以快速过。

## 3.2 C# 控制台应用程序的基本结构

`Hello World` 程序的基本结构很简单，最主要的当前项目存在一个和项目名称 ConsoleApp 相等的 namespace，在 namespace 下有一个 Program 类，该类有一个 Main 方法，该方法会作为程序的入口方法，

在 C# 中，提供了一种将代码块折叠的方式，使用 `#region 代码注释` 和 `#endregion` 包括一整块代码块，可以将代码块折叠，并以一行代码注释的形式展示。因为 `#` 和 markdown 的代码插件兼容有问题，此处不演示代码。

## 3.3 变量

定义变量的方式也是和 C 语言一样，采用 `类型关键字 变量名称` 的方式定义，例如 `int age`。

### 3.3.1 简单类型

|  类型  |     别名      |                    范围                    |
| :----: | :-----------: | :----------------------------------------: |
| sbyte  | System.SByte  |                 -128 ~ 127                 |
|  byte  |  System.Byte  |                  0 ~ 255                   |
| short  | System.Int16  |               -32768 ~ 32767               |
| ushort | System.UInt16 |                 0 ~ 65535                  |
|  int   | System.Int32  |          -2147483648 ~ 2147493647          |
|  uint  | System.UInt32 |                0~4294967295                |
|  long  | System.Int64  | -9223372036854775808 ~ 9223372036854775807 |
| ulong  | System.UInt64 |             0 ~ 18446744073709             |

- 介绍支持的变量类型以及取值范围
- 介绍变量的命名规则
- 介绍字面值对应的类型
- 介绍二进制和十六进制字面值
- 数字字面值支持以 \_ 分隔以增强可读性
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
class Program
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

# 11 集合、比较和转换

## 11.1 集合

- 介绍 System.Collection 下的各个集合相关的接口和类
- 常见的接口包括：IEnumerable, ICollection, IList, IDctionary
- 数组 System.Array 实现了 IList, ICollection, IEnumerable（对应 foreach 语法） 接口
- 集合 System.Collection.ArrayList 实现了 IList, ICollection, IEnumerable 接口，但实现方式比 System.Array 更复杂
- 介绍如何基于 System.Collections.CollectionBase 自定义集合
- 介绍如何为自定义集合编写索引符
- 介绍哈希表：IDictionary 接口和 DictionaryBase 基类
- 介绍迭代器 IEnumerable 接口与 foreach 循环
