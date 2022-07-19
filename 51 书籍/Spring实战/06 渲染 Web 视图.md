 

# 6. 渲染 Web 视图

- 主要内容：
    - 模型数据渲染为 HTML
    - 使用 JSP 视图
    - 通过 tiles 定义视图布局
    - 使用 Thymeleaf 视图

## 6.1 理解视图解析器

- 控制器一般处理请求，然后返回逻辑视图名称，视图解析器根据名称查找并解析对应视图
- 这样的处理请求逻辑与视图分离的 MVC 解耦架构是 Spring MVC 的一个重要特性
- 前一章中，我们使用了 InternalResourceViewResolver 视图解析器，其主要用于查找和解析 JSP 视图，比如根据配置的前缀、后缀和返回的逻辑视图名称查找对应的 JSP 页面

**Spring 视图解析器架构**

- Spring 中的视图解析主要涉及两个接口：View 和 ViewResolver
- ViewResolver 接口中的 `View resolveViewName(String viewName, Locale locale) throws Exception;` 方法接受视图名称和 Locale 对象，返回一个 View
- View 是另一个接口，其根据模型数据、request、response 最终确定响应内容，将视图写入响应并返回，可以直接将其看做返回的视图
- 基于这种架构，我们要返回一个视图时，只需实现上述两个接口，将逻辑视图名转化为对应的视图即可，但实际上 Spring 提供了很多默认的视图解析器，我们不必再自己编写，只需使用默认的视图解析器即可，如 InternalResourceViewResolver 用于解析和返回 JSP 视图
- Spring 提供了 13 个视图解析器，常见的包括 JSP, FreeMarker, tiles, velocity 等， JSP 是最常用的视图

## 6.2 创建 JSP 视图

- 要使用 JSP 视图，主要使用 InternalResourceViewResolver 视图解析器，并配置前缀、后缀即可，可采用基于 Java 的配置或基于 XML 的配置
- 基于 Java 配置的代码大致如下：
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
        // 书上说要该行才能解析 jstl，但我不要这句也能解析标准的 jstl 和 el 表达式，我猜可能是要这句才能解析基于 Spring 的标签库
        resolver.setViewClass(org.springframework.web.servlet.view.JstlView.class);
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
- 也可以基于 XML 配置视图解析器，即配置一个 Bean 即可：
```xml
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="viewResolver">
    <property name="prefix" value="/WEB-INF/views" />
    <property name="suffix" value=".jsp" />
    <!-- 可能是为了解析 Spring 的标签库，一般可以不配置 -->
    <property name="viewClass" value="org.springframework.web.servlet.view.JstlView" />
</bean>
```
- jsp 是非常常见的视图，但若要前后端分离，还是建议直接返回 json 然后使用 js 填充数据

# 其他视图暂时觉得用处不大，先略过