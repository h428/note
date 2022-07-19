[TOC]

# 定区关联客户

## 一、在BOS项目中配置远程代理对象，远程调用CRM

1. 使用命令wsimport命令解析wsdl文件生成本地源代码

```
wsimport -s . -p com.hao.crm.service http://localhost:8080/CRM/service/customer?wsdl
```

2. 复制CustomerService和Customer类对象啊到bos项目中

3. 引入cxf的依赖（已经在porm.xml中引过）

4. 在Spring配置文件中注册crm客户端的代理对象

```
<!-- 注册CRM客户端代理对象 -->
<jaxws:client id="customerService" serviceClass="com.hao.crm.service.CustomerService" 
address="http://localhost:8080/CRM/service/customer?wsdl"></jaxws:client>
```

5. 在UserAction中注入代理对象，添加断点测试CustomerService是否注入成功（可以在login方法中），最后删除刚刚添加的代码

## 二、完善crm的Service

1. 在CRM的CustomerService接口中扩展查询未关联定区的客户和查询已关联定区的客户的方法

```
@WebService
public interface CustomerService {

/**
* 查询所有客户
* @return
*/
List<Customer> list(); 

/**
* 查询未关联定区的客户
* @return
*/
List<Customer> listNotAssociation(); 

/**
* 查询已关联定区的客户
* @param decidedzoneId 定区id
* @return
*/
List<Customer> listHasAssociation(String decidedzoneId); 
}
```

2. 在CustomerServiceImpl中实现扩展的方法，并使用静态内部类重构CustomerServiceImpl

```
@Transactional(isolation=Isolation.REPEATABLE_READ, readOnly=false)
public class CustomerServiceImpl implements CustomerService{

@Override
public List<Customer> list() {
String sql = "select * from t_customer";
List<Customer> customerList = jdbcTemplate.query(sql, new CustomerRowMapper());
return customerList;
}

@Override
public List<Customer> listNotAssociation() {
String sql = "select * from t_customer where decidedzone_id is null";
List<Customer> customerList = jdbcTemplate.query(sql, new CustomerRowMapper());
return customerList;
}

@Override
public List<Customer> listHasAssociation(String decidedzoneId) {
String sql = "select * from t_customer where decidedzone_id =?";
List<Customer> customerList = jdbcTemplate.query(sql, new CustomerRowMapper(), decidedzoneId);
return customerList;
}

private JdbcTemplate jdbcTemplate;

public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
this.jdbcTemplate = jdbcTemplate;
}

private static class CustomerRowMapper implements RowMapper<Customer>{

@Override
public Customer mapRow(ResultSet rs, int arg1) throws SQLException {
//根据字段名称从结果集中获取对应的值
int id = rs.getInt("id");
String name = rs.getString("name");
String station = rs.getString("station");
String telephone = rs.getString("telephone");
String address = rs.getString("address");
String decidedzoneId = rs.getString("decidedzone_id");
Customer c = new Customer(id, name, station, telephone, address, decidedzoneId);
return c;
}
}
}
```

3. 注意服务端代码更改后，客户端要重新获取新的服务类

## 三、调整定区关联客户的页面以及数据的查询

1. 必须且只选择一个定区时，点击关联客才有效

2. 为DecidedzoneAction注入CustomerService代理对象

```
//注入代理的CustomerService
@Autowired
private CustomerService customerServiceProxy;
```

3. 编写Decidedzone.listNotAssociation和listHasAssociation方法

```
/**
* 调用远程服务crm查询未关联定区的用户
* @return
*/
public String listNotAssociation(){
//调用代理对象执行请求获取客户数据
List<Customer> customerList = customerServiceProxy.listNotAssociation();
list2JsonAndWriteResponse(customerList);
return NONE;
}

/**
* 调用远程服务crm查询已关联定区的用户
* @return
*/
public String listHasAssociation(){
String id = model.getId();
List<Customer> customerList = customerServiceProxy.listHasAssociation(id);
list2JsonAndWriteResponse(customerList);
return NONE;
}
```

4. 注意这个时候我把BaseAction中的list2JsonAndWriteResponse和objec2JsonAndWriteResponse的第二个参数类型改成了可变参数类型，这样更加灵活

5. 在页面响应函数中填充数据，最终关联客户按钮的响应函数实现如下：

```
function doAssociations(){
//获取当前数据表格所有选中的行，返回数组
var rows = $("#grid").datagrid("getSelections");
if(rows.length != 1){
//弹出提示
$.messager.alert("提示信息", "请选择一个定区进行操作", "warning");
}else{
//清理数据
$("#noassociationSelect").empty();
$("#associationSelect").empty();
//选中了一个定区，可以弹出窗口
$('#customerWindow').window('open');
//发送ajax请求请求定区管理的Action，在定区Action中通过crm代理对象完成对于crm服务远程调用
var url_1 = "decidedzoneAction_listNotAssociation.action";
$.ajax({
"url":url_1,
"dataType":"json",
"type":"get",
"success":function(respData, textStatus, xmlHttp){
//遍历json数组
for(var i = 0; i < respData.length; ++i){
var id = respData[i].id;
var name = respData[i].name;
var telephone = respData[i].telephone;
name = name+"("+telephone+")";
$("#noassociationSelect").append("<option value='"+id+"'>"+name+"</option>");
}
},
"error":function(xmlHttp, textStatus, exception){
alert(textStatus);
}
});

var decidedzoneId = rows[0].id;
//发送ajax请求请求定区管理的Action，在定区Action中通过crm代理对象完成对于crm服务远程调用
var url_2 = "decidedzoneAction_listHasAssociation.action";
$.ajax({
"url":url_2,
"data":{"id":decidedzoneId},
"dataType":"json",
"type":"get",
"success":function(respData, textStatus, xmlHttp){
//遍历json数组
for(var i = 0; i < respData.length; ++i){
var id = respData[i].id;
var name = respData[i].name;
var telephone = respData[i].telephone;
name = name+"("+telephone+")";
$("#associationSelect").append("<option value='"+id+"'>"+name+"</option>");
}
},
"error":function(xmlHttp, textStatus, exception){
alert(textStatus);
}
});
}
}
```

6. 为左右移动按钮添加响应函数

```
$(function(){
$("#toRight").click(function(){
$("#associationSelect").append($("#noassociationSelect option:selected"));
});
$("#toLeft").click(function(){
$("#noassociationSelect").append($("#associationSelect option:selected"));
});
});
```

7. 为关联客户的提交按钮绑定事件，提交关联客户请求

```
$(function(){
//为关联客户按钮绑定事件
$("#associationBtn").click(function(){
//为隐藏域（存放定区id）赋值
var rows = $("#grid").datagrid("getSelections");
var id = rows[0].id;
$("input[name=id]").val(id);

//选中右侧的所有表单项
$("#associationSelect option").prop("selected", "selected");
console.log($("#customerForm").serialize());
$("#customerForm").submit();
});
});
```

## 四、定区关联客户的服务端实现

1. 在crm服务端扩展定区关联客户方法

```
/**
* 定区关联客户
* @param decidedzoneId
* @param customerIds
*/
void assigncustomerstodecidedzone(String decidedzoneId, Integer[] customerIds);
```

2. 扩展方法的实现

```
@Override
public void assigncustomerstodecidedzone(String decidedzoneId,
Integer[] customerIds) {
//清空该定区的所有关联
String sql = "update t_customer set decidedzone_id = null where decidedzone_id = ?";
jdbcTemplate.update(sql, decidedzoneId);
//客户重新关联定区

if(customerIds != null && customerIds.length > 0){
StringBuilder sb = new StringBuilder("update t_customer set decidedzone_id = ? where id in(");
for (Integer id : customerIds) {
sb.append(id).append(",");
}
sb.deleteCharAt(sb.length()-1);
sb.append(")");
jdbcTemplate.update(sb.toString(), decidedzoneId);
}
}
```

3. 重新生成客户端调用代码，复制新的类到bos项目

4. 编写DecidedzoneAction.assigncustomerstodecidedzone

```
/**
* 远程调用CRM服务，将客户关联到定区
* @return
*/
public String assigncustomerstodecidedzone(){
customerServiceProxy.assigncustomerstodecidedzone(model.getId(), customerIds);
return NONE;
}
```

# 查看定区中关联的分区数据

## 一、页面修改

1. 为datagrid每一行的双击事件绑定响应函数，在$("#grid").datagrid({})的json参数中执行

```
// 收派标准数据表格
$('#grid').datagrid( {
iconCls : 'icon-forward',
fit : true,
border : true,
rownumbers : true,
striped : true,
pageList: [30,50,100],
pagination : true,
toolbar : toolbar,
url : "decidedzoneAction_pageQuery.action",
idField : 'id',
columns : columns,
onDblClickRow : doDblClickRow
});
```

2. 在双击的响应事件中构造数据表格，其样式已经写好，只需更改其url地址

```
function doDblClickRow(index, data){
//alert("双击表格数据...");
$('#association_subarea').datagrid( {
fit : true,
border : true,
rownumbers : true,
striped : true,
url : "subareaAction_listByDecidedzoneId.action?decidedzoneId="+data.id,
columns : [ [{
field : 'id',
title : '分拣编号',
width : 120,
align : 'center'
},{
field : 'province',
title : '省',
width : 120,
align : 'center',
formatter : function(data,row ,index){
return row.region.province;
}
}, {
field : 'city',
title : '市',
width : 120,
align : 'center',
formatter : function(data,row ,index){
return row.region.city;
}
}, {
field : 'district',
title : '区',
width : 120,
align : 'center',
formatter : function(data,row ,index){
return row.region.district;
}
}, {
field : 'addresskey',
title : '关键字',
width : 120,
align : 'center'
}, {
field : 'startnum',
title : '起始号',
width : 100,
align : 'center'
}, {
field : 'endnum',
title : '终止号',
width : 100,
align : 'center'
} , {
field : 'single',
title : '单双号',
width : 100,
align : 'center'
} , {
field : 'position',
title : '位置',
width : 200,
align : 'center'
} ] ]
});
$('#association_customer').datagrid( {
fit : true,
border : true,
rownumbers : true,
striped : true,
url : "json/association_customer.json",
columns : [[{
field : 'id',
title : '客户编号',
width : 120,
align : 'center'
},{
field : 'name',
title : '客户名称',
width : 120,
align : 'center'
}, {
field : 'station',
title : '所属单位',
width : 120,
align : 'center'
}]]
});
}
```

## 二、服务端实现

1. 编写SubareaAction.listByDecidedzoneId，实现根据定区ID查询关联的分区

```
/**
* 根据定区ID查询相关的分区
* @return
*/
public String listByDecidedzoneId(){
List<Subarea> subareaList = subareaService.listByDecidedzoneId(decidedzoneId);
list2JsonAndWriteResponse(subareaList, "decidedzone", "subareas");
return NONE;
}
```

2. 编写SubareaService.listByDecidedzoneId，利用离线查询对象进行查询

```
@Override
public List<Subarea> listByDecidedzoneId(String decidedzoneId) {
DetachedCriteria dc = DetachedCriteria.forClass(Subarea.class);
//添加过滤条件
dc.add(Restrictions.eq("decidedzone.id", decidedzoneId));
return subareaDao.findByCriteria(dc);
}
```

