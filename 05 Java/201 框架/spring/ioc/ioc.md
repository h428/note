- [参考文章1](https://juejin.im/post/5bc5c88df265da0b001f5dee)

# BeanDefinition

- Spring 实例化一个 Bean，和你的类没有关系，而是和 BeanDefinition 有关

```java
// Spring 每检测到一个 Bean 后，就会创建一个 BeanDefinition 来描述 Bean
// 最后创建 Bean 是通过 BeanDefinition 的信息创建的，而不是你自定义的类和对象
GenericBeanDefinition genericBeanDefinition = new GenericBeanDefinition();
// 设置 bean 的包全名
genericBeanDefinition.setBeanClassName("com.hao.service.UserService");
// 设置 bean 对应的 Class
genericBeanDefinition.setBeanClass(UserService.class);
// 设置 scope
genericBeanDefinition.setScope("singleton");
// ... 其他大量设置

// 每有一个 Bean，就有一个对应的 BeanDefinition
// 在 DefaultListableBeanFactory 中有一个 beanDefinitionMap (Map<String, BeanDefinition>)
//
Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<>();
// 每个 Bean 的 definition 就会放置到该 map 中，名字默认为 userService，或者你指定了就是你指定的
beanDefinitionMap.put("userService", genericBeanDefinition);
```


# bean 初始化过程涉及的方法调用

```java
org.springframework.context.support.AbstractApplicationContext#refresh
    org.springframework.context.support.AbstractApplicationContext#finishBeanFactoryInitialization
        org.springframework.beans.factory.config.ConfigurableListableBeanFactory#preInstantiateSingletons
            org.springframework.beans.factory.support.AbstractBeanFactory#getBean(java.lang.String)
                org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean
                    // 第一次调用 getSingleton，先从单例池取，再从早期单例池取，主要为了解决循环依赖问题，如果是创建 Bean，此次返回 null
                    // 如果是第二次依赖的 bean，则会直接从早期单例池中拿到创建到一半的 bean
                    org.springframework.beans.factory.support.DefaultSingletonBeanRegistry#getSingleton(java.lang.String)
                        // 第二次调用，先从单例池拿，没有则调用 beforeSingletonCreation 标记准备创建，
                        org.springframework.beans.factory.support.DefaultSingletonBeanRegistry#getSingleton(java.lang.String, org.springframework.beans.factory.ObjectFactory<?>)
                            // 准备工作完成后调用 getObject 创建 Bean
                            org.springframework.beans.factory.ObjectFactory#getObject
                                // 匿名类提供的 getObject 中，通过调用 createBean 来创建 Bean
                                // createBean 中的创建过程即体现了 Bean 的生命周期（主要通过 9 个后置处理器体现）
                                org.springframework.beans.factory.support.AbstractBeanFactory#createBean
                                    // 以上内容都是 Bean 的准备过程，doCreateBean 用于创建 Bean
                                    // 主要涉及 7 个后置处理器来体现 Bean 的生命周期， 9 - 7 = 2
                                    // 剩余的两个：第一个是干预 Bean 实例化的后置处理器，如果其创建了 Bean 则不会调用 doCreateBean
                                    // 最后一个后置处理器则是销毁容器时调用的收尾工作
                                    org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#doCreateBean
```

- AbstractBeanFactory#createBean 创建 Bean 过程中涉及的 8 个后置处理器

```java

// 1.
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#resolveBeforeInstantiation
    --> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#applyBeanPostProcessorsBeforeInstantiation
        --> org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor#postProcessBeforeInstantiation
// 注意如果有进入第一次调用，内部实例化 bean 后，在 doCreateBean 中的第 2-7 次调用就不再执行
// 但在 resolveBeforeInstantiation 内部，如果成功调用并返回 bean，还有有一次等价的第 8 次调用，
// 即 applyBeanPostProcessorsAfterInitialization，用于完成创建 Bean 的收尾工作

// 之后的后置处理器都在 org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#doCreateBean 中调用

// 2.
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#createBeanInstance
    --> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#determineConstructorsFromBeanPostProcessors
        --> org.springframework.beans.factory.config.SmartInstantiationAwareBeanPostProcessor#determineCandidateConstructors

// 3.
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#applyMergedBeanDefinitionPostProcessors
    --> org.springframework.beans.factory.support.MergedBeanDefinitionPostProcessor#postProcessMergedBeanDefinition

// 4.
org.springframework.beans.factory.support.DefaultSingletonBeanRegistry#addSingletonFactory
    --> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#getEarlyBeanReference
        --> org.springframework.beans.factory.config.SmartInstantiationAwareBeanPostProcessor#getEarlyBeanReference

// 5. 6.
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#populateBean
    --> org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor#postProcessAfterInstantiation
    --> org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor#postProcessProperties

// 7. 8.
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#initializeBean(java.lang.String, java.lang.Object, org.springframework.beans.factory.support.RootBeanDefinition)
    --> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#applyBeanPostProcessorsBeforeInitialization
        --> org.springframework.beans.factory.config.BeanPostProcessor#postProcessBeforeInitialization
    --> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#applyBeanPostProcessorsAfterInitialization
        --> org.springframework.beans.factory.config.BeanPostProcessor#postProcessAfterInitialization
```


# doCreateBean 调用流程

```java

```

# createBeanInstance 如何创建实例

- spring 如何 new 出来一个对象？


# Spring 装配模型

- 找到注入的对象的方式（根据某种规则找到容器中的某个 Bean）有 2 种 : by name, by type （我们将其称之为装配技术）
- 注入方式 : 4 种 autowiredMode 有 4 个取值 : 0, 1, 2, 3 （AutowireCapableBeanFactory）
    - int AUTOWIRE_NO = 0;
    - int AUTOWIRE_BY_NAME = 1; (这个 by name 和前面的 by name 含义不同)
    - int AUTOWIRE_BY_TYPE = 2;
    - int AUTOWIRE_CONSTRUCTOR = 3;
- 注意上述 4 种装配模型在寻找 bean 时都需要利用到 by name 或者 by type 装配技术，因此两个地方的 by name, by type 含义不一样
- 0 表示无任何装配模型，则看属性上是否存在 `@Autowired` 注解(postProcessPropertyValues)，存在则先 by type，后 by name，然后通过 field.set 设置，无需提供 set 方法（如果是 `@Resource` 则先 by name 后 by type）
- 1 表示 by name，这里的 by name 指的是 : 查找所有合适的 writeMethod (set 为前缀，后缀对应的 bean 存在于 Spring 容器中) 并调用注入
- 2 表示 by type，查找所有合适的 writeMethod（set 为前缀，后缀任意，但参数的类型对应的 bean 要处在容器中）
- 3 表示用构造方法注入，此时会查找到最合适的构造方法（优先找参数最多的，且所有参数对应的 bean 都处于容器中的那个构造方法，全都没有当然用默认构造方法）
- 使用 xml 配置我们可以指定装配模型，但如果使用纯注解的开发，默认的装配模型就是 NO，但我们可以利用 ImportBeanDefinitionRegistrar 接口拿到 Bean 的 GenericBeanDefinition，然后设置该 Bean 的装配模型


# 装配的应用（以 Mybatis 为例）

- 如何把自己产生的对象交给 spring 管理？
    - 使用 `@Bean` 注解，我们常见的 DataSource, sqlSessionFactory 就是这种方式（相当于 xml）
    - 利用 FactoryBean 接口，然后把 FactoryBean 接口的实现类交给容器
    - 利用 `context.getBeanFactory().registerSingleton("beanName", bean);` 方法进行注册（不建议采用）
- 注意上述问题想问的是自己 new 出的对象如何交给 Spring 管理，和我们平常在类上使用 `@Component` 注解不一样，`@Component` 注解在类上后，Spring 会自动 new 出对象并交给容器，而我们自己 new 的对象，要交给容器不能使用这种方法，而是使用上面提到的三种方法


## 首先配置 mybatis 环境并模拟 mybatis 动态代理

- 环境配置请参照笔记或者官网
- 加入这样一个 UserDao 接口 :
```java
public interface UserDao {
	@Select("select * from user")
	List<Map<String, Object>> query();
}
```
- 要实现动态代理，首先要创建一个 InvocationHandler 来实现所有方法
```java
public class DaoInvocationHandler implements InvocationHandler {

	@Override
	public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

		// 执行接口的方法
		System.out.println("query db with sql : " + method.getAnnotation(Select.class).value()[0]);

		return null;
	}
}
```
- 然后，基于 handler 创建代理对象并调用 
```java
// 模拟 Mybatis 的动态代理
Class[] classes = new Class[]{UserDao.class};
UserDao userDao = (UserDao) Proxy.newProxyInstance(Test.class.getClassLoader(),
        classes, new DaoInvocationHandler());

userDao.query();
```


## MyBatis 如何实例化 Mapper 的实现类并交给 Spring 管理？

- 暂时不理解

