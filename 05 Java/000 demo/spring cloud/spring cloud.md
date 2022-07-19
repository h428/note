

# 1. 概述

## 1.1 简介

SpringCloud 是 Spring 旗下的项目之一，它将现在非常流行的一些技术整合到一起，实现了诸如：配置管理，服务发现，智能路由，负载均衡，熔断器，控制总线，集群状态等等功能，以提供完整的微服务解决方案。其主要涉及的组件包括：
- Eureka：服务治理组件，包含服务注册中心，服务注册与发现机制的实现。（服务治理，服务注册/发现） 
- Zuul：网关组件，提供智能路由，访问过滤功能 
- Ribbon：客户端负载均衡的服务调用组件（客户端负载） 
- Feign：服务调用，给予Ribbon和Hystrix的声明式服务调用组件 （声明式服务调用） 
- Hystrix：容错管理组件，实现断路器模式，帮助服务依赖中出现的延迟和为故障提供强大的容错能力。(熔断、断路器，容错) 

## 1.2 版本

- Spring Cloud 不同其他独立项目，它拥有很多子项目的大项目。所以它的版本是版本名+版本号 （如Angel.SR6）
- 版本名：是伦敦的地铁名  
- 版本号：SR（Service Releases）是固定的 ,大概意思是稳定版本。后面会有一个递增的数字。 
- 所以 Edgware.SR3就是Edgware的第3个Release版本
- 当确定大版本后，即确定该项目下各个组件的版本

# 2. Eureka 注册中心

- Spring Cloud 使用 Eureka 作为注册中心，负责管理、记录服务提供者的信息，服务调用者无需自己寻找服务，而是把自己的需求告诉 Eureka，然后 Eureka 会把符合你需求的服务告诉你
- 同时，服务提供方与 Eureka 之间通过“心跳”机制进行监控，当某个服务提供方出现问题， Eureka 自然会把它从服务列表中剔除
- 这就实现了服务的自动注册、发现、状态监控
- 心跳(续约)：提供者定期通过http方式向Eureka刷新自己的状态
- 下述 demo 主要包括三个项目：
    - 服务提供者 hao-service-provider
    - 服务消费者 hao-service-consumer
    - 注册中心 hao-eureka


## 2.1 注册中心 hao-eureka

**概述**

- 该项目主要用作注册中心，用于注册、发现、监控服务
- 基于 spring boot 构建项目，需要引入 eureka 的服务端依赖

**配置**

- 主要在 application.yml 中配置注册中心的服务端：
```yml
server:
  port: 10086 # 端口
spring:
  application:
    name: eureka-server # 应用名称，作为在 eureka 中的服务名
eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:${server.port}/eureka # 注册中心自己也作为一个服务注册到注册中心（集群时则注册到其他注册中心）
  server:
    eviction-interval-timer-in-ms: 10000 # 每 10 秒对无效服务进行剔除，生产环境不要修改
    enable-self-preservation: false # 关闭自我保护模式，防止不剔除服务，生产环境不要更改
```
- 然后配置 spring boot 的启动类，启用 eureka 服务端：
```java
@SpringBootApplication
@EnableEurekaServer // 声明当前 springboot 应用是一个 eureka server 注册中心
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

## 2.2 服务提供者 

**概述**

- 该项目为服务提供者，因此除了 spring boot 基本启动器外，还需要导入 jdbc, tk mybatis 启动器等
- 由于采用微服务架构，首先需要在 dependencyManagement 中事先设置 spring cloud 的版本，然后再确定引入需要的微服务组件，例如本例中需要引入 eureka 客户端以发布服务
- 然后就是项目架构：mapper 做基本 crud，service 层进行封装，controller 暴露 restful 接口以提供服务

**配置**

- 由于要连接数据库和注册中心，因此需要配置数据库和注册中心相关内容，直接配置在 application.yml 中
```yml
server:
  port: 8081 # 服务暴露的端口
spring:
  datasource: # 数据库配置
    url: jdbc:mysql://localhost:3306/maven
    username: root
    password: root
  application:
    name: service-provider # 应用名称，注册到 eureka 后作为服务名称，服务消费者也会用到
mybatis:
  type-aliases-package: com.hao.service.pojo

eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:10086/eureka # 注册中心地址，将服务注册到注册中心
  instance:
    prefer-ip-address: true # 使用 ip+端口 注册服务（访问的地址），否则默认使用 计算机名+端口
    lease-expiration-duration-in-seconds: 10 # 10 秒未收到心跳即过期
    lease-renewal-interval-in-seconds: 5 # 5 秒一次心跳
```
- 配置完注册中心后，要在配置类上启用 eureka 客户端：
```java
@SpringBootApplication
@EnableDiscoveryClient // eureka 客户端，将服务注册到注册中心或从注册中心拉取服务
public class ProviderApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProviderApplication.class, args);
    }
}
```

**代码**

- 主要包括 pojo, mapper, service, controller 层，其中 controller 暴露 restful 风格服务
- pojo : Admin 类
```java
@Data
public class Admin implements Serializable {
    @Id
    private Long id;
    private String userName;
    private String userPass;
    private Integer age;
    private Double height;
    private Integer type;
    private Date registerTime;
    private Date loginTime;
    private Boolean deleted;
}
```
- mapper : 基于通用 mapper 创建的 AdminMapper
```java
@org.apache.ibatis.annotations.Mapper
public interface AdminMapper extends Mapper<Admin> {
}
```
- service : 封装 mapper
```java
@Service
public class AdminService {
    @Autowired
    private AdminMapper adminMapper;

    public Admin queryById(Long id) {
        return this.adminMapper.selectByPrimaryKey(id);
    }
}
```
- controller : 暴露 restful 服务
```java
@RestController
@RequestMapping("admin")
public class AdminController {
    @Autowired
    private AdminService adminService;

    @GetMapping("{id}")
    public Admin queryById(@PathVariable("id") Long id) {
        return this.adminService.queryById(id);
    }
}
```

## 2.3 服务消费者

**概述**

- 服务消费者需要从注册中心拉取服务，因此同样依赖 eureka 客户端
- 该项目类似传统的 web 层，只不过服务是调用远程服务实现

**配置**

- 主要配置注册中心地址以拉取服务，在 application.yml 中配置
```yml
server:
  port: 80

spring:
  application:
    name: service-consumer # # 应用名称，注册到 eureka 后作为服务名称（虽然是消费者，但也可以发布服务）

eureka:
  client:
    registry-fetch-interval-seconds: 5 # 快速得到最新服务，生产环境则无需修改
    service-url:
      defaultZone: http://localhost:10086/eureka # 注册中心地址
  instance:
    prefer-ip-address: true
```
- 同样在配置类开启 eureka 客户端
```java
@SpringBootApplication
@EnableDiscoveryClient // eureka 客户端，将服务注册到注册中心或从注册中心拉取服务
public class ConsumerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }

    @Bean
    @LoadBalanced // 开启负载均衡（Ribbon）
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

**代码**

- 由于使用 restful 接口提供服务，不再存在接口的耦合，因此只需在 controller 中直接通过 restTemplate 调用服务即可，但仍然需要导入相关 pojo，其和服务提供者中的 pojo 保持一致
```java
@Controller
@RequestMapping("consumer/admin")
public class AdminController {

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping
    @ResponseBody
    public Admin queryUserById(@RequestParam("id") Long id){
        // 开启负载均衡后，不再手动获取ip和端口，而是直接通过服务名称调用
        String baseUrl = "http://service-provider/admin/" + id;
        Admin admin = this.restTemplate.getForObject(baseUrl, Admin.class);
        return admin;
    }
}
```

## 2.4 Eureka 详解

### 2.4.1 基础架构

- Eureka 架构中的三个核心角色：
- **服务注册中心**：Eureka 的服务端应用，提供服务注册和发现功能，就是刚刚我们建立的 hao-eureka
- **服务提供者**：提供服务的应用，可以是 SpringBoot 应用，也可以是其它任意技术实现，只要对外提供的是 Rest 风格服务即可，本例中就是我们实现的hao-service-provider
- **服务消费者**：消费应用从注册中心获取服务列表，从而得知每个服务方的信息，知道去哪里调用服务方，本例中就是我们实现的 hao-service-consumer
- 注意在 spring cloud 中，服务往往是以 http restful 形式发布的并使用 restTemplate 进行远程调用，因此实际上服务提供者和服务消费者之间的界限是很模糊的，因为实际上它们都是 webapp，都可以发布 restful 风格服务，都可以作为服务提供者，也都能拉取服务进行消费，在技术上它们是等价的（配置项会略有不同），因此我们所说的服务提供者和服务消费者都是基于相对逻辑的，即提供服务的 app 作为提供者，而调用服务的 app 作为消费者
- 此外，注册中心、服务提供者、服务消费者都会作为服务注册到注册中心，注册的服务名即为应用名，应用名使用 `spring.application.name` 配置

### 2.4.2 高可用的 Eureka Server（集群）

- Eureka Server 即服务的注册中心，其也可以是一个集群，形成高可用的 Eureka 中心
- 只有单个注册中心时，注册中心即将自己作为一个服务注册到自身，若是注册中心集群，则需要将注册中心的注册地址配置到其他注册中心节点，不同节点间会自动进行数据同步
- 多个 Eureka Server 之间也会互相注册为服务，当服务提供者注册到Eureka Server 集群中的某个节点时，该节点会把服务的信息同步给集群中的每个节点，从而实现**数据同步**
- 对服务提供者来说，配置注册中心时可以配置一个节点地址，然后利用注册中心的数据同步自动同步到其他节点，但这样就失去了高可用集群的意义，因为若你配置的这个节点正好挂了，该服务就无法完成注册，因此服务提供者需要统一配置所有注册中心进行注册以实现高可用
- 因此，无论客户端访问到 Eureka Server 集群中的任意一个节点，都可以获取到完整的服务列表信息

**测试**

- 在 hao-eureka 中添加 `server.port=10086` 和 `server.centerPort=10086` 两个配置项，前者为当前注册中心端口，后者为当前应用要注册到的注册中心端口（两个注册中心互相注册，构成集群）
- 然后分别以参数 `--server.port=10086 --server.centerPort=10087` 和 `--server.port=10087 --server.centerPort=10086` 运行两个 hao-eureka 实例，互相向对方注册以构成 eureka 集群
- 构成 eureka 集群后，服务提供者和服务消费者只需向其中一个节点即可，各个节点会自动进行同步，但为了高可用，还是需要配置所有的注册中心节点：
```yaml
eureka:
  client:
    service-url: # EurekaServer地址,多个地址以','隔开
      defaultZone: http://127.0.0.1:10086/eureka,http://127.0.0.1:10087/eureka
```

### 2.4.3 服务提供者

- 服务提供者要向 EurekaServer 注册服务，并且完成服务续约等工作

**服务注册**

- 服务提供者在启动时，会检测配置属性中的： `eureka.client.register-with-eureka=true` 参数是否正确，默认就是 true。如果值确实为 true，则会向 EurekaServer 发起一个 Rest 请求，并携带自己的元数据信息，Eureka Server 会把这些信息保存到一个双层 Map 结构中
- 第一层 Map 的 Key 是服务 id，一般是配置中的 `spring.application.name` 属性
- 第二层 Map 的 key 是服务的实例 id。一般为 host+ serviceId + port，例如： locahost:service-provider:8081
- 值则是服务的实例对象，也就是说一个服务，可以同时启动多个不同实例，形成集群

**服务续约**

- 成功注册服务以后，服务提供者会维持一个心跳（定时向 EurekaServer 发起 Rest 请求），告诉 EurekaServer：“我还活着”，该机制称为服务的续约（renew）
- 服务的续约主要涉及两个参数：
```yaml
eureka:
  instance:
    lease-expiration-duration-in-seconds: 90 # 服务失效时间，默认值 90 秒
    lease-renewal-interval-in-seconds: 30 # 服务续约(renew)的间隔，默认为 30 秒
```
- 也就是说，默认情况下每 30 秒服务会向注册中心发送一次心跳，证明自己还活着，如果超过 90 秒没有收到服务的心跳，EurekaServer 就会认为该服务宕机，会将服务从服务列表中移除，这两个值在生产环境不要修改，默认即可
- 但是在开发时，这个值有点太长了，经常我们关掉一个服务，会发现 Eureka 依然认为服务在活着，所以我们在开发阶段可以适当调小，例如分别设置为 10 秒和 5 秒

### 2.4.4 服务消费者

- 当服务消费者启动时，会检测 `eureka.client.fetch-registry=true` 参数的值，如果为true，则会拉取 Eureka Server 服务的列表只读备份，然后缓存在本地，并且默认每隔 30 秒会重新获取并更新数据，拉取间隔可以使用下述参数修改：
```yaml
eureka:
  client:
    registry-fetch-interval-seconds: 5
```
- 生产环境中，我们不需要修改这个值，但是为了开发环境下能够快速得到服务的最新状态，我们可以将其设置小一点

### 2.4.5 失效剔除和自我保护

**服务下线**

- 当服务进行正常关闭操作时，它会触发一个服务下线的 REST 请求给 Eureka Server，告诉服务注册中心：“我要下线了”
- 服务中心接受到请求之后，将该服务置为下线状态

**失效剔除**

- 服务提供方并不一定会正常下线，可能因为内存溢出、网络故障等原因导致服务无法正常工作。Eureka Server 需要将这样的服务剔除出服务列表。因此它会开启一个定时任务，每隔 60 秒对所有失效的服务（默认超过 90 秒未响应或没有心跳续约）进行剔除
- 可以通过 `eureka.server.eviction-interval-timer-in-ms` 参数对其进行修改，单位是毫秒，生产环境不要修改，开发环境则需要调小一点，否则每次重启服务都要 60 秒后注册中心才会对该失效服务进行剔除，对开发十分不方便，开发阶段可以适当调整，如 5000 ms

**自我保护**

- 默认情况下关停一个服务，就会在 Eureka 面板看到一条警告
- 当一个服务未按时进行心跳续约时，Eureka 会统计最近 15 分钟心跳失败的服务实例的比例是否超过了 85%。在生产环境下，因为网络延迟等原因，心跳失败实例的比例很有可能超标，但是此时就把服务剔除列表并不妥当，因为服务可能没有宕机
- 这种情况下 Eureka 就会把当前实例的注册信息保护起来，不予剔除（即自我保护），生产环境下这很有效，保证了大多数服务依然可用
- 但是这给我们的开发带来了麻烦， 因此开发阶段我们都会关闭自我保护模式
```yaml
eureka:
  server:
    enable-self-preservation: false # 关闭自我保护模式（缺省为打开）
    eviction-interval-timer-in-ms: 1000 # 扫描失效服务的间隔时间，即失效剔除时间（缺省为60*1000ms）
```

# 3. 负载均衡 Ribbon

- 调用服务最原始的方法，是通过 DiscoveryClient 实例来获取服务实例信息，然后获取 ip 和端口来访问
- 但是实际环境中，我们往往会开启很多个服务集群（例如 hao-service-provider 集群），此时我们获取的服务列表中就会有多个，到底该访问哪一个服务呢？
- 一般这种情况下我们就需要编写负载均衡算法，在多个实例列表中进行选择，但 Eureka 中已经帮我们集成了负载均衡组件：Ribbon，我们只需简单修改代码即可使用

## 3.1 样例

- 首先，开启两个 hao-service-provider 实例，他们占用不同的端口，但应用名（即服务名）保持相同并注册到注册中心中
- 服务消费方中无需额外配置，只需在 RestTemplate 的配置方法上添加 `@LoadBalanced` 注解即可：
```java
@Bean
@LoadBalanced // 开启负载均衡（Ribbon）
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```
- 调用服务时，不再通过手动获取 ip+端口 的方式调用，而是直接通过服务名称调用，负载均衡拦截器会自动将服务名称映射到不同的相对应的服务实例
```java
@GetMapping
@ResponseBody
public Admin queryUserById(@RequestParam("id") Long id){
    // 开启负载均衡后，不再手动获取ip和端口，而是直接通过服务名称调用
    String baseUrl = "http://service-provider/admin/" + id;
    Admin admin = this.restTemplate.getForObject(baseUrl, Admin.class);
    return admin;
}
```

## 3.2 分析

- 对于调用代码，一路往里跟踪，直至 `LoadBalancerInterceptor.intercept` 方法，在该方法内部对服务 id 做了处理，使用对应负载均衡算法拉取对应的具体服务实例并返回

## 3.3 负载均衡策略

- Ribbon 默认的负载均衡策略是简单的轮询
- 使用 `{服务名称}.ribbon.NFLoadBalancerRuleClassName` 配置负载均衡策略，值就是 IRule 接口实现类，例如 `com.netflix.loadbalancer.RandomRule` 为随机策略

# 4. Hystrix 熔断组件

## 4.1 简介

- 在微服务架构中，服务间调用关系错综复杂，一个请求，可能需要嵌套调用多个微服务接口，形成调用链路
- 此时，若底层某个微服务阻塞，上层的调用得不到响应，则 tomcat 的这个线程不会释放，于是越来越多的用户请求到来时，越来越多的线程被阻塞
- 服务器支持的线程和并发数有限，请求一直阻塞，会导致服务器资源耗尽，从而导致所有其它服务都不可用，形成雪崩效应
- Hystrix 是 Netflix 开源的一个延迟和容错库，用于隔离访问远程服务、第三方库，防止出现级联失败，Spring Cloud 采用 hystrix 进行服务熔断以避免雪崩问题
- Hystrix 通过线程隔离、服务熔断来解决雪崩问题

## 4.2 线程隔离与服务熔断

- Hystrix 为每个依赖服务调用（服务消费者方）分配一个小的线程池，用户的请求将不再直接访问服务，而是通过线程池中的空闲线程来访问服务，如果线程池已满，或者请求超时，则会进行降级处理，调用对应的降级逻辑（注意服务熔断也有对应的降级逻辑，有了降级逻辑的服务熔断触发后，也可以看作是主动停用的服务降级，它们的效果是等价的）
- 调用降级逻辑虽然会导致请求失败，但是不会导致阻塞，而且最多会影响这个依赖服务对应的线程池中的资源，对其它服务没有影响

**熔断原理**

- 熔断状态机 3 个状态：
- Closed：关闭状态，所有请求都正常访问。
- Open：打开状态，所有请求都会被降级。Hystix 会对请求情况计数，当一定时间内失败请求百分比达到阈值，则触发熔断，断路器会完全打开。默认失败比例的阈值是 50%，请求次数最少不低于 20 次，该状态下目标服务将不可用
- Half Open：半开状态，open 状态不是永久的，打开后会进入休眠时间（默认是 5S）。随后断路器会自动进入半开状态。此时会释放部分请求通过，若这些请求都是健康的，则会完全关闭断路器，否则继续保持打开，再次进行休眠计时

## 4.3 样例

- 熔断主要在服务消费方配置，因此在 hao-service-consumer 引入 hystrix 依赖（我的好像不用额外引入）
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
</dependency>
```
- 然后在服务消费方使用注解 `@EnableCircuitBreaker` 开启熔断器组件，而 `@SpringCloudApplication` 是一个组合注解，组合了我们目前用到的微服务最常用的三个注解，因此我们直接使用 `@SpringCloudApplication`
```java
//@SpringBootApplication
//@EnableDiscoveryClient // 开启Eureka客户端
//@EnableCircuitBreaker // 开启熔断器
@SpringCloudApplication // 组合注解，整合了前面三个注解
public class ConsumerApplication {
    ...
}
```
- 编写降级逻辑，并使用 `@HystrixCommand` 注解声明要服务失败后的降级逻辑（因为熔断的降级逻辑方法必须跟正常逻辑方法保证具有相同的参数列表和返回值声明，而失败逻辑中返回 User 对象没有太大意义，一般会返回友好提示，因此我们把 queryById 的方法改造为返回 String，反正也是 Json 数据。这样失败逻辑中返回一个错误说明，会比较方便），修改后的 AdminController 如下
```java
@Controller
@RequestMapping("consumer/admin")
public class AdminController {

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping
    @ResponseBody
    @HystrixCommand(fallbackMethod = "queryUserByIdFallBack") // 声明降级逻辑处理方法
    public String queryUserById(@RequestParam("id") Long id){
        // 开启负载均衡后，不再手动获取ip和端口，而是直接通过服务名称调用
        String baseUrl = "http://service-provider/admin/" + id;
        return this.restTemplate.getForObject(baseUrl, String.class);
    }

    // 定义降级逻辑，注意参数列表和返回类型要和源方法保持一致
    public String queryUserByIdFallBack(Long id){
        return "请求繁忙，请稍后再试！";
    }
}
```
- `@HystrixCommand(fallbackMethod = "queryByIdFallBack")` 用来声明一个降级逻辑的方法，hao-service-provder 正常提供服务时，访问与以前一致。但是当我们将 hao-service-provider 停机时，会发现页面返回了降级处理信息

## 4.4 默认降级逻辑方法

- 前面将 fallback 写在了某个业务方法上，如果这样的方法很多，将会十分繁琐，需要编写很多降级方法，此时可以将 fallback 配置加在类上，并定义一个默认降级方法进行处理
- 首先使用 `@DefaultProperties` 注解在类上声明默认降级逻辑
```java
@DefaultProperties(defaultFallback = "fallBackMethod") // 指定一个类的全局熔断方法
public class AdminController {

    ...

    /**
     * 熔断方法
     * 返回值要和被熔断的方法的返回值一致
     * 熔断方法不需要参数
     *
     * @return 提示消息
     */
    public String fallBackMethod() {
        return "请求繁忙，请稍后再试！（默认 fallBack）";
    }
}
```
- 对于需要降级逻辑的方法，仍然需要添加 `@HystrixCommand` 注解，但可以不用再指定降级逻辑，此时会自动使用默认的降级逻辑
- 但要注意默认降级方法，不需要任何参数，以匹配更多方法，但是返回值一定一致（一般是 String，也就是该类下的所有需要降级逻辑的方法的返回值类型都是 String）

## 4.5 补充配置

- 超市时长：Hystrix 的默认超时时长为 1 秒，我们可以通过属性 `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds` 修改这个值，该配置无提示
```yml
hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 6000 # 设置 hystrix 的超时时间为 6000 ms
```
- 熔断触发条件：默认的熔断触发要求较高，休眠时间窗较短，为了测试方便，我们可以通过下述配置修改熔断策略
```yml
hystrix:
  command:
    default:
      circuitBreaker:
        requestVolumeThreshold: 10 # 触发熔断的最小请求次数，默认 20
        errorThresholdPercentage: 50 # 触发熔断的失败请求最小占比，默认 50%
        sleepWindowInMilliseconds: 10000 # 休眠时长，默认是 5000 毫秒
```
- 我们可以修改服务逻辑，让指定请求发生异常，已测试熔断器的触发，例如将逻辑修改为：
```java
    @GetMapping
    @ResponseBody
    @HystrixCommand // 仍然需要在方法上添加该注解
    public String queryUserById(@RequestParam("id") Long id) {

        if (id.equals(1L)) {
            // 抛出异常
            throw new RuntimeException("超时异常");
        }

        // 开启负载均衡后，不再手动获取ip和端口，而是直接通过服务名称调用
        String baseUrl = "http://service-provider/admin/" + id;
        return this.restTemplate.getForObject(baseUrl, String.class);
    }
```
- 先做一次 `http://192.168.25.1/consumer/admin?id=2` 请求验证服务正常访问，然后做 9 次 `http://192.168.25.1/consumer/admin?id=1` 请求发生异常，此时 10 次 9 次发生异常，触发熔断，再访问 `http://192.168.25.1/consumer/admin?id=2` 验证其已经执行降级逻辑，说明服务熔断


# 5. Feign

- 在前面的介绍中，我们使用负载均衡组件 Ribbon，大大简化了远程调用时的代码，此时，几乎每次调用的地方都会存在类似下面的调用代码，格式基本相同，无非参数不一样
```java
String user = this.restTemplate.getForObject("http://service-provider/user/" + id, String.class);
```
- 而使用 Feign 可以隐藏这些 Rest 请求，将这些请求快速封装成接口，让上层调用就好像在在调用本项目中的方法一样
- 

## 5.1 样例

- 首先在需要调用服务的消费端引入 Feign 的依赖
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```
- 在配置类上使用 `@EnableFeignClients` 注解开启 Feign，由于 Feign 已经自动集成了负载均衡 Ribbon 的 RestTemplate，因此不必再定义该 Bean，配置类修改为如下：
```java
@SpringCloudApplication // 组合注解，整合了前面三个注解
@EnableFeignClients // 开启feign客户端
public class ConsumerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }
}
```
- 然后创建客户端代理接口，并配置方法对应的 restful api 地址
```java
@FeignClient(value = "service-provider") // 标注该类是一个feign接口
public interface AdminClient {
    // 代理方法，feign 会自动根据服务名和路径自动请求，并转化结果
    @GetMapping("admin/{id}")
    Admin queryById(@PathVariable("id") Long id);
}
```
- 客户端 Controller 直接注入客户端接口并通过接口调用方法即可，Feign 会自动将方法调用转化为 rest 请求
```java
@Controller
@RequestMapping("consumer/admin")
public class AdminController {

    @Autowired
    AdminClient adminClient;

    @GetMapping
    @ResponseBody
//    @HystrixCommand // 仍然需要在方法上添加该
    public Admin queryUserById(@RequestParam("id") Long id) {
        // 使用 client 接口进行调用，就好像调用本地方法一样，Feign 会自动转化为 http 调用（且自动集成了负载均衡）
        return adminClient.queryById(id);
    }
}
```
- 启动服务，测试即可



## 5.2 集成 Hystrix

- 仍然可以和之前对 Hystrix 的配置一样，对客户端的 controller 调用处添加降级逻辑
- 但 Feign 已经集成了 Hystrix，但默认情况下是关闭的，需要手动开启它：
```yml
feign:
  hystrix:
    enabled: true # 开启Feign的熔断功能
```
- 但对于 feign 还可以单独对所有调用方法配置降级逻辑，我们可以定义降级逻辑实现类，其实现客户端代理接口，当接口的方法调用失败或超时时，feign 会自动调用降级逻辑实现类中的相同方法来执行降级逻辑
```java
// 降级逻辑实现类，当 AdminClient 接口中的 restful api 请求异常或超时时，会调用该对象中的方法来执行降级逻辑
@Component // 注意要由 Spring 管理起来
public class AdminClientFallback implements AdminClient {

    // 降级逻辑方法，和客户端代理类中的请求方法一一对应
    @Override
    public Admin queryById(Long id) {
        Admin admin = new Admin();
        admin.setUserName("网络拥挤");
        return admin;
    }
}
```
- Feign 使用接口实现的降级逻辑具有较高的优先级，当 Feign 处理完毕后，上层自然捕捉不到异常，也不会超时，因此上层的降级逻辑不生效
- 目前来看，如果针对简单请求，统一在 Controller 层处理是可取的，但若方法调用了多个服务进行处理，则降级逻辑放在 Feign 上处理也是可以的，需要根据实际自己斟酌
- 但我觉得统一放在 controller 中处理比较好，因为底层部分服务不可用，必然导致上传服务不可用或部分失效，此时直接在最顶层添加降级逻辑其实是比较合理的，而且在 controller 中可以统一返回 ResponseEntity 更加适合使用通用的默认方法和提示


## 5.3 补充配置

**请求压缩**

- Spring Cloud Feign 支持对请求和响应进行GZIP压缩，以减少通信过程中的性能损耗。通过下面的参数即可开启请求与响应的压缩功能：
```yml
feign:
  compression:
    request:
      enabled: true # 开启请求压缩
    response:
      enabled: true # 开启响应压缩
```
- 也可以对请求的数据类型，以及触发压缩的大小下限进行设置：
```yml
feign:
  compression:
    request:
      enabled: true # 开启请求压缩
      mime-types: text/html,application/xml,application/json # 设置压缩的数据类型
      min-request-size: 2048 # 设置触发压缩的大小下限
```
- 注：上面的数据类型、压缩大小下限均为默认值

**日志级别**

- spring boot 过 `logging.level.xx=debug` 来设置日志级别
- 然而这个对 Fegin 客户端而言不会产生效果。因为 `@FeignClient` 注解修改的客户端在被代理时，都会创建一个新的 `Fegin.Logger` 实例，我们需要额外指定这个日志的级别才可以
- 设置 `com.hao` 包下的日志级别都为 debug
```yml
logging:
  level:
    com.hao: debug
```
- 自定义日志配置类
```java
@Configuration
public class FeignLogConfiguration {

    @Bean
    Logger.Level feignLoggerLevel(){
        return Logger.Level.FULL;
    }
}
```
- 里指定的 Level 级别是 FULL，Feign 支持 4 种级别：
    - NONE：不记录任何日志信息，这是默认值
    - BASIC：仅记录请求的方法，URL 以及响应状态码和执行时间
    - HEADERS：在 BASIC 的基础上，额外记录了请求和响应的头信息
    - FULL：记录所有请求和响应的明细，包括头信息、请求体、元数据
- 在 FeignClient 中指定配置类：
```java
@FeignClient(value = "service-privider", fallback = AdminClientFallback.class, configuration = FeignConfig.class)
public interface AdminClient {
    @GetMapping("/admin/{id}")
    Admin queryAdminById(@PathVariable("id") Long id);
}
```
- 重启项目检查配置是否成功

# 6. Zuul 网关

- 在前面的介绍中，我们使用 Spring Cloud Netflix 中的 Eureka 实现了服务注册中心以及服务注册与发现；而服务间通过 Ribbon 或 Feign 实现服务的消费以及均衡负载；为了使得服务集群更为健壮，使用 Hystrix 的熔断机制来避免在微服务架构中个别服务出现异常时引起的故障蔓延
- 在该架构中，我们的服务集群包含：内部服务 Service A 和 Service B，他们都会注册与订阅服务至 Eureka Server，而 Open Service 是一个对外的服务，通过均衡负载公开至服务调用方；我们把焦点聚集在对外服务这块，直接暴露我们的服务地址，这样的实现是否合理，或者是否有更好的实现方式呢？
- 先说说目前这种架构可能导致的问题：
    - 破坏了服务无状态特点：为了保证对外服务的安全性，我们需要实现对服务访问的权限控制，而开放服务的权限控制机制将会贯穿并污染整个开放服务的业务逻辑，这会带来的最直接问题是，破坏了服务集群中REST API无状态的特点。从具体开发和测试的角度来说，在工作中除了要考虑实际的业务逻辑之外，还需要额外考虑对接口访问的控制处理。
    - 无法直接复用既有接口：当我们需要对一个即有的集群内访问接口，实现外部服务访问时，我们不得不通过在原有接口上增加校验逻辑，或增加一个代理调用来实现权限控制，无法直接复用原有的接口
- 而解决办法就是，使用**服务网关**
- 为了解决前述问题，我们需要将权限控制这样的东西从我们的服务单元中抽离出去，而最适合这些逻辑的地方就是处于对外访问最前端的地方，我们需要一个更强大一些的均衡负载器的服务网关
- 服务网关是微服务架构中一个不可或缺的部分。通过服务网关统一向外系统提供 REST API 的过程中，除了具备服务路由、均衡负载功能之外，它还具备了权限控制等功能；Spring Cloud Netflix 中的 Zuul 就担任了这样的一个角色，为微服务架构提供了前门保护的作用，同时将权限控制这些较重的非业务逻辑内容迁移到服务路由层面，使得服务集群主体能够具备更高的可复用性和可测试性

## 6.1 简介

- Zuul 是 Netflix 开源的微服务网关，它可以和 Eureka, Ribbon, Hystrix 等组件配合使用
- Zuul 的核心是一系列过滤器
    - 身份认证和安全：识别每个资源的验证要求，并拒绝那些与要求不符的请求。
    - 审查与监控：在边缘位置追踪有意义的数据和统计结果，从而带来精确的生产视图。
    - 动态路由：动态地将请求路由到不同的后端集群。
    - 压力测试：逐渐增加指向集群的流量，以了解性能。
    - 负责分配：为每一种负载类型分配对应容量，并弃用超出限定值的请求。
    - 静态响应处理：在边缘位置直接建立部分响应，避免其转发到内部集群。
    - 多区域弹性：跨越AWS Region进行请求路由，旨在实现ELB（Elastic Load Blancing）使用的多样化，以及让系统的边缘更贴近系统的使用者。
- Spring Cloud 对 Zuul 进行了整合与增强。目前，Zuul 使用默认 HTTP 客户端是 Apache HTTP Client，也可使用 RestClient 或okhttp3.OkHttpClient
- 如果想要使用 RestClient，可以设置 `ribbon .restclient.enabled=true`
- 想要使用 okhttp3.OkHttpClient，可以设置 `ribbon.okhttp.enabled=true`
- 不管是来自于客户端（PC或移动端）的请求，还是服务内部调用。一切对服务的请求都会经过 Zuul 这个网关，然后再由网关来实现 鉴权、动态路由等等操作。Zuul 就是我们服务的统一入口

## 6.2 样例

**入门配置**

- 新建工程 hao-api-gateway 作为服务网关，依赖参考笔记底部
- 创建配置类 `com.hao.api.gateway.ApiGatewayApplication`，启用 Zuul
```java
@SpringBootApplication
@EnableZuulProxy // 开启 Zuul 网关功能
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```
- 配置 application.yml，根据服务进行路由，这里对应的地址暂时是写死的，后面要自动根据服务名从 eureka 拉取对应服务
```yml
server:
  port: 10010 #服务端口
spring:
  application:
    name: api-gateway #指定服务名
zuul:
  routes:
    service-provider: # 这里是路由id，随意写
      path: /service-provider/** # 这里是映射路径
      url: http://127.0.0.1:8081 # 映射路径对应的实际url地址
```
- 启动项目，以 `/service-provider/**` 开头访问，验证能否成功路由到 `http://127.0.0.1:8081` 对应地址

**面向服务的路由（简化路由规则）**

- 在前面配置的路由规则中，我们把路径对应的服务地址写死了！如果同一服务有多个实例的话，这样做显然就不合理了
- 正确的做法是：我们应该根据服务的名称，去 Eureka 注册中心查找 服务对应的所有实例列表，然后进行动态路由才对
- 首先在前面的基础上引入 Eureka Client 依赖，然后添加 Eureka 客户端相关配置：
```yml
eureka:
  client:
    registry-fetch-interval-seconds: 5 # 获取服务列表的周期：5s
    service-url:
      defaultZone: http://127.0.0.1:10086/eureka # Eureka Server 地址
```
- 修改配置类，启用 Zuul 网关和 Eureka 客户端：
```java
@SpringBootApplication
@EnableDiscoveryClient // Eureka 客户端
@EnableZuulProxy // 开启 Zuul 网关功能
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```
- 修改路由规则，不再直接写死地址，而是根据服务名称来访问
```yml
zuul:
  routes:
    service-provider: # 这里是路由id，随意写（表示一个路由配置项。一般和服务名保持一致）
      path: /service-provider/** # 这里是映射路径
      serviceId: service-provider # 指定服务名称
```
- 并且一般来说，配置项的路由 id 会和服务名保持一致，因此 Zuul 提供了更简洁的语法，让你可以省略服务名称，直接在路由配置项后编写对应的 url 即可，如下述配置，service-provider 同时表示路由配置项的 id 和服务名称：
```yml
zuul:
  routes:
    service-provider: /service-provider/** # 这里是映射路径
```
- 重启项目，然后访问 `http://localhost:10010/service-provider/admin/1` 查看结果

**默认的路由规则**

- 在使用 Zuul 的过程中，上面讲述的规则已经大大的简化了配置项，但是当服务较多时，配置也是比较繁琐的
- Zuul 其实有默认的路由规则：默认情况下，一切服务的映射路径就是服务名本身，例如服务名为：service-provider，则默认的映射路径就是：/service-provider/**，也就是说，我们前面的配置可以省略掉
- 我们可以通过另一个服务 service-consumer 来验证这一点，我们目前为止并没有配置和 service-consumer 服务相关的路由，但我们通过网关访问相关的服务：`http://localhost:10010/service-consumer/consumer/admin?id=1` 验证结果，可以看到结果生效，也就是说默认的路由规则是有用的
- 建议采用默认的路由规则而省去繁琐的配置，直接通过服务名进行路由，将不同的路径转发到不同的服务

**路由前缀**

- 一般对于服务，我们最好配置统一的前缀，以区别于普通的请求，最常用的就是以 `/api/` 为前缀，如下述配置：
```yml
zuul:
  routes:
    service-provider: /service-provider/**
    service-consumer: /service-consumer/**
  prefix: /api # 添加路由前缀
```

## 6.3 过滤器

- Zuul 作为网关的其中一个重要功能，就是实现请求的鉴权，而这个动作我们往往是通过 Zuul 提供的过滤器来实现的
- 常用场景：
    - 请求鉴权：一般放在pre类型，如果发现没有访问权限，直接就拦截了
    - 异常处理：一般会在error类型和post类型过滤器中结合来处理。
    - 服务调用时长统计：pre和post结合使用

### 6.3.1 ZuulFilter

- ZuulFilter 是过滤器的顶级父类，在这里我们看一下其中定义的 4 个最重要的方法：
```java
public abstract ZuulFilter implements IZuulFilter{
    abstract public String filterType();
    abstract public int filterOrder();
    boolean shouldFilter();// 来自IZuulFilter
    Object run() throws ZuulException;// IZuulFilter
}
```
- shouldFilter：返回一个Boolean值，判断该过滤器是否需要执行。返回true执行，返回false不执行。
- run：过滤器的具体业务逻辑。
- filterType：返回字符串，代表过滤器的类型。包含以下4种：
  - pre：请求在被路由之前执行
  - route：在路由请求时调用
  - post：在 route 和 errror 过滤器之后调用
  - error：处理请求时发生错误调用
- filterOrder：通过返回的 int 值来定义过滤器的执行顺序，数字越小优先级越高

### 6.3.2 过滤器流程

**正常流程**

- 请求到达首先会经过 pre 类型过滤器，而后到达 route 类型，进行路由，请求就到达真正的服务提供者，执行请求，返回结果后，会到达 post 过滤器。而后返回响应

**异常流程**

- 整个过程中，pre 或者 route 过滤器出现异常，都会直接进入 error 过滤器，在 error 处理完毕后，会将请求交给 post 过滤器，最后返回给用户。
- 如果是 error 过滤器自己出现异常，最终也会进入 post 过滤器，将最终结果返回给请求客户端
- 如果是 post 过滤器出现异常，会跳转到 error 过滤器，但是与 pre 和 route 不同的是，请求不会再到达 post 过滤器了

### 6.3.3 样例

- 自定义一个过滤器，模拟一个登录的校验。基本逻辑：如果请求中有 access-token 参数，则认为请求有效，放行，否则拦截
```java
@Component
public class LoginFilter extends ZuulFilter {
    /**
     * 过滤器类型，前置过滤器
     *
     * @return
     */
    @Override
    public String filterType() {
        return "pre";
    }

    /**
     * 过滤器的执行顺序
     *
     * @return
     */
    @Override
    public int filterOrder() {
        return 1;
    }

    /**
     * 该过滤器是否生效
     *
     * @return
     */
    @Override
    public boolean shouldFilter() {
        return true;
    }

    /**
     * 登陆校验逻辑
     *
     * @return
     * @throws ZuulException
     */
    @Override
    public Object run() throws ZuulException {
        // 获取zuul提供的上下文对象
        RequestContext context = RequestContext.getCurrentContext();
        // 从上下文对象中获取请求对象
        HttpServletRequest request = context.getRequest();
        // 获取token信息
        String token = request.getParameter("access-token");
        // 判断
        if (StringUtils.isBlank(token)) {
            // 过滤该请求，不对其进行路由
            context.setSendZuulResponse(false);
            // 设置响应状态码，401
            context.setResponseStatusCode(HttpStatus.SC_UNAUTHORIZED);
            // 设置响应信息
            context.setResponseBody("{\"status\":\"401\", \"text\":\"request error!\"}");
        }
        // 校验通过，把登陆信息放入上下文信息，继续向后执行
        context.set("token", token);
        return null;
    }
}
```
- 定义完过滤器并由 Spring 容器管理即可，无需额外配置

### 6.3.4 负载均衡和熔断

- Zuul 中默认就已经集成了 Ribbon 负载均衡和 Hystix 熔断机制。但是所有的超时策略都是走的默认值，比如熔断超时时间只有 1S，很容易就触发了。因此建议我们手动进行配置：
```yml
hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 2000 # 设置hystrix的超时时间为6000ms
```



# 9. 补充

## 9.1 服务降级与服务熔断的区别

- [参考1](https://blog.csdn.net/guwei9111986/article/details/51649240), [参考2](https://www.cnblogs.com/rjzheng/p/10340176.html)
- 后续内容为个人看法总结，网络上也没个明确概念，看法不一

**服务熔断**

1. 服务熔断（往往是故障引起的）：当下游的服务因为某种原因（网络超时、持续发生异常等）突然变得不可用或响应过慢，上游服务为了保证自己整体服务的可用性，不再继续调用目标服务，直接返回，快速释放资源，如果目标服务情况好转则恢复调用
2. 服务熔断更像是一种框架或组件自带的保护机制，防止部分服务出现问题从而导致整个系统雪崩
3. 可以编写降级逻辑但不是必须，这是和服务降级比较不同的处理（连接超时的异常处理也可以看作是一种降级逻辑）
4. 只要涉及服务调用其他服务，基本都需要服务熔断机制，以确保调用的高可用以及避免服务雪崩

**服务降级**

1. 服务降级（往往是总体负荷不足）：在服务器压力陡增的情况下，利用有限资源，根据当前业务情况，关闭某些服务接口或者页面，以此释放服务器资源以保证核心任务的正常运行
2. 相比服务熔断的保护机制，服务降级更像是一种针对实际需求作出的架构策略，根据业务并发的可预测性来主动停用或关闭相关接口
3. 由于是主动停用，进行服务降级的服务往往需要编写对应的降级逻辑，以在下游服务停用时能调用对应的降级逻辑
4. 服务降级是策略上的东西，一般在上层服务处理，主动停用这些上层非核心服务，转去执行对应的较为简单的降级逻辑，以释放一定资源让核心服务得到更多资源


**对比**

- 原因不同：服务熔断往往是故障（也有可能是超负荷，但超负荷时就应该进一步考虑进行服务降级处理了）而产生的保护机制来避免服务雪崩；而服务降级则是考虑全局负荷，在资源不足的情况下，主动停用非核心的服务
- 服务降级必定要提供对应的降级逻辑以在主动停用服务时调用；而服务熔断可以不提供降级逻辑，可以在发生错误后排查问题（例如网络问题）后利用熔断机制具有自恢复的特点来恢复服务
- 服务熔断是框架提供的保护机制，服务降级更像是一种架构策略，在技术上基本区别不大，都可以在服务不可用时编写降级逻辑，例如 Hystrix 同时提供了熔断机制和降级逻辑





## 9.9 依赖

- hao-eureka 的 pom 文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.hao</groupId>
    <artifactId>hao-eureka</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>hao-eureka</name>
    <description>Demo project for Spring Boot</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.6.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
        <spring-cloud.version>Finchley.SR3</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.SR3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```

- hao-service-provider 的 pom 文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.hao</groupId>
    <artifactId>hao-service-provider</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>hao-service-provider</name>
    <description>Demo project for Spring Boot</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.6.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>1.3.2</version>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <!-- 需要手动引入通用mapper的启动器，spring没有收录该依赖 -->
        <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper-spring-boot-starter</artifactId>
            <version>2.0.4</version>
        </dependency>

        <!-- Lombok Begin -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
            <scope>provided</scope>
        </dependency>
        <!-- Lombok End -->

        <!-- Eureka客户端 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.SR3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```
- hao-service-consumer 的 pom 文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.hao</groupId>
    <artifactId>hao-service-consumer</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>hao-service-consumer</name>
    <description>Demo project for Spring Boot</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.4.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- Lombok Begin -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
            <scope>provided</scope>
        </dependency>
        <!-- Lombok End -->
        <!-- Eureka客户端 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!--<dependency>-->
            <!--<groupId>org.springframework.cloud</groupId>-->
            <!--<artifactId>spring-cloud-starter-netflix-hystrix</artifactId>-->
        <!--</dependency>-->

        <!--<dependency>-->
            <!--<groupId>org.springframework.cloud</groupId>-->
            <!--<artifactId>spring-cloud-starter-openfeign</artifactId>-->
        <!--</dependency>-->
    </dependencies>

    <!-- SpringCloud的依赖 -->
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.SR3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```
- hao-api-gateway 的 pom 文件：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.hao</groupId>
    <artifactId>hao-api-gateway</artifactId>
    <version>0.0.1-SNAPSHOT</version>


    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.4.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Begin -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <!-- Spring Boot End -->

        <!-- Lombok Begin -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
            <scope>provided</scope>
        </dependency>
        <!-- Lombok End -->

        <!-- Zuul Begin-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
        </dependency>
        <!-- Zuul End-->

        <!-- Eureka Client Begin -->
        <!--<dependency>-->
            <!--<groupId>org.springframework.cloud</groupId>-->
            <!--<artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>-->
        <!--</dependency>-->
        <!-- Eureka Client End -->

    </dependencies>

    <!-- SpringCloud Management -->
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.SR3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

