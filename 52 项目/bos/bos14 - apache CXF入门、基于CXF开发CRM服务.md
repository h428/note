[TOC]

# apache CXF入门

> 官网：cxf.apache.org

## 一、服务端开发

1. 创建Web项目，导入项目jar包

2. 在web.xml中配置CXF提供的一个Servlet，用于发布服务

```
<servlet>
<servlet-name>cxf</servlet-name>
<servlet-class>org.apache.cxf.transport.servlet.CXFServlet</servlet-class>
<init-param>
<!-- 这是配置文件的默认值 -->
<param-name>config-location</param-name>
<param-value>classpath:cxf.xml</param-value>
</init-param>
</servlet>
<servlet-mapping>
<servlet-name>cxf</servlet-name>
<url-pattern>/service/*</url-pattern>
</servlet-mapping>
```

3. 指定配置文件，若不想使用，可在servlet中配置初始化参数，若不指定默认为

```
<init-param>
<!-- 这是配置文件的默认值 -->
<param-name>config-location</param-name>
<param-value>/WEB-INF/cxf-servlet.xml</param-value>
</init-param>
```

4. 在类路径下提供cxf.xml配置文件(就是一个Spring配置文件)

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:jaxws="http://cxf.apache.org/jaxws"
xmlns:soap="http://cxf.apache.org/bindings/soap"
xsi:schemaLocation="
http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
http://cxf.apache.org/bindings/soap http://cxf.apache.org/schemas/configuration/soap.xsd
http://cxf.apache.org/jaxws http://cxf.apache.org/schemas/jaxws.xsd">

</beans>
```

5. 开发一个接口和实现类

```
/**
* 注意注解必须放在接口上
*/
@WebService
public interface HelloService {

String sayHello(String name);

}

public class HelloServiceImpl implements HelloService{

@Override
public String sayHello(String name) {
System.out.println("基于CXF开发的服务端sayHello方法被调用了");
return "hello,"+name;
}

}
```

6. 在cxf.xml中注册服务

```
<!-- 配置bean -->
<bean id="helloService" class="com.hao.service.HelloServiceImpl"></bean>
<!-- 注册服务 -->
<jaxws:server id="myService" address="/hello">
<jaxws:serviceBean>
<ref bean="helloService"/>
</jaxws:serviceBean>
</jaxws:server>
```

7. 访问http://localhost:8080/TestCXF/service/hello?wsdl观察结果


## 二、使用wsimport命令完成客户端开发

1. 进入生成代码的目录，在命令行输入` wsimport -s . -p com.hao.service http://localhost:8080/TestCXF/service/hello?wsdl`

2. 将生成的java代码复制到项目中，创建调用类测试调用

```
public class App {
public static void main(String[] args) {
HelloServiceImplService ss = new HelloServiceImplService();
HelloService proxy = ss.getHelloServiceImplPort();
String res = proxy.sayHello("world");
System.out.println(res);
}
}
```

## 三、使用CXF完成客户端开发

1. 客户端工程也需要导入cxf的jar包才能使用这种方式进行调用

2. 使用wsimport或者CXF提供的wsdl2java生成本地代码

```
.\wsdl2java -d E:\test\ -p com.hao.service http://localhost:8080/TestCXF/service/hello?wsdl
```

3. 只需将接口文件拷贝到目标项目，更改报错(删除ObjectFactory.class)

4. 提供Spring配置文件，注册客户端代理对象

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:jaxws="http://cxf.apache.org/jaxws"
xmlns:soap="http://cxf.apache.org/bindings/soap"
xsi:schemaLocation="
http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
http://cxf.apache.org/bindings/soap http://cxf.apache.org/schemas/configuration/soap.xsd
http://cxf.apache.org/jaxws http://cxf.apache.org/schemas/jaxws.xsd">


<!-- 注册CXF客户端代理对象，通过Spring框架创建代理对象，使用代理对象实现远程调用 -->
<jaxws:client id="myClient" address="http://localhost:8080/TestCXF/service/hello" serviceClass="com.hao.service.HelloService">
</jaxws:client>

</beans>
```

5. 创建调用代码，注意要从Spring上下文获取代理对象

```
public class App {

public static void main(String[] args) {

ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("cxf.xml");
HelloService proxy = (HelloService) context.getBean("myClient");
String res = proxy.sayHello("World!");
System.out.println("CXF client:"+res);
context.close();
}
}
```

# 基于CXF开发CRM服务

注意：理论上crm不应该由我们自己开发，应该有其他人开发，我们只负责调用

## 一、crm数据库幻境搭建

1.`create database crm character set utf8 collate utf8_general_ci;`

2. 执行sql创建表

```
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `t_customer`
-- ----------------------------
DROP TABLE IF EXISTS `t_customer`;
CREATE TABLE `t_customer` (
`id` int(11) NOT NULL auto_increment,
`name` varchar(255) default NULL,
`station` varchar(255) default NULL,
`telephone` varchar(255) default NULL,
`address` varchar(255) default NULL,
`decidedzone_id` varchar(255) default NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of t_customer
-- ----------------------------
INSERT INTO `t_customer` VALUES ('1', '张三', '百度', '13811111111', '北京市西城区长安街100号', null);
INSERT INTO `t_customer` VALUES ('2', '李四', '哇哈哈', '13822222222', '上海市虹桥区南京路250号', null);
INSERT INTO `t_customer` VALUES ('3', '王五', '搜狗', '13533333333', '天津市河北区中山路30号', null);
INSERT INTO `t_customer` VALUES ('4', '赵六', '联想', '18633333333', '石家庄市桥西区和平路10号', null);
INSERT INTO `t_customer` VALUES ('5', '小白', '测试空间', '18511111111', '内蒙古自治区呼和浩特市和平路100号', null);
INSERT INTO `t_customer` VALUES ('6', '小黑', '联想', '13722222222', '天津市南开区红旗路20号', null);
INSERT INTO `t_customer` VALUES ('7', '小花', '百度', '13733333333', '北京市东城区王府井大街20号', null);
INSERT INTO `t_customer` VALUES ('8', '小李', '长城', '13788888888', '北京市昌平区建材城西路100号', null);
```

## 二、crm项目搭建

1. 创建动态Web项目crm

2. 导入cxf相关jar包，注意没有Hibernate和Struts2的jar包，但有Spring的，可以用其jdbc模板

3. 配置web.xml，利用Spring监听器直接启动上下文

```
<listener>
<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<context-param>
<param-name>contextConfigLocation</param-name>
<param-value>classpath:cxf.xml</param-value>
</context-param>

<servlet>
<servlet-name>cxf</servlet-name>
<servlet-class>org.apache.cxf.transport.servlet.CXFServlet</servlet-class>
</servlet>
<servlet-mapping>
<servlet-name>cxf</servlet-name>
<url-pattern>/service/*</url-pattern>
</servlet-mapping>
```

4. 在类路径下提供cxf.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:jaxws="http://cxf.apache.org/jaxws"
xmlns:soap="http://cxf.apache.org/bindings/soap"
xsi:schemaLocation="
http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
http://cxf.apache.org/bindings/soap http://cxf.apache.org/schemas/configuration/soap.xsd
http://cxf.apache.org/jaxws http://cxf.apache.org/schemas/jaxws.xsd">


</beans>
```

5. 针对t_customer表创建一个实体类Customer

```
public class Customer implements java.io.Serializable {

private static final long serialVersionUID = 1L;

private Integer id;
private String name;
private String station;
private String telephone;
private String address;
private String decidedzoneId;

public Customer() {
}
}
```

6. 创建CustomerService接口

```
@WebService
public interface CustomerService {

/**
* 查询所有客户
* @return
*/
List<Customer> list(); 

}
```

7. CustomerServiceImpl实现类

```
@Transactional(isolation=Isolation.REPEATABLE_READ, readOnly=false)
public class CustomerServiceImpl implements CustomerService{

@Override
public List<Customer> list() {

String sql = "select * from t_customer";
List<Customer> customerList = jdbcTemplate.query(sql, new RowMapper<Customer>(){

@Override
public Customer mapRow(ResultSet rs, int arg1) throws SQLException {
//根据字段名称从结果集中获取对应的值
int id = rs.getInt("id");
String name = rs.getString("name");
String station = rs.getString("station");
String telephone = rs.getString("telephone");
String address = rs.getString("address");
String decidedzoneId = rs.getString("decidedzone_id");

Customer c = new Customer(id, name, station, telephone, address, decidedzoneId);
return c;
}});
return customerList;
}

private JdbcTemplate jdbcTemplate;

public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
this.jdbcTemplate = jdbcTemplate;
}
}
```

8. 配置cxf.xml进行服务注册，以及其他所需要的bean

```
<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
<property name="driverClassName" value="com.mysql.jdbc.Driver" />
<property name="url" value="jdbc:mysql:///crm?useUnicode=true&amp;characterEncoding=utf8" />
<property name="username" value="root" />
<property name="password" value="h66666" />
</bean>

<!-- 配置核心事务管理器，必须提供数据源 -->
<bean name="transactionManager"
class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
<property name="dataSource" ref="dataSource" />
</bean>

<!-- 开启注解事务 -->
<tx:annotation-driven transaction-manager="transactionManager" />

<!-- my jdbcTemplate, no use JdbcDaoSupport -->
<bean name="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
<property name="dataSource" ref="dataSource"></property>
</bean>

<bean id="customerService" class="com.hao.crm.service.CustomerServiceImpl">
<property name="jdbcTemplate" ref="jdbcTemplate"/>
</bean>

<jaxws:server id="myCrmService" address="/customer">
<jaxws:serviceBean>
<ref bean="customerService"/>
</jaxws:serviceBean>
</jaxws:server
```

9. 访问`http://localhost:8080/CRM/service/customer?wsdl`测试服务是否发布正常

## 三、客户端调用服务进行测试

1. 执行命令 `wsimport -s . -p com.hao.crm.service http://localhost:8080/CRM/service/customer?wsdl`

2. 创建项目，引入cxf依赖包，复制wsimport命令生成的java类（若使用CXF则只需要复制CustomerService一个类即可）

3. 配置cxf.xml(若不使用cxf进行测试，可以省略此步骤)

```
<!-- 注册CXF客户端代理对象，通过Spring框架创建代理对象，使用代理对象实现远程调用 -->
<jaxws:client id="customerService" address="http://localhost:8080/CRM/service/customer" serviceClass="com.hao.crm.service.CustomerService">
</jaxws:client>
```
4. 创建客户端测试代码

```
public class App {

public static void testWithJava(){
CustomerServiceImplService ss = new CustomerServiceImplService();
CustomerService proxy = ss.getCustomerServiceImplPort();
List<Customer> list = proxy.list();
for (Customer customer : list) {
System.out.println(customer);
}
}

public static void testWithSpring(){
ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("cxf.xml");
CustomerService proxy = (CustomerService) context.getBean("customerService");
List<Customer> list = proxy.list();
for (Customer customer : list) {
System.out.println(customer);
}
context.close();
}

public static void main(String[] args) {
//	testWithJava();
testWithSpring();
}

}

```

5. 调用无错误，则CRM模块开发完毕，等待bos项目调用
