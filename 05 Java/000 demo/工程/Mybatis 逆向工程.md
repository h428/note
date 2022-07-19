
# 1. 概述

- [官方文档](http://www.mybatis.org/generator/index.html)
- MyBatis 逆向工程（MyBatis Generator, MGB）用于从数据库逆向出 pojo，mapper 接口以及对应的 XML 配置文件
- 逆向工程需要提供下述配置：
    - generatorConfig.xml : 主配置，配置数据源、pojo、Mapper等具体信息
    - log4j.properties : 日志文件
    - MyBatisGeneratorApp : 一个用于运行的 Java 类，可以任意取名

# 2. 重要配置 generatorConfig.xml

- generatorConfig.xml 是最主要的配置，所有数据源，生成的详细代码等都在改文件中格式
- `<jdbcConnection>` 元素用于配置数据源信息
- `<javaModelGenerator>` 元素用于配置 pojo 的信息
- `<sqlMapGenerator>` 元素用于配置 mapper xml 文件的信息
- `<javaClientGenerator>` 元素用于配置 mapper 接口的信息
- `<table>` 元素用于配置要逆向的数据表

# 3. 构建步骤

- 首先，创建 maven 普通项目，并在 pom 文件中引入所需依赖
```xml
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
</dependency>
<!--MyBatis Generator -->
<dependency>
    <groupId>org.mybatis.generator</groupId>
    <artifactId>mybatis-generator-core</artifactId>
    <version>1.3.5</version>
</dependency>
<!--mysql-connector-java -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.38</version>
</dependency>
<!--mybatis -->
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.2.1</version>
</dependency>
```

- 然后，在 src/main/resources 下提供 log4j.properties 配置文件
- 然后，在 src/main/resources 下编写逆向配置文件 generatorConfig.xml 如下
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
    <context id="testTables" targetRuntime="MyBatis3">


        <!--生成的实体类自动实现 Serializable 接口的插件（分布式项目需要）-->
        <!--<plugin type="org.mybatis.generator.plugins.SerializablePlugin" />-->

        <!--自定义的插件类，生成的和实体相关的 Example 以及内部的类都实现 Serializable 接口的插件-->
        <!--<plugin type="util.MySerializablePlugin"/>-->

        <commentGenerator>
            <!-- 是否去除自动生成的注释 true：是 ： false:否 -->
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>
        <!--数据库连接的信息：驱动类、连接地址、用户名、密码 -->
        <jdbcConnection driverClass="com.mysql.jdbc.Driver"
                        connectionURL="jdbc:mysql://localhost:3306/example" userId="root"
                        password="root">
        </jdbcConnection>
        <!-- <jdbcConnection driverClass="oracle.jdbc.OracleDriver"
            connectionURL="jdbc:oracle:thin:@127.0.0.1:1521:yycg"
            userId="yycg"
            password="yycg">
        </jdbcConnection> -->

        <!-- 默认false，把JDBC DECIMAL 和 NUMERIC 类型解析为 Integer，为 true时把JDBC DECIMAL 和
            NUMERIC 类型解析为java.math.BigDecimal -->
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false"/>
        </javaTypeResolver>

        <!-- targetProject:生成PO类的位置 -->
        <javaModelGenerator targetPackage="com.hao.entity"
                            targetProject=".\src\main\java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false"/>
            <!-- 从数据库返回的值被清理前后的空格 -->
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>
        <!-- targetProject:mapper映射文件生成的位置 -->
        <sqlMapGenerator targetPackage="com.hao.mapper"
                         targetProject=".\src\main\java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false"/>
        </sqlMapGenerator>
        <!-- targetPackage：mapper接口生成的位置 -->
        <javaClientGenerator type="XMLMAPPER"
                             targetPackage="com.hao.mapper"
                             targetProject=".\src\main\java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false"/>
        </javaClientGenerator>
        <!-- 指定要逆向的数据库表 -->
        <table schema="" tableName="admin"></table>
        <table schema="" tableName="course"></table>
        <table schema="" tableName="female_student_health"></table>
        <table schema="" tableName="male_student_health"></table>
        <table schema="" tableName="student"></table>
        <table schema="" tableName="student_card"></table>
        <table schema="" tableName="student_class"></table>
        <table schema="" tableName="student_take_course"></table>
        <table schema="" tableName="teacher"></table>


        <!-- 有些表的字段需要指定java类型
         <table schema="" tableName="user">
            <columnOverride column="id" javaType="Long" />
        </table> -->
    </context>
</generatorConfiguration>
```

- 最后编写主类，运行上述文件即可
```java
public class MyBatisGeneratorApp {

    public void generator() throws Exception{

        List<String> warnings = new ArrayList<String>();
        boolean overwrite = true;
        //指定 逆向工程配置文件（从类路径读取）
        URL url = this.getClass().getClassLoader().getResource("generatorConfig.xml");
        System.out.println(url.getFile());
        File configFile = new File(url.getFile());
        ConfigurationParser cp = new ConfigurationParser(warnings);
        Configuration config = cp.parseConfiguration(configFile);
        DefaultShellCallback callback = new DefaultShellCallback(overwrite);
        MyBatisGenerator myBatisGenerator = new MyBatisGenerator(config,
                callback, warnings);
        myBatisGenerator.generate(null);

    }
    public static void main(String[] args) throws Exception {
        try {
            MyBatisGeneratorApp generatorSqlmap = new MyBatisGeneratorApp();
            generatorSqlmap.generator();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
```

# 4. 补充

- 有时，分布式下我们需要生成的实体类和 Example 类能实现 Serializable 接口，则还需要进行一些额外的配置，主要是通过 MyBatis 插件实现的
- 详细可参考前面配置文件的注释掉的 plugin 元素
- 其中 org.mybatis.generator.plugins.SerializablePlugin 是内置的一个插件，其给生成的实体类加上 Serializable 接口
- 如果我们需要为和实体相关的 Example 及其内部的内实现 Serializable 接口，则需要编写自定义的插件类
- 我们可以在 util 包下编写自定义插件类 MySerializablePlugin，内容如下
```java
public class MySerializablePlugin extends PluginAdapter {
    private FullyQualifiedJavaType serializable = new FullyQualifiedJavaType("java.io.Serializable");
    private FullyQualifiedJavaType gwtSerializable = new FullyQualifiedJavaType("com.google.gwt.user.client.rpc.IsSerializable");
    private boolean addGWTInterface;
    private boolean suppressJavaInterface;

    public MySerializablePlugin() {
    }

    public boolean validate(List<String> warnings) {
        return true;
    }

    public void setProperties(Properties properties) {
        super.setProperties(properties);
        this.addGWTInterface = Boolean.valueOf(properties.getProperty("addGWTInterface"));
        this.suppressJavaInterface = Boolean.valueOf(properties.getProperty("suppressJavaInterface"));
    }

    public boolean modelBaseRecordClassGenerated(TopLevelClass topLevelClass, IntrospectedTable introspectedTable) {
        this.makeSerializable(topLevelClass, introspectedTable);
        return true;
    }

    public boolean modelPrimaryKeyClassGenerated(TopLevelClass topLevelClass, IntrospectedTable introspectedTable) {
        this.makeSerializable(topLevelClass, introspectedTable);
        return true;
    }

    public boolean modelRecordWithBLOBsClassGenerated(TopLevelClass topLevelClass, IntrospectedTable introspectedTable) {
        this.makeSerializable(topLevelClass, introspectedTable);
        return true;
    }

    protected void makeSerializable(TopLevelClass topLevelClass, IntrospectedTable introspectedTable) {
        if (this.addGWTInterface) {
            topLevelClass.addImportedType(this.gwtSerializable);
            topLevelClass.addSuperInterface(this.gwtSerializable);
        }

        if (!this.suppressJavaInterface) {
            topLevelClass.addImportedType(this.serializable);
            topLevelClass.addSuperInterface(this.serializable);
            Field field = new Field();
            field.setFinal(true);
            field.setInitializationString("1L");
            field.setName("serialVersionUID");
            field.setStatic(true);
            field.setType(new FullyQualifiedJavaType("long"));
            field.setVisibility(JavaVisibility.PRIVATE);
            this.context.getCommentGenerator().addFieldComment(field, introspectedTable);
            topLevelClass.addField(field);
        }

    }

    @Override
    public boolean modelExampleClassGenerated(TopLevelClass topLevelClass, IntrospectedTable introspectedTable) {
        makeSerializable(topLevelClass, introspectedTable);

        for (InnerClass innerClass : topLevelClass.getInnerClasses()) {
            if ("GeneratedCriteria".equals(innerClass.getType().getShortName())) { //$NON-NLS-1$
                innerClass.addSuperInterface(serializable);
            }
            if ("Criteria".equals(innerClass.getType().getShortName())) { //$NON-NLS-1$
                innerClass.addSuperInterface(serializable);
            }
            if ("Criterion".equals(innerClass.getType().getShortName())) { //$NON-NLS-1$
                innerClass.addSuperInterface(serializable);
            }
        }

        return true;
    }
}
```
- 编写后，注意将插件配置到主配置文件中