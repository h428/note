[TOC]

# 权限数据管理

## 一、初始化权限数据

1. 系统运行所以须的基础数据

2. 运行sql

```
INSERT INTO `auth_function` VALUES ('11', '基础档案', 'jichudangan', null, null, '1', '0', null);
INSERT INTO `auth_function` VALUES ('112', '收派标准', 'standard', null, 'page_base_standard.action', '1', '1', '11');
INSERT INTO `auth_function` VALUES ('113', '取派员设置', 'staff', null, 'page_base_staff.action', '1', '2', '11');
INSERT INTO `auth_function` VALUES ('114', '区域设置', 'region', null, 'page_base_region.action', '1', '3', '11');
INSERT INTO `auth_function` VALUES ('115', '管理分区', 'subarea', null, 'page_base_subarea.action', '1', '4', '11');
INSERT INTO `auth_function` VALUES ('116', '管理定区/调度排班', 'decidedzone', null, 'page_base_decidedzone.action', '1', '5', '11');
INSERT INTO `auth_function` VALUES ('12', '受理', 'shouli', null, null, '1', '1', null);
INSERT INTO `auth_function` VALUES ('121', '业务受理', 'noticebill', null, 'page_qupai_noticebill_add.action', '1', '0', '12');
INSERT INTO `auth_function` VALUES ('122', '工作单快速录入', 'quickworkordermanage', null, 'page_qupai_quickworkorder.action', '1', '1', '12');
INSERT INTO `auth_function` VALUES ('124', '工作单导入', 'workordermanageimport', null, 'page_qupai_workorderimport.action', '1', '3', '12');
INSERT INTO `auth_function` VALUES ('13', '调度', 'diaodu', null, null, '1', '2', null);
INSERT INTO `auth_function` VALUES ('131', '查台转单', 'changestaff', null, null, '1', '0', '13');
INSERT INTO `auth_function` VALUES ('132', '人工调度', 'personalassign', null, 'page_qupai_diaodu.action', '1', '1', '13');
INSERT INTO `auth_function` VALUES ('14', '物流配送流程管理', 'zhongzhuan', null, null, '1', '3', null);
INSERT INTO `auth_function` VALUES ('141', '启动配送流程', 'start', null, 'workOrderManageAction_list.action', '1', '0', '14');
INSERT INTO `auth_function` VALUES ('142', '查看个人任务', 'personaltask', null, 'taskAction_findPersonalTask.action', '1', '1', '14');
INSERT INTO `auth_function` VALUES ('143', '查看我的组任务', 'grouptask', null, 'taskAction_findGroupTask.action', '1', '2', '14');
INSERT INTO `auth_function` VALUES ('8a7e843355a4392d0155a43aa7150000', '删除取派员', 'staff.delete', 'xxx', 'staffAction_delete.action', '0', '1', '113');
INSERT INTO `auth_function` VALUES ('8a7e843355a442460155a442bcfc0000', '传智播客', 'itcast', '', 'http://www.itcast.cn', '1', '1', null);
```

## 二、添加权限数据

1. 将function.hbm.xml中的主键生成策略设置为uuid

2. 将admin/function_add.jsp页面的输入id的更改为关键字

```
<tr>
<td width="200">关键字</td>
<td>
<input type="text" name="code" class="easyui-validatebox" data-options="required:true" />	
</td>
</tr>
```

3. 修改父功能点这一栏的的textField和url属性，设置从Action获取数据

```
<tr>
<td>父功能点</td>
<td>
<input name="parentFunction.id" class="easyui-combobox" data-options="valueField:'id',textField:'name',url:'functionAction_listajax.action'"/>
</td>
</tr>
```

3. 实现FunctionAction.listajax

```
/**
* 查询所有权限数据，返回json
*/
public String listajax(){
List<Function> list = functionService.list();
list2JsonAndWriteResponse(list, "parentFunction", "roles", "children");
return NONE;
}
```

4. 实现FuctionService.list方法

```
@Override
public List<Function> list() {
return functionDao.list();
}
```

5. 为保存按钮绑定单机事件，进行校验，通过则提交表单

```
$(function(){
// 点击保存
$('#save').click(function(){
//表单校验
var f = $("#functionForm").form("validate");
if(f){
//校验通过则提交表单
$("#functionForm").submit();
}
});
});
```

6. 实现FunctionAction.add方法

```
@Override
public void save(Function model) {
Function parentFunction = model.getParentFunction();
if(parentFunction != null && parentFunction.getId().equals("")){
model.setParentFunction(null);
}
functionDao.save(model);
}
```

## 三、权限分页查询

1. 修改页面数据表格的url为functionAction_pageQuery.action

2. 实现FunctionAction.pageQuery方法，注意处理page属性被Function实体读取的问题

```
/**
* 权限数据分页查询
* @return
*/
public String pageQuery(){
//处理分页参数page和Function属性page冲突的情况
int currentPage = Integer.parseInt(model.getPage());
pageBean.setCurrentPage(currentPage);
//调用service进行分页查询
functionService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, "parentFunction", "roles", "children");
return NONE;
}
```

# 角色管理

## 一、添加角色

1. role_add.jsp页面调整，编号更改为add

2. 对于授权属性，设置ztree的勾选效果：setting的check属性设置为true即可

```
var setting = {
data : {
key : {
title : "t"
},
simpleData : {
enable : true
}
},
check : {
enable : true,
}
};
```

3. 设置ztree获取数据的url为pageContext.request.contextPath}/functionAction_listajax.action

```
$.ajax({
url : '${pageContext.request.contextPath}/functionAction_listajax.action',
type : 'POST',
dataType : 'json',
success : function(resp) {
$.fn.zTree.init($("#functionTree"), setting, resp);
},
error : function(msg) {
alert('树加载异常!');
}
});
```

4. 为保存按钮绑定事件，提交表单

```
// 点击保存
$('#save').click(function(){
//表单校验
var f = $("#roleForm").form("validate");
if(f){
//根据ztree的id获取ztree对象
var treeObj = $.fn.zTree.getZTreeObj("functionTree");
//获取ztree上选中的节点，返回数组对象
var nodes = treeObj.getCheckedNodes(true);
var array = new Array();
for(var i = 0; i < nodes.length; ++i){
var id = nodes[i].id;
array.push(id);
}
var functionIds = array.join(",");
//为隐藏域赋值（权限的id拼接成的字符串）
$("input[name=functionIds]").val(functionIds);
$("#roleForm").submit();
}
});
```

5. 实现RoleAction.add方法

```
/**
* 添加角色
* @return
*/
public String add(){
roleService.save(model, functionIds);
return LIST;
}
```

6. 实现RoleService.save方法

```
/**
* 保存一个角色，同时关联权限
*/
@Override
public void save(Role model, String functionIds) {
roleDao.save(model);
if(StringUtils.isNotBlank(functionIds)){
String[] fIds = functionIds.split(",");
for (String id : fIds) {
//角色关联权限
Function f = new Function();
f.setId(id);
model.getFunctions().add(f);
}
}
}
```

7. 在struts.xml中配置RoleAction

```
<action name="roleAction_*" class="roleAction" method="{1}">
<result name="list">/WEB-INF/pages/admin/role.jsp</result>
</action> 
```

## 二、角色分页查询

1. 修改role.jsp的datagrid获取url的地址为roleAction_pageQuery.action

2. 实现RoleAction.pageQuery方法

```
/**
* 分页查询角色对象，返回json数据
* @return
*/
public String pageQuery(){
roleService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, "functions", "users");
return NONE;
}
```

3. 实现RoleService.pageQuery方法

```
@Override
public void pageQuery(PageBean<Role> pageBean) {
roleDao.pageQuery(pageBean);
}
```

# 用户管理

## 一、添加用户

1. 发送ajax请求获取角色数据，在回调函数中进行回显为checkbox

```
<script type="text/javascript">
$(function(){
//页面加载完成后发送ajax请求获取角色数据并回显为checkbox
$.post("roleAction_listajax.action", function(data){
for(var i = 0; i < data.length; ++i){
var id = data[i].id;
var name = data[i].name;
$("#roleTD").append('<input id="'+id+'" type="checkbox" name="roleIds" value='+id+'><label for="'+id+'">'+name+'</label>');
}
});
});
</script>
```

2. 提供RoleAction.listajax方法

```
/**
* 查询所有角色数据，返回json
* @return
*/
public String listajax(){
List<Role> roleList = roleService.list();
list2JsonAndWriteResponse(roleList, "functions", "users");
return NONE;
}
```

3. 实现RoleService.listajax方法

```
@Override
public List<Role> list() {
return roleDao.list();
}
```

4. 为保存按钮添加事件，提交表单

```
$(function(){
$("body").css({visibility:"visible"});
$('#save').click(function(){
var f = $("#userForm").form("validate");
if(f){
$("#userForm").submit();
}
});
});
```

5. 实现UserAction.add方法

```
/**
* 新增用户
* @return
*/
public String add(){
userService.save(model, roleIds);
return LIST;
}
```

6. 实现UserService.save

```
/**
* 添加一个用户同时关联角色
*/
@Override
public void save(User model, String[] roleIds) {
//密码加密
String pass = MD5Utils.md5(model.getPassword());
model.setPassword(pass);
userDao.save(model);
if(roleIds != null && roleIds.length > 0){
for (String id : roleIds) {
//手动构造托管对象
Role role = new Role();
role.setId(id);
//用户对象关联角色对象
model.getRoles().add(role);
}
}
}
```

## 二、用户分页查询

1. 更改页面数据表格的url为userAction_pageQuery.action

2. 实现UserAction.pageQuery方法

```
/**
* 分页查询用户数据
* @return
*/
public String pageQuery(){
userService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, "currentPage", "detachedCriteria", "pageSize", "roles", "noticebills");
return NONE;
}
```

3. 实现UserService.pageQuery方法

```
@Override
public void pageQuery(PageBean<User> pageBean) {
userDao.pageQuery(pageBean);;
}
```

4. 为User添加getRoleNames方法，用于json数据的返回

```
public String getRoleNames(){
StringBuilder sb = new StringBuilder();
for (Role role : roles) {
sb.append(role.getName()).append(" ");
}
return sb.toString();
}
```
