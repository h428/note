
[TOC]

# 添加取派员

## 一、基础准备

1. 更改staff.jsp页面，删除编号的`<input>`标签
2. 更改staff.hbm.xml配置文件，生成策略为uuid(Hibernate自动生成的长度为32为，没有横线)

## 二、添加基于easyui的自定义校验规则 - 扩展手机号校验规则

1. 自定义扩展规则

```
$(function(){
//扩展手机号校验规则
$.extend($.fn.validatebox.defaults.rules, {
telephone:{
validator:function(value, param){
var reg = /^1[3|4|5|7|8][0-9]{9}$/;
return reg.test(value);
},
message:"手机号输入有误"
}
});
});
```

2. 手机号的`<input>`应用自定义规则

```
<input type="text" data-options="validType:'telephone'" name="telephone" class="easyui-validatebox" required="true"/>
```

## 三、为保存按钮添加事件

```
//为保存按钮添加事件
$("#save").click(function(){
//表单校验
var validateRes = $("#addStaffForm").form("validate");
if(validateRes){
//通过则提交表单
$("#addStaffForm").submit();
}
});
```

## 四、服务端实现

1. 创建StaffAction.add方法

```
@Controller("staffAction")
@Scope("prototype")
public class StaffAction extends BaseAction<Staff>{

private static final long serialVersionUID = 1L;

/**
* 添加取派员
* @return
*/
public String add(){
staffService.save(model);
return LIST;
}

@Autowired
private StaffService staffService;

public StaffService getStaffService() {
return staffService;
}

public void setStaffService(StaffService staffService) {
this.staffService = staffService;
}
}
```

2. 创建StaffService相关

```
public interface StaffService {

void save(Staff model);

}

@Service
@Transactional(isolation=Isolation.REPEATABLE_READ, propagation=Propagation.REQUIRED, readOnly=true)
public class StaffServiceImpl implements StaffService{

@Override
@Transactional(isolation=Isolation.REPEATABLE_READ, propagation=Propagation.REQUIRED, readOnly=false)
public void save(Staff model) {
staffDao.save(model);
}
private StaffDao staffDao;

public StaffDao getStaffDao() {
return staffDao;
}

public void setStaffDao(StaffDao staffDao) {
this.staffDao = staffDao;
}

}
```

3. 创建StaffDao相关

```
public interface StaffDao extends BaseDao<Staff>{

}

public class StaffDaoImpl extends BaseDaoImpl<Staff> implements StaffDao{

}
```

4. 配置StaffAction

```
<action name="staffAction_*" class="staffAction" method="{1}">
<result name="list">/WEB-INF/pages/base/staff.jsp</result>
</action>
```

# datagrid用法

## 一、将静态HTML渲染为datagrid样式

```
<table class="easyui-datagrid">
<thead>
<tr>
<th data-options="field:'id'">编号</th>
<th data-options="field:'name'">姓名</th>
<th data-options="field:'age'">年龄</th>
</tr>
</thead>
<tbody>
<tr>
<td>001</td>
<td>小明</td>
<td>30</td>
</tr>
<tr>
<td>002</td>
<td>老王</td>
<td>30</td>
</tr>
</tbody>
</table>
```

## 二、发送ajax请求获取json数据创建datagrid(页面刷新完自动发送请求)

```
<table class="easyui-datagrid" data-options="url:'${pageContext.request.contextPath}/json/datagrid.json'">
<thead>
<tr>
<th data-options="field:'id'">编号</th>
<th data-options="field:'name'">姓名</th>
<th data-options="field:'age'">年龄</th>
</tr>
</thead>
<tbody>
</tbody>
</table>
```

- 请求的datagrid.json：

```
[
{"id":"001","name":"小明","age":"11"},
{"id":"002","name":"小智","age":"12"},
{"id":"003","name":"小刚","age":"13"}
]
```

## 三、使用easyui提供的API创建datagrid(重点)

1. 创建一个表格，提供id

```
<table id="mytable"></table>
```

2. 调用API填充数据

```
<script type="text/javascript">
$(function(){
$("#mytable").datagrid({
//定义表头，是一个二维数组
columns:[[
{"title":"编号","field":"id"},
{"title":"姓名","field":"name"},
{"title":"年龄","field":"age"}
]],
//制定数据表格发送ajax请求的地址
url:"${pageContext.request.contextPath}/json/datagrid.json"
});
});
</script>
```

## 三、额外功能：工具栏分页等

1. 代码

```
<script type="text/javascript">
$(function(){
$("#mytable").datagrid({
//定义表头
columns:[[
{"title":"编号","field":"id","checkbox":true},
{"title":"姓名","field":"name"},
{"title":"年龄","field":"age"}
]],
//制定数据表格发送ajax请求的地址
url:"${pageContext.request.contextPath}/json/datagrid.json",
rownumbers:true,
toolbar:[ //工具栏
{"text":"添加","iconCls":"icon-add","handler":function(){
//为按钮绑定单击事件
}},
{"text":"删除","iconCls":"icon-remove"},
{"text":"修改","iconCls":"icon-edit"},
{"text":"查询","iconCls":"icon-search"},
],
pagination:true //显示分页条
});
});
</script>
```

2. 开启分页条后，会额外发送page和rows两个参数，分别表示请求的页面和每页的记录数

3. 开启分页后，服务端返回的json数据格式也要进行相应更改，要总记录数的当前请求页的数据

```
{
"total":123,
"rows":[
{"id":"001","name":"小明","age":"11"},
{"id":"002","name":"小智","age":"12"},
{"id":"003","name":"小刚","age":"13"}
]
}
```

4. 请求发送的rows表示每页的记录数(pageSize)，服务器返回的rows表示数据内容(data)，注意名字虽然相同但是含义不一样


