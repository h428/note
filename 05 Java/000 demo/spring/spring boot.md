
# 0. 概述

- Spring 1.x 时代，都是通过 xml 配置 Bean，随着项目的不断扩大，需要将 xml 配置到不同的配置文件中，需要频繁地在 java 类和 xml 配置文件中切换
- Spring 2.x 时代，由于 JDK 1.5 带来的注解支持，Spring 2.x 可以使用注解对 Bean 进行申明和注入，大大减少了 xml 配置和简化了项目开发，且经过多年的讨论和沉淀，总结出如下配置约定：
    - 应用的基本配置使用 xml，比如数据源，资源文件等
    - 业务开发使用注解，比如 Service 中注入 Bean 等
- Spring 3.x, Spring 4.x 时代，Spring 3.x 开始提供 JavaConfig 配置方式，Spring 4.x 增强和完善了 JavaConfig 配置，使用基于 JavaConfig 的配置可以更好地理解配置的 Bean，是 Spring 4.x 和 Spring Boot 推荐的配置方式


# 1. JavaConfig 配置

- Spring 推荐基于 JavaConfig 的配置使用注解来代替原有的 XML 文件，可以完全替代 XML 文件
- JavaConfig 主要通过 `@Configuration` 和 `@Bean` 两个注解实现的（最重要的）：
    - `@Configuration` 注解在 Java 类上，此时该 Java 类相当于一个 XML 文件
    - `@Bean` 作用在方法上，相当于 xml 中的 `<bean>` 元素
- 配合 `@PropertySource(value = "classpath:db.properties")` 和 `@Value("${jdbc.url")` 来完成对 properties 文件的读取
- 可以使用 `@ImportResource{"classpath:applicationContext-trans.xml"}` 注解引入 XML 配置，但大多情况下优先考虑使用 JavaConfig
- 样例
```java
@Configuration
@PropertySource(value = "classpath:db.properties")
public class DaoConfig {
    @Bean(name = "dataSource", initMethod = "init", destroyMethod = "close")
    @Lazy(false)
    public DataSource dataSource(@Value("${jdbc.driver}") String driver,
                                 @Value("${jdbc.url}") String url,
                                 @Value("${jdbc.username}") String username,
                                 @Value("${jdbc.password}") String password) {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        dataSource.setMaxActive(10);
        dataSource.setMinIdle(5);
        return dataSource;
    }
}
```

# 2. Spring Boot 入门样例

- 使用 Spring Boot 使用“约定由于配置”的理念，让项目快速运行起来，使得你可以快速构建项目而只需很少的的配置，可用于快速开发
- 设置 Spring Boot 的 parent，其内部定义了大量常用的 lib 的版本，我们只需导入所需依赖和启动器，无需管理版本

## 2.1 基于 @EnableAutoConfiguration 启动

- `@EnableAutoConfiguration` 注解用于开启 Spring Boot 的自动配置
- 编写 HelloController，添加上述注解，并添加 `@RestController` 注解将其作为一个控制器，然后从开控制器启动，Spring Boot 会进行自动配置
```java
@RestController
@EnableAutoConfiguration
public class HelloController {

    @GetMapping("show")
    public String test(){
        return "hello Spring Boot!";
    }

    public static void main(String[] args) {
        SpringApplication.run(HelloController.class, args);
    }
}
```
- 但如果有多个控制器，我们应该将 `@EnableAutoConfiguration` 抽取出来，然后统一配置一个扫描 controller 的路径，如下述引导启动类
```java
@EnableAutoConfiguration
@ComponentScan
public class TestApplication {

    public static void main(String[] args) {
        SpringApplication.run(TestApplication.class, args);
    }
}
```
- 这样，对于每个项目，我们只要添加 `@EnableAutoConfiguration` 即可启用启动配置，然后利用 `@ComponentScan` 将需要的 Bean 注入到 Spring 容器即可
- 但每次需要添加该两个注解有点麻烦，spring boot 提供了一个更优雅的注解 `@SpringBootApplication`，整合了这两个注解


## 2.2 基于 @SpringBootApplication 启动

- `@SpringBootApplication` 整合了 `@SpringBootConfiguration`, `@EnableAutoConfiguration`, `@ComponentScan` 注解，只要在配置类上添加该注解，则项目默认启用自动配置和路径下的相关类扫描，即变为一个 Spring Boot 项目
- Spring Boot 项目有一个入口类，一般命名为 XxxApplication，为其添加 `@SpringBootApplication` 注解
- 在该入口类的 main 方法
```java
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        // 入口类的 main 方法中必须包含该代码，以启动 SpringBoot 项目
        SpringApplication.run(DemoApplication.class, args);
    }
}
```
- 然后创建 web 包，并编写 HelloController
```java
@RestController
public class HelloController {
    @RequestMapping(value = "hello")
    public String hello() {
        return "Hello, World!";
    }
}
```
- 运行 DemoApplication 的 main 方法，访问 `http://localhost:8080/hello` 观察结果
- 若配置了 Spring Boot 的 maven 插件 `spring-boot-maven-plugin`，则也可以使用 maven 启动：`clean spring-boot:run`


# 3. Spring Boot 核心

## 3.1 入口类和 @SpringBootApplication

- Spring Boot 项目一般都会有一个名为 XxxApplication 的入口类，入口类中有 main 方法，其实标准 Java 应用程序的入口
- `@SpringBootApplication` 注解是 Spring Boot 的核心注解，其是一个组合注解，包含了一系列注解，例如 `@SpringBootConfiguration`, `@EnableAutoConfiguration`, `@ComponentScan` 等，而 `@SpringBootConfiguration` 也是一个组合注解，其内部就包括了 `@Configuration` 等注解，因此 `@SpringBootApplication` 注解包含了一堆功能
- Spring Boot 项目中推荐使用 `@SpringBootConfiguration` 替代 `@Configuration` 
- `@EnableAutoConfiguration` 开启自动配置，添加该注解后，Spring Boot 项目将根据项目引入的依赖执行自动配置，比如添加了 `spring-boot-starter-web` 依赖，则项目引入 Spring MVC，Spring Boot 就会自动配置 tomcat 和 SpringMVC
- `@SpringBootApplication` 包含 `@ComponentScan`，将导致 Spring Boot 扫描 XxxApplication 所在目录以及子目录

## 3.2 自动配置

### 3.2.1 @ConfigurationProperties 读取配置

- 在传统的 JavaConfig 中，配置使用 `@PropertySource` 和 `@Value` 读取 properties 中的配置，而在 SpringBoot 中提供了更加 `@ConfigurationProperties` 注解用于属性的读取，其支持各种java基本数据类型及复杂类型的注入
- 首先，使用 `@ConfigurationProperties` 定义一个属性读取类，属性类的前缀+字段要和配置文件中的保持一致，
```java
@ConfigurationProperties(prefix = "jdbc")
public class JdbcProperties {
    private String url;
    private String driverClassName;
    private String username;
    private String password;
    // ... 略
    // getters 和 setters
}
```
- 上述配置只是生命了一个配置读取类，其还没有被容器管理起来，因此，我们还需要在配置类中引用该属性读取类，则该属性读取类即可由容器管理起来，需要使用时则可以进行注入 :
```java
@Configuration
@EnableConfigurationProperties(JdbcProperties.class)
public class JdbcConfiguration {

    @Bean
    public DataSource dataSource(JdbcProperties jdbcProperties) {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setUrl(jdbcProperties.getUrl());
        dataSource.setDriverClassName(jdbcProperties.getDriverClassName());
        dataSource.setUsername(jdbcProperties.getUsername());
        dataSource.setPassword(jdbcProperties.getPassword());
        return dataSource;
    }
}
```
- Spring Boot 推荐使用 `@ConfigurationProperties` 替代 `@Value` 进行属性的读取，其具有下述优势 :
    - 松散绑定 : 不严格要求属性文件中的属性名与成员变量名一致。支持驼峰，中划线，下划线等等转换，甚至支持对象引导
    - 比如：user.friend.name：代表的是user对象中的friend属性中的name属性，显然friend也是对象。@value注解就难以完成这样的注入方式
    - meta-data support : 元数据支持，帮助 IDE 生成属性提示（写开源框架会用到），这就是为什么 application.properties 中有提示，Spring Boot 的自动配置都是通过该种方式读取的属性

**更优雅地属性读取**

- 可以直接在带 `@Bean` 之类的方法上添加 `@ConfigurationProperties(prefix = "jdbc")` 注解，只要名称保持一致，框架会自动将对应的属性通过 set 方法注入到 Bean 中

## 3.2.2 Spring Boot 的默认配置

- 我们已知，`@EnableAutoConfiguration` 会开启 SpringBoot 的自动配置，并根据你项目中引入的依赖来启用的默认配置，那默认配置是如何设置的，如何覆盖呢？
- Spring Boot 就是使用我们前面介绍过的属性读取类以及 `@EnableConfigurationProperties` 注解来定义可配置属性，相关的配置内容都在 spring-boot-autoconfigure，其内部自动配置了非常多内容
- 如果想取消自动配置而进行手动配置，则使用 `@SpringBootApplication` 注解的 exclude 属性，类名即为 spring-boot-autoconfigure 这个 jar 下的配置类 XxxAutoConfiguration
- Spring Boot 的自动配置一般涉及两个类 : XxxAutoConfiguration 和 XxxProperties
    - 其中 XxxProperties 就是属性读取类，其定义了属性的前缀、名称、默认值， application 中的配置则会覆盖该属性读取类的默认值
    - XxxAutoConfiguration 则是自动配置类，自动配置类使用条件注解进行自动化配置，此外还会有一个 `@EnableConfigurationProperties`  注解来读取属性读取类中的参数，自动配置使用到的相关配置即为使用该属性读取类中的内容
- 因此，如果需要覆盖自动配置，只需在 application 配置文件中进行配置即可

## 3.3 自定义 Banner

- 生成文本，将文本复制到 banner.txt，然后将该文件拷贝到 resources 下即可
- 若想禁用 Banner 输出，则使用代码进行关闭，参考下述代码
```java
@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
//        SpringApplication.run(DemoApplication.class, args);
        SpringApplication app = new SpringApplication(DemoApplication.class);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
    }
}
```

## 3.4 全局配置文件

- Spring Boot 项目使用一个全局的配置文件 application.properties 或者 application.yml，在 resources 下或在类路径的 /config 下，一般放在 resources 下
- `server.port=8088` : 更改 tomcat 端口为 8088，默认 8080
- Spring Boot 1 中，用 `​server.context-path` 配置项目的前缀，而 `server.servlet-path` 用于配置 DispatchServlet 的前后缀，其中 `server.servlet-path` 可以在 `​server.context-path` 的基础上进一步过滤
- Spring Boot 2.0 中，更名为 `server.servlet.context-path`，`server.servlet.path`，而且配置后缀无效（可能要在代码中设置），此外，在 2.1 之后移除 `server.servlet.path` 更名为 `spring.mvc.servlet.path`，同样只能设置前缀
- 配置静态资源目录 `spring.resources.static-locations=classpath:/META-INF/resources,classpath:/resources/,classpath:/static/,classpath:/public/`，不配置好像会默认放行
- 该文件包含了超多的全局设置，其他属性修改请谷歌或请查文档

## 3.5 日志

- 设置日志级别 `logging.level.org.springframework=DEBUG`
- 格式 `logging.level.*=...`


# 4. Spring Boot 自动配置

## 4.1 自动配置原理

> 使用 dependency:sources 下载项目中所有依赖包的源码

- Spring Boot 在进行 SpringApplication 对象实例化时会加载 spring-boot 依赖包下的 META-INF/spring.factories 文件，将该配置文件中的配置载入到 Spring 容器
- spring.factories 内部配置了很多内容，SpringApplication 执行时，会先调用其 initialize 方法，该方法通过 getSpringFactoriesInstances 方法获取 spring.factories 中所对应的实例，然后调用 setInitializers 方法将配置的内容设置到 Spring 容器中
- spring-boot-autoconfigure 下的 META-INF 也有 spring.factories 文件，也做了一系列自动配置类的声明，但这些自动配置不是直接启用的，而是有条件的
- 自动配置类中会使用一系列属性，这些属性一般放在同目录下的一个配置类中，他们的值可以在 application 文件中修改，此时自动配置类则会读取全局文件中的值并覆盖配置类的默认值
- 以 Redis 的自动配置为例
    - Redis 自动配置相关类在 spring-boot-autoconfigure 依赖包的 `org.springframework.boot.autoconfigure.data.redis` 包下
    - 首先 spring-boot-autoconfigure/META-INF/spring.factories 中声明了 redis 相关的自动配置类 `RedisAutoConfiguration`, `RedisRepositoriesAutoConfiguration` 
    - 这些配置类都带有条件注解，会自动根据项目是否包含了指定类而开启配置
    - 此外，部分配置类会额外抽象出一些可配置参数，这些参数可以在全局配置文件中进行配置和覆盖，例如 `RedisAutoConfiguration` 中引用了 `RedisProperties` 属性类，该属性定义一系列配置项，这些配置项和全局配置文件中的配置项是一一对应的

## 4.2 条件注解

- `@ConditionalOnClass`, `@ConditionalOnBean`, `@ConditionalOnExpression`
- 还有其他一系列条件注解

## 4.3 SpringMVC 的自动配置

- 在 `spring-boot-autoconfigure/org.springframework.boot.autoconfigure.web` 下
- `WebMvcAutoConfiguration` 做了和 SpringMVC 的相关配置
- 比如，其内部的 `defaultViewResolver` 方法配置了视图解析器 `InternalResourceViewResolver`
- `WebMvcProperties` 则抽象了一系列可配置属性（注意和 application.properties 中的命名可能不完全一致，有细微的差别，比如横线，但配置项在代码中肯定有对应内容的）



# 5. 配置

- 配置主要通过 `@Configuration` 和 `@Bean` 实现

## 5.1 Spring MVC 配置

- 配置内容其实和 XML 差不多，只不过改为 JavaConfig 形式

**消息转化器**

- 比如我要配置一个字符串的消息转化器处理中文乱码，只要在一个配置类内部添加下述代码
```java
    @Bean
    public StringHttpMessageConverter stringHttpMessageConverter() {
        StringHttpMessageConverter converter = new StringHttpMessageConverter(Charset.forName("UTF-8"));
        return converter;
    }
```
- 但实际上，Spring Boot 默认已经配置了 UTF-8 的消息转换器（也可能是通过过滤器处理的），即已经具备处理中文乱码的能力，因此上述内容可以不配置

**拦截器**

- 编写配置类并继承 `WebMvcConfigurerAdapter`，然后重写 addInterceptors 方法，自定义的拦截器必须实现 `HandlerInterceptor` 接口
```java
@SpringBootConfiguration
public class WebConfig extends WebMvcConfigurerAdapter {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 匿名内部类
        HandlerInterceptor handlerInterceptor = new HandlerInterceptor() {
            @Override
            public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
                System.out.println("进入自定义拦截器");
                return true;
            }

            @Override
            public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

            }

            @Override
            public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

            }
        };
        registry.addInterceptor(handlerInterceptor).addPathPatterns("/**");
    }

    // 另一种添加消息转化器的方法
    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        StringHttpMessageConverter converter = new StringHttpMessageConverter(Charset.forName("UTF-8"));
        converters.add(converter);
    }
}
```

# 9. 其他

## 9.1 日志

- 默认使用 logback 作为日志框架
- `logging.file=/logs/demo/aaaa.log` : 日志文件
- `logging.path=/logs/demo/` : 日志文件位置，不设置 `logging.file` 才生效，此时名称默认为 `spring.log`


