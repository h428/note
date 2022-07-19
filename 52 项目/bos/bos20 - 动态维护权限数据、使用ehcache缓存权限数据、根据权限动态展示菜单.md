[TOC]

# 动态维护权限数据

1. 修改BosRealm中的授权方法

```
//授权方法
@Override
protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
//创建授权信息对象
SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();

//根据当前用户查询数据库，获取实际对应的权限

List<Function> list = null;
//获取当前登录的用户对象
User user = (User) SecurityUtils.getSubject().getPrincipal();
//User user2 = (User) principals.getPrimaryPrincipal();

if(user.getUsername().equals("admin")){
//超级管理员用户
DetachedCriteria dc = DetachedCriteria.forClass(Function.class);
list = functionDao.findByCriteria(dc);
}else{
//根据用户ID查询其拥有的权限
list = functionDao.findFunctionListByUserId(user.getId());
}
//遍历权限集合
for (Function function : list) {
info.addStringPermission(function.getCode());
}
//返回授权信息对象
return info;
}
```

2. 实现根据用户ID查询对应的权限

```
/**
* 根据用户ID查询对应的权限
*/
@Override
public List<Function> findFunctionListByUserId(String id) {
//涉及5张表的关联查询，使用hql由于省略的中间表，剩下3个类的关联查询
String hql = "SELECT DISTINCT f FROM Function f LEFT OUTER JOIN f.roles r LEFT OUTER JOIN r.users u WHERE u.id=?";
@SuppressWarnings("unchecked")
List<Function> find = (List<Function>) getHibernateTemplate().find(hql, id);
return find;
}
```

# 使用ehcache缓存权限数据

1. 若不使用缓存，会频繁查询数据库，因此要为权限数据建立缓存

2. ehcache是一个缓存插件，可以缓存Java对象提高系统的性能

3. ehcache.xml配置文件样例

```
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://ehcache.org/ehcache.xsd">

<diskStore path="java.io.tmpdir" />

<defaultCache maxElementsInMemory="10000" eternal="false"
timeToIdleSeconds="120" timeToLiveSeconds="120" overflowToDisk="true"
maxElementsOnDisk="10000000" diskPersistent="false"
diskExpiryThreadIntervalSeconds="120" memoryStoreEvictionPolicy="LRU" />
</ehcache>
```

4. 在Spring中配置缓存管理器并注入缓存管理器器

```
<!-- 注册缓存管理器 -->
<bean id="cacheManager" class="org.apache.shiro.cache.ehcache.EhCacheManager">
<!-- 注入ehcache的配置文件 -->
<property name="cacheManagerConfigFile" value="classpath:ehcache.xml"/>
</bean>

<bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
<property name="realm" ref="bosRealm" />
<!-- 注入缓存管理器 -->
<property name="cacheManager" ref="cacheManager"/>
</bean>
```

# 根据权限动态展示菜单

1. 修改index.jsp页面中ajax请求的url为functionAction_findMenu.action，请求菜单数据

2. 实现FunctionAction.findMenu方法

```
/**
* 根据当前登录的用户查询对应的菜单数据，返回json
* @return
*/
public String findMenu(){
List<Function> functionList = functionService.findMenu();
list2JsonAndWriteResponse(functionList, "parentFunction" , "roles", "children");
return NONE;
}
```

3. 实现FunctionService.findMenu

```
@Override
public List<Function> findMenu() {
List<Function> functionList = null;
User user = BOSUtils.getLoginUser();
if(user.getUsername().equals("admin")){
//如果是内置用户，则查询所有菜单
functionList = functionDao.findAllMenu();
}else{
//其他用户，根据用户ID查询菜单
functionList = functionDao.findMenuByUserId(user.getId());
}
return functionList;
}
```

4. 实现FunctionDao.findAllMenu();

```
/**
* 查询所有菜单
*/
@Override
public List<Function> findAllMenu() {
String hql = "from Function f where f.generatemenu = '1' ORDER BY f.zindex";
@SuppressWarnings("unchecked")
List<Function> list = (List<Function>) getHibernateTemplate().find(hql);
return list;
}
```

5. 实现FunctionDao.findMenuByUserId

```
@Override
public List<Function> findMenuByUserId(String id) {
//涉及5张表的关联查询，使用hql由于省略的中间表，剩下3个类的关联查询
String hql = "SELECT DISTINCT f FROM Function f LEFT OUTER JOIN f.roles r LEFT OUTER JOIN r.users u "
+ " WHERE u.id=? AND f.generatemenu = '1' "
+ "ORDER BY f.zindex";
@SuppressWarnings("unchecked")
List<Function> find = (List<Function>) getHibernateTemplate().find(hql, id);
return find;
}
```

