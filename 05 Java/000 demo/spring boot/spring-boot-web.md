

# 概述

- spring-boot-web 为基于 Spring Boot 构建的 Web 工程 demo，参考自 Spring Boot 的 [官方 Guide](https://spring.io/guides/gs/rest-service/)


# 依赖


- 要使用 Spring Boot 工程，首先需要统一依赖一个 Spring Boot 的 parent 工程，例如下述配置：
```xml
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>2.1.13.RELEASE</version>
  <relativePath/> <!-- lookup parent from repository -->
</parent>
```
- 或者也可以使用 compile 为 import 类型的 maven 依赖，例如下述配置：
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-dependencies</artifactId>
      <version>2.1.13.RELEASE</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```
- 配置 parent 后，引入下述依赖：
```xml
<dependencies>
  <!--lombok-->
  <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
  </dependency>
  <!--web 启动器-->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>
  <!--测试启动器-->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
  </dependency>
</dependencies>
```
- maven 的打包插件默认不会打包依赖，spring boot 提供了插件打包所有工程依赖并生成完整 jar 包，使得可以直接运行 jar 包，只要引入下述插件即可
```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
    </plugin>
  </plugins>
</build>
```

# Java 版本

- spring boot 提供了 java.version 属性来统一配置采用的 java 版本
```xml
<java.version>1.8</java.version>
```
- 而 maven 工程则默认提供了 maven.compiler.source 和 maven.compiler.target 来控制编译和运行的版本
```xml
<properties>
  <maven.compiler.source>8</maven.compiler.source>
  <maven.compiler.target>8</maven.compiler.target>
</properties>
```


# 代码

- 首先构造 Application 类作为应用入口：
```java
@SpringBootApplication
@Slf4j
public class SpringBootWebApplication implements ApplicationRunner {

    public static void main(String[] args) {
        SpringApplication.run(SpringBootWebApplication.class, args);
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        log.info("ApplicationRunner：启动成功");
    }

    @Bean
    public CommandLineRunner commandLineRunner() {
        return args -> log.info("commandLineRunner：启动成功");
    }

}
```
- 其中 ApplicationRunner 和 CommandLineRunner 两个接口是 Spring 提供的用于在程序启动后快速执行一段代码的接口，通过创建实现该接口的 Bean 可以快速运行一段代码，方便测试
- 之后，创建传输类 Greeting
```Java
@AllArgsConstructor
@Getter
@Accessors(chain = true)
@Builder
@ToString
public class Greeting {

    private final long id;
    private final String content;

}
```
- 之后，创建控制器 GreetingController
```java
@RestController
public class GreetingController {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/greeting")
    public Greeting greeting(@RequestParam(value = "name", defaultValue = "World") String name) {
        return new Greeting(counter.incrementAndGet(), String.format(template, name));
    }
}
```
- 打开浏览器，访问 http://localhost:8080/greeting?name=hao 即可看到 json 结果
