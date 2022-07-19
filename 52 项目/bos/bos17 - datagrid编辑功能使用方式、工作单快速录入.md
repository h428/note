[TOC]

# datagrid编辑功能使用方式

数据表格编辑功能是以列为单位
通过数据表格中的列属性指定具体那一列具有编辑功能：editor

beginEdit：开始编辑一行
endEdit：编辑一行结束
insertRow：插入一行
deleteRow：删除一行
getRowIndex:给定行对象，返回其在数据表格中的索引

数据表格用于监听结束编辑的事件：

onAfterEdit：编辑完后触发

```
onAfterEdit:function(index, data, changes){
alert(data.name);
}	
```

示例代码

```
<table id="mytable"></table>

<script type="text/javascript">
$(function(){

//给定全局变量，值为正在编辑行的索引
var myIndex = -1;

$("#mytable").datagrid({
//定义表头
columns:[[
{"title":"编号","field":"id","checkbox":true},
{"title":"姓名","field":"name",editor:{
type:"validatebox",
options:{}
}},
{"title":"年龄","field":"age",editor:{
type:"numberbox",
options:{}
}}
]],
//制定数据表格发送ajax请求的地址
url:"${pageContext.request.contextPath}/json/datagrid.json",
rownumbers:true,
singleSelect:true,
toolbar:[ //工具栏
{"text":"添加","iconCls":"icon-add","handler":function(){
//插入一行
$("#mytable").datagrid("insertRow", {
"index":0, //插入行号
"row":{}
});
//插入后直接可编辑
$("#mytable").datagrid("beginEdit", 0);
//表示正在编辑第一行
myIndex = 0;

}},
{"text":"删除","iconCls":"icon-remove",handler:function(){
//获取选中的行
var rows = $("#mytable").datagrid("getSelections");
//是否选中单行
if(rows.length == 1){
//获得选中的当行
var row = rows[0];
//获得当行在数据表格中的索引
myIndex = $("#mytable").datagrid("getRowIndex", row);
//删除改行
$("#mytable").datagrid("deleteRow", myIndex);
//发送ajax请求进行更新
}
}},
{"text":"修改","iconCls":"icon-edit",handler:function(){
//获取选中的行
var rows = $("#mytable").datagrid("getSelections");
//是否选中单行
if(rows.length == 1){
//获得选中的当行
var row = rows[0];
//获得当行在数据表格中的索引
myIndex = $("#mytable").datagrid("getRowIndex", row);
//使数据表格的该行可编辑
$("#mytable").datagrid("beginEdit", myIndex);
}
}},
{"text":"保存","iconCls":"icon-save",handler:function(){
//结束当前正在编辑的行-myIndex
$("#mytable").datagrid("endEdit", myIndex);
}},
],
pagination:true, //显示分页条
onAfterEdit:function(index, data, changes){
//发送ajax请求进行更新
}
});
});
</script>
```

# 工作单快速录入

## 一、前台代码理解及修改

1. 新增行也可完成提交原来编辑的行功能（如果有在编辑的行）

```
//全局变量
var editIndex;

function doAdd() {
if (editIndex != undefined) {
//表示有一行正在编辑，先结束编辑的行（会触发onAfterEdit）
$("#grid").datagrid('endEdit', editIndex);
}
//没有行在编辑状态才能进行新增
if (editIndex == undefined) {
//alert("快速添加电子单...");
$("#grid").datagrid('insertRow', {
index : 0,
row : {}
});
$("#grid").datagrid('beginEdit', 0);
editIndex = 0;
}
}
```

2. 数据表格

```
// 收派标准数据表格
$('#grid').datagrid({
iconCls : 'icon-forward',
fit : true,
border : true,
rownumbers : true,
striped : true,
pageList : [ 30, 50, 100 ],
pagination : true,
toolbar : toolbar,
url : "",
idField : 'id',
columns : columns,
onDblClickRow : doDblClickRow,
onAfterEdit : function(rowIndex, rowData, changes) {
console.info(rowData);
//编辑完毕，重置editIndex表示没有行在编辑
editIndex = undefined;
$.post("workordermanagerAction_add.action", rowData, function(data){

});
}
});
```

## 二、服务端实现

1. WorkordermanageAction.add实现

```
public String add() throws IOException{
String f = "1";
try {
workordermanagerService.save(model);
} catch (Exception e) {
f = "0";
}
ServletActionContext.getResponse().setContentType("text/html;charset=utf-8");
ServletActionContext.getResponse().getWriter().write(f);
return NONE;
}
```

2. WorkordermanagerServiceImpl.save实现

```
@Override
public void save(Workordermanager model) {
workordermanagerDao.save(model);
}
```

