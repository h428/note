
# 5. 构建 Spring Web 应用程序


- porm.xml 内容如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>ocom.hao.web</groupId>
    <artifactId>Web1</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <name>Web1 Maven Webapp</name>
    <!-- FIXME change it to the project's website -->
    <url>http://www.example.com</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.7</maven.compiler.source>
        <maven.compiler.target>1.7</maven.compiler.target>
        <spring.version>4.2.4.RELEASE</spring.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.11</version>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.1.0</version>
            <scope>provided</scope>
        </dependency>

    </dependencies>

    <build>
        <finalName>Web1</finalName>
        <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
            <plugins>
                <plugin>
                    <artifactId>maven-clean-plugin</artifactId>
                    <version>3.1.0</version>
                </plugin>
                <!-- see http://maven.apache.org/ref/current/maven-core/default-bindings.html#Plugin_bindings_for_war_packaging -->
                <plugin>
                    <artifactId>maven-resources-plugin</artifactId>
                    <version>3.0.2</version>
                </plugin>
                <plugin>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.8.0</version>
                </plugin>
                <plugin>
                    <artifactId>maven-surefire-plugin</artifactId>
                    <version>2.22.1</version>
                </plugin>
                <plugin>
                    <artifactId>maven-war-plugin</artifactId>
                    <version>3.2.2</version>
                </plugin>
                <plugin>
                    <artifactId>maven-install-plugin</artifactId>
                    <version>2.5.2</version>
                </plugin>
                <plugin>
                    <artifactId>maven-deploy-plugin</artifactId>
                    <version>2.8.2</version>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
```

## 5.1 Spring MVC 初步

### 5.1.1 跟踪 Spring MVC 处理请求的流程


- Spring 处理请求最核心的一个组件就是 DispatcherServlet ，可以将其称作请求分发器
- 除了请求分发器 DispatcherServlet ，还需要理解处理器映射、控制器、逻辑视图、视图解析器、视图等重要概念
- Spring 处理 HTTP 请求的流程大致如下：
    1. 浏览器发出请求到服务器，使用了 Spring MVC 后，Spring 会接受、拦截并处理请求
    2. DispatcherServlet 接收到 url 后，查询一个或多个处理器映射，将 url 映射到对应的控制器
    3. 控制器处理请求，返回模型和逻辑视图
    4. DispatcherServlet 调用视图解析器，将逻辑视图映射到指定的视图 (如 JSP)，并作为响应返回到用户
- MVC 三层架构，M 为模型，可以理解为 Service 及下层的相关内容，V 即视图，可以是是具体的 JSP，也可以是其他视图渲染方式甚至是 json 等，C 即为控制器，用于处理请求，并调用模型进行处理

### 5.1.2 搭建 Spring MVC

- 由于 Spring 新版本功能增强，我们只需要配置几个基本的核心组件
- 传统方式都是把 DispatcherServlet 配置在 web.xml 中，但由于 Servlet 3 规范和 Spring 3.1 的增强，我们采用基于 Java 的配置

**配置 DispatcherServlet**

- 任何继承 AbstractAnnotationConfigDispatcherServletInitializer 的类都会自动地配置 DispatcherServlet 和 Spring 应用上下文
- 传统都是在 web.xml 中配置，一个是监听器，一个是 Servlet，基于 Java 配置代码如下：
```java
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    /**
     * DispatcherServlet 处理所有 / 请求
     * @return
     */
    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }

    /**
     * ContextLoaderListener 上下文，应用中除了 Web 组件以外的相关 Bean 的配置类
     * @return
     */
    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class[] {RootConfig.class};
    }

    /**
     * DispatcherServlet 上下文，Web 组件的 Bean 配置类，如控制器，视图解析器等
     * @return
     */
    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class[] {WebConfig.class};
    }
}
```

**AbstractAnnotationConfigDispatcherServletInitializer 剖析**

- 在 Servlet 3.0 中，容器会在类路径中查找实现 javax.servlet.ServletContainerInitializer 接口的类，若找到会用其配置 Servlet 容器
- Spring 提供了这个接口的的实现 SpringServletContainerInitializer ，这个类会查找实现了 WebApplicationInitializer 的类并将配置的任务交给它们完成
- AbstractAnnotationConfigDispatcherServletInitializer 就是 WebApplicationInitializer 的实现
- 因此，容器会找到我们自定义的 SpittrWebAppInitializer 并用于配置容器，实现主要涉及 3 个方法
- getServletMappings() 用于配置 DispatcherServlet 的路径映射
- getServletConfigClasses() 用于配置 DispatcherServlet 相关的上下文的配置类
- getRootConfigClasses() 用于配置 ContextLoaderListener 相关的上下文的配置类

**两个应用上下文**

- 主要涉及一个 Servlet 和一个监听器： DispatcherServlet 和 ContextLoaderListener，它们分别对应了各自的上下文
- 当创建和启动 DispatcherServlet 时，基于 getServletMappings() 确定要处理的路径，基于 getServletConfigClasses() 方法返回的配置类构造对应的上下文
- 和 DispatcherServlet 相关的上下文主要用于加载一些 Web 组件相关的 Bean，如控制器，视图解析器以及处理器映射等
- 此外，还有另一个上下文（就是原来的 Spring 容器），这个上下文一般由 **ContextLoaderListener** 创建，主要放置一些后端相关的 Bean，如模型、数据层组件等，且在分模块项目中可以分离出来
- AbstractAnnotationConfigDispatcherServletInitializer 会同时创建 DispatcherServlet 和 ContextLoaderListener 两个 Web 组件，同时基于 getServletConfigClasses() 和 getRootConfigClasses() 方法返回的配置构造出对应的两个上下文
- AbstractAnnotationConfigDispatcherServletInitializer 是传统 web.xml 配置方案的替代方案，你也可以同时包含二者，但没必要
- 注意必须是支持 Servlet 3.0 的容器，否则只能使用 web.xml 方式

**启用 Spring MVC**

- Spring MVC 也有多种配置方式，比如在 web.xml 中可以使用 `<mvc:annotation-driven />` 开启注解驱动
- 基于 Java 的 Spring MVC 一般需要配置下述内容：
    - 视图解析器：若不配置，会默认使用 BeanNameView-Resolver，这个视图解析器会查找 Bean， 其中 Bean ID和视图名称相同，且这个 Bean 要实现 View 接口，这很少见，因此我们需要配置自己的视图解析器
    - 启用组件扫描，这样你就不用再额外配置 Bean，可以减少配置量
    - 配置对静态资源放行
- 下面是一个基于 Java 的最小可用的 WebConfig 配置：
```java
@Configuration
@EnableWebMvc  // 启用 MVC ，表示这是一个基于 Web 配置类
@ComponentScan("com.hao.web")
public class WebConfig extends WebMvcConfigurerAdapter {

    /**
     * 配置 JSP 视图解析器
     * @return 视图解析器
     */
    @Bean
    public ViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setPrefix("/WEB-INF/views/");
        resolver.setSuffix(".jsp");
        resolver.setExposeContextBeansAsAttributes(true);
        return resolver;
    }

    /**
     * 配置静态资源的处理
     * @param configurer 配置器
     */
    @Override
    public void configureDefaultServletHandling(DefaultServletHandlerConfigurer configurer) {
        configurer.enable();
    }
}
```
- 之后，配置类 RootConfig 主要用于 ContextLoaderListener 相关的上下文：
```java
@Configuration
@ComponentScan(basePackages = {"com.hao"},  // 配置要扫描的 Bean 的基本包
        excludeFilters = {
                // 排除掉已经扫描过的 web 相关的配置类
                @ComponentScan.Filter(type = FilterType.ANNOTATION, value = EnableWebMvc.class)
        })
public class RootConfig {

}
```

### 5.1.3 Spittr 应用

- 略

## 5.2 编写基本控制器

- 控制器就是一个简单的 POJO，只需为其添加 `@Controller` 注解即可成为一个控制器，即可处理请求
- 控制器代码样例：
```java
@Controller
public class HomeController {
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String home() {
        return "home";
    }
}
```
- `@Controller` 作用基本和 `@Component` 相同，只是语义更加明显
- `@RequestMapping` 注解可以用于类和方法，其用于设置请求的相关信息
- jsp 是最常见的视图，返回的逻辑视图名和前面配置视图解析器以及前后缀 "/WEB-INF/views/", ".jsp" 组合，确定最终的视图，"/WEB-INF/views/home.jsp"

### 5.2.1 测试控制器

- 除了基本的单元测试外，对于控制器，Spring 提供了特殊的测试，可以模拟 HTTP 请求然后执行对应测试而不需要启动 Servlet 容器，这变得十分方便
- 测试主要涉及 MockMvcRequestBuilders, MockMvcResultMatchers, MockMvcBuilders 三个类下的静态方法：
```java

// 使用 MockMvc 进行测试的相关的类，使用静态导入
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.*;

public class HomeControllerTest {
    @Test
    public void testHomePage() throws Exception {
        // 创建控制器
        HomeController controller = new HomeController();
        // 用控制器构建 Mock 测试实例
        MockMvc mockMvc = standaloneSetup(controller).build();
        // 模拟 http 请求，执行测试
        mockMvc.perform(get("/"))
                .andExpect(view().name("home"));
    }
}
```

### 5.2.2 定义类级别的请求处理

- 可以为控制器类指定一个统一的路径或前缀，然后在方法上可以基于此进一步配置，甚至可以设置多个前缀
- 由于 JSON 是很常见的返回类型，我超前给出了一个例子，详细以后再解释，这里给出样例（其实也很好理解）
```java
@Controller
@RequestMapping(value = {"/", "/homepage"})
public class HomeController {
    @RequestMapping
    public String home() {
        return "home";
    }

    @RequestMapping("/rand")
    @ResponseBody
    public User rand() {
        return User.generateRandomUser();
    }
}
```
- 其中 User 是我自定义的方便使用的实体类，代码省略默认构造器和 get/set 函数
```java
public class User {
    private String username;
    private String password;
    private Integer age;

    // 省略默认构造器和 get/set 方法

    public static User generateRandomUser() {
        User user = new User();
        int num = (int)(Math.random() * 100);
        user.setUsername("user"+num);
        user.setPassword("pass"+num);
        user.setAge(num);
        return user;
    }
}
```
- 打开对应的页面，不断刷新，可以得到随机的用户 json

### 5.2.3 传递模型数据到视图中

- 其中，书上的 Spittle 实体类，实现 equals 和 hashCode 时，调用了 Apache Common Lang 工具包下的类，可以参考一下
- 为了方便，我模拟书上的返回 Spittle 列表功能，实现一个类似的功能：返回用户列表
    - 编写实体类 User 前面已经编写过
    - 为了方便起见，不采用严格的 MVC 三层架构，Controller 直接调用 dao 层，故创建 UserDao，且为了方便直接创建类而不基于接口编程
    - 编写 UserController，并调用 UserDao，可以直接返回 json 或返回逻辑视图然后在 jsp 中用 el 表达式取出值，由于本小结练习模型传递到视图，故采用后者
    - 如果有需要，可以使用前几章的方法对 Dao 层单独编写单元测试，分模块常用，此处可省略
    - 基于 MockMvc 编写控制器测试，或直接编写 Controller 层的单元测试也可，但建议采用前者
- 编写 UserDao，返回用户列表：
```java
@Component
public class UserDao {
    public List<User> getUsers(int size) {
        List<User> userList = new ArrayList<User>();
        for (int i = 0; i < size; ++i) {
            userList.add(User.generateRandomUser());
        }
        return userList;
    }
}
```
- 编写 UserController，其处理请求并调用 Dao 返回结果，并将模型数据存储起来，可以在 JSP 中使用 EL 表达式取出
```java
@Controller
public class UserController {
    @Autowired
    private UserDao userDao;

    @RequestMapping(value = "/users", method = RequestMethod.GET)
    public String users(Model model) {
        List<User> users = userDao.getUsers(5);
//        model.addAttribute(users);
        model.addAttribute("userList", users);
        return "users";
    }
}
```
- 在 users.jsp 中取出模型：
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page isELIgnored="false" %>
<html>
<head>
    <title>Users</title>
</head>
<body>
    <c:forEach items="${userList}" var="user">
        <div>
            <c:out value="${user.username}"/> ,
            <c:out value="${user.password}"/> ,
            <c:out value="${user.age}"/> ,
        </div>
    </c:forEach>
</body>
</html>
```
- 之后运行 Servlet 容器 （如 Tomcat） 查看结果
- 调用 `model.addAttribute()` 没有指定 key 则会根据类型推断出 key，例如 List<User> 类型则 key 为 userList，key 需要在 EL 表达式中使用
- 也可以手动设置 key，上述代码和 `model.addAttribute("userList", users);` 等价

## 5.3 接受请求的出入

- 用户的输入数据大致分为三种：
    - 查询参数 (url 中问号后面的内容)
    - 表单参数 (表单 post 提交)
    - 路径参数 (形如 /a/123 的 RestFul 风格)

### 5.3.1 处理查询参数

- 查询参数指的是 url 中问号后面的内容，一般针对 get 请求，如 `/users?size=20`，多个请求参数使用 & 分隔 
- 使用 `@RequestParam` 注解读取查询参数并传递给方法参数，其还有一个 defaultValue 可用于设置默认值
- 例如我们可以这样修改 users 方法：
```java
@RequestMapping(value = "/users", method = RequestMethod.GET)
public String users(Model model, @RequestParam(value = "size", defaultValue = "5") int size) {
    List<User> users = userDao.getUsers(size);
//        model.addAttribute(users);
    model.addAttribute("userList", users);
    return "users";
}
```
- 这样，访问 `/users?size=20` 将会每页显示 20 条用户信息，若不传递参数则默认显示 5 条
- 注意 defaultValue 是 String，但绑定到方法参数时会自动转化为具体的基本类型

### 5.3.2 通过路径参数接受输入

- 路径参数是指，要传递的参数也作为路径的一部分，而不是跟在问号后面，如 `/users/20`
- 要处理路径参数，在 `@RequestMapping` 路径中就要配置一个名称，然后在方法参数中使用，例如下面的例子：
```java
@RequestMapping(value = "/users/{size}", method = RequestMethod.GET)
public String users(Model model, @PathVariable("size") int size) {
    List<User> users = userDao.getUsers(size);
//        model.addAttribute(users);
    model.addAttribute("userList", users);
    return "users";
}
```
- 则访问可以使用 `/users/20` 访问，每页显示 20 条记录
- @PathVariable 的 value 属性可以省略，若是省略，则默认和方法参数名一致，这种方式可以减少配置量


## 5.4 处理表单

- 表单数据的接受一般采用方法参数名接受，但最常见的做法是采用一个 Bean 接受

### 5.4.1 编写处理表单的控制器

- 大致流程为：用户请求表单页面 -> 提交表单 -> 处理表单完成注册 -> 重定向到结果页面
- 首先编写表单页面 registerForm：
```jsp
<body>
    <h3>注册</h3>
    <div>
        <
        <form action="/register" method="post">
            <input type="text" name="username" /> <br/>
            <input type="password" name="password" /> <br/>
            <input type="number" name="age"> <br/>
            <button type="submit">提交</button>
        </form>
    </div>
</body>
```
- 然后编写相关方法：
```java
@RequestMapping("/registerForm")
public String showRegisterForm() {
    return "registerForm";
}

@RequestMapping("/info")
public String info() {
    return "info";
}

@RequestMapping(value = "/register", method = RequestMethod.POST)
public String processRegister(User user, HttpSession session) {
    session.setAttribute("user", user);
    return "redirect:info";
}
```
- 注册成功的跳转页面 info.jsp：
```jsp
<body>
    <h3>注册成功</h3>
    <div>
        <c:out value="${user.username}" /> ,
        <c:out value="${user.password}" /> ,
        <c:out value="${user.age}" />
    </div>
</body>
```

### 5.4.2 校验表单

- 利用 Spring 提供的注解，可以做一些基本的表单校验
    1. 在实体类上打 `@NotNull`, `@Size` 等标签进行校验 (注解基于 javax.validation.constraints)
    2. 然后在方法参数上打上 `@Valid` 注解，并使用 Errors 对象判断是否校验成功
- 我在 Spring 4.2.4 测试不成功，而且似乎也很少采用该种表单校验方式，都是自己编写判定












