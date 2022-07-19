
# 2. Mybatis 入门

> 注意：本笔记要结合笔记：<b>基于Maven构建Mybatis项目</b>共同翻看

## 2.1 开发环境准备

- 书上使用的是传统的方式，建议改为基于 Maven 构建的方式
- 构建过程可以参考笔记：基于 Maven 构建 Mybatis 项目

## 2.2 Mybatis的基本构成

- 最核心的两个接口：
    - SqlSessionFactory：一般整个项目只有一个，其主要的作用是创建 SqlSession
    - SqlSession：类似 JDBC 中的 Connection ，可使用 sqlSession 获取到 Mapper 实现类，用于操作数据库
- SqlSessionFactoryBuilder：SqlSessionFactory 是一个接口，该 Builder 类用于根据读取到配置文件，并创建 SqlSessionFactory 实现类的对象
- SqlMapper：由一个 Java 接口和 XML 文件构成，例如，对于实体类 User，可以有 UserMapper 接口和对应的实现 UserMapper.xml

### 2.2.1 构建SqlSessionFactory

- 注意，SqlSessionFactory 是一个接口而不是一个实现类，其实例可以通过 SqlSessionFactoryBuilder 获得
- Mybatis 初始化时，将所有的配置一次性读取，并保存在 Configuration 对象中(org.apache.ibatis.session.Configuration)，这样，配置数据就单例的形式存储在内存中，占用小，性能高，可反复使用
- SqlSessionFactory 有两个实现类，DefaultSqlSessionFactory 和 SqlSessionManager，目前使用的是 DefaultSqlSessionFactory
- 建议采用 XML 的方式构建 SqlSessionFactory，详细的构建配置参考笔记：基于 Maven 构建 Mybatis 项目
- SqlSessionFactory 相关配置主要包括 <b>mybatis-config.xml</b> 配置文件和 <b>SqlSessionFactoryUtil</b> 中创建 SqlSessionFactory 的过程

### 2.2.2 创建SqlSession

- SqlSession 也是一个接口，其相当于的 JDBC 的 Connection ，主要作用是操作数据库，由于资源有限，因此使用完毕后，要确保 SqlSession 得到关闭
- 使用 SqlSession 的模板代码如下
```java
SqlSession sqlSession = null;

try {
	sqlSession = SqlSessionFactoryUtil.openSession();
	// 一些操作数据库的代码 ...
	sqlSession.commit();
	
} catch (Exception e) {
	System.out.println(e);
	sqlSession.rollback();
}finally{
	if(sqlSession != null){
		sqlSession.close();
	}
}
```
- SqlSession 的主要用途有两种：
    - 获取 XxxMapper
    - 直接通过命名信息去执行 SQL 返回结果，这是 iBatis 版本留下的方式

### 2.2.3 映射器 Mapper

- 映射器由 Java 接口和XML文件（或注解）共同组成，它的作用如下：
    - 定义参数类型
    - 描述缓存
    - 描述SQL语句
    - 定义查询结果和 POJO 的映射关系
- Mapper 接口可以通过同名的 xml 文件实现或者直接在 Mapper 接口中添加注解实现，但建议采用 xml 文件实现，因为其更加灵活，功能更强大，且具有更好的可读性
- XML 实现样例参考笔记：基于 Maven 构建 Mybatis 项目中的 AdminMapper 接口和 AdminMapper.xml 的内容
- 原理：Mybatis 通过读取 Mapper.xml 文件的内容，利用 Java 的动态代理技术，将其转化为 Mapper 接口的实现类，这样我们就不需要再编写实现类，只需提供接口和配置即可，其中配置文件中就包含了 sql 语句

## 2.3 生命周期

> 讲述 SqlSessionFactoryBuilder, SqlSessionFactory, SqlSession, Mapper 的生命周期

### 2.3.1 SqlSessionFactoryBuilder

- SqlSessionFactoryBuilder 是利用 XML 或者 Java 编码获得资源来构建 SqlSessionFactory 的，通过它可以构建多个 SqlSessionFactory
- 它的作用就是一个构建器，因此一旦构建了 SqlSessionFactory ，它的作用就已经完结
- 因而，它的生命周期应该只存在于方法的局部，生成 SqlSessionFactory 后就结束

### 2.3.2 SqlSessionFactory

- SqlSessionFactory 的作用是创建 SqlSession ，每次应用程序需要访问数据库时，就要用它创建一个 SqlSession ，因此 SqlSessionFactory 应该存在于整个应用程序的生命周期中
- 由于 SqlSessionFactory 责任是唯一的，且消耗数据库资源很大，因此应该实现为单例模式
- 正确的做法是：每一个数据库只对应一个 SqlSessionFactory ，管理好数据库资源的分配，避免过多的 Connection 被消耗

### 2.3.3 SqlSession

- SqlSession 是一个会话，相当于 JDBC 的一个 Connection 对象，它的生命周期应该是请求数据库处理事务的过程中
- 它是一个线程不安全对象，在涉及多线程的时候，我们需要特别的当心，操作数据库需要注意其隔离级别，数据库锁等高级特性
- 此外，每次创建的 SqlSession 都必须及时关闭它，它长期存在就会使数据库连接池的活动资源减少，对系统影响性能很大

### 2.3.4 Mapper

- Mapper 是一个接口，它的作用适用于发送 SQL ，然后返回我们需要的结果，因此它应该在 SqlSession 事务的方法之内，是一个方法级别的东西
- 它就如同 JDBC 中的一条 SQL 语句的执行，它最大的范围和 SqlSession 是相同的
- 尽管我们想一直保持 Mapper ，但你会发现它很难控制，所以尽量在一个 SqlSession 事务的方法中使用它们，然后废弃掉（引入 Spring 后可能发生变化）

## 2.4 实例

- 参考笔记：<b>基于Maven构建Mybatis项目</b>
