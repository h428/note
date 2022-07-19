
[toc]

# 代码抽取

## 基于Hibernate的Dao层代码的抽取

1. 定义BaseDao接口，其他Dao接口继承该接口

2. 在Dao接口定定义基本的增删改查和分页有关的方法

```
public interface BaseDao<T> {
/**
* 保存实体
* @param entity
*/
void save(T entity);
/**
* 删除实体
* @param entity
*/
void delete(T entity);
/**
* 根据实体Id删除实体
* @param id
*/
void deleteById(Serializable id);
/**
* 更新实体信息
* @param entity
*/
void update(T entity);
/**
* 根据Id查询实体
* @param id
* @return
*/
T findById(Serializable id);
/**
* 查询所有实体信息
* @return
*/
List<T> list();
/**
* 查询实体的总数
* @param dc
* @return
*/
Integer	getTotalCount(DetachedCriteria dc);
/**
* 分页查询实体
* @param dc 离线查询条件
* @param start 查询起始下标
* @param pageSize 每页的记录条数
* @return
*/
List<T> getPageList(DetachedCriteria dc, Integer start, Integer pageSize);
}
```

2. 定义BaseDaoImpl，继承HibernateDaoSupport，实现BaseDao接口，主要要注入SessionFactory对象

```
public class BaseDaoImpl<T> extends HibernateDaoSupport implements BaseDao<T> {

private Class<T> entityClass;

@SuppressWarnings("unchecked")
public BaseDaoImpl() {
// 获取子类对象的父类类型
ParameterizedType superClass = (ParameterizedType) this.getClass()
.getGenericSuperclass();
// 获得在父类类型上声明的反省数组
Type[] genericTypes = superClass.getActualTypeArguments();
// 第一个泛型即为实体类型
entityClass = (Class<T>) genericTypes[0];
}

@Override
public void save(T entity) {
getHibernateTemplate().save(entity);
}

@Override
public void delete(T entity) {
getHibernateTemplate().delete(entity);
}

@Override
public void deleteById(Serializable id) {
T entity = getHibernateTemplate().load(entityClass, id);
getHibernateTemplate().delete(entity);
}

@Override
public void update(T entity) {
getHibernateTemplate().update(entity);
}

@Override
public T findById(Serializable id) {
return getHibernateTemplate().get(entityClass, id);
}

@Override
public List<T> list() {
return getHibernateTemplate().loadAll(entityClass);
}

@Override
public Integer getTotalCount(DetachedCriteria dc) {
//设置查询的聚合函数,总记录数
dc.setProjection(Projections.rowCount());
@SuppressWarnings("unchecked")
List<Long> list = (List<Long>) getHibernateTemplate().findByCriteria(dc);
//清空之前设置的聚合函数
dc.setProjection(null);

if(list!=null && list.size()>0){
Long count = list.get(0);
return count.intValue();
}else{
return null;
}
}

@Override
public List<T> getPageList(DetachedCriteria dc, Integer start, Integer pageSize) {
@SuppressWarnings("unchecked")
List<T> list = (List<T>) getHibernateTemplate().findByCriteria(dc, start, pageSize);
return list;
}

/**
* HibernateDao接口在使用前必须注入SessionFactory
* 
* @param sessionFactory
*/
@Autowired
public void setSF(SessionFactory sessionFactory) {
super.setSessionFactory(sessionFactory);
}
}
```

3. 其他的Dao接口继承BaseDao接口，定义额外的方法

4. 其他的Dao实现类继承BaseDaoImpl，实现Dao接口定义的方法

## 基于Struts2的Action层的抽取

1. 抽取BaseAction，定义基本的内容，供其他Action继承

```
public class BaseAction<T> extends ActionSupport implements ModelDriven<T>,
RequestAware, SessionAware {

private static final long serialVersionUID = 1L;

protected Map<String, Object> request;
protected Map<String, Object> session;
protected T model;

@Override
public void setRequest(Map<String, Object> request) {
this.request = request;
}

@Override
public void setSession(Map<String, Object> session) {
this.session = session;
}

@Override
public T getModel() {
return model;
}

public BaseAction() {
// 获取父类
ParameterizedType genericSuperclass = (ParameterizedType) this
.getClass().getGenericSuperclass();
// 获取父类的泛型数组
Type[] types = genericSuperclass.getActualTypeArguments();
// 取得第一个泛型，即Model的类型
@SuppressWarnings("unchecked")
Class<T> entityClass = (Class<T>) types[0];
try {
model = entityClass.newInstance();
} catch (InstantiationException | IllegalAccessException e) {
e.printStackTrace();
throw new RuntimeException(e);
}
}

}
```

2. 其他Action类继承该类即可

# 登录注销功能实现

## 登录

1. 准备validate.jsp页面

2. 在数据库插入数据

```
insert into t_user(id, username, password) values('1', 'admin', md5('admin'));
```

3. 调整login.jsp页面

    - 登录按钮的href改为#，并添加click事件，进行表单提交
    - 更改表单的action为Struts2中配置的地址：userAction_login.action

4. 创建UserAction，提供登录方法，添加@Controller注解和@Scope注解

```
public String login(){

//先校验验证码是否输入正确
String validatecode = (String) session.get("key");
if(StringUtils.isNotBlank(checkcode) && checkcode.equals(validatecode)){
//正确则调用service进行登录
User user = userService.login(model);
if(user != null){
//登录成功，将user放入session，然后跳转到首页
session.put("loginUser", user);
return HOME;
}else{
//登录失败
this.addActionError("用户名或者密码输入错误");
return LOGIN;
}

}else{
//输入验证码错误。设置提示信息，
this.addActionError("输入的验证码错误");
return LOGIN;
}
}
```

5. 创建UserService、UserDao相关，进行登录逻辑

6. 在struts.xml中配置UserAction

```
<action name="userAction_*" class="userAction" method="{1}">
<result name="login">/login.jsp</result>
<result name="home">/index.jsp</result>
</action>
```
## 注销

1. 在UserAction中编写logout

## 登录拦截器

1. 自定义一个拦截器进行登录过滤，最好是继承MethodFiMethodFilterInterceptor，因为这个拦截器可以定义不过滤的路径

```
public class LoginInterceptor extends MethodFilterInterceptor{

private static final long serialVersionUID = 1L;

@Override
protected String doIntercept(ActionInvocation invocation) throws Exception {
User user = BOSUtils.getLoginUser();
if(user == null){
return "login";
}
return invocation.invoke();
}

}
```

2. 在struts中配置登录拦截器和拦截器栈

```
<interceptors>
<!-- 注册拦截器 -->
<interceptor name="loginInterceptor" class="com.hao.bos.interceptor.LoginInterceptor">
<!-- 制定不拦截的方法 -->
<param name="excludeMethods">login</param>
</interceptor>
<!-- 定义拦截器栈 -->
<interceptor-stack name="myStack">
<interceptor-ref name="loginInterceptor"/>
<interceptor-ref name="defaultStack"/>
</interceptor-stack>
</interceptors>
```

3. 配置默认拦截器栈

```
<default-interceptor-ref name="myStack"/>
```

4.配置全局结果

```
<global-results>
<result name="login">/login.jsp</result>
</global-results>
```

# 基于ajax的密码修改

## validatebos的使用

1. validatebox用于做页面的输入校验
2. 提供以下校验规则：
    - 非空校验
    - 使用validType指定，可选值为email,url,length[0,100],remote['http://.../action.do', 'paramName']
    - 其中remote['http://.../action.do', 'paramName']表示发送ajax请求做验证（基于ajax的服务端校验），返回"true"即成功
    - 支持自定义规则
3. 要进行校验，首先为input添加一个class：easyui-validatebox
4. 添加校验规则：
    - required="true"添加非空校验
    - data-options="validateType:'length[4,6]'"
5. 可以在js中使用$("#formId").form("validate");对添加了规则的表单进行校验，校验通过返回true，否则返回false

## 基于ajax修改密码

1. 为两个密码输入框添加非空和长度校验

```
<input id="txtNewPass" type="Password" class="txt01 easyui-validatebox" required="true" data-options="validateType:'length[4,6]'"/>
<input id="txtRePass" type="Password" class="txt01 easyui-validatebox" required="true" data-options="validateType:'length[4,6]'"/>
```

2. 在input外层添加form标签，并添加id

```
<form id="editPasswordForm">...</form>
```

3. 为提交按钮添加单击事件响应函数，在函数里进行表单校验、密码一致性校验、并提交请求

```
$("#btnEp").click(function(){
var v = $("#editPasswordForm").form("validate");
if(v){
//手动校验输入是否一致
var v1 = $("#txtNewPass").val();
var v2 = $("#txtRePass").val();
if(v1 == v2){
//输入一致，发送请求
$.ajax({
"url":"userAction_editPassword.action",
"data":{"password":v1},
"type":"post",
"success":function(resp, textStatus, xmlHttp){
console.log(resp);
if(resp=="true"){
//修改成功，关闭修改密码窗口
$("#editPwdWindow").window("close");
$.messager.alert("提示信息", "密码修改成功！", "info");
}else{
//修改失败，弹出提示
$.messager.alert("提示信息", "密码修改失败！", "error");
}
},
"error":function(xmlHttp, textStatus, exception){
alert(xmlHttp.status);
}
});
}else{
$.messager.alert("提示信息", "两次密码输入不一致！", "warning");
}
}
});
```

4. 编写UserAction的editPassword，注意基于Ajax的返回类型要为NONE，响应直接通过out回写

```
public String editPassword(){
String respData = "true";
//修改当前用户的密码
User loginUser = BOSUtils.getLoginUser();
try {
userService.editPassword(loginUser.getId(), model.getPassword());
} catch (Exception e) {
respData = "false";
e.printStackTrace();
}
BOSUtils.getWriter().write(respData);
return NONE;
}
```

5. 更改BaseDao和BaseDaoImpl，抽取更新部分列的方法

    - BaseDao接口

```
/**
* 使用hbm中自定义的基于HQL的查询名称进行部分列的更新
* @param queryName 
* @param objects 待更新的列的值
*/
void executeUpdate(String queryName, Object... objects);
```
    - BaseDaoImpl实现类

```
@Override
public void executeUpdate(String queryName, Object... objects) {
Session session = this.getSessionFactory().getCurrentSession();
//根据定义的查询名称创建对应的Query对象
Query query = session.getNamedQuery(queryName);
//为HQL中的？赋值
int index = 0;
for (Object object : objects) {
query.setParameter(index++, object);
}
//执行更新
query.executeUpdate();
}
```

6. 在User.hbm.xml中定义HQL

```
<query name="user.editPassword">
UPDATE User SET password = ? WHERE id = ?
</query>
```

7. 在UserService直接调用抽取的executeUpdate方法执行密码更新

```
@Override
@Transactional(isolation=Isolation.REPEATABLE_READ, propagation=Propagation.REQUIRED, readOnly=false)
public void editPassword(String id, String password) {
password = MD5Utils.md5(password);
userDao.executeUpdate("user.editPassword", password, id);
}
```