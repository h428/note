

# 2. 装配 Bean

---

- 本章主要包含如下内容：
    - 声明 bean
    - 构造器注入和 Setter 方法注入
    - 装配 Bean
    - 控制 Bean 的创建和销毁
- 一个应用必须通过各个组件、对象之间的交流实现完整而强大的功能，也就是说，耦合是不可避免的
- 但是，过度耦合将导致复杂的代码结构，使得查找 bug 和单元测试难以进行
- Spring 中，对象无需自己查找或者创建所关联的对象，而是由容器统一管理，容器负责把需要相互协作的对象引用赋予各个对象
- 创建对象之间协作关系的行为称为装配，这也是依赖注入 (DI) 的本质
- 本章将介绍使用 Spring 装配 bean 的基础知识，DI 是其基本元素
- 使用的 maven 环境，porm.xml 内容如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.hao.test</groupId>
    <artifactId>SpringTest</artifactId>
    <version>1.0-SNAPSHOT</version>

    <name>SpringTest</name>
    <!-- FIXME change it to the project's website -->
    <url>http://www.example.com</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.7</maven.compiler.source>
        <maven.compiler.target>1.7</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.11</version>
            <scope>compile</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>4.2.4.RELEASE</version>
            <scope>compile</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-aspects</artifactId>
            <version>4.2.4.RELEASE</version>
            <scope>compile</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>4.2.4.RELEASE</version>
            <scope>compile</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-instrument</artifactId>
            <version>4.2.4.RELEASE</version>
            <scope>compile</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>4.2.4.RELEASE</version>
            <scope>compile</scope>
        </dependency>

    </dependencies>

    <build>
        <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
            <plugins>
                <plugin>
                    <artifactId>maven-clean-plugin</artifactId>
                    <version>3.0.0</version>
                </plugin>
                <!-- see http://maven.apache.org/ref/current/maven-core/default-bindings.html#Plugin_bindings_for_jar_packaging -->
                <plugin>
                    <artifactId>maven-resources-plugin</artifactId>
                    <version>3.0.2</version>
                </plugin>
                <plugin>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.7.0</version>
                </plugin>
                <plugin>
                    <artifactId>maven-surefire-plugin</artifactId>
                    <version>2.20.1</version>
                </plugin>
                <plugin>
                    <artifactId>maven-jar-plugin</artifactId>
                    <version>3.0.2</version>
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


## 2.1 Spring配置的可选方案

- Spring 提供了三种主要的装配机制：
    - 在 XML 中显式配置
    - 在 Java 中进行显式配置
    - 隐式的 bean 发现机制和自动装配机制
- Spring 的配置风格可以使互相搭配的，故可以选择使用 XML 装配一些 bean，使用 Spring 基于 Java 的配置(JavaConfig)来装配另一些 bean，而将剩余的 bean 让 Spring 自动发现
- 作者建议尽可能使用隐式的配置，在必须使用显式配置时（比如你没有源代码），最好采用 JavaConfig 而不是 XML
- 只有想要使用便利的 XML 命名空间并且在 JavaConfig 没有同样的实现时，才应该使用 XML
- JavaConfig 相对于 XML 的直接优势是重构友好，并且构造 bean 时可以通过 Java 代码精细控制

## 2.2 自动化装配Bean

- Spring 从两个角度实现自动化装配
    - 组件扫描：Spring 会自动发现应用上下文中所创建的 Bean
    - 自动装配：Spring 自动满足 bean 之间的依赖
- 配合使用组件扫描和自动装配，可以将显式配置降低到最少
- 我们使用这样一个案例：创建 CompactDisc 类和 CDPlayer 类，CDPlayer 依赖 CompactDisc， 让 Spring 发现它们并完成自动注入

### 2.2.1 创建可被发现的 Bean

- 我们假设可能有各种 CD，故先抽象出 CompactDisc 接口
- `@Component` 注解用于告知 Spring 这是一个 Bean，需要实例化，具有同样功能的还有 `@Repository`、`@Service`和 `@Controller`
- 可使用 `@ComponentScan` 注解开启组件扫描，此时 Spring 会扫描配置类所在的包以及它们的子包
- 若想更改扫描的包，可以使用注解的 value 属性(只能指定一个)或者 basePackages 属性(是一个数组，可以指定多个)指定要扫描的基本包
- 此外，还可以使用 basePackageClasses，该属性是一个 Class 数组，可以提供多个 Class，Spring 会以这些 Class 所在的包作为基本包
- 可以在需要扫描的包中创建一个空标记接口，并将 basePackages 设置为这个接口，这样可以保持对重构的友好引用
- 如果使用 XML 配置，也可以使用 `<context:component-scan base-package=""/>` 进行组件扫描
- 利用 Spring 能很方便地进行单元测试：
    1. 创建一个 POJO，添加 `@RunWith(SpringJunit4ClassRunner.class)` 注解
    2. 使用 `@ContextConfiguration()` 注解提供配置信息，若是基于 XML 的配置则用 location 属性，若是基于 JavaConfig 的配置则使用 class 属性
    3. 在测试类内部可以使用 `@Autowired` 等注解进行自动装配，之后即可进行单元测试

**样例代码**

- 首先，在指定的包下创建书上提到的三个组件，包括我这里选择 con.hao.entity 包
- 抽象 CD 接口
```java
package com.hao.entity;

/**
 * 抽象的 cd 接口
 */
public interface CompactDisc {
    void play();
}
```
- 具体专辑：
```java
package com.hao.entity;

import org.springframework.stereotype.Component;

/**
 * 一张 CD 或专辑
 */
@Component
public class SgtPeppers implements CompactDisc {

    private String title = "Sgt. Pepper's Lonely Hearts Club Band"; // 这是专辑名称
    private String artist = "The Beatles"; // 这是一个英国摇滚乐队

    @Override
    public void play() {
        System.out.println("播放 "+ artist + " 的专辑：" + title);
    }
}
```
- 然后是一个 Spring 配置类 （也可以采用 XML 配置，这里采用 JavaConfig 配置方式）, `@Configuration` 表示这是一个配置类，`@ComponentScan` 设置自动扫描，默认自动扫描当前包及其子包，后文介绍如何配置扫描指定包
```java
package com.hao.entity;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan
public class CDPlayerConfig {
}
```
- 之后，便可以开始执行单元测试：
```java
package com.hao.entity;


import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = CDPlayerConfig.class)
public class CDPlayerTest {

    @Autowired
    private CompactDisc cd;

    @Test
    public void  cdShouldNotBeNull() {
        Assert.assertNotNull(cd);
        cd.play();
    }

}
```
- 也可以使用 XML 配置，XML 使用如下配置进行自动扫描指定包：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="com.hao.entity"/>

</beans>
```
- 最后，修改单元测试类的起点为 XML 配置文件而不是 JavaConfig 类：
```java
package test.com.hao.entity;


import com.hao.entity.CDPlayerConfig;
import com.hao.entity.CompactDisc;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.annotation.Resource;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration (classes = CDPlayerConfig.class)
//@ContextConfiguration (locations = "classpath:spring.xml")
public class CDPlayerTest {

    @Resource
    private CompactDisc cd;

    @Test
    public void  cdShouldNotBeNull() {
        Assert.assertNotNull(cd);
        cd.play();
    }

}
```

### 2.2.2 为组件扫描的 bean 命名


- Spring 上下文中所有的 bean 都有一个 ID，尽管在前面的例子中我们没有显式设置名称，但 Spring 会根据类名指定一个 id，即类名首字母改为小写，剩余字母不变
- 若要设置不同的 id，则可使用 `@Component` 注解的 value 参数 （即默认参数），比如 `@Component("obj")`
- 也可以采用 JDI 标准提供的 `@Named` 注解设置 Bean 的 ID （我测试发现没有 `@Named` 注解，不知道要怎么引入这个注解，可能需要 JavaEE 标准相关的包）

### 2.2.3 设置组件扫描的基础包

- `@ComponentScan` 注解默认把当前配置类所在的目录作为基本目录，Spring 会扫描当前目录及子目录
- 若想扫描其他目录，可以使用 `@ComponentScan` 注解的 value 属性指明包的名称
- 还可以使用 basePackages 属性设置基础包，其可以是一个 String 数组，例如 `@ComponentScan (basePackages = {"com.hao.entity", "com.hao.dao", "com.hao.service"})` 或直接 `@ComponentScan (basePackages = "com.hao")`
- 还可以使用 basePackageClasses，设置多个 JavaConfig 类，例如 `@ComponentScan (basePackageClasses = {EntityConfig.class, DaoConfig.class, ServiceConfig.class})` 或 `@ComponentScan (basePackageClasses = {BaseConfig.class})`，其中 EntityConfig, DaoConfig, ServiceConfig 分别是对应 package 下的标记空类，而 BaseConfig 是 com.hao 下的类
- 可以在需要扫描的包中创建一个空标记接口，并将 basePackages 设置为这个接口，这样可以保持对重构的友好引用

### 2.2.4 通过为 bean 添加注解实现自动装配

- 可以利用 `@Autowired` 注解实现自动装配，默认是按类型进行自动装配
- 书上说也可以使用基于 JDI 标准的 `@Inject` 注解进行自动装配，但要引入 JavaEE 相关的包 （我没有对应的 lib，没有测试）
- 此外，还可以使用 `@Resource` 进行自动装配，这也是 Java 标准且 Java SE 自带，我暂时不知道和 `@Inject` 有什么区别
- `@Autowired` 注解可以用在私有域、构造器、setter 上，放在域上最方便，但破坏了封装性，放在 setter 方法上最符合标准
- 其实，`@Autowired` 注解可以放在任何方法上，框架会调用该方法并实现注入（写个类似 setter 的方法），比如：
```java
@Autowired
public void insertUserDao(UserDao userDao) {
    this.userDao = userDao;
}
```


### 2.2.5 验证自动装配

- 验证可参考前面的单元测试代码

## 2.3 通过 Java 代码装配 Bean

### 2.3.1 创建配置类

- 创建一个专门用于配置的 JavaConfig 类，本例中即 CDPlayerConfig
- 详细代码可查看接下来的 2.3.2

### 2.3.2 声明简单的 Bean

- 我们注释掉 `@ComponentScan` 注解来取消自动扫描，测试一下自定义装配 Bean
- 要配置一个 Bean，可以在 JavaConfig 类中编写方法，该方法返回所需实例，然后为这个方法添加 `@Bean` 注解，如下代码所示
```java
@Configuration
//@ComponentScan
public class CDPlayerConfig {
    @Bean
    public CompactDisc sgtPeppers() {
        return new SgtPeppers();
    }
}
```
- 上述方法产生的 Bean 的 ID 默认和方法名称一样，若要指定 Bean 的 ID，可以使用 `@Bean` 注解的 name 属性，如 `@Bean(name = "sgt")`，注意设置了名称后，引用时可以显式指定名称 `@Resource(name = "sgt")`，也可以按类型（只有一个该类型的对象时时）
- 利用 JavaConfig 产生 Bean，我们甚至可以随机生成一个 CompactDisc 的实现类，XML 就无法做到该功能，因此强烈建议采用 JavaConfig，其生成 Bean 的方式更加灵活，仅受限于 Java 语言，因此接近于无限可能，详细的实现可参考本小结尾部的综合实例


### 2.3.3 借助 JavaConfig 实现注入

- 由于 JavaConfig 是使用 Java 代码产生 Bean 的，因此其注入的方式也十分简单，直接在 new 对象时传递依赖的对象，或者调用 set 方法设置依赖的对象即可
- 使用上述方式十分灵活，可重构性好，优于 XML 方式
- 基于 JavaConfig 进行注入时，可以把要注入的 Bean 直接调用方法产生，使用该种方式时，Spring 会拦截对应的方法，并把已经创建的对象注入进去，如下述代码所示
```java
@Bean
public CDPlayer cdPlayer() {
    // Spring 会拦截 randomCompactDisc() 方法的调用并直接返回已经创建的对象而不会再去重新创建
    return new CDPlayer(randomCompactDisc());
}
```
- 但这种方式要求创建 Bean 的方法在同一个 JavaConfig 中，否则无法调用（如 `randomCompactDisc()` 不在同一个 JavaConfig 中将无法调用该方法），因而十分不灵活
- 最好的方式是，将要装配的 Bean 作为一个参数传递给该方法，Spring 会自动在容器中找到合适的 Bean 并传递给方法参数，这种方式对 Bean 的创建方式没有要求，你可以使用在其他 JavaConfig 或 XML 配置的类，或是自动扫描到的类，声明配置要注入的 Bean，如下述代码所示
```java
@Bean
public CDPlayer cdPlayer(CompactDisc compactDisc) {
    return new CDPlayer(compactDisc);
}
```
- 注入时可以采用构造器注入或者 set 注入，使用 JavaConfig 时甚至可以调用任意方法注入
```java

```

**样例实现代码**

- 首先，定义 CompactDisc 接口和 4 个不同的实现类：
```java
package com.hao.entity;

/**
 * 抽象的 cd 接口
 */
public interface CompactDisc {
    void play();
}


package com.hao.entity;

import org.springframework.stereotype.Component;

/**
 * 一张 CD 或专辑
 */
@Component
public class SgtPeppers implements CompactDisc {

    private String title = "Sgt. Pepper's Lonely Hearts Club Band"; // 这是专辑名称
    private String artist = "The Beatles"; // 这是一个英国摇滚乐队

    @Override
    public void play() {
        System.out.println("play SgtPeppers : 播放 "+ artist + " 的专辑：" + title);
    }
}


package com.hao.entity;

import org.springframework.stereotype.Component;

@Component
public class WhiteAlbum implements CompactDisc {
    @Override
    public void play() {
        System.out.println("play WhiteAlbum");
    }
}


package com.hao.entity;

import org.springframework.stereotype.Component;

@Component
public class HardDaysNight implements CompactDisc{

    @Override
    public void play() {
        System.out.println("play HardDaysNight");
    }
}


package com.hao.entity;

import org.springframework.stereotype.Component;

@Component
public class Revolver implements CompactDisc {
    @Override
    public void play() {
        System.out.println("play Revolver");
    }
}
```
- 然后，创建 MediaPlayer 接口和 CDPlayer 实现类，其含有一个 CompactDisc 成员：
```java
package com.hao.entity;

public interface MediaPlayer {
  void play();
}


package com.hao.entity;

import org.springframework.beans.factory.annotation.Autowired;

public class CDPlayer implements MediaPlayer {
    private CompactDisc cd;

    public void play() {
        cd.play();
    }

    public CompactDisc getCd() {
        return cd;
    }

    @Autowired
    public void setCd(CompactDisc cd) {
        this.cd = cd;
    }
}
```
- 之后，设置 JavaConfig 类，其中 CompactDisc 是随机生成，手动装配 CDPlayer 的成员 （通过方法参数）
```java
package com.hao.entity;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
//@ComponentScan
public class CDPlayerConfig {

    @Bean
    public CompactDisc randomCompactDisc() {

        int choice = (int) Math.floor(Math.random() * 4);

        if (choice == 0) {
            return new SgtPeppers();
        } else if (choice == 1) {
            return new WhiteAlbum();
        } else if (choice == 2) {
            return new HardDaysNight();
        } else {
            return new Revolver();
        }
    }

    @Bean
    public CDPlayer cdPlayer(CompactDisc compactDisc) {
        CDPlayer cdPlayer = new CDPlayer();
        cdPlayer.setCd(compactDisc);
        return cdPlayer;
    }
}
```
- 之后可运行单元测试查看，单元测试代码如下：
```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = CDPlayerConfig.class)
public class Test1 {

    @Autowired
    CDPlayer cdPlayer;

    @Autowired
    CompactDisc compactDisc;

    @org.junit.Test
    public void test(){
        Assert.assertNotNull(cdPlayer);
        Assert.assertEquals(cdPlayer.getCd(), compactDisc);
        cdPlayer.play();
        compactDisc.play();
    }
}
```

## 2.4 通过 XML 装配 Bean

- Spring 现在有了强大的自动化配置和基于 Java 的配置，XML 不应该是你的第一选择
- 在 Spring 刚出现时，XML 是主要的配置方式，为了能阅读和维护已有的 Spring 配置，我们不可避免地需要学习 XML 方式

### 2.4.1 创建 XML 配置规范

- 在 XML 配置中，要创建一个 XML 文件，并以 `<bean>` 为根元素，一个空的最简单的初始模板如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- configuration details go here -->

</beans>
```

### 2.4.2 声明一个简单的的 <bean>

- 使用 `<bean>` 元素声明一个 Bean，其作用类似 JavaConfig 中的 `@Bean` 注解，如 `<bean class="com.hao.entity.SgtPeppers" />`
- 由于没有明确定义 id，这个 bean 的 id 会被默认命名为 `com.hao.entity.SgtPeppers#0`，其中 `#0` 是计数器形式，用来区分同类型的其他 Bean
- 若有多个同类型的 Bean，建议使用 id 属性进行命名，因为你在装配的时候会用到这个名字（含有多个同同类型的 Bean 不能再按类型自动装配，必须指定名称，否则会抛出异常）
- 为了减少配置，可以对只有那些需要引用的 bean 进行命名 （比如要将某个 bean 注入到另一个 bean 中时，XML 一般要配置名称）
- 若没有配置其他类似 `<constructor-arg>` 这样的元素，框架会调用默认构造函数实例化 Bean （这也是建议的方式，符合 JavaBean 的规范）

### 2.4.3 借助构造器注入初始化 Bean

- 若要采用构造器注入，有两种配置方式可以选择：
    - `<constructor-arg>` 元素
    - 使用 Spring 3.0 引入的 `c-命名空间`
- `<constructor-arg>` 比 `c-命名空间` 更加繁琐和冗长，但 `<constructor-arg>` 具备一些 `c-` 命名空间没有的功能

**构造器注入 Bean 引用**

- 使用下述配置进行构造器注入：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- configuration details go here -->

    <bean id="sgtPeppers" class="com.hao.entity.SgtPeppers" />

    <bean id="cdPlayer" class="com.hao.entity.CDPlayer">
        <constructor-arg ref="sgtPeppers"/>
    </bean>

</beans>
```
- 对基于 XML 的配置，可以按如下方式编写单元测试 (主要是 `@ContextConfiguration` 的 locations 属性)，代码如下：
```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:spring.xml")
public class Test2 {

    @Autowired
    MediaPlayer mediaPlayer;

    @Test
    public void test() {
        Assert.assertNotNull(mediaPlayer);
        mediaPlayer.play();
    }
}
```
- 若是采用基于`c-` 命名空间的配置方式，则配置变为如下内容，但要注意开头需要引入 `c-命名空间` 相关的模式声明 `xmlns:c="http://www.springframework.org/schema/c"`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:c="http://www.springframework.org/schema/c"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- configuration details go here -->

    <bean id="sgtPeppers" class="com.hao.entity.SgtPeppers" />

    <bean id="cdPlayer" class="com.hao.entity.CDPlayer" c:cd-ref="sgtPeppers" />

</beans>
```
- 再次运行单元测试代码，验证正确性
- 我们讲解一下 `c:cd-ref` 的各个组成部分：
    - `c:` 即为命名空间的前缀，表示构造器注入，类似的还有 `p:`
    - `cd` 即为构造器的参数名称，由于构造函数 `public CDPlayer(CompactDisc cd) { this.cd = cd; }` 的参数名为 cd，在此处才配置为 cd
    - `-ref` 是一个命名约定，表示这里配置的是一个 Bean，要进行注入的，而不是一个字符串常量，缺少该后缀将变为装配常量值(参考下一段内容)
- 另一种构造器注入的配置方式是使用函数参数下标而不是函数参数名称，如 `<bean id="cdPlayer" class="com.hao.entity.CDPlayer" c:_0-ref="sgtPeppers" />`，其中 `_0` 表示构造器的第 0 个参数，其他成分的含义和 `c:cd-ref` 相同
- 还有另一种方式，不用标注参数位置，而是根据类型，此时要求参数列表不能有相同类型（我猜测，没验证），配置为：`<bean id="cdPlayer" class="com.hao.entity.CDPlayer" c:_-ref="sgtPeppers" />`
- 不建议采用这种方式，跑是能跑，但是 spring.xml 文件会报错

**将常量值注入到构造器中**

- 注入常量值可以理解为对基本类型以及 String 类型的注入
- 我们创建如下的 BlankDisk 来说明常量值的注入，该类实现了 CompactDisc 接口，是一个空白的 CD 类
```java
package com.hao.entity;

public class BlankDisk implements CompactDisc {

    private String title;
    private String artist;

    public BlankDisk(String title, String artist) {
        this.title = title;
        this.artist = artist;
    }

    public BlankDisk() {

    }

    @Override
    public void play() {
        System.out.println("BlankDisk : Playing " + title + " by " + artist);
    }
}
```
- 之后，我们创建一个该类型的 Bean，并在创建时注入标题和艺术家（都是 String 类型），并将其注入到 cdPlayer 中：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:c="http://www.springframework.org/schema/c"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="compactDisk" class="com.hao.entity.BlankDisk">
        <constructor-arg name="title" value="千里之外" />
        <constructor-arg name="artist" value="周杰伦" />
    </bean>

    <bean class="com.hao.entity.CDPlayer" id="cdPlayer" c:cd-ref="compactDisk"/>

</beans>
```
- 运行单元测试代码查看情况，可以得到输出 `BlankDisk : Playing 千里之外 by 周杰伦`
- 对用常量值的注入，`<constructor-arg>` 不再使用 ref 属性而是使用 value 属性
- 也可以采用 `c-命名空间` 注入常量值，例如基于名称的配置 `<bean id="compactDisk" class="com.hao.entity.BlankDisk" c:title="千里之外" c:artist="周杰伦"/>` 或是基于参数位置的配置 `<bean id="compactDisk" class="com.hao.entity.BlankDisk" c:_0="千里之外" c:_1="周杰伦"/>`
- 注意，这个例子不能使用 `_` 进行自动匹配，因为两个参数都是 String 类型，Spring 不知道哪个值对应哪个参数，这也是为什么不建议该种方式的原因，一般来说，按位置是比较建议的
- 可以看到，对于常量值的注入，和装配引用的区别就是去掉了 `-ref` 后缀，
- 在装配 Bean 和字面值常量方面，`<constructor-arg>` 和 `c-命名空间` 的功能是相同的，但对于集合类型的装配，`c-命名空间` 无法做到

**集合装配**

- 现实中的一张 CD 应该除了标题与作者外，应该还含有多个磁道，每个磁道上包含一首歌，我们在这样一个基础上对 CD 建模，修改前面的 BlankDisc 得到如下代码：
```java
package com.hao.entity;

import java.util.List;

public class BlankDisk implements CompactDisc {

    private String title;
    private String artist;
    private List<String> tracks;


    public BlankDisk() {

    }

    public BlankDisk(String title, String artist, List<String> tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public List<String> getTracks() {
        return tracks;
    }

    public void setTracks(List<String> tracks) {
        this.tracks = tracks;
    }

    @Override
    public void play() {
        System.out.println("BlankDisk : Playing " + title + " by " + artist);
        if (tracks != null) {
            for (String track : tracks) {
                System.out.println("-Track:" + track);
            }
        }
    }
}
```
- 我们可以先简单地初始化，即不提供 List，相当于一张 CD 只有专辑名称和歌手，没有曲目
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:c="http://www.springframework.org/schema/c"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="compactDisk" class="com.hao.entity.BlankDisk">
        <constructor-arg value="范特西" name="title"/>
        <constructor-arg value="周杰伦" name="artist" />
        <constructor-arg name="tracks"><null /></constructor-arg>
    </bean>

    <bean class="com.hao.entity.CDPlayer" id="cdPlayer" c:cd-ref="compactDisk"/>

</beans>
```
- 为了配置曲目，我们需要 `<list>` 元素，将 CompactDisc 改为如下配置：
```xml
<bean id="compactDisk" class="com.hao.entity.BlankDisk">
    <constructor-arg value="范特西" name="title"/>
    <constructor-arg value="周杰伦" name="artist" />
    <constructor-arg name="tracks">
        <list>
            <value>爱在西元前</value>
            <value>爸我回来了</value>
            <value>简单爱</value>
            <value>忍者</value>
            <value>开不了口</value>
            <value>上海一九四三</value>
            <value>对不起</value>
            <value>威廉古堡</value>
            <value>双截棍</value>
            <value>安静</value>
        </list>
    </constructor-arg>
</bean>
```
- 执行单元测试，可以观测到打印的磁道，表示常量值的 List 注入成功
- 若 List 的每个元素不是常量值而是对象，可以使用 `<ref>` 元素代替上述 `<value>` 元素进行对象注入，其中每个对象都是 Spring 中已经配置或扫描到的
- `<list>` 元素对应的类型是 `java.util.List` 接口类型，对于 `<set>` 元素与 `java.util.Set` 接口类型类似
- 需要注意的是，不管是 list 还是 set，在类成员中声明的都应该是接口类型，Spring 会自动注入对应的实现类 （不是 ArrayList 而是 Spring 自己实现的）
- 可以尝试将上述代码中的 tracks 更改为 `java.util.Set` 接口类型，然后注入时使用 `<set>` 标签，能得到类似的效果
- 二者的区别就是，Set 会删除重复的元素，并忽略存放顺序 （但经过我测试，即使是 Set 好像顺序也是按你声明的 value 的顺序，保持疑问）
- 在装配集合方面，`<constructor-arg>` 比 `c-命名空间` 具有优势，`c-命名空间` 目前还无法装配集合

### 2.4.4 设置属性

- 到目前为止，讲解的都是基于构造器注入，现在讲讲基于 setter 方法注入，首先要求 Bean 实现 setter 方法，这点前面的代码已经做到
- 选择构造器注入还是属性注入？ --- 一般来说对于强依赖使用构造器注入，但是对于可选性的依赖建议使用属性注入
- 注入属性可以使用 `<property>` 元素，例如：
```xml
<bean class="com.hao.entity.CDPlayer" id="cdPlayer">
    <property name="cd" ref="compactDisk"/>
</bean>
```
- 类似 `c-命名空间`，对于属性注入，Spring 提供了 `p-命名空间` 用于替代 `<property>` 元素，要使用 `p-命名空间` 必须要在 XML 文件头部中进行声明，添加 `xmlns:p="http://www.springframework.org/schema/p"`
- 之后，便可以使用 `p-命名空间` 装配属性，如 `<bean class="com.hao.entity.CDPlayer" id="cdPlayer" p:cd-ref="compactDisk" />`
- `p-命名空间` 的属性约定和 `c-命名空间` 类似，此处不再赘述

**将字面量注入到属性中**

- 和构造器类似，也可以利用 setter 注入常量值
- 首先，要使用属性注入，一般要求实体符合 JavaBean 规范，即要有默认构造器以及包含对应的属性的 getter/setter，这点我们前面的 BlankDisc 已经符合要求
- 然后可以使用 `<bean>` 元素配置实体，使用 `<property>` 元素或 `p-命名空间` 注入属性，如下面的 compactDisc 的配置：
```xml
<bean class="com.hao.entity.BlankDisk" id="compactDisk">
    <property name="title" value="范特西" />
    <property name="artist" value="周杰伦" />
    <property name="tracks">
        <list>
            <value>爱在西元前</value>
            <value>爸我回来了</value>
            <value>简单爱</value>
            <value>忍者</value>
            <value>开不了口</value>
            <value>上海一九四三</value>
            <value>对不起</value>
            <value>威廉古堡</value>
            <value>双截棍</value>
            <value>安静</value>
        </list>
    </property>
</bean>
```
- 也可以利用 `p-命名空间`，注意 list 不能使用命名空间
```xml
<bean class="com.hao.entity.BlankDisk" id="compactDisk" p:artist="周杰伦" p:title="范特西">
    <property name="tracks">
        <list>
            <value>爱在西元前</value>
            <value>爸我回来了</value>
            <value>简单爱</value>
            <value>忍者</value>
            <value>开不了口</value>
            <value>上海一九四三</value>
            <value>对不起</value>
            <value>威廉古堡</value>
            <value>双截棍</value>
            <value>安静</value>
        </list>
    </property>
</bean>
```
- 还可以利用 `util-命名空间` 提供的 `<util:list>` 元素配置一个通用的 List，然后就可以在 Bean 的 `p-命名空间` 中直接饮用 List
- 首先， XML 要先引入 util 命名空间：
```xml
<beans xmlns="http://www.springframework.org/schema/beans"
       ...
       xmlns:util="http://www.springframework.org/schema/util"
       xsi:schemaLocation="...
        http://www.springframework.org/schema/util
        http://www.springframework.org/schema/util/spring-util.xsd">
```
- 然后配置 `<util:list>` 元素并在 bean 中使用 `p-命名空间` 引用它，最终配置如下
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:util="http://www.springframework.org/schema/util"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/util
        http://www.springframework.org/schema/util/spring-util.xsd">

    <util:list id="trackList">
        <value>爱在西元前</value>
        <value>爸我回来了</value>
        <value>简单爱</value>
        <value>忍者</value>
        <value>开不了口</value>
        <value>上海一九四三</value>
        <value>对不起</value>
        <value>威廉古堡</value>
        <value>双截棍</value>
        <value>安静</value>
    </util:list>

    <bean class="com.hao.entity.BlankDisk" id="compactDisk" p:artist="周杰伦" p:title="范特西" p:tracks-ref="trackList" />

    <bean class="com.hao.entity.CDPlayer" id="cdPlayer" p:cd-ref="compactDisk" />

</beans>
```
- 之后，我们运行单元测试类，确保配置正确
- `util-命名空间` 提供了下列常用的工具，详细可以查看文档

|元素|描述|
|:---:|:---:|
|`<util:constant>`|引用某个类型的 public static 域，并将其暴露为 bean |
|`<util:list>`|创建一个 java.util.List 类型的 bean，其中包含值或引用|
|`<util:map>`|创建一个 java.util.Map 类型的 bean，其中包含值或引用|
|`<util:properties>`|创建一个 java.util.Properties 类型的 bean|
|`<util:property-path>`|引用一个 bean 的属性（或内嵌属性），并将其暴露为 bean|
|`<util:set>`|创建一个 java.util.Set 类型的 bean，其中包含值或引用|

## 2.5 导入和混合配置

- 在典型的 Spring 应用中，一般会同时使用自动化和显式配置，即使你更喜欢使用 JavaConfig，但有的时候 XML 确实是最佳方案
- 在 Spring 中，这些都不是互斥的，我们可以将 JavaConfig 的组件扫描和自动装配以及 XML 混合在一起
- 混合配置，最关键的一点就是：不要在意装配的 bean 来自哪里，而是当做是从 Spring 容器中取出来的即可，而不管它们是在 JavaConfig 或 XML 中声明的还是通过组件扫描获取到的

### 2.5.1 在 JavaConfig 中引用 XML 配置

**JavaConfig 引入其他 JavaConfig**

- JavaConfig 引入其他 JavaConfig 使用 `@Import` 注解
- 首先，在 JavaConfig 中可以进行拆分，然后利用 `@Import` 注解导入其他 JavaConfig 的配置到一个总的配置
- 首先，我们将 compactDisc 的创建拆分到 CDConfig
```java
@Configuration
public class CDConfig {
    @Bean
    public CompactDisc compactDisc() {
        return new SgtPeppers();
    }
}
```
- 然后，在 CDPlayerConfig 使用 `@Import` 注解引入 CDConfig，并将依赖的 bean 作为方法参数即可，Spring 会自动将 bea 传递给方法参数
```java
@Configuration
@Import(CDConfig.class)
public class CDPlayerConfig {
    @Bean
    public MediaPlayer cdPlayer(CompactDisc compactDisc) {
        return new CDPlayer(compactDisc);
    }
}
```
- 或者也可以 CDPlayerConfig 不引入其他配置，在一个总的 JavaConfig 中引入所有分散的配置，Spring 会自动识别并注入（这种方式 idea 会给我报错，由于在 CDPlayerConfig 没有 Import CDConfig，它会报错说 compactDisc 不能注入，但实际上我做单元测试是能运行的，应该是 IDE 的缺陷），三个配置类的代码如下，其中 BaseConfig 是总的 JavaConfig：
```java
@Configuration
public class CDConfig {
    @Bean
    public CompactDisc compactDisc() {
        return new SgtPeppers();
    }
}


@Configuration
public class CDPlayerConfig {
    @Bean
    public MediaPlayer cdPlayer(CompactDisc compactDisc) {
        return new CDPlayer(compactDisc);
    }
}


@Configuration
@Import({CDConfig.class, CDPlayerConfig.class})
public class BaseConfig {


}
```

**JavaConfig 引入 XML**

- 使用 `@ImportResource` 注解引入 XML 文件
- 我们不使用 CDConfig 而是在 XML 中配置 compactDisc
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:util="http://www.springframework.org/schema/util"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/util
        http://www.springframework.org/schema/util/spring-util.xsd">

    <util:list id="trackList">
        <value>爱在西元前</value>
        <value>爸我回来了</value>
        <value>简单爱</value>
        <value>忍者</value>
        <value>开不了口</value>
        <value>上海一九四三</value>
        <value>对不起</value>
        <value>威廉古堡</value>
        <value>双截棍</value>
        <value>安静</value>
    </util:list>

    <bean class="com.hao.entity.BlankDisk" id="compactDisk" p:artist="周杰伦" p:title="范特西" p:tracks-ref="trackList" />

</beans>
```
- 然后，在前面的总的 BaseConfig 类中引入该 XML 文件，以及 CDPlayerConfig 以实现混合配置，CDPlayerConfig 类代码不变（IDEA 仍然会报错说找不到依赖的 compactDisc，但实际上能运行，因为 compactDisc 是运行时候找容器要的，静态的代码检测不出来所以给你报错）：
```java
@Configuration
@Import({ CDPlayerConfig.class})
@ImportResource("classpath:spring.xml")
public class BaseConfig {


}
```

### 2.5.2 在 XML 中引用 JavaConfig


- 在 XML 中可以使用 `<import>` 元素引入其他 XML 配置文件，以实现 XML 配置文件的拆分
- 事实上，没有特定的元素将 JavaConfig 导入到 XML，但可以使用 bean 元素直接将 JavaConfig 导入到 XML 中
- 可以配置一个总的 XML，在该 XML 内部用 `<import>` 元素导入其他 XML 的配置，用 `<bean>` 元素导入 JavaConfig 的配置
- 我们打算使用 CDConfig 声明 compactDisc，然后在子 XML 文件中声明 CDPlayer 类型，并引用 compactDisc，最后，使用一个总的 XML 文件引用这两个子配置：
- CDConfig 代码如下：
```java
@Configuration
public class CDConfig {
    @Bean
    public CompactDisc compactDisc() {
        return new SgtPeppers();
    }
}
```
- 子 XML 文件 cdplayer-config.xml 如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean class="com.hao.entity.CDPlayer" id="cdPlayer">
        <property name="cd" ref="compactDisc"/>
    </bean>

</beans>
```
- 总 XML 文件 spring.xml 如下：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:util="http://www.springframework.org/schema/util"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/util
        http://www.springframework.org/schema/util/spring-util.xsd">

    <bean class="com.hao.cfg.CDConfig"/>
    <import resource="classpath:com/hao/entity/cdplayer-config.xml"/>

</beans>
```

- 不管是使用 JavaConfig 还是使用 XML 进行装配，通常都需要创建一个根配置，用这个根配置将多个装配类或 XML 文件组合起来
- 一般也会在根配置中启用组件扫描 `<context:component-scan>` 或 `@Component`

## 2.6 小结

- Spring 框架的核心是 Spring 容器，以及基于容器的 IoC 和 AOP 概念
- 配置 Bean 主要有三种方式，它们之间不会互相排斥，可以同时使用：
    - 自动化 （为了减少配置，一般都会开启）
    - 基于 JavaConfig （除了自动扫描外，自己要配置的 Bean 建议使用该方式）
    - 基于 XML （除非不可避免，否则尽量少使用该种方式）
- 基于 Java 的配置，它比基于 XML 的配置更加强大、类型安全并且易于重构

**自我理解**

- 对于一个项目，首先用一个总的配置（XML 或 JavaConfig 皆可），然后这个文件开启自动扫描
- 若需要分模块或单独配置部分 Bean，在其他子配置中进行配置，子配置优先采用 JavaConfig
- 最后，在总的配置中引入所有其他子配置即可

