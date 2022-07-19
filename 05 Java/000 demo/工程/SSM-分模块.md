
# 1. 分模块项目介绍

- 参考 e3mall 完成自己的分模块项目整合
- 使用前缀 mpc 描述该分模块项目 （Multiple Project Config）
- mp-parent：父工程，打包方式 pom ，管理 jar 包的版本号。项目中所有工程都应该继承父工程
    1. mp-common：通用的工具类通用的 pojo，打包方式 jar
    2. mp-manager：后台聚合工程，打包方式为 pom
        1. mp-manager-dao：打包方式 jar
        2. mp-manager-pojo：打包方式 jar
        3. mp-manager-interface：打包方式 jar
        4. mp-manager-service：打包方式 jar
        5. mp-manager-web：表现层工程。打包方式 war
- 基于配置文件更改为 mpc, 基于注解更改为 mpa
- 原来的 Servlet 是 2.5 版本，但由于要使用注解升级为 3.1，原来的 jdk 是 1.7，但我想使用分模块热部署，升级为 1.8，其他依赖包版本无变化
- 原来的项目的配置文件都直接放在 web 模块中，我为了能进行单元测试，将配置拆分到各自的模块中
- 由于是模板样例，数据库使用自己的样例数据库 maven
- 原视频 parent 和 conmon, manager 放在同级目录，但据我理解，conmon, manager 就是 parent 的子工程，还是放置为子集目录更合适，因此本例子尝试放置为子目录
- 以后，基于 soa 架构时， web 模块要从 manager 中独立出来，通过中间件实现 service 的调用，因此此时其和 commons, manager 同级，只是需要依赖 interface 模块
- 此外为了保持目录结构在 github 上正常显示，保留所有原有的 App 和 AppTest

# 2. 基于配置文件整合

- Group Id : `com.hao.mpc`
- ArtifactID : `parent, common, manager, manager-dao ...`

## 2.1 各个模块依赖

- 首先按级别创建各个模块，并导入对应的依赖，依赖参考 [mpc](./pom/mpc.pom.md)

## 2.2 基础准备

- 创建数据库，执行逆向工程，获取实体和 Mapper 并复制到对应的工程
- 复制 EntityUtil 和 SnowFlakeIdWorker 两个工具类到 common 模块中
- 由于分模块将 interface 和 service 拆分，使得 interface 不再依赖 mybatis 分页插件包，因此分页查询返回的分页类要自己构造， dto 放置在 common 模块更合适，如下面的 PageBean
```java
public class PageBean<T> {

    private long total;
    private long pages;
    private long size;
    private List<T> list;

    public PageBean(long total, long pages, long size, List<T> list) {
        this.total = total;
        this.pages = pages;
        this.size = size;
        this.list = list;
    }

    // 省略 get 方法
}
```

## 2.3 Dao 模块

- 在 log4j.properties 中配置日志系统
```properties
log4j.rootLogger=DEBUG,A1

log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%-d{yyyy-MM-dd HH:mm:ss,SSS} [%t] [%c]-[%p] %m%n
```
- 在 db.properties 中配置数据源
```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/maven?characterEncoding=utf-8
jdbc.username=root
jdbc.password=root
```
- 提供 mybatis.xml 文件，配置分页插件
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
- 在 applicationContext-dao.xml 中配置 dao 层内容
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
        <property name="basePackage" value="com.hao.mpc.mapper" />
    </bean>

    <!--id 生成器，数据中心 id 和机器 id 可以使用配置文件注入-->
    <bean class="com.hao.mpc.util.SnowflakeIdWorker">
        <constructor-arg value="0" />
        <constructor-arg value="0" />
    </bean>
</beans>
```
- 执行单元测试，验证整合是否正确
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
        admin.setId("542639533754155008");
        adminMapper.updateByPrimaryKeySelective(admin);
    }
    @Test
    public void testDelete() {
        adminMapper.deleteByPrimaryKey("542682623139381248");
    }
    @Test
    public void testGet() {
        Admin admin = adminMapper.selectByPrimaryKey("1");
        EntityUtil.printString(admin);
    }
    @Test
    public void testPageList(){
        // 每页 2 条，查询第一页
        PageHelper.startPage(1, 5);
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

## 2.4 Service 模块

- 在 applicationContext-service.xml 中配置 service 组件
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
	<context:component-scan base-package="com.hao.mpc.service"/>
	
</beans>
```
- 在 applicationContext-trans.xml 中配置声明式事务（可以整合到 service 中）
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
			pointcut="execution(* com.hao.mpc.service..*.*(..))" />
	</aop:config>
</beans>
```
- 首先在 interface 模块中编写 BaseService 接口，提供单表 CRUD，其他 Service 接口继承该 Service 接口
```java
public interface BaseService<T1, T2> {
    String addEntity(T1 entity);
    int deleteEntityById(T1 entity);
    int updateEntityById(T1 entity);
    T1 getEntityById(String id);
    PageBean<T1> getPageList(T2 example, int pageNum, int pageSize);
}
```
- 然后在 service 模块提供 BaseService 的抽象实现 BaseServiceImpl，其是一个抽象类，其他类都继承该类便自动具有单表的 CRUD
```java
/**
 * 抽象的 Service，其他 Service 继承该 Service 后自动具有单标 CRUD
 * @param <T1> 实体类型，如 Admin
 * @param <T2> 实体对应的 Mybatis 查询类型，如 AdminExample
 */
public abstract class BaseServiceImpl<T1, T2> implements BaseService<T1, T2> {

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
     * @return 返回 pageBean，其包括了分页所需要的各种信息和实体集合
     */
    public PageBean<T1> getPageList(T2 example, int pageNum, int pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        try {
            // 根据主键选取对象
            Method selectByExample = clazz.getMethod("selectByExample", example.getClass());
            List<T1> entityList = (List<T1>) invokeMapperMethod("selectByExample", example);
            PageInfo<T1> pageInfo = new PageInfo<>(entityList);
            PageBean<T1> pageBean= new PageBean<>(pageInfo.getTotal(), pageInfo.getPages(), pageInfo.getSize(), pageInfo.getList());
            return pageBean;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
```
- 编写 AdminServiceImpl，单表操作只需继承即可
```java
@Service
public class AdminServiceImpl extends BaseServiceImpl<Admin, AdminExample> implements AdminService {
    @Autowired
    private AdminMapper adminMapper;

    @Override
    protected void init() {
        initMapper(adminMapper);
    }
}
```
- 执行单元测试，验证是否整合正确
```java
@RunWith(SpringJUnit4ClassRunner.class)
// 若不显式指定 applicationContext-dao.xml 在执行 maven install 时会找不到该文件，不知道为啥
@ContextConfiguration(locations = {"classpath*:applicationContext-*.xml"})
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
        admin.setId("542718473789243392");
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
        PageBean<Admin> pageBean = adminService.getPageList(example, 2, 7);
        // 打印分页相关信息
        System.out.println(pageBean.getTotal()); // 总记录数
        System.out.println(pageBean.getPages()); // 总页数
        System.out.println(pageBean.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageBean.getList()); // 本次查询的结果
    }
}
```

## 2.5 整合 web 模块

- 在 springmvc.xml 中配置 SpringMVC 组件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
        http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.2.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd">

    <context:component-scan base-package="com.hao.mpc.controller" />
    <mvc:annotation-driven />
    <bean
            class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/" />
        <property name="suffix" value=".jsp" />
    </bean>
</beans>
```
- 编写 Controller
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
    public PageBean<Admin> getPageList(@PathVariable int pageNum) {
        System.out.println("getPageList");
        PageBean<Admin> pageBean = adminService.getPageList(new AdminExample(), pageNum, 5);
        return pageBean;
    }

    // 省略 delete 和 update 方法
}
```
- 启动项目，访问对应地址看能否访问对应的地址

# 3. 基于注解的 SSM 分模块项目

- Group Id : `com.hao.mpa`
- ArtifactID : `parent, common, manager, manager-dao ...`

## 3.1 各个模块依赖

- 首先按级别创建各个模块，并导入对应的依赖，依赖参考 [mpc](./pom/mpc.pom.md)
- 只需修改内部依赖为 mpa 域名即可，外部依赖一模一样

## 3.2 基础准备（和 mpc 一致）

- 创建数据库，执行逆向工程，获取实体和 Mapper 并复制到对应的工程
- 复制 EntityUtil 和 SnowFlakeIdWorker 两个工具类到 common 模块中
- 由于分模块将 interface 和 service 拆分，使得 interface 不再依赖 mybatis 分页插件包，因此分页查询返回的分页类要自己构造， dto 放置在 common 模块更合适，如下面的 PageBean
```java
public class PageBean<T> {

    private long total;
    private long pages;
    private long size;
    private List<T> list;

    public PageBean(long total, long pages, long size, List<T> list) {
        this.total = total;
        this.pages = pages;
        this.size = size;
        this.list = list;
    }

    // 省略 get 方法
}
```

## 3.3 整合 Dao 模块

- 在 log4j.properties 中配置日志系统
```properties
log4j.rootLogger=DEBUG,A1

log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%-d{yyyy-MM-dd HH:mm:ss,SSS} [%t] [%c]-[%p] %m%n
```
- 在 db.properties 中配置数据源
```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/maven?characterEncoding=utf-8
jdbc.username=root
jdbc.password=root
```
- 提供 mybatis.xml 文件，配置分页插件
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
    public PropertySourcesPlaceholderConfigurer placeholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }
    @Bean
    public MapperScannerConfigurer mapperScannerConfigurer() {
        MapperScannerConfigurer configurer = new MapperScannerConfigurer();
        configurer.setBasePackage("com.hao.mpa.mapper");
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

## 3.2 整合 Service 模块

- 在 cfg 包下创建 ServiceConfig (相当于 applicationContext-service.xml)，配置扫描和事务管理器
```java
@Configuration
@ComponentScan(basePackages = {"com.hao.mpa.service"})
@EnableTransactionManagement(proxyTargetClass = true)
public class ServiceConfig {
    @Bean
    public DataSourceTransactionManager dataSourceTransactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}
```
- 在 interface 模块中编写 BaseService 接口，提供单表 CRUD，其他 Service 接口继承该 Service 接口
```java
public interface BaseService<T1, T2> {
    String addEntity(T1 entity);
    int deleteEntityById(T1 entity);
    int updateEntityById(T1 entity);
    T1 getEntityById(String id);
    PageBean<T1> getPageList(T2 example, int pageNum, int pageSize);
}
```
- 然后在 service 模块提供 BaseService 的抽象实现 BaseServiceImpl，其是一个抽象类，其他类都继承该类便自动具有单表的 CRUD
```java
/**
 * 抽象的 Service，其他 Service 继承该 Service 后自动具有单标 CRUD
 * @param <T1> 实体类型，如 Admin
 * @param <T2> 实体对应的 Mybatis 查询类型，如 AdminExample
 */
public abstract class BaseServiceImpl<T1, T2> implements BaseService<T1, T2> {

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
     * @return 返回 pageBean，其包括了分页所需要的各种信息和实体集合
     */
    public PageBean<T1> getPageList(T2 example, int pageNum, int pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        try {
            // 根据主键选取对象
            Method selectByExample = clazz.getMethod("selectByExample", example.getClass());
            List<T1> entityList = (List<T1>) invokeMapperMethod("selectByExample", example);
            PageInfo<T1> pageInfo = new PageInfo<>(entityList);
            PageBean<T1> pageBean= new PageBean<>(pageInfo.getTotal(), pageInfo.getPages(), pageInfo.getSize(), pageInfo.getList());
            return pageBean;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
```
- 编写 AdminServiceImpl，单表操作只需继承即可
```java
@Service
public class AdminServiceImpl extends BaseServiceImpl<Admin, AdminExample> implements AdminService {
    @Autowired
    private AdminMapper adminMapper;

    @Override
    protected void init() {
        initMapper(adminMapper);
    }
}
```
- 执行单元测试，验证是否整合正确
```java
@RunWith(SpringJUnit4ClassRunner.class)
// 若不显式指定 applicationContext-dao.xml 在执行 maven install 时会找不到该文件，不知道为啥
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
        admin.setId("542725569452703744");
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
        PageBean<Admin> pageBean = adminService.getPageList(example, 2, 7);
        // 打印分页相关信息
        System.out.println(pageBean.getTotal()); // 总记录数
        System.out.println(pageBean.getPages()); // 总页数
        System.out.println(pageBean.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageBean.getList()); // 本次查询的结果
    }
}
```

## 3.3 整合 web 模块

- 创建 WebConfig，配置视图解析器（使用继承和注解好像自动配置了另外两个组件）
```java
@Configuration
@EnableWebMvc  // 启用 SpringMVC
@ComponentScan("com.hao.mpa.controller")
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

## 3.4 配置 web 启动器

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
    public PageBean<Admin> getPageList(@PathVariable int pageNum) {
        System.out.println("getPageList");
        PageBean<Admin> pageBean = adminService.getPageList(new AdminExample(), pageNum, 5);
        return pageBean;
    }

    // 省略 delete 和 update 方法
}
```
- 最后，我们访问 http://localhost:8080/admin/1 查看是否获取到对应的 json 数据
- 至此，基于注解的 SSM 分模块项目整合完毕
