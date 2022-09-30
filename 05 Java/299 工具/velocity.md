

# 概述

Velocity 是一个基于 Java 的模板引擎，模板文件后缀一般为 vm。

模板引擎：提前定义好一份文件模板，并提供一种占位符或表达式语法，并以一定的方式从 Java 中取出值并填入到表达式中。例如 JSP 和 EL 表达式就可以看成一种模板引擎技术，只不过是 Java Web 自带的，常见的模板引擎有 FreeMarker、Velocity、Thymeleaf 等。

在后台渲染的 Web 时代，可以使用模板引擎技术实现界面和代码的分离，而在前后端分离时代已经很少进行后端渲染，只有部分对 SEO 要求较高的页面可能会采用后端渲染的方式，此时可以采用模板引擎技术。

另一个常见应用则是从逆向工程出发，基于数据库表生成对应的 Entity、Dao、Service 等文件，可以提前编写好 Entity、Dao、Service 模板并填入对应的配置。

# 简单使用

要使用 Velocity 主要包括下列四个步骤：
- 首先创建模板引擎对象 VelocityEngine，设置必备的资源加载器属性，之后执行 `init()` 方法
- 利用 velocityEngine 对象，根据资源加载器和模板名称，以一定的方式获取模板文件对象 template
- 创建 VelocityContext 上下文对象，设置模板文件中所声明的占位符、表达式等到上下文
- 执行模板文件 template 的 `merge(Context context, Writer writer)` 方法进行渲染，其会将上下文中定义的属性值填写到模板中，并输出到 writer

编写 `template/velocity.vm` 模板文件，填入下述内容：
```vm
Engine Name: ${name}

idxList:

#foreach ($idx in $list)
        it is $idx
#end

This is End...
```

执行下述代码并观察指定输出文件：
```java
public class VelocityTest {
    
    public static void main(String[] args) throws IOException {
        // 创建模板引擎对象
        VelocityEngine velocityEngine = new VelocityEngine();
        // 设置必备属性，详细配置可查看 https://velocity.apache.org/engine/2.0/configuration.html
        // 2.1 开始，配置项的形式有了变化，此处引入的是 1.7 版本故采用的是旧配置，后面和 hutool 整合时再介绍新配置
        // 设置资源加载方式为类路径加载，即基于类路径查找模板文件
        velocityEngine.setProperty(RuntimeConstants.RESOURCE_LOADER, "classpathLoader");
        velocityEngine.setProperty("classpathLoader.resource.loader.class", ClasspathResourceLoader.class.getName());
        // 初始化模板引擎
        velocityEngine.init();

        // 获取模板文件
        Template t = velocityEngine.getTemplate("template/velocity.vm");

        // 创建模板引擎上下文并设置 Template 所需变量
        // 设置属性可以直接提供一个 Map，也可以对上下文 put 设置，查看源码他们都是一样的
        HashMap<String, Object> props = new HashMap<>();
        props.put("name", "Velocity");
        VelocityContext ctx = new VelocityContext(props);
        List<String> list = new ArrayList<>();
        list.add("1");
        list.add("2");
        ctx.put("list", list);

        // 定义输出文件
        FileWriter fileWriter = new FileWriter("E:\\code\\java\\java-test\\velocity-test\\src\\main\\resources\\out.txt");

        // 执行 template.merge 方法进行模板渲染
        t.merge(ctx, fileWriter);
        fileWriter.close();
    }
    
}
```

# 和 hutool 整合

各种模板引擎语法大相径庭，使用方式也不尽相同，学习成本很高，Hutool 旨在封装各个引擎的共性，使用户只关注模板语法即可，减少学习成本。

类似于 Java 中 slf4j 日志门面的思想，Hutool 将模板引擎的渲染抽象为两个概念：
- TemplateEngine 模板引擎，用于封装模板对象，配置各种配置
- Template 模板对象，用于配合参数渲染产生内容

通过实现这两个接口，用户便可抛开模板实现，从而渲染模板。和 slf4j 类似，我们可以直接使用这两个接口使用模板引擎，而不再需要关注底层不同的模板引擎细节，Hutool 会通过 TemplateFactory 根据用户引入的模板引擎库的 jar 来自动选择用哪个引擎来渲染。

需要特别注意，Velocity 从 2.1 开始资源加载器的配置项发生了变化，统一将 name 前缀 `name.resource.loader.class` 放到了中间 `resource.loader.name.class`，而我们本次使用的 hutool 为 5.7.22，从起创建模板引擎一路跟进去直到 `cn.hutool.extra.template.engine.velocity.VelocityEngine#createEngine` 可以看到其配置项采用的是新写法，因此我们需要引入新版的 velocity。这种情况在基于门面来屏蔽各个底层细节的情况还是很常见的，类似的情况在日志门面中也常常出现版本匹配问题。

我们还是使用同样的模板，但基于 hutool 渲染代码变为下述内容：
```java
public class VelocityTest {

    public static void main(String[] args) {
        // 创建模板引擎对象，其中配置 template 为类路径下的前缀
        TemplateEngine engine = TemplateUtil.createEngine(new TemplateConfig("template", ResourceMode.CLASSPATH));
        
        // 找到 template/velocity.vm 文件
        Template template = engine.getTemplate("velocity.vm");
        
        // 参数统一为 Dict，本质上是一个 Map
        ArrayList<String> list = new ArrayList<>();
        list.add("1");
        list.add("2");
        list.add("3");
        Dict dict = Dict.create()
            .set("name", "velocity")
            .set("list", list);
        
        // 渲染模板
        String result = template.render(dict);
        
        // 打印 result 或者写到文件
        System.out.println(result);
        FileWriter writer = new FileWriter("E:\\code\\java\\java-test\\velocity-test\\src\\main\\resources\\out.txt");
        writer.write(result);
    }

}
```

可以看到基于 hutool 代码精简了很多，只需关注渲染内容无需关注底层细节，同时若需要更换其他模板引擎技术，代码都无需改变，只需更换对应的依赖即可。


# 参考链接

- [Velocity, by apache](https://velocity.apache.org/)
- [hutool](https://hutool.cn/docs/#/extra/%E6%A8%A1%E6%9D%BF%E5%BC%95%E6%93%8E/%E6%A8%A1%E6%9D%BF%E5%BC%95%E6%93%8E%E5%B0%81%E8%A3%85-TemplateUtil)