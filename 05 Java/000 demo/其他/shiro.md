

# 0. 概述

- Subject : 代表当前用户，用于提供当前用户的信息
- SecurityManager : 所有 Subject 的管理者，是 Shiro 的核心组件，用于调度各种 Shiro 框架的服务，类似 SpringMVC 中的 Dispatch
- Realm : 用户信息认证器和用户的权限认证器，可以看成是数据源，SecurityManager 要认证用户，需要从 Realm 获取和用户认证相关的数据
- 简单应用 : 通过 Subject 进行认证和授权，然后 Subject 委托给 SecurityManager，我们要将 Realm 提供给 SecurityManager，这样 SecurityManager 在认证的时候会调用 Realm 获取相关信息以进行用户认证
- Authenticator : 认证器，有许多认证策略，用于认证（用于登录时）
- Authrizer : 授权器，访问资源时则会调用授权器进行授权，查看当前认证的用户是否具有对应权限

**初始相关配置**

- maven 依赖
```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-log4j12</artifactId>
    <version>1.6.4</version>
</dependency>
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-core</artifactId>
    <version>1.2.3</version>
</dependency>
```
- 在 resources 下提供 log4j.properties

# 1. 入门样例

## 1.1 ini 数据源样例

- pom 中引入依赖，在 resources 下创建 log4j.properties 文件
- 以及下述 shiro.ini 配置文件
    - 在 `[users]` 下方定义用户，每个用户格式为：用户=密码, 角色1, 角色2...，例如 `root=123456, admin, role2, ...`，支持多个角色
    - 在 `[roles]` 下方定义角色，格式为：角色=权限，例如 `admin=*`, `test=search, add, update`，其中 * 表示任意权限
```ini
[users]
root=123456, admin
test=000000, test

[roles]
admin=*
test=search, add, update
```

- 编写 ShiroTest 类，包括创建过程、登录、验证是否具有对应角色，是否具有对应权限等操作，详细参考注释
```java
public class ShiroTest {
    public static void main(String[] args) {
        // 从 shiro.ini 配置文件创建工厂
        Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro.ini");
        // 获得 SecurityManager
        SecurityManager securityManager = factory.getInstance();
        // 利用 工具类将 securityManager 绑定到上下文中（这是一个全局设置，只需设置一次）
        SecurityUtils.setSecurityManager(securityManager);

        // 获得与用户交互的 Subject，大部分操作都通过该对象进行
        Subject subject = SecurityUtils.getSubject();
        // 创建用户名和密码的 token
        UsernamePasswordToken token = new UsernamePasswordToken("root", "123456");

        try {
            // 执行登录，若验证不通过会抛出异常
            subject.login(token);
            if (subject.isAuthenticated()) {
                System.out.println("登录成功");

                // 判断是否具有某角色
                String role = "admin";
                if (subject.hasRole(role)) {
                    System.out.println("有 "+ role +" 角色");
                } else {
                    System.out.println("没有 "+ role +" 角色");
                }

                // 传入多个角色逐一判断
                String[] roles = new String[]{"admin", "test"};
                boolean[] hasRoles = subject.hasRoles(Arrays.asList(roles));
                System.out.println(Arrays.toString(hasRoles));

                // 判断是否同时具有多个角色
                System.out.println(subject.hasAllRoles(Arrays.asList(roles)));

                // 判断权限
                String[] aus = new String[]{"search", "del"};

                for (String au : aus) {
                    // 判断是否具有某权限
                    if (subject.isPermitted(au)) {
                        System.out.println("有 "+ au +" 权限");
                    } else {
                        System.out.println("没有 "+ au +" 权限");
                    }
                }

                // 直接传入数组判断是否具有权限，返回对应长度的 boolean 数组
                boolean[] permitted = subject.isPermitted(aus);
                System.out.println(Arrays.toString(permitted));

                // 还可以判断是否同时具有多种权限
                boolean permittedAll = subject.isPermittedAll(aus);
                System.out.println(permittedAll);
            }
        } catch (AuthenticationException e) {
            System.out.println("用户名或密码错误");
        }

        // 查看验证信息
        System.out.println(subject.isAuthenticated()); // 查看当前用户是否验证过
    }
}
```

## 1.2 基于纯 Java 代码的样例

- 使用自定义 Realm 来定义数据源而不是使用 ini 文件
```java
public class MyRealm implements Realm {

    public String getName() {
        return "myrealm";
    }

    public boolean supports(AuthenticationToken authenticationToken) {
        // 限定数据源只支持 UsernamePasswordToken
        return authenticationToken instanceof UsernamePasswordToken;
    }

    public AuthenticationInfo getAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
        // 使用模拟数据（或者从数据库获取）

        String username = (String) authenticationToken.getPrincipal();
        String password = new String((char[])authenticationToken.getCredentials());

        // 假设 test 用户
        if (!"test".equals(username)) {
            // 用户名不是 test
            throw new UnknownAccountException();
        }
        else if (!"123456".equals(password)) {
            // 密码不正确
            throw new IncorrectCredentialsException();
        }
        return new SimpleAuthenticationInfo(username, password, getName());
    }
}
```

- 测试类
```java
public class ShiroJavaTest {
    public static void main(String[] args) {
        // 1. 设置核心组件 SecurityManager（纯 Java 要自行创建和设置：认证器, 授权器, 数据源 到 SecurityManager）
        DefaultSecurityManager securityManager = new DefaultSecurityManager(); // 创建 SecurityManager

        // 认证器相关
        ModularRealmAuthenticator authenticator = new ModularRealmAuthenticator(); // 创建认证器
        authenticator.setAuthenticationStrategy(new AtLeastOneSuccessfulStrategy()); // 设置认证器策略
        securityManager.setAuthenticator(authenticator);  // 然后将认证器指定给 SecurityManager

        // 授权器相关
        ModularRealmAuthorizer authorizer = new ModularRealmAuthorizer();  // 创建授权器
        authorizer.setPermissionResolver(new WildcardPermissionResolver()); // 设置权限转换器：将字符串转化为权限实例对象
        securityManager.setAuthorizer(authorizer);

        // 设置数据源，需要自定义 Realm
        securityManager.setRealm(new MyRealm());

        // 将 securityManager 绑定到上下文
        SecurityUtils.setSecurityManager(securityManager);

        // 2. 获取 Subject 并执行操作：包括认证（即登录）, 授权（即查看是否具有指定权限）
        String[] roles = new String[]{"admin", "test"};
        String[] permissions = new String[]{"search", "del"};
        testSubject("test", "123456", roles, permissions);

    }

    /**
     * 提供用户名和密码，查看是否认证成功，并测试是否具有指定角色和权限
     * @param username 用户名
     * @param password 密码
     * @param roles 角色数组
     * @param permissions 权限数组
     */
    private static void testSubject(String username, String password, String[] roles, String[] permissions) {
        // 获得与用户交互的 Subject，大部分操作都通过该对象进行
        Subject subject = SecurityUtils.getSubject();
        // 创建用户名和密码的 token
        UsernamePasswordToken token = new UsernamePasswordToken(username, password);

        try {
            subject.login(token); // 认证：执行登录，若验证不通过会抛出异常
            if (subject.isAuthenticated()) {
                System.out.println(username + " 登录成功");

                // 循环判断是否具有某角色
                for (String role : roles) {
                    if (subject.hasRole(role)) {
                        System.out.println(username + " 有 "+ role +" 角色");
                    } else {
                        System.out.println(username + " 没有 "+ role +" 角色");
                    }
                }

                // 传入多个角色数组逐一判断，返回 boolean 数组
                boolean[] hasRoles = subject.hasRoles(Arrays.asList(roles));
                System.out.println(Arrays.toString(roles) + " : " + Arrays.toString(hasRoles));

                // 判断是否同时具有多个角色
                boolean hasAllRoles = subject.hasAllRoles(Arrays.asList(roles));
                System.out.println("是否同时具有上述角色 : " + hasAllRoles);

                // 循环判断是否具有某权限
                for (String permission : permissions) {
                    // 判断是否具有某权限
                    if (subject.isPermitted(permission)) {
                        System.out.println(username + " 有 "+ permission +" 权限");
                    } else {
                        System.out.println(username + " 没有 "+ permission +" 权限");
                    }
                }

                // 直接传入数组判断是否具有权限，返回对应长度的 boolean 数组
                boolean[] permitted = subject.isPermitted(permissions);
                System.out.println(Arrays.toString(permissions) + " : " + Arrays.toString(permitted));

                // 还可以判断是否同时具有多种权限
                boolean permittedAll = subject.isPermittedAll(permissions);
                System.out.println("是否同时具有上述权限 : " + permittedAll);
            }
        } catch (UnknownAccountException e){
            System.out.println("用户" + username +"不存在");
        }
        catch (IncorrectCredentialsException e) {
            System.out.println("密码错误");
        }
        catch (AuthenticationException e) {
            e.printStackTrace();
            System.out.println("发生异常，认证失败");
        }

        // 查看验证信息
        System.out.println(username + " 是否授权成功 : " + subject.isAuthenticated()); // 查看当前用户是否验证过
    }
}
```

## 1.3 MySQL 数据源（使用 ini 配置数据源）使用样例

- 数据库使用 user, role, permission 以及两张中间关联表，支持多对多，详细参考 [maven.sql](./sql/maven.sql.md)
- 数据源配置，使用 ini 配置，在 resources 下提供 shiro-mysql.ini 文件
```ini
[main]
dataSource=com.alibaba.druid.pool.DruidDataSource
dataSource.url=jdbc:mysql://localhost:3306/maven?characterEncoding=utf-8
dataSource.driverClassName=com.mysql.jdbc.Driver
dataSource.username=root
dataSource.password=root

jdbcRealm=org.apache.shiro.realm.jdbc.JdbcRealm
# 是否检查权限
jdbcRealm.permissionsLookupEnabled = true
jdbcRealm.dataSource=$dataSource

# 重写 sql 语句
# 根据用户名查询密码
jdbcRealm.authenticationQuery = select password from user where username = ?
jdbcRealm.userRolesQuery = select name from role where exists ( select * from user_role where user_role.role_id = role.id and exists( select * from user where user_role.user_id = user.id and user.username = ? ) )
jdbcRealm.permissionsQuery = select name from permission where exists( select * from role_permission where permission_id = permission.id and exists( select * from role where role_id = id and role.name = ? ) )

securityManager.realms=$jdbcRealm
```

- 测试代码
```java
public class ShiroMysqlTest {
    public static void main(String[] args) {
        // 1. 设置 SecurityManager
        Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro-mysql.ini"); // 从 ini 文件读取配置并创建工厂
        SecurityManager securityManager = factory.getInstance();  // 从工厂获得 SecurityManager 实例
        SecurityUtils.setSecurityManager(securityManager); // 设置 SecurityManager

        // 2. 获取 Subject 并执行操作
        Subject subject = SecurityUtils.getSubject(); // 获得与用户交互的 Subject，大部分操作都通过该对象进行
        UsernamePasswordToken token = new UsernamePasswordToken("cat", "cat"); // 创建用户名和密码的 token

        try {
            subject.login(token); // 执行登录，若验证不通过会抛出异常
            if (subject.isAuthenticated()) {
                System.out.println("登录成功");

                // 判断是否具有某角色
                String[] roles = new String[]{"admin", "test"};
                for (String role : roles) {
                    if (subject.hasRole(role)) {
                        System.out.println("有 "+ role +" 角色");
                    } else {
                        System.out.println("没有 "+ role +" 角色");
                    }
                }

                // 传入多个角色逐一判断
                boolean[] hasRoles = subject.hasRoles(Arrays.asList(roles));
                System.out.println(Arrays.toString(hasRoles));

                // 判断是否同时具有多个角色
                System.out.println(subject.hasAllRoles(Arrays.asList(roles)));

                // 判断权限
                String[] aus = new String[]{"search", "del", "add", "update"};
                for (String au : aus) {
                    // 判断是否具有某权限
                    if (subject.isPermitted(au)) {
                        System.out.println("有 "+ au +" 权限");
                    } else {
                        System.out.println("没有 "+ au +" 权限");
                    }
                }

                // 直接传入数组判断是否具有权限，返回对应长度的 boolean 数组
                boolean[] permitted = subject.isPermitted(aus);
                System.out.println(Arrays.toString(permitted));

                // 还可以判断是否同时具有多种权限
                boolean permittedAll = subject.isPermittedAll(aus);
                System.out.println(permittedAll);
            }
        } catch (UnknownAccountException e){
            System.out.println("用户不存在");
        }
        catch (IncorrectCredentialsException e) {
            System.out.println("密码错误");
        }
        catch (AuthenticationException e) {
            e.printStackTrace();
            System.out.println("发生异常，认证失败");
        }

        // 查看验证信息
        System.out.println(subject.isAuthenticated()); // 查看当前用户是否验证过
    }
}
```

# 2. 说明

## 2.1 认证

**大致登录流程**

- 从配置文件创建 SecurityManager 工厂并生成对应实例，然后调用 SecurityUtils.setSecurityManager() 设置全局 SecurityManager
- 获取 subject，并调用 `Subject.login(token)` 进行登录，其会自动委托给 SecurityManager 进行身份验证
- Authenticator 才是真正的身份验证着，Shiro API 中核心的身份认证入口点，此处可以自定义插入自己的认证逻辑
- Authenticator 可能会委托给相应的 AuthenticationStrategy 进行多 Realm 身份验证，默认 ModularRealmAuthenticator 会调用 AuthenticationStrategy 进行多 Realm 身份验证
- Authenticator 会吧相应的 token 传入 Realm，从 Realm 获取身份验证，默认 ModularRealmAuthenticator 会调用 AuthenticatorStrategy 进行多 Realm 身份验证
- Authenticator 会把相应的 token 传入 Realm，从 Realm 获取身份验证信息，如果没有返回或者抛出异常则说明身份验证失败

**其他说明**

- SecurityManager 接口继承了 Authenticator，另外还有一个 ModularRealmAuthenticator 实现，其委托给多个 Realm 进行验证，验证时可能有很多策略，通过 AuthenticationStrategy 接口指定，默认提供下述实现：
    - FirstSuccessfulStrategy
    - AtLeastOneSuccessfulStrategy
    - AllSuccessfulStrategy
    - ModularRealmAuthenticator 默认使用 AtLeastOneSuccessfulStrategy 策略

## 2.2 授权

- 授权，也叫访问控制，即在应用中控制谁能访问哪些资源（如访问页面/编辑数据/页面操作等）
- 授权需要重点关注几个对象：主体（Subject）、资源（Resource）、权限（Permission）、角色（Role）
- 主体：访问应用的用户，在 Shiro 中使用 Subject 表示，用户只有在认证并授权后才能访问相应资源
- 资源：应用中可以访问的任何东西、如页面、数据等
- 权限：原子授权单位，通过权限表示用户是否具有操作某个资源的能力，需要将权限授权给用户以和用户绑定起来

## 2.3 数据源 Realm

- Realm 接口声明下述方法：
    - getName() : 数据源名称
    - supports() : 支持哪种类型的 token
    - getAuthenticationInfo() : 获得用户验证信息的方法
- Shiro 提供许多默认的 Realm，例如 ini 样例中使用的就是基于 ini 的 Realm，此外还有 jdbc realm


# 备注

- 创建并设置 SecurityManager
- 获取 Subject ，创建 token 并进行登录
- 判断当前 Subject 是否具有对应角色和权限