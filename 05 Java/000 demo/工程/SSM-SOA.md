
> 参考 e3mall，原视频基于配置文件整合，本笔记直接基于注解整合

# 整合思路

- SOA 架构为面向服务的架构，Service 和 Web 分别部署在不同的机子上，Web 通过远程调用等方法调用 Service 中的方法
- 利用 中间件 dubbo，Service 模块启动并部署后，向注册中心发布服务，而 Web 则从注册中心取得对应的服务并进行调用，注册中心使用 zookeeper
- 由于 Service 模块要单独发布运行，因此和原来的分模块项目不同的是，Service 也要发布为 war 形式，但只处理和服务相关的请求
- 和分模块的架构相比，Web 模块则从原来的 manager 分离出来，不再作为 manager 的子工程，但仍然需要依赖接口才能调用 Service 相关方法，因此，我们还需要单独将 Service 的接口抽象出来，这点在分模块中已经做了，即 interface 模块
- 因此终上所述，我们大概可以得到以下目录结构，没有特别提到的依赖和分模块中保持一致，详细可参考 pom 文件：
- soa-parent: 父工程
    - soa-common : 工具类
    - soa-manager : 聚合工程，提供服务
        - soa-entity : 实体类
        - soa-dao : dao 层相关
        - soa-interface : service 的接口，web 中要使用，必须抽象出来
        - soa-service : service 实现，此外由于要发布服务，该模块要打包成 war
    - soa-web : 单独的模块，但依赖 interface 以调用服务
- 使用中间件 dubbo 发布和调用服务，发布服务即向注册中心注册，而调用服务则向注册中心索要，因此还要提供一个注册中心管理服务，官方推荐的是 zookeeper，因此还需要安装 zookeeper，建议在 Linux 安装

# 安装 zookeeper

- 首先准备 jdk, zookeeper，然后配置相关环境，注意下述操作都需要 root 权限，且实验环境需要关闭防火墙
- 配置 jdk 环境，编辑 `/etc/profile` 文件，在尾部添加下述内容：
```bash
# set java environment
JAVA_HOME=/usr/local/jdk1.7.0_71
CLASSPATH=.:$JAVA_HOME/lib.tools.jar
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME CLASSPATH PATH
```
- 然后输入下述命令验证 jdk 安装完成：
```bash
java -version
javac -version
```
- 解压 `zookeeper-3.4.6.tar.gz` 并进入对应目录
- 在目录下创建 data 文件夹，用于存放数据
- 进入 conf 目录，将 zoo_sample.cfg 改名为 zoo.cfg
- 然后编辑 zoo.cfg 文件，设置 dataDir 为前面创建的目录，例如 `dataDir=/root/zookeeper-3.4.6/data`
- 然后启动 zookeeper 即可
- zookeeper 相关命令
```bash
./zkServer.sh start # 启动
./zkServer.sh stop # 关闭
./zkServer.sh status # 查看状态
```

**zookeeper 可视化界面**

- 官方提供了 dubbo-admin-2.5.4.war 来可视化管理服务，是否使用该工具不影响 SOA 项目的使用，只是该工具能让你更方便的排查服务相关的 bug
- 首先，准备好 tomcat，然后将该 war 包复制到 webapps 中，然后启动 tomcat 访问即可（注意必须配好 JAVA 环境）
- 默认的用户名和密码都为 root

# 基础准备

- 执行 [maven.sql](./sql/maven.sql.md) 创建数据库
- 利用 Mybatis 逆向工程生成实体和 Mapper
- 复制 SnowFlakeIdWorker, EntityUtil, PageBean 到 common 的对应的包中，两个工具类一个 dto

# 整合 Dao 模块

- 准备 log4j.properties
```properties
log4j.rootLogger=DEBUG,A1

log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%-d{yyyy-MM-dd HH:mm:ss,SSS} [%t] [%c]-[%p] %m%n
```
- 准备 db.properties
```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/maven?characterEncoding=utf-8
jdbc.username=root
jdbc.password=root
```
- 准备 DaoConfig
```java
@Configuration
@PropertySource("classpath:db.properties")
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
        configurer.setBasePackage("com.hao.soa.mapper");
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
- 编写 AdminMapperTest，执行单元测试
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
        adminMapper.deleteByPrimaryKey("542756400497950720");
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

# 整合 Service 模块

- 需要注意，Service 接口中返回的方法的所有相关的类都要实现 Serializable 接口才能进行传输，否则在进行通信时会抛出异常
- 首先，明确接口的包为 `com.hao.soa.service`，实现类的包为 `com.hao.soa.service`
- 首先，创建 DubboConfig 配置 Dubbo
```java
@Configuration
public class DubboConfig {
    /**
     * 对应 dubbo:application
     * @return 应用实体
     */
    @Bean
    public ApplicationConfig applicationConfig(){
        ApplicationConfig applicationConfig = new ApplicationConfig();
        applicationConfig.setName("aop-manager");
        return applicationConfig;
    }
    /**
     * 对应 dubbo:registry
     * @return 注册中心
     */
    @Bean
    public RegistryConfig registryConfig() {
        RegistryConfig registryConfig = new RegistryConfig();
        registryConfig.setProtocol("zookeeper");
        registryConfig.setCheck(true);
        registryConfig.setAddress("192.168.11.42:2181");
        return registryConfig;
    }
    /**
     * 对应 dubbo:protocol
     * @return 协议
     */
    @Bean
    public ProtocolConfig protocolConfig() {
        ProtocolConfig protocolConfig = new ProtocolConfig();
        protocolConfig.setName("dubbo");
        protocolConfig.setPort(20880);
        return protocolConfig;
    }
    /**
     * 开启注解扫描
     * @return 注解扫描 Bean
     */
    @Bean
    public AnnotationBean annotationBean(){
        AnnotationBean annotationBean = new AnnotationBean();
        annotationBean.setPackage("com.hao.soa.service.impl");
        return annotationBean;
    }
}
```
- 上述配置和下面的 xml 配置等价
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:context="http://www.springframework.org/schema/context" xmlns:p="http://www.springframework.org/schema/p"
       xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd
	http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.2.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.2.xsd
	http://code.alibabatech.com/schema/dubbo http://code.alibabatech.com/schema/dubbo/dubbo.xsd
	http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.2.xsd">

    <!-- 使用dubbo发布服务 -->
    <!-- 提供方应用信息，用于计算依赖关系 -->
    <dubbo:application name="aop-manager" />
    <dubbo:registry protocol="zookeeper" check="true"
                    address="192.168.11.42:2181" />
    <!-- 用dubbo协议在20880端口暴露服务 -->
    <dubbo:protocol name="dubbo" port="20880" />
    <!-- 声明需要暴露的服务接口 -->
    <dubbo:service interface="com.hao.soa.service.AdminService" ref="adminServiceImpl" />

</beans>
```
- 在 cfg 包下创建 ServiceConfig (相当于 applicationContext-service.xml)，配置扫描和事务管理器
```java
@Configuration
@ComponentScan(basePackages = {"com.hao.soa.service"})
@EnableTransactionManagement(proxyTargetClass = true)
//@ImportResource(locations = "classpath*:dubbo.xml")
@Import(DubboConfig.class)
public class ServiceConfig {
    @Bean
    public DataSourceTransactionManager dataSourceTransactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}
```
- 最后创建 ServiceRootConfig 整合上述配置类作为最终配置类，并让其随容器启动而激活（在 web.xml 中配置）
```java
@Configuration
@Import({ServiceConfig.class, DaoConfig.class})
public class ServiceRootConfig {
    // 为了和 web 模块中的 RootConfig 区别而起个不同的名字
}
```
- 然后配置 Spring 容器随 Tomcat 启动而启动，由于 service 层没有引入 Servlet 相关依赖包，且当前模块没有 WebConfig，因此选择直接在 web.xml 中配置容器，而不使用注解方式
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

    <!--配置 Spring 容器启动器-->
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>
    <!--启动器相关参数-->
    <context-param>
        <param-name>contextClass</param-name>
        <param-value>org.springframework.web.context.support.AnnotationConfigWebApplicationContext</param-value>
    </context-param>
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>com.hao.soa.cfg.ServiceRootConfig</param-value>
    </context-param>
</web-app>
```
- 在 interface 模块中编写 BaseService 接口，提供单表 CRUD 方法，其他 Service 接口继承该 Service 接口
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
- 编写 AdminServiceImpl，单表操作只需继承该类即可
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
        admin.setId("542795440718872576");
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
        PageBean<Admin> pageBean = adminService.getPageList(example, 3, 7);
        // 打印分页相关信息
        System.out.println(pageBean.getTotal()); // 总记录数
        System.out.println(pageBean.getPages()); // 总页数
        System.out.println(pageBean.getSize());  // 最终显示几条，等于 list 的长度，一般等于 PageSize，若是最后一页则可能小于 pageSize
        EntityUtil.printString(pageBean.getList()); // 本次查询的结果
    }
}
```

# 整合 Web 模块

- 首先配置 DubboRefConfig 以引用 dubbo
```java
@Configuration
public class DubboRefConfig {
    /**
     * 对应 dubbo:application
     * @return 应用实体
     */
    @Bean
    public ApplicationConfig applicationConfig(){
        ApplicationConfig applicationConfig = new ApplicationConfig();
        applicationConfig.setName("aop-manager");
        return applicationConfig;
    }
    /**
     * 对应 dubbo:registry
     * @return 注册中心
     */
    @Bean
    public RegistryConfig registryConfig() {
        RegistryConfig registryConfig = new RegistryConfig();
        registryConfig.setProtocol("zookeeper");
        registryConfig.setCheck(true);
        registryConfig.setAddress("192.168.11.42:2181");
        return registryConfig;
    }
    /**
     * 开启注解扫描
     * @return 注解扫描 Bean
     */
    @Bean
    public AnnotationBean annotationBean(){
        AnnotationBean annotationBean = new AnnotationBean();
        // 注意这里扫描的是控制器而不是 service
        annotationBean.setPackage("com.hao.soa.controller");
        return annotationBean;
    }
}
```
- 然后提供 RootConfig，RootConfig 暂时留空，本来是打算在 RootConfig 中引入 DubboRefConfig 服务，这样比较符合 RootConfig 保留非 Web 相关的组件的原则，但这样由于初始化次序问题，会导致 Controller 中的服务为空，因为自动扫描到的 Service 估计不在 Spring 容器中，无法完整自动注入，最后运行导致空指针异常，因此实际上不需要 RootConfig 为了保持一致性以及 WebAppInitializer 的启动，仍然提供该类
```java
@Configuration
public class RootConfig {

}
```
- 由于需要确保扫描 controller 的同时或之前必须已经扫描到 dubbo 的 service 才能完成 service 的自动注入（使用 `@Reference` 注解），因此在 WebConfig 中扫描 controller 的同时引入 dubbo 配置类
- 经过测试，不管是使用 JavaConfig 还是 XML，只要你是使用注解扫描 service 的，都必须在 WebConfig 中引入，在 RootConfig 中引入会导致 controller 中的 service 为空
- 此外，经过测试，若是使用 dubbo:ref 单独配置具体的 Bean，然后在 Controller 使用 `@Autowired` 进行注入，这样可以直接将 dubbo 相关的配置转移到 RootConfig 中也能找到
> 下述内容为自己根据运行的测试进行的一个也许不那么合理的猜测，只是为了方便我自己理解，不一定正确
> - 我觉得可以这样理解这个问题：dubbo 也许有个自己的维护服务的容器上下文，我们暂且将其称之为 dubbo 容器，配置注解扫描到的服务类应该都是存放在dubbo 容器中，`@Reference` 则是从该容器中查找服务并注入到对应的实体中
> - 对于第一个问题，我们在 Web 启动时，可能先扫描了 Controller，且此时还没有扫描到相关的 service，dubbo 容器为空，自然无法通过 `@Reference` 注入对应的服务（当然 service 更不存在 Spring 容器中，更不可能用 `@Autowired` 进行注入），因此，若要使用 `@Reference` 引用服务，必须确保 Controller 扫描之前扫描到 dubbo 相关的 service
> - 对于第二个问题，dubbo:ref 应该是相当于配置了一个 Bean，这个 Bean 自然是由 Spring 容器管理的，自然可以使用 `@Autowired` 注入（但我还不太清楚 Web 下两个上下文的启动优先级，Spring 可能可以自动调用）

- 因此，基于上述内容，我们在 WebConfig 中配置 SpringMVC 三大组件以及扫描的同时，引入 DubboRefConfig 的配置
```java
@Configuration
@EnableWebMvc  // 启用 SpringMVC
@ComponentScan("com.hao.soa.controller")
// 经测试，若要用注解，必须同时在 controller 扫描的地方提供 Dubbo 配置，这行放到 RootConfig 中不起作用，
// 我猜测，可能是注入的先后次序问题吧
// 由于 dubbo 和 spring 可能不是无缝整合，必须要在 扫描 controller 的同时或者之前扫描到 service 才能完成服务引用
@Import(DubboRefConfig.class)
//@ImportResource("classpath:dubboref.xml")
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
- 然后配置 Web 启动器，这样就不用再 web.xml 中配置相关监听器了
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
- 然后我们编写 AdminController 处理请求，但要注意是使用 `@Reference` 注解引用服务
```java
@Controller
public class AdminController {
    @Reference
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
        PageBean<Admin> pageBean = adminService.getPageList(new AdminExample(), pageNum, 5);
        return pageBean;
    }

    // 省略 delete 和 update 方法
}
```
- 打开 zookeeper，启动 manager 模块提供服务（可以利用 dubbo-admin 查看服务是否发布成功，迅速定位是 manager 还是 web 的问题）
- 在 manager 启动成功后，启动 web 模块，访问对应网址，看能否处理请求
- 自此，基于 SOA 架构的 SSM 整合完毕



