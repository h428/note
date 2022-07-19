
# 8. MyBatis-Spring

- 整合 Mybatis 到 Spring，使用的是 MyBatis-Spring 1.2.3 版本


## 8.1 Spring 基础知识

- Spring 的核心技术主要由 IOC 和 AOP 构成，MyBatis-Spring 提供了一些基础的类，使得 Spring 能和 Mybatis 结合起来
- Spring 基础可以参考 Spring 实战的笔记

### 8.1.1 Spring IoC 基础

- Spring 使得我们可以不用自己 new 对象，而是由容器帮我们创建并管理，然后在注入到需要的对象中，这称作控制反转 (IoC)
- IoC 注入方式分为构造器注入， setter 注入和接口注入，最常用的是 setter 注入

### 8.1.2 Spring AOP 基础

- AOP 值得的面向切面的编程，在 Mybatis-Spring 中，主要用于控制数据库事务
- AOP 通过动态代理实现
- 核心概念有切点、切面、连接点、通知、织入等

### 8.1.3 Spring 事务管理

- 默认情况下，Spring 在执行方法跑抛出异常后，引发事务回滚

#### 8.1.3.1 事务隔离界别

- 读未提交
- 读已提交
- 可重复读
- 序列化

#### 8.1.3.2 传播行为

- 包括 PROPAGATION_REQUIRED, PROPAGATION_SUPPORTS, PROPAGATION_MANDATORY, PROPAGATION_REQUIRED_NEW, PROPAGATION_NOT_SUPPORTED, PROPAGATION_NEVER, PROPAGATION_NESTED
- 需要注意自调用的问题，自调用将导致被调用的事务无效，若是不同事务，需要单独切割成两个类


### 8.1.4 Spring MVC 基础

- 其核心是 DispatchServlet，其将根据拦截的配置去拦截一些请求，并请求分发工作
- 一般是在 web.xml 中配置 SpringMVC 的 DispatchServlet
- 在 Servlet 3 规范和 Spring 3.1 之后，可以利用 AbstractAnnotationConfigDispatcherServletInitializer 配置 DispatchServlet
- DispatchServlet 在拦截到请求后会将请求分发给 Controller，因此我们在 Web 层的主要任务是编写 Controller
- 除了 DispatchServlet 和 Controller 外，我们还要配置一个试图解析器用于映射处理结果并返回对应视图，最常见的是 JSP 视图解析器
- 若想返回 json 可以直接使用 @ResponseBody 注解即可 

## 8.2 MyBatis-Spring 应用

### 8.2.1 概述

- Spring 可以使用 XML 或者注解进行配置，但是注解是主流，因此，建议采用注解进行配置
- MyBatis-Spring 主要配置下述内容：
    - 数据源
    - SqlSessionFactory
    - SqlSessionTemplate （基于动态代理的 Mapper 进行编程时该项不配置）
    - 配置 Mapper
    - 事务处理
- Mybatis 要构建 SqlSessionFactory，用它来创建 SqlSession，而 SqlSessionTemplate 提供了对 SqlSession 操作的封装

### 8.2.2 配置 SqlSessionFactory

- 使用 SqlSessionFactoryBean 来配置 SqlSessionFactory，只需提供数据源和 Mybatis 配置文件路径即可
- 上述配置完成后，Spring IoC 容器就会初始化这个 Bean 并将 Mybatis 配置文件连通数据源一同保存在 Bean 中



