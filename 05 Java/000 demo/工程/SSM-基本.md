
# 1. 依赖的 lib

**大致依赖内容**

- spring 核心包
- mybatis 核心包
- mybatis-spring 整合包
- 数据库驱动和数据库连接池
- json 转化工具 jackson
- junit 单元测试以及方便 Spring 单元测试的 spring-test 模块
- web 相关的 servlet, jsp, jstl

**Spring lib简介**

- Spring 4 共有 20 个包，配置时你不必显示配置所有的包，只需配置最后的，Maven 会自动导入依赖的模块
- 括号里的表示会自动依赖，非括号里的表示要配置，重复的内容依赖不再列出，当然配置方式不唯一，省略了 spring 前缀
- SSM 大概用到下面相关包：
    - Dao 层 : context(core, beans, aop, expression), oxm, jdbc(tx), test
    - Service 层 : aspects, jms(messaging)
    - Web 层 : context-support, webmvc(web)
- 其他一些未用到的包 : orm, portlet, instrument, instrument-tomcat, websocket

- pom 文件参考 pom 目录下的 [ssm.md](./pom/ssm.md)


# 2. 整合思路

- 编写 db.properties 文件，配置数据源信息
- 编写 mybatis.xml 文件，配置别名
- applicationContext-dao.xml 文件，配置数据源和连接池，以及配置 Mybatis 相关的组件，包括 SqlSessionFactory 实例和 mapper 扫描
- applicationContext-service.xml 文件，配置扫描包，扫描 Service 组件，以及配置事务管理
- springmvc.xml 文件，配置 Controller 扫描和以及三大组件（处理器映射器、处理器适配器和视图解析器）
- 在 web.xml 中配置前端控制器 DispatchServlet 并提供 spring.xml 和拦截请求，此外还要配置一个监听器加载各个 Spring 配置文件以及一个 Post 乱码过滤器
- 整合有配置文件和注解两种方式，建议采用注解方式，但是注解方式依赖 Servlet 3.0 规范以后的容器

# 3. 数据库准备

- 参考 [maven.sql](./sql/maven.sql.md)


# 4. 传统整合（基于配置文件启动）

## 4.1 整合 Dao 层：Mybatis 整合到 Spring

- 在 resources 下提供 log4j.properties，配置日志环境
- 利用逆向工程从数据库生成对应的实体和 Mapper 文件以及实现，用于快速测试
- 在 resources 中编写 db.properties 文件配置数据源
- 在 resources 中编写 mybatis 的配置文件 mybatis.xml，并配置分页插件
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <plugins>
        <!-- com.github.pagehelper为PageHelper类所在包名 -->
        <plugin interceptor="com.github.pagehelper.PageInterceptor">
            <!-- 使用下面的方式配置参数，后面会有所有的参数介绍 -->
            <property name="helperDialect" value="mysql"/>
        </plugin>
    </plugins>
    
</configuration>
```
- 在 resources 中编写 applicationContext-dao.xml 文件，配置数据库连接池和 Mybatis 组件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:context="http://www.springframework.org/schema/context" xmlns:p="http://www.springframework.org/schema/p"
       xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd
	http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.2.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.2.xsd
	http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.2.xsd">

    <!-- 数据库连接池 -->
    <!-- 加载配置文件 -->
    <context:property-placeholder location="classpath:db.properties" />
    <!-- 数据库连接池 -->
    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource"
          destroy-method="close">
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
        <property name="driverClassName" value="${jdbc.driver}" />
        <property name="maxActive" value="10" />
        <property name="minIdle" value="5" />
    </bean>
    <!-- 让spring管理sqlsessionfactory 使用mybatis和spring整合包中的 -->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <!-- 数据库连接池 -->
        <property name="dataSource" ref="dataSource" />
        <!-- 加载mybatis的全局配置文件 -->
        <property name="configLocation" value="classpath:mybatis.xml" />
    </bean>
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="com.hao.mapper" />
    </bean>

    <!--id 生成器，数据中心 id 和机器 id 可以使用配置文件注入-->
    <bean class="com.hao.util.SnowflakeIdWorker">
        <constructor-arg value="0" />
        <constructor-arg value="0" />
    </bean>
</beans>
```
- 导入 EntityUtil 和 SnowFlakeIdWorker 两个工具类，其中 EntityUtil 用于打印实体对象，SnowFlakeIdWorker 用于 Id 生成
- 执行单元测试，测试整合是否正确，为了完整性，测试所有 CRUD 方法
```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext-dao.xml")
public class AdminMapperTest {
    @Autowired
    AdminMapper adminMapper;
    @Autowired
    SnowflakeIdWorker snowflakeIdWorker;
    @Test
    public void testAdd() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId(String.valueOf(snowflakeIdWorker.nextId()));
        adminMapper.insertSelective(admin);
    }
    @Test
    public void testUpdate() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId("542639870493851648");
        adminMapper.updateByPrimaryKeySelective(admin);
    }
    @Test
    public void testDelete() {
        adminMapper.deleteByPrimaryKey("542640461362233344");
    }
    @Test
    public void testGet() {
        Admin admin = adminMapper.selectByPrimaryKey("1");
        EntityUtil.printString(admin);
    }
    @Test
    public void testPageList(){
        // 每页 2 条，查询第一页
        PageHelper.startPage(2, 7);
        // 用于设置查询条件的 example，此处不设置
        AdminExample example = new AdminExample();
        // 执行条件查找
        List<Admin> adminList = adminMapper.selectByExample(example);
        // 查找结果封装成 PageInfo 返回
        PageInfo<Admin> pageInfo = new PageInfo<>(adminList);
        // 打印分页相关信息
        System.out.println(pageInfo.getTotal()); // 总记录数
        System.out.println(pageInfo.getPages()); // 总页数
        System.out.println(pageInfo.getPageNum()); // 本次查询第几页
        System.out.println(pageInfo.getPageSize());  // 本次查询每页显示几条
        System.out.println(pageInfo.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageInfo.getList()); // 本次查询的结果
    }
}
```

## 4.2 整合 Service 层：事务控制

- 在 resources 中编写 applicationContext-service.xml 文件，配置下述内容
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:context="http://www.springframework.org/schema/context" xmlns:p="http://www.springframework.org/schema/p"
       xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd
	http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.2.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.2.xsd
	http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.2.xsd">

    <!-- 配置包扫描器 -->
    <context:component-scan base-package="com.hao.service"/>

    <!-- 事务管理器 -->
    <bean id="transactionManager"
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <!-- 数据源 -->
        <property name="dataSource" ref="dataSource" />
    </bean>
    <!-- 通知 -->
    <tx:advice id="txAdvice" transaction-manager="transactionManager">
        <tx:attributes>
            <!-- 传播行为 -->
            <tx:method name="save*" propagation="REQUIRED" />
            <tx:method name="insert*" propagation="REQUIRED" />
            <tx:method name="add*" propagation="REQUIRED" />
            <tx:method name="create*" propagation="REQUIRED" />
            <tx:method name="delete*" propagation="REQUIRED" />
            <tx:method name="update*" propagation="REQUIRED" />
            <tx:method name="find*" propagation="SUPPORTS" read-only="true" />
            <tx:method name="select*" propagation="SUPPORTS" read-only="true" />
            <tx:method name="get*" propagation="SUPPORTS" read-only="true" />
        </tx:attributes>
    </tx:advice>
    <!-- 切面 -->
    <aop:config>
        <aop:advisor advice-ref="txAdvice"
                     pointcut="execution(* com.hao.service..*.*(..))" />
    </aop:config>

</beans>
```
- 编写 BaseService 以抽象单表的 CRUD 方法：
```java
/**
 * 抽象的 Service，其他 Service 继承该 Service 后自动具有单标 CRUD
 * @param <T1> 实体类型，如 Admin
 * @param <T2> 实体对应的 Mybatis 查询类型，如 AdminExample
 */
public abstract class BaseService<T1, T2> {

    // 子类继承时再赋值，对应注入的具体的 mapper
    private Object baseMapper;
    // 存储 mapper 的 class
    private Class<?> clazz;

    // Id 生成器
    @Autowired
    private SnowflakeIdWorker snowflakeIdWorker;

    /**
     * 调用该方法初始化 mapper
     * @param baseMapper 子类中注入的 mapper
     */
    protected void initMapper(Object baseMapper){
        this.baseMapper = baseMapper;
        this.clazz = baseMapper.getClass();
    }

    /**
     * 初始化方法，根据生命周期 @PostConstruct 使得在 Spring 注入 Bean 之后执行初始化，
     * 实现该方法时必须调用 initMapper() 方法初始化 mapper
     */
    @PostConstruct
    protected abstract void init();


    /**
     * 调用 mapper 的方法
     * @param methodName mapper 中的方法名
     * @param param mapper 方法参数
     * @return 返回对应方法的结果
     */
    private Object invokeMapperMethod(String methodName, Object param) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        // 反射调用 mapper 的方法执行删除
        Method method = clazz.getMethod(methodName, param.getClass());
        Object obj = method.invoke(baseMapper, param);
        return obj;
    }

    /**
     * 插入一条记录，返回插入行数，
     * @param entity 带插入的对象，要求已经设置主键
     * @return 返回新插入的主键，失败则返回 null
     */
    public String addEntity(T1 entity) {
        try {
            // 反射调用 entity 的 setId() 方法设置 Id
            Class<?> entityClass = entity.getClass();
            Method setId = entityClass.getMethod("setId", String.class);
            String id = String.valueOf(snowflakeIdWorker.nextId());
            setId.invoke(entity, id);
            // 然后反射调用 mapper 插入记录
            Object res = invokeMapperMethod("insertSelective", entity);
            if ((int)res != 0) {
                return id;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 删除对象，物理删除，还有一种软删除则需要利用 update 方法
     * @param entity 带有要删除 Id 的实体，内部已经设置了 deleteTime 列
     * @return 删除成功则返回删除成功的函数（应该是1）
     */
    public int deleteEntityById(T1 entity){
        int cnt = 0;
        try {
            // 反射调用 entity 的 getId() 方法获取 Id
            Class<?> entityClass = entity.getClass();
            Method getId = entityClass.getMethod("getId");
            Object id = getId.invoke(entity);
            cnt = (int) invokeMapperMethod("deleteByPrimaryKey", id);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return cnt;
    }

    /**
     * 根据 id 更新对象，注意列是条件化的
     * @param entity 被更新的对象
     * @return 更新成功返回更新的行数（应该是1）
     */
    public int updateEntityById(T1 entity) {
        int cnt = 0;
        try {
            // 更新对象
            cnt = (int) invokeMapperMethod("updateByPrimaryKeySelective", entity);
            return cnt;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cnt;
    }

    /**
     * 根据 Id 获取对象实体
     * @param id id
     * @return 对象实体
     */
    public T1 getEntityById(String id) {
        Method selectByPrimaryKey = null;
        T1 entity;
        try {
            // 根据主键选取对象
            selectByPrimaryKey = clazz.getMethod("selectByPrimaryKey", id.getClass());
            entity = (T1) selectByPrimaryKey.invoke(baseMapper, id);
            return entity;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 实体分页查询，如果要值查找出未删除的实体，要为 oredCriteria 添加删除条件才行
     * @param example 查询实体，调用之前需要添加删除条件 andDeleteTimeIsNull
     * @param pageNum  第几页
     * @param pageSize 每页记录数
     * @return 返回 PageInfo，其包括了分页所需要的各种信息和实体集合
     */
    public PageInfo<T1> getPageList(T2 example, int pageNum, int pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        try {
            // 根据主键选取对象
            Method selectByExample = clazz.getMethod("selectByExample", example.getClass());
            List<T1> entityList = (List<T1>) invokeMapperMethod("selectByExample", example);
            PageInfo<T1> pageInfo = new PageInfo<>(entityList);
            return pageInfo;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

- 编写 AdminService 并添加注解，简便起见这里直接创建类不再对接口编程了
```java
@Service
public class AdminService extends BaseService<Admin, AdminExample> {
    @Autowired
    private AdminMapper adminMapper;

    @Override
    protected void init() {
        initMapper(adminMapper);
    }
}
```
- 然后编写单元测试
```java
@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(locations = {"classpath:applicationContext-dao.xml", "classpath:applicationContext-service.xml"})
@ContextConfiguration("classpath*:applicationContext-*.xml")
public class AdminServiceTest {
    @Autowired
    AdminService adminService;
    @Test
    public void testAdd() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        adminService.addEntity(admin);
    }
    @Test
    public void testUpdate() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId("542639533754155008");
        adminService.updateEntityById(admin);
    }
    @Test
    public void testDelete() {
        Admin admin = new Admin();
        admin.setId("542660756382941184");
        adminService.deleteEntityById(admin);
    }
    @Test
    public void testGet() {
        Admin admin = adminService.getEntityById("1");
        EntityUtil.printString(admin);
    }
    @Test
    public void testGetPageList() {
        AdminExample example = new AdminExample();
        PageInfo<Admin> pageInfo = adminService.getPageList(example, 2, 7);
        // 打印分页相关信息
        System.out.println(pageInfo.getTotal()); // 总记录数
        System.out.println(pageInfo.getPages()); // 总页数
        System.out.println(pageInfo.getPageNum()); // 本次查询第几页
        System.out.println(pageInfo.getPageSize());  // 本次查询每页显示几条
        System.out.println(pageInfo.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageInfo.getList()); // 本次查询的结果
    }
}
```

## 4.3 整合 web 层：配置 SpringMVC 三大组件

- 首先在 springmvc.xml 中配置 SpringMVC 三大组件以及扫描 Controller 的路径
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
        http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.2.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd">

    <!--配置扫描 controller -->
    <context:component-scan base-package="com.hao.controller" />
    <!--配置处理器映射器和处理器适配器-->
    <mvc:annotation-driven />
    <!-- 视图解析器 -->
    <bean
            class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/" />
        <property name="suffix" value=".jsp" />
    </bean>
</beans>
```
- 在 web.xml 中配置监听器，用于在容器启动时启动 Spring 容器，还有配置一个前端控制器，以启动 Spring MVC，以及还要配置一个解决乱码问题的过滤器，注意引入的 servlet 标准是 3.1 的，因此 web.xml 的头文件也要为该版本的头文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <display-name>Archetype Created Web Application</display-name>
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>

    <!-- 配置spring -->
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:applicationContext-*.xml</param-value>
    </context-param>
    <!-- 配置监听器加载spring -->
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <!-- 配置过滤器，解决post的乱码问题 -->
    <filter>
        <filter-name>encoding</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>encoding</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <!-- 配置SpringMVC -->
    <servlet>
        <servlet-name>dispatcherServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:springmvc.xml</param-value>
        </init-param>
        <!-- 配置springmvc什么时候启动，参数必须为整数 -->
        <!-- 如果为0或者大于0，则springMVC随着容器启动而启动 -->
        <!-- 如果小于0，则在第一次请求进来的时候启动 -->
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatcherServlet</servlet-name>
        <!-- 所有的请求都进入springMVC -->
        <url-pattern>/</url-pattern>
    </servlet-mapping>

</web-app>
```
- 之后，我们编写 Controller 处理请求
```java
@Controller
public class AdminController {
    @Autowired
    private AdminService adminService;

    @RequestMapping("/admin/get/{id}")
    @ResponseBody
    public Admin getAdmin(@PathVariable String id) {
        Admin admin = adminService.getEntityById(id);
        return admin;
    }

    @RequestMapping("/admin/list/{pageNum}")
    @ResponseBody
    public PageInfo<Admin> getPageList(@PathVariable int pageNum) {
        System.out.println("getPageList");
        PageInfo<Admin> pageInfo = adminService.getPageList(new AdminExample(), pageNum, 5);
        // 也可以自己组装返回对应的类
        return pageInfo;
    }

    // 省略 delete 和 update 方法
}
```
- 最后，我们访问对应的地址，查看是否获取到对应的 json 数据
- 至此，SSM 整合完毕


# 5. 基于注解的 SSM 整合

## 5.1 整合 Dao 层：Mybatis 整合到 Spring

- 在 log4j.properties 中配置日志环境
- Mybatis 的相关步骤不变，利用逆向工程从数据库生成对应的实体和 Mapper 文件以及实现，用于快速测试
- 导入 EntityUti 和 SnowFlakeIdWorker 工具类
- 在 resources 中编写 db.properties 文件配置数据源
- 在 resources 中编写 mybatis 的配置文件 mybatis.xml，配置分页插件
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <plugins>
        <!-- com.github.pagehelper为PageHelper类所在包名 -->
        <plugin interceptor="com.github.pagehelper.PageInterceptor">
            <!-- 使用下面的方式配置参数，后面会有所有的参数介绍 -->
            <property name="helperDialect" value="mysql"/>
        </plugin>
    </plugins>
</configuration>
```
- 在 cfg 包下创建 DaoConfig 类，用于 Dao 层的配置，相当于 applicationContext-dao.xml，在其内部配置数据源，工厂和 Mapper 扫描
```java
@Configuration
@PropertySource("classpath:db.properties")
//@MapperScan("com.hao.ssm.mapper")
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

    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception{
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource);
        sqlSessionFactoryBean.setConfigLocation(new ClassPathResource("mybatis.xml"));
        return sqlSessionFactoryBean.getObject();
    }

    @Bean
    public static PropertySourcesPlaceholderConfigurer placeholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }

    @Bean
    public MapperScannerConfigurer mapperScannerConfigurer() {
        MapperScannerConfigurer configurer = new MapperScannerConfigurer();
        configurer.setBasePackage("com.hao.mapper");
        configurer.setSqlSessionFactoryBeanName("sqlSessionFactory");
        return configurer;
    }

    @Bean
    public SnowflakeIdWorker snowflakeIdWorker() {
        SnowflakeIdWorker snowflakeIdWorker = new SnowflakeIdWorker(0, 0);
        return snowflakeIdWorker;
    }
}
```
- 利用自动生成的类，执行单元测试，验证是否整合成功
```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {DaoConfig.class})
public class AdminMapperTest {
    @Autowired
    AdminMapper adminMapper;
    @Autowired
    SnowflakeIdWorker snowflakeIdWorker;
    @Test
    public void testAdd() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId(String.valueOf(snowflakeIdWorker.nextId()));
        adminMapper.insertSelective(admin);
    }
    @Test
    public void testUpdate() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId("542639870493851648");
        adminMapper.updateByPrimaryKeySelective(admin);
    }
    @Test
    public void testDelete() {
        adminMapper.deleteByPrimaryKey("542670348395479040");
    }
    @Test
    public void testGet() {
        Admin admin = adminMapper.selectByPrimaryKey("1");
        EntityUtil.printString(admin);
    }
    @Test
    public void testPageList(){
        // 每页 2 条，查询第一页
        PageHelper.startPage(2, 7);
        // 用于设置查询条件的 example，此处不设置
        AdminExample example = new AdminExample();
        // 执行条件查找
        List<Admin> adminList = adminMapper.selectByExample(example);
        // 查找结果封装成 PageInfo 返回
        PageInfo<Admin> pageInfo = new PageInfo<>(adminList);
        // 打印分页相关信息
        System.out.println(pageInfo.getTotal()); // 总记录数
        System.out.println(pageInfo.getPages()); // 总页数
        System.out.println(pageInfo.getPageNum()); // 本次查询第几页
        System.out.println(pageInfo.getPageSize());  // 本次查询每页显示几条
        System.out.println(pageInfo.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageInfo.getList()); // 本次查询的结果
    }
}
```

## 5.2 整合 Service 层：事务控制

- 在 cfg 包下创建 ServiceConfig (相当于 applicationContext-service.xml)，配置扫描和事务管理器
```java
@Configuration
@ComponentScan(basePackages = {"com.hao.service"})
@EnableTransactionManagement(proxyTargetClass = true)
public class ServiceConfig {
    @Bean
    public DataSourceTransactionManager dataSourceTransactionManager(DataSource dataSource) {
        DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
        return transactionManager;
    }
}
```
- 然后创建 AdminService，并使用注解设置事务，BaseService 和前面的配置一样
```java
@Service
// 经查询，有些 orm 不支持 readOnly 属性，好像只有 Hibernate 能识别，其他的只能将他理解为一个标记
@Transactional(isolation = Isolation.REPEATABLE_READ, propagation = Propagation.REQUIRED, readOnly = true)
public class AdminService extends BaseService<Admin, AdminExample> {
    @Autowired
    private AdminMapper adminMapper;

    @Override
    protected void init() {
        initMapper(adminMapper);
    }
}
```
- 最后，执行单元测试
```java
@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(locations = {"classpath:applicationContext-dao.xml", "classpath:applicationContext-service.xml"})
@ContextConfiguration(classes = {DaoConfig.class, ServiceConfig.class})
public class AdminServiceTest {
    @Autowired
    AdminService adminService;
    @Test
    public void testAdd() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        adminService.addEntity(admin);
    }
    @Test
    public void testUpdate() {
        Admin admin = EntityUtil.generateRandomOne(Admin.class);
        admin.setId("542639533754155008");
        adminService.updateEntityById(admin);
    }
    @Test
    public void testDelete() {
        Admin admin = new Admin();
        admin.setId("542687570337726464");
        adminService.deleteEntityById(admin);
    }
    @Test
    public void testGet() {
        Admin admin = adminService.getEntityById("1");
        EntityUtil.printString(admin);
    }
    @Test
    public void testGetPageList() {
        AdminExample example = new AdminExample();
        PageInfo<Admin> pageInfo = adminService.getPageList(example, 3, 5);
        // 打印分页相关信息
        System.out.println(pageInfo.getTotal()); // 总记录数
        System.out.println(pageInfo.getPages()); // 总页数
        System.out.println(pageInfo.getPageNum()); // 本次查询第几页
        System.out.println(pageInfo.getPageSize());  // 本次查询每页显示几条
        System.out.println(pageInfo.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageInfo.getList()); // 本次查询的结果
    }
}
```


## 5.3 整合 web 层：配置 SpringMVC 三大组件

- 创建 WebConfig，配置视图解析器（使用继承和注解好像自动配置了另外两个组件）
```java
@Configuration
@EnableWebMvc  // 启用 SpringMVC
@ComponentScan("com.hao.controller")
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

## 5.4 配置 web 启动器

- 首先，在额外配置一个 RootConfig 整合 DaoConfig 和 ServiceConfig，以让启动器使用
```java
@Configuration
@Import({ServiceConfig.class, DaoConfig.class})
public class RootConfig {
}
```

- 配置启动类，设置两个上下文配置类和前端控制器映射，注意必须要在 Servlet 3.0 规范以上的容器才可以用这种方式扫描到
```java
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    /**
     * ContextLoaderListener 上下文，应用中除了 Web 组件以外的相关 Bean 的配置类
     * @return
     */
    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class[]{RootConfig.class};
    }

    /**
     * DispatcherServlet 上下文，配置 Web 组件，如控制器，视图解析器等
     * @return
     */
    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class[]{WebConfig.class};
    }

    /**
     * DispatcherServlet 处理所有 / 请求
     * @return
     */
    @Override
    protected String[] getServletMappings() {
        return new String[]{"/"};
    }
}
```
- 然后，我们编写 AdminController 处理请求
```java
@Controller
public class AdminController {
    @Autowired
    private AdminService adminService;

    @RequestMapping("/admin/get/{id}")
    @ResponseBody
    public Admin getAdmin(@PathVariable String id) {
        Admin admin = adminService.getEntityById(id);
        return admin;
    }

    @RequestMapping("/admin/list/{pageNum}")
    @ResponseBody
    public PageInfo<Admin> getPageList(@PathVariable int pageNum) {
        System.out.println("getPageList");
        PageInfo<Admin> pageInfo = adminService.getPageList(new AdminExample(), pageNum, 5);
        // 也可以自己组装返回对应的类
        return pageInfo;
    }

    // 省略 delete 和 update 方法
}
```
- 最后，我们访问 http://localhost:8080/admin/1 查看是否获取到对应的 json 数据
- 至此，基于注解的 SSM 整合完毕