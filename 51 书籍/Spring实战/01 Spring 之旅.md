
# 0. 概述


- 本章快速介绍 Spring 框架，包括 Spring DI 和 AOP 的概况，如何利用它们进行解耦
- 主要包括如下内容：
    - Spring 的 bean 容器
    - 介绍 Spring 的核心模块
    - 更为强大的 Spring 生态系统
    - Spring 的新功能
- Spring 诞生的最初目的是为了替代 EJB 这种重量级的企业技术，其提供了更加轻量级和简单的编程模型
- 核心的思想是依赖注入和面向切面编程的概念

# 1. 简化Java开发

- 为了降低 Java 开发的复杂性，Spring 采取了以下 4 个关键策略：
    - 通过 POJO 实现轻量级和最小侵入性编程（只需提供一个简单的 Bean）
    - 通过依赖注入和面向接口实现松耦合（IoC，对接口编程）
    - 基于切面和惯例进行声明式编程（声明式事务）
    - 通过切面和模板减少某些固定的代码（路数据库链接、释放等）


## 1.1 激发 POJO 潜能

- 很多框架由于要强迫应用继承它们的类或实现它们的接口使得应用和框架绑死
- Spring 尽力避免因为自身的 API 而弄乱你的代码，它不会强迫你实现 Spring 规范的接口或 Spring 规范的类
- 在基于 Spring 构建的应用程序，通常没有任何痕迹表明你使用了 Spring，最坏的情形也只是使用 Spring 注解，但它仍然是 POJO。


## 1.2 依赖注入

- DI 简单地说就是不在自己内部 new 一个对象，而是提供 get/set 方法，让框架自动调用方法注入依赖的对象，以实现轻耦合的目的

Spring提供了基于Java的配置，可作为XML的替代方案（对重构友好）

DI能够让相互协作的软件组件保持松耦合，而面向切面编程允许你把遍布应用各处的功能分离出来形成可重用的组件（如日志记录）

Spring还提供了一系列模板代码，用于小厨样板式代码，如JDBC模板

# 容纳你的Bean

Spring容器负责创建对象，装配它们，配置它们并管理它们的整个生命周期

Spring自带多个容器的实现，常见的为BeanFactory和ApplicationContext，ApplicationContext更加常见

常见的应用上下文包括以下几种：

AnnotationConfigApplicationContext：从一个或多个基于Java的配置类中加载Spring应用上下文
AnnotationConfigWebApplicationContext：从一个或多个基于Java的配置类中加载Spring Web应用上下文
ClassPathXmlApplicationContext：从类路径下的一个或多个XML配置文件中加载应用上下文
FileSystemXmlApplicationContext：从文件系统下的一个或多个XML文件中加载上下文定义
XmlWebApplicationContext：从Web应用上下文的一个或多个XML配置文件加载应用上下文定义


Bean的生命周期

1. Spring对Bean进行实例化
2. 注入Bean所依赖的属性
3. 如果bean实现了BeanNameAware接口，Spring将调用setBeanName()方法，把bean的ID传递进来
4. 如果bean实现了BeanFactoryAware接口，Spring将调用setBeanFactory()方法，把BeanFactory示例传递进来
5. 如果bean实现了ApplicationContextAware接口，Spring将调用setApplicationContext()方法，把bean所在的应用上下文传递进来
6. 如果bean实现了BeanPostProcessor接口，Spring将调用它的postProcessBeforeInitialization方法，执行进行初始化操作之前的一些额外操作
7. 如果bean实现了InitializingBean接口，Spring将调用它的afterPropertiesSet方法，执行初始化操作
8. 如果Bean使用init-method声明了方法，则调用这些方法
9. 如果bean实现了BeanPostProcessor接口，Spring将调用它的postProcessAfterInitialization方法，进行一些初始化后的收尾操作
10. 此时，bean已经准备就绪，可以被应用程序使用了，它们将一直留在应用上下文中，知道应用上下文被销毁
11. 如果bean实现了DisposableBean接口，Spring将调用它的destroy方法
12. 如果bean使用了destroy-method声明了销毁方法，该方法也会被调用

BeanNameAware接口可以让Bean拿到自己被实例化时定义的名字

关于Bean的类名，有以下几种可能：

若显式定义了类名，则为你定义的类名
若没有显式定义，则与定义Bean的方式有关：
如果使用的是XML中的bean标签，则默认名称为包全名#*，*为从0开始一直往后递增的数字
如果使用的是JavaConfig方式，则默认类名与方法名相同
如果使用的是注解(@Component等)，则默认名称为简单类名的首字母小写（UserDao-->userDao）


，若没有定义，则默认为包全名#*，*号从0开始，一直往后递增

BeanPostProcessor接口中定义了两个方法，分别是postProcessBeforeInitialization和postProcessAfterInitialization方法，分别在初始化操作的前后执行一些额外操作
经测试，这两个方法可能为执行多次，且如果Before返回了null，那么After则不会执行
