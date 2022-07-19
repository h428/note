
# 1. 微服务介绍

## 1.1 系统架构演变

- 随着互联网的发展，网站应用的规模也在不断的扩大，进而导致系统架构也在不断的进行变化
- 从互联网早起到现在，系统架构大体经历了下面几个过程: 单体应用架构 ---> 垂直应用架构 ---> 分布式架构 ---> SOA 架构 ---> 微服务架构，当然还有悄然兴起的 Service Mesh（服务网格化）
- 接下来我们就来了解一下每种系统架构是什么样子的， 以及各有什么优缺点

### 1.1.1 单体应用架构

- 互联网早期，一般的网站应用流量较小，只需一个应用，将所有功能代码都部署在一起就可以，这样可以减少开发、部署和维护的成本
- 比如说一个电商系统，里面会包含很多用户管理，商品管理，订单管理，物流管理等等很多模块，我们会把它们做成一个 web 项目，然后部署到一台 tomcat 服务器上
![单体应用架构](https://raw.githubusercontent.com/h428/img/master/note/00000067.jpg)
- 优点：
    - 项目架构简单，小型项目的话， 开发成本低
    - 项目部署在一个节点上， 维护方便
- 缺点：
    - 全部功能集成在一个工程中，对于大型项目来讲不易开发和维护
    - 项目模块之间紧密耦合，单点容错率低
    - 无法针对不同模块进行针对性优化和水平扩展

### 1.1.2 垂直应用架构

- 随着访问量的逐渐增大，单一应用只能依靠增加节点来应对，但是这时候会发现并不是所有的模块都会有比较大的访问量
- 还是以上面的电商为例子，用户访问量的增加可能影响的只是用户和订单模块，但是对消息模块的影响就比较小，那么此时我们希望只多增加几个订单模块，而不增加消息模块，此时单体应用就做不
到了，垂直应用就应运而生了
- 所谓的垂直应用架构，就是将原来的一个应用拆成互不相干的几个应用，以提升效率。比如我们可以将上面电商的单体应用拆分成:
    - 电商系统(用户管理 商品管理 订单管理)
    - 后台系统(用户管理 订单管理 客户管理)
    - CMS 系统(广告管理 营销管理)
- 这样拆分完毕之后，一旦用户访问量变大，只需要增加电商系统的节点就可以了，而无需增加后台
和 CMS 的节点
![垂直应用架构](https://raw.githubusercontent.com/h428/img/master/note/00000068.jpg)
- 优点：
    - 系统拆分实现了流量分担，解决了并发问题，而且可以针对不同模块进行优化和水平扩展
    - 一个系统的问题不会影响到其他系统，提高容错率
- 缺点：
    - 系统之间相互独立， 无法进行相互调用
    - 系统之间相互独立， 会有重复的开发任务

### 1.1.3 分布式架构

- 当垂直应用越来越多，重复的业务代码就会越来越多，这时候，我们就思考可不可以将重复的代码抽取出来，做成统一的业务层作为独立的服务，然后由前端控制层调用不同的业务层服务呢？
- 这就产生了新的分布式系统架构：它将把工程拆分成表现层和服务层两个部分，服务层中包含业务逻辑，表现层只需要处理和页面的交互，业务逻辑都是调用服务层的服务来实现
![分布式架构](https://raw.githubusercontent.com/h428/img/master/note/00000069.jpg)
- 优点：抽取公共的功能为服务层，提高代码复用性
- 缺点：系统间耦合度变高，调用关系错综复杂，难以维护

### 1.1.4 SOA 架构

- 在分布式架构下，当服务越来越多，容量的评估，小服务资源的浪费等问题逐渐显现，此时需增加一个调度中心对集群进行实时管理
- 此时，用于资源调度和治理中心（SOA Service Oriented
Architecture，面向服务的架构）是关键
![SOA 架构](https://raw.githubusercontent.com/h428/img/master/note/00000070.jpg)
- 优点：使用注册中心解决了服务间调用关系的自动调节
- 缺点：
    - 服务间会有依赖关系，一旦某个环节出错会影响较大（服务雪崩）
    - 服务关心复杂，运维、测试部署困难

### 1.1.5 微服务架构

- 微服务架构在某种程度上是面向服务的架构 SOA 继续发展的下一步，它更加强调服务的"彻底拆分"
![微服务架构](https://raw.githubusercontent.com/h428/img/master/note/00000071.jpg)
- 优点：
    - 服务原子化拆分，独立打包、部署和升级，保证每个微服务清晰的任务划分，利于扩展
    - 微服务之间采用 Restful 等轻量级 http 协议相互调用
- 缺点：
    - 分布式系统开发的技术成本高（容错、分布式事务等）

## 1.2 微服务架构介绍

- 微服务架构， 简单的说就是将单体应用进一步拆分，拆分成更小的服务，每个服务都是一个可以独立运行的项目

### 1.2.1 微服务架构的常见问题

- 一旦采用微服务系统架构，就势必会遇到这样几个问题：
    - 这么多小服务，如何管理他们？（服务治理 注册中心[服务注册 发现剔除]）
    - 这么多小服务，他们之间如何通讯？（restful rpc）
    - 这么多小服务，客户端怎么访问他们？（网关）
    - 这么多小服务，一旦出现问题了，应该如何自处理？（容错）
    - 这么多小服务，一旦出现问题了，应该如何排错? （链路追踪）
- 对于上面的问题，是任何一个微服务设计者都不能绕过去的，因此大部分的微服务产品都针对每一个问题提供了相应的组件来解决它们
![微服务架构](https://raw.githubusercontent.com/h428/img/master/note/00000072.jpg)

### 1.2.2 微服务架构的常见概念

#### 1.2.2.1 服务治理

- 服务治理就是进行服务的自动化管理，其核心是服务的自动注册与发现。
- **服务注册**：服务实例将自身服务信息注册到注册中心。
- **服务发现**：服务实例通过注册中心，获取到注册到其中的服务实例的信息，通过这些信息去请求它们提供的服务。
- **服务剔除**：服务注册中心将出问题的服务自动剔除到可用列表之外，使其不会被调用到。

#### 1.2.2.2 服务调用

- 在微服务架构中，通常存在多个服务之间的远程调用的需求。目前主流的远程调用技术有基于 HTTP 的 RESTful 接口以及基于 TCP 的 RPC 协议。
- REST（Representational State Transfer），这是一种 HTTP 调用的格式，更标准，更通用，无论哪种语言都支持 http 协议
- RPC（Remote Promote Call）
    - 一种进程间通信方式。
    - 允许像调用本地服务一样调用远程服务。
    - RPC 框架的主要目标就是让远程服务调用更简单、透明。
    - RPC 框架负责屏蔽底层的传输方式、序列化方式和通信细节。开发人员在使用的时候只需要了解谁在什么位置提供了什么样的远程服务接口即可，并不需要关心底层通信细节和调用过程。

**区别与联系**

|比较项|RESTful|RPC|
|:---:|:---:|:---:|
|性能|略低|较高|
|灵活度|高|低|
|应用|微服务架构|SOA架构|

#### 1.2.2.3 服务网关

- 随着微服务的不断增多，不同的微服务一般会有不同的网络地址，而外部客户端可能需要调用多个服务的接口才能完成一个业务需求，如果让客户端直接与各个微服务通信可能出现：
    - 客户端需要调用不同的url地址，增加难度
    - 在一定的场景下，存在跨域请求的问题
    - 每个微服务都需要进行单独的身份认证
- 针对这些问题，API网关顺势而生。
- API网关直面意思是将所有API调用统一接入到API网关层，由网关层统一接入和输出。一个网关的基本功能有：统一接入、安全防护、协议适配、流量管控、长短链接支持、容错能力。有了网关之后，各个API服务提供团队可以专注于自己的的业务逻辑处理，而API网关更专注于安全、流量、路由等问题。
![服务网关](https://raw.githubusercontent.com/h428/img/master/note/00000073.jpg)

#### 1.2.2.4 服务容错

- 在微服务当中，一个请求经常会涉及到调用几个服务，如果其中某个服务不可用，没有做服务容错的话，极有可能会造成一连串的服务不可用，这就是雪崩效应。
- 我们没法预防雪崩效应的发生，只能尽可能去做好容错。服务容错的三个核心思想是：
    - 不被外界环境影响
    - 不被上游请求压垮
    - 不被下游响应拖垮
![服务容错](https://raw.githubusercontent.com/h428/img/master/note/00000074.jpg)

#### 1.2.2.5 链路追踪

- 随着微服务架构的流行，服务按照不同的维度进行拆分，一次请求往往需要涉及到多个服务。互联网应用构建在不同的软件模块集上，这些软件模块，有可能是由不同的团队开发、可能使用不同的编程语言来实现、有可能布在了几千台服务器，横跨多个不同的数据中心。因此，就需要对一次请求涉及的多个服务链路进行日志记录，性能监控即链路追踪
![链路追踪](https://raw.githubusercontent.com/h428/img/master/note/00000075.jpg)

### 1.2.3 微服务架构的常见解决方案

#### 1.2.3.1 ServiceComb

- Apache ServiceComb，前身是华为云的微服务引擎 CSE (Cloud Service Engine) 云服务，是全球首个Apache微服务顶级项目。它提供了一站式的微服务开源解决方案，致力于帮助企业、用户和开发者将企业应用轻松微服务化上云，并实现对微服务应用的高效运维管理。

#### 1.2.3.2 SpringCloud

- Spring Cloud是一系列框架的集合。它利用Spring Boot的开发便利性巧妙地简化了分布式系统基础设施的开发，如服务发现注册、配置中心、消息总线、负载均衡、断路器、数据监控等，都可以用Spring Boot的开发风格做到一键启动和部署。
- Spring Cloud并没有重复制造轮子，它只是将目前各家公司开发的比较成熟、经得起实际考验的服务框架组合起来，通过Spring Boot风格进行再封装屏蔽掉了复杂的配置和实现原理，最终给开发者留出了一套简单易懂、易部署和易维护的分布式系统开发工具包。

#### 1.2.3.3 SpringCloud Alibaba

- Spring Cloud Alibaba 致力于提供微服务开发的一站式解决方案。此项目包含开发分布式应用微服务的必需组件，方便开发者通过 Spring Cloud 编程模型轻松使用这些组件来开发分布式应用服务。

## 1.3 SpringCloud Alibaba 介绍

- Spring Cloud Alibaba 致力于提供微服务开发的一站式解决方案。此项目包含开发分布式应用微服务的必需组件，方便开发者通过 Spring Cloud 编程模型轻松使用这些组件来开发分布式应用服务。
- 依托 Spring Cloud Alibaba，您只需要添加一些注解和少量配置，就可以将 Spring Cloud 应用接入阿里微服务解决方案，通过阿里中间件来迅速搭建分布式应用系统。

### 1.3.1 主要功能

- 服务限流降级：默认支持 WebServlet、WebFlux， OpenFeign、RestTemplate、Spring CloudGateway， Zuul， Dubbo 和 RocketMQ 限流降级功能的接入，可以在运行时通过控制台实时修改限流降级规则，还支持查看限流降级 Metrics 监控。
- 服务注册与发现：适配 Spring Cloud 服务注册与发现标准，默认集成了 Ribbon 的支持。
- 分布式配置管理：支持分布式系统中的外部化配置，配置更改时自动刷新。
- 消息驱动能力：基于 Spring Cloud Stream 为微服务应用构建消息驱动能力。
- 分布式事务：使用 @GlobalTransactional 注解， 高效并且对业务零侵入地解决分布式事务问题。
- 阿里云对象存储：阿里云提供的海量、安全、低成本、高可靠的云存储服务。支持在任何应用、任何时间、任何地点存储和访问任意类型的数据。
- 分布式任务调度：提供秒级、精准、高可靠、高可用的定时（基于 Cron 表达式）任务调度服务。同时提供分布式的任务执行模型，如网格任务。网格任务支持海量子任务均匀分配到所有 Worker（schedulerx-client）上执行。
- 阿里云短信服务：覆盖全球的短信服务，友好、高效、智能的互联化通讯能力，帮助企业迅速搭建客户触达通道。

### 1.3.2 组件

- Sentinel：把流量作为切入点，从流量控制、熔断降级、系统负载保护等多个维度保护服务的稳定性。
- Nacos：一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。
- RocketMQ：一款开源的分布式消息系统，基于高可用分布式集群技术，提供低延时的、高可靠的消息发布与订阅服务。
- Dubbo：Apache Dubbo™ 是一款高性能 Java RPC 框架。
- Seata：阿里巴巴开源产品，一个易于使用的高性能微服务分布式事务解决方案。
- Alibaba Cloud ACM：一款在分布式架构环境中对应用配置进行集中管理和推送的应用配置中心产品。
- Alibaba Cloud OSS: 阿里云对象存储服务（Object Storage Service，简称 OSS），是阿里云提供的海量、安全、低成本、高可靠的云存储服务。您可以在任何应用、任何时间、任何地点存储和访问任意类型的数据。
- Alibaba Cloud SchedulerX: 阿里中间件团队开发的一款分布式任务调度产品，提供秒级、精准、高可靠、高可用的定时（基于 Cron 表达式）任务调度服务。
- Alibaba Cloud SMS: 覆盖全球的短信服务，友好、高效、智能的互联化通讯能力，帮助企业迅速搭建客户触达通道

# 2. 微服务环境搭建

- 我们本次是使用的电商项目中的商品、订单、用户为案例进行讲解。

## 2.1 案例准备

### 2.1.1 技术选型

- maven：3.3.9
- 数据库：MySQL 5.7
- 持久层: SpingData Jpa
- 其他: SpringCloud Alibaba 技术栈

### 2.1.2 模块设计

- springcloud-alibaba 父工程
- shop-common 公共模块【实体类】
- shop-user 用户微服务 【端口: 807x】
- shop-product 商品微服务 【端口: 808x】
- shop-order 订单微服务 【端口: 809x】
![模块设计](https://raw.githubusercontent.com/h428/img/master/note/00000076.jpg)

### 2.1.3 微服务调用

- 在微服务架构中，最常见的场景就是微服务之间的相互调用。我们以电商系统中常见的用户下单为例来演示微服务的调用：客户向订单微服务发起一个下单的请求，在进行保存订单之前需要调用商品微服务查询商品的信息。
- 我们一般把服务的主动调用方称为服务消费者，把服务的被调用方称为服务提供者。
- 在下面的场景下，订单微服务就是一个服务消费者， 商品微服务就是一个服务提供者。
![微服务调用](https://raw.githubusercontent.com/h428/img/master/note/00000077.jpg)

## 2.2 创建父工程

- 创建一个 maven 工程 springcloud-alibaba，然后在 pom.xml 文件中添加下面内容
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.itheima</groupId>
    <artifactId>springcloud-alibaba</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    <modules>
        <module>shop-common</module>
        <module>shop-user</module>
        <module>shop-product</module>
        <module>shop-order</module>
        <module>api-gateway</module>
    </modules>

    <!--父工程-->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.3.RELEASE</version>
    </parent>

    <!--依赖版本的锁定-->
    <properties>
        <java.version>1.8</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <spring-cloud.version>Greenwich.RELEASE</spring-cloud.version>
        <!--        <spring-cloud-alibaba.version>2.1.1.RELEASE</spring-cloud-alibaba.version>-->
        <spring-cloud-alibaba.version>2.1.0.RELEASE</spring-cloud-alibaba.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>${spring-cloud-alibaba.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>5.1.6</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```
- 版本对应：![版本对应](https://raw.githubusercontent.com/h428/img/master/note/00000078.jpg)

## 2.3 创建基础模块

- 创建 shop-common 模块，在 pom.xml 中添加依赖
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>springcloud-alibaba</artifactId>
        <groupId>com.itheima</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>shop-common</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.56</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
    </dependencies>
</project>
```
- 在 `com.itheima.domain` 下创建实体类 User、Product、Order
```java
//用户
@Entity(name = "shop_user")//实体类跟数据表的对应
@Data//不再去写set和get方法
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)//数据库自增
    private Integer uid;//主键
    private String username;//用户名
    private String password;//密码
    private String telephone;//手机号
}

//商品
@Entity(name = "shop_product")
@Data
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer pid;//主键

    private String pname;//商品名称
    private Double pprice;//商品价格
    private Integer stock;//库存
}

//订单
@Entity(name = "shop_order")
@Data
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long oid;//订单id

    //用户
    private Integer uid;//用户id
    private String username;//用户名

    //商品
    private Integer pid;//商品id
    private String pname;//商品名称
    private Double pprice;//商品单价

    //数量
    private Integer number;//购买数量
}
```

## 2.4 创建用户微服务

- 步骤:
    - 创建模块 导入依赖
    - 创建SpringBoot主类
    - 加入配置文件
    - 创建必要的接口和实现类(controller service dao)
- 新建一个 shop-user 模块并编写 pom.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>springcloud-alibaba</artifactId>
        <groupId>com.itheima</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>shop-user</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.itheima</groupId>
            <artifactId>shop-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

</project>
```
- 在 `com.itheima` 下编写主类 UserApplication
```java
@SpringBootApplication
@EnableDiscoveryClient
public class UserApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class);
    }
}
```
- 创建配置文件 application.yml：
```yml
server:
  port: 8071

spring:
  application:
    name: service-product
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql:///shop?
    serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8&useSSL=true
    username: root
    password: root
  jpa:
    properties:
      hibernate:
        hbm2ddl:
          auto: update
        dialect: org.hibernate.dialect.MySQL5InnoDBDialect
```

## 2.5 创建商品微服务

- 创建一个名为 shop_product 的模块，并添加依赖
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>springcloud-alibaba</artifactId>
        <groupId>com.itheima</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>shop-product</artifactId>

    <dependencies>

        <dependency>
            <groupId>com.itheima</groupId>
            <artifactId>shop-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

</project>
```
- 在 `com.itheima` 下创建主类：
```java
@SpringBootApplication
public class ProductApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductApplication.class, args);
    }
}
```
- 创建配置文件 application.yml
```yml
server:
  port: 8081
spring:
  application:
    name: service-product
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql:///shop?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8&useSSL=true
    username: root
    password: root
  jpa:
    properties:
      hibernate:
        hbm2ddl:
          auto: update
        dialect: org.hibernate.dialect.MySQL5InnoDBDialect
```
- 在 `com.itheima.dao` 下创建 ProductDao 接口
```java
public interface ProductDao extends JpaRepository<Product, Integer> {

}
```
- 在 `com.itheima.service` 下创建 ProductService 接口
```java
public interface ProductService {

    //根据pid查询商品信息
    Product findByPid(Integer pid);

    //扣减库存
    void reduceInventory(Integer pid, Integer number);
}
```
- 在 `com.itheima.service.impl` 下 ProdutServiceImpl 实现类
```java
@Service
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductDao productDao;

    @Override
    public Product findByPid(Integer pid) {
        return productDao.findById(pid).get();
    }

    @Transactional
    @Override
    public void reduceInventory(Integer pid, Integer number) {
        //查询
        Product product = productDao.findById(pid).get();
        //省略校验

        //内存中扣减
        product.setStock(product.getStock() - number);

        //模拟异常
        //int i = 1 / 0;

        //保存
        productDao.save(product);
    }
}
```

- 在 `com.itheima.controller` 下创建 ProductController
```java
@RestController
@Slf4j
public class ProductController {

    @Autowired
    private ProductService productService;

    @RequestMapping("/product/api1/demo1")
    public String demo1() {
        return "demo";
    }

    @RequestMapping("/product/api1/demo2")
    public String demo2() {
        return "demo";
    }

    @RequestMapping("/product/api2/demo1")
    public String demo3() {
        return "demo";
    }

    @RequestMapping("/product/api2/demo2")
    public String demo4() {
        return "demo";
    }

    //商品信息查询
    @RequestMapping("/product/{pid}")
    public Product product(@PathVariable("pid") Integer pid) {
        log.info("接下来要进行{}号商品信息的查询", pid);
        Product product = productService.findByPid(pid);
        log.info("商品信息查询成功,内容为{}", JSON.toJSONString(product));
        return product;
    }

    //扣减库存
    @RequestMapping("/product/reduceInventory")
    public void reduceInventory(Integer pid, Integer number) {
        productService.reduceInventory(pid, number);
    }
}
```
- 启动工程，等到数据库表创建完毕之后，加入测试数据
```sql
INSERT INTO shop_product VALUE(NULL,'小米','1000','5000');
INSERT INTO shop_product VALUE(NULL,'华为','2000','5000');
INSERT INTO shop_product VALUE(NULL,'苹果','3000','5000');
INSERT INTO shop_product VALUE(NULL,'OPPO','4000','5000');
```
- 然后访问查询数据

## 2.6 创建订单微服务

- 创建一个名为 shop-order 的模块，并添加 springboot 依赖
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>springcloud-alibaba</artifactId>
        <groupId>com.itheima</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>shop-order</artifactId>

    <dependencies>
        <!--springboot-web-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <!--shop-common-->
        <dependency>
            <groupId>com.itheima</groupId>
            <artifactId>shop-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

</project>
```

- 创建应用类 OrderApplication
```java

```