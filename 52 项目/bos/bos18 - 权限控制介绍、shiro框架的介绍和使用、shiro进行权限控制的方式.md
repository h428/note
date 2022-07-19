[TOC]

# 权限控制介绍

## 一、权限概述

1. 认证：系统提供的用于识别用户身份的功能，通常登录功能就是认证功能-----让系统知道你是谁？？
2. 授权：系统授予用户可以访问哪些功能的许可（证书）----让系统知道你能做什么？？

# 二、常见的权限控制方式

1. URL拦截权限控制

    - 底层基于拦截器或者过滤器实现
    - 用户访问某一url，在过滤器或拦截器中先判定该url是否需要拦截，若需要，则取出当前登录的用户，判定是否具有足够的权限

2. 方法注解权限控制

    - 添加某一注解表示该方法需要进行权限控制
    - 底层基于代理技术实现，为Action或Service创建代理对象，由代理对象进行权限校验

## 三、权限数据模型

1. 权限数据模型一般涉及五张表：权限表、角色表、用户表、角色权限关系表、用户角色关系表
2. 角色就是权限的集合，引入角色表，是为了方便授权，角色可以理解为权限控制的对象
3. 角色与用户是多对多的关系，中间使用用户角色关系表建立关联
4. 角色与权限也是多对多的关系（某些角色可能弱化为多对一），中间使用角色权限关系表建立关联


# shiro框架的介绍和使用

> 官网：shiro.apache.org

## 一、shiro介绍

1. shiro框架的核心功能：认证、授权、会话管理、加密

2. shiro框架认证流程：

3. 涉及的相关概念和类

ApplicationConde，应用程序代码，由开发人员进行开发
Subject，框架提供的接口，代表当前用户对象
SecurityManager，框架提供的接口，代表安全管理器，是shiro框架最核心的对象
Realm，可以开发人员编写，框架也提供一些，类似于DAO，用于访问权限数据

4. 导包方式：只要导入shiro-all，相当于导入了所有的分包

## 二、shiro相关配置简单介绍

ShiroFilterFactoryBean：是一个工厂类，用于创建过滤器，进行权限拦截，要求对其注入SecurityManager，以及三个URL

authc过滤器为shiro过滤器类的别名，用于检查用户是否认证过（俗称的登录） - 此时可以取消自己编写的登录过滤器了
anon过滤器为匿名访问过滤器，表示不登录也能访问资源
perms过滤器用于检查权限，用于检查登录用户是否具有对应的权限：/page_base_staff.action = perms["staff-list"]

**表示多级子目录
validatecode.jsp*表示通配（用于匹配不同的参数参数）


## 三、在bos项目中使用shiro框架进行认证

1. 在porm.xml中引入对shiro框架的依赖

```
<!-- 引入shiro框架的依赖 -->
<dependency>
<groupId>org.apache.shiro</groupId>
<artifactId>shiro-all</artifactId>
<version>1.2.2</version>
</dependency>
```

2. 在web.xml中配置过滤器，Spring提供的，用于整合shiro框架，注意要放在struts2过滤器的前面

```
<!-- 配置Spring框架提供的用于整合shiro框架的过滤器 -->
<filter>
<filter-name>shiroFilter</filter-name>
<filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
<filter-mapping>
<filter-name>shiroFilter</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping>	
```

3. 配置完过滤器后，会要求Spring工厂提供一个对应名称(如按上述配置就是shiroFilter)的Bean，若不提供则项目启动报错

4. 对于shiroFilter，要为其注入securityManager、相关URL以及URL的拦截规则

```
<!-- 配置shiro框架的工厂对象 -->
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
<property name="securityManager" ref="securityManager"></property>
<!-- 注入相关页面访问URL -->
<property name="loginUrl" value="/login.jsp"/>
<property name="successUrl" value="/index.jsp"/>
<property name="unauthorizedUrl" value="unauthorized.jsp"/>

<!-- 注入URL拦截规则 -->
<property name="filterChainDefinitions">
<value>
/css/** = anon
/js/** = anon
/images/** = anon
/validatecode.jsp* = anon
/login.jsp = anon
/userAction_login.action = anon
/page_base_staff.action = perms["staff-list"]
/* = authc
</value>
</property>
</bean>
```

5. 对于securityManager，需要为其注入realm，该reaml可以是自定义的，也可以是框架提供的

```
<bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
<property name="realm" ref="bosRealm"></property>
</bean>
```

6. 编写自定义的Realm

```
public class BosRealm extends AuthorizingRealm{

//认证方法
@Override
protected AuthenticationInfo doGetAuthenticationInfo(
AuthenticationToken arg0) throws AuthenticationException {

UsernamePasswordToken token = (UsernamePasswordToken) arg0;
//获得页面输入的用户名
String username = token.getUsername();
//根据用户名从数据库查询实体
User user = userDao.findByUsername(username);

if(user == null){
//页面输入的用户名不存在
return null;
}
//框架负责检验输入和数据库查询出来的对象是否一致

//简单认证信息对象
AuthenticationInfo info = new SimpleAuthenticationInfo(user, user.getPassword(), this.getName());
//返回信息对象，由安全管理器调用认证器进行信息认证
return info;
}

//授权方法
@Override
protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection arg0) {
return null;
}

@Autowired
private UserDao userDao;

public void setUserDao(UserDao userDao) {
this.userDao = userDao;
}

}
```

7. 配置自定义的bosRealm

```
<bean id="bosRealm" class="com.hao.bos.realm.BosRealm"/>
```

8. 重写UserAction的登录方法，利用shiroFilter进行登录的过滤

```
/**
* 用户登录，使用shiro框架提供的方式进行认证
* 
* @return
*/
public String login() {

// 先校验验证码是否输入正确
String validatecode = (String) session.get("key");
if (StringUtils.isNotBlank(checkcode) && checkcode.equals(validatecode)) {
// 使用shiro框架提供的方式进行认证

// 获得当前用户对象，里面包含认证状态
Subject subject = SecurityUtils.getSubject();
// 创建用户名密码令牌对象
AuthenticationToken token = new UsernamePasswordToken(model.getUsername(), MD5Utils.md5(model.getPassword()));
try {
subject.login(token);
} catch (UnknownAccountException e) {
this.addActionError("用户名不存在！");
return LOGIN;
} catch (IncorrectCredentialsException e) {
this.addActionError("密码输入错误！");
return LOGIN;
} catch (Exception e) {
this.addActionError("发生未知错误！");
return LOGIN;
}
//取得查询出来的User对象,放到Session
User user = (User) subject.getPrincipal();
session.put("loginUser", user);
return HOME;

} else {
// 输入验证码错误。设置提示信息，
this.addActionError("输入的验证码错误");
return LOGIN;
}
}
```

## 四、在BosRealm中完成授权

```
//授权方法
@Override
protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection arg0) {
//创建授权信息对象
SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();
//添加具体的授权信息
info.addStringPermission("staff-list");

//TODO 后期需要修改为根据当前用户查询数据库，获取实际对应的权限

//返回授权信息对象
return info;
}

```

# shiro进行权限控制的方式

## 一、URL拦截方式（基于过滤器实现）

1. 如前面介绍的，通过配置ShiroFilterFactoryBean的filterChainDefinitions属性，进行URL拦截的相关配置

```
<!-- 配置shiro框架的工厂对象 -->
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
<property name="securityManager" ref="securityManager"></property>
<!-- 注入相关页面访问URL -->
<property name="loginUrl" value="/login.jsp"/>
<property name="successUrl" value="/index.jsp"/>
<property name="unauthorizedUrl" value="unauthorized.jsp"/>

<!-- 注入URL拦截规则 -->
<property name="filterChainDefinitions">
<value>
/css/** = anon
/js/** = anon
/images/** = anon
/validatecode.jsp* = anon
/login.jsp = anon
/userAction_login.action = anon
/page_base_staff.action = perms["staff-list"]
/* = authc
</value>
</property>
</bean>
```

## 二、使用shiro的方法注解方式进行权限控制（基于代理技术实现）

1. 在Spring的配置文件中开启shiro的注解支持

```
<!-- 开启shiro框架注解支持 -->
<bean id="defaultAdvisorAutoProxyCreator" class="org.springframework.aop.framework.autoproxy.DefaultAdvisorAutoProxyCreator">
<!-- 表示必须使用cglib方式为Action创建动态代理对象 -->
<property name="proxyTargetClass" value="true"/>
</bean>

<!-- 配置shiro框架提供的切面类，用于创建代理对象 -->
<bean class="org.apache.shiro.spring.security.interceptor.AuthorizationAttributeSourceAdvisor"></bean>
```

2. 在Action的方法上添加注解，注明调用方法需要的权限

> 下面的注解表示执行StaffAction的deleteBatch方法需要用户具有staff-delete权限

```
/**
* 批量删除
* @return
*/
@RequiresPermissions("staff-delete")
public String deleteBatch(){
staffService.deleteBatch(ids);
return LIST;
}
```

3. 注意开启注解时，proxyTargetClass要设置为true

    - 该属性默认为false，表示使用JDK提供的动态代理创建目标Action的代理对象，这要求目标类必须对接口编程
    - 这在StaffAction中并不适用，虽然StaffAction实现了接口，但向页面提供的方法并不是用接口定义的，因此若不设置为true将无法代理Action中的方法
    - 设置为true，表示使用cglib进行代理对象的创建，由于cglib是利用继承进行代理，因此对任何类都是适用的

4. 当用户不具有权限时，核心过滤器会直接抛出异常，若不捕获则会直接再页面回显，用户不友好，因此要利用表现层框架捕获异常

5. 在struts.xml中配置捕获权限不足所抛出的异常，并配置对应的处理页面，注意全局异常要在全局结果集的后面

```
<global-results>
<result name="login">/login.jsp</result>
<result name="unauthorized">/unauthorized.jsp</result>
</global-results>

<!-- 配置全局异常捕获 -->
<global-exception-mappings>
<exception-mapping result="unauthorized" exception="org.apache.shiro.authz.UnauthorizedException"/>
</global-exception-mappings>
```

## 三、使用shiro提供的页面标签的方式进行权限控制（标签技术实现）

1. 在jsp页面中引入shiro的标签库

```
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
```

2. 使用shiro的标签来控制页面元素的展示

```
<shiro:hasPermission name="staff-delete">
{
id : 'button-delete',
text : '删除',
iconCls : 'icon-cancel',
handler : doDelete
},
</shiro:hasPermission>
```

3. `<shiro:hasPermission name="权限名">`标签可以根据是否具有权限进行内部相应按钮的展示

## 四、代码级别权限控制（基于代理技术）

1. 通过在调用方法之前编写Java代码校验权限，违背开闭原则，不建议使用

```
public String deleteBatch(){

//获取当前的Subject对象
Subject subject = SecurityUtils.getSubject();
//校验权限，没有权限直接抛出异常，有权限才可继续执行
subject.checkPermission("staff-delete");

staffService.deleteBatch(ids);
return LIST;
}
```
