[TOC]

# 取派员分页查询


## 一、页面调整

1. 修改staff.jsp中的表格的获取datagrid数据的url为staffAction_pageQuery.action

## 二、封装PageBean工具类

```
public class PageBean<T> {

private int currentPage;
private int pageSize;
private DetachedCriteria detachedCriteria;
private int total;
private List<T> rows;

public int getCurrentPage() {
return currentPage;
}
public void setCurrentPage(int currentPage) {
this.currentPage = currentPage;
}
public int getPageSize() {
return pageSize;
}
public void setPageSize(int pageSize) {
this.pageSize = pageSize;
}
public DetachedCriteria getDetachedCriteria() {
return detachedCriteria;
}
public void setDetachedCriteria(DetachedCriteria detachedCriteria) {
this.detachedCriteria = detachedCriteria;
}
public int getTotal() {
return total;
}
public void setTotal(int total) {
this.total = total;
}
public List<T> getRows() {
return rows;
}
public void setRows(List<T> rows) {
this.rows = rows;
}
}
```

## 三、服务端实现

1. 编写StaffAction.pageQuery

```
/**
* 分页查询取派员
* @return
*/
public String pageQuery(){

PageBean<Staff> pageBean = new PageBean<Staff>();
pageBean.setCurrentPage(page);
pageBean.setPageSize(rows);
DetachedCriteria dc = DetachedCriteria.forClass(Staff.class);
pageBean.setDetachedCriteria(dc);

staffService.pageQuery(pageBean);

//将pageBean转为json写到页面中
JsonConfig jsonConfig = new JsonConfig();
//设置排除属性
jsonConfig.setExcludes(new String[]{"currentPage", "detachedCriteria", "pageSize"});
String json = JSONObject.fromObject(pageBean, jsonConfig).toString();
System.out.println(json);
ServletActionContext.getResponse().setContentType("text/json;charset=utf-8");
BOSUtils.getWriter().write(json);
return NONE;
}
```

2. 编写StaffService.pageQuery

```
@Override
public void pageQuery(PageBean<Staff> pageBean) {
staffDao.pageQuery(pageBean);
}

3.在BaseDao抽取通用的分页查询方法，并在BaseDaoImpl中实现

@Override
@SuppressWarnings("unchecked")
public void pageQuery(PageBean<T> pageBean) {

int currentPage = pageBean.getCurrentPage();
int pageSize = pageBean.getPageSize();
DetachedCriteria detachedCriteria = pageBean.getDetachedCriteria();

//指定Hibernate框架发出sql的形式 - 查询记录总数
detachedCriteria.setProjection(Projections.rowCount());
List<Long> countList = (List<Long>) getHibernateTemplate().findByCriteria(detachedCriteria);
Long count = countList.get(0);
pageBean.setTotal(count.intValue());

//清空指定的查询记录数，以进行分页查询
detachedCriteria.setProjection(null);
int firstResult = (currentPage-1)*pageSize;
int maxResults = pageSize;
List<T> rows = (List<T>) getHibernateTemplate().findByCriteria(detachedCriteria,firstResult,maxResults);
pageBean.setRows(rows);
}
```


# 取派员批量逻辑删除

## 一、涉及的页面显示

1. 作废情况显示相关代码

```
{
field : 'deltag',
title : '是否作废',
width : 120,
align : 'center',
formatter : function(data,row, index){
if(data=="0"){
return "正常使用"
}else{
return "已作废";
}
}
}
```

## 二、页面调整

1. 删除按钮的处理函数

```
function doDelete(){
//使用数据表格获取选中的行
var rows = $("#grid").datagrid("getSelections");
if(rows.length == 0){
$.messager.alert("提示信息", "请选择需要删除的取派员", "warning");
}else{
//选中了取派员，弹出确认框
$.messager.confirm("删除确认", "确定删除选择的取派员吗？", function(flag){
if(flag){
//确定删除
var array = new Array();
//获取左右选中的取派员的id
for(var i = 0; i < rows.length; ++i){
var staff = rows[i];
var id = staff.id;
array.push(id);
}
var ids = array.join(","); //1,2,3,4

//发送一个请求
window.location.href = "staffAction_deleteBatch.action?ids="+ids;
}
});
}
}
```

## 三、服务端实现

1. 实现StaffAction.deleteBatch

```
/**
* 批量删除
* @return
*/
public String deleteBatch(){
staffService.deleteBatch(ids);
return LIST;
}
```

2. 实现StaffService.deleteBatch

```
@Override
public void deleteBatch(String ids) {
if(StringUtils.isNoneBlank(ids)){
String[] staffIds = ids.split(",");
for(String id : staffIds){
staffDao.executeUpdate("staff.delete", id);
}
}
}
```

3. 在Staff.hbm.xml中编写更新HQL

```
<query name="staff.delete">
UPDATE Staff SET deltag = '1' where id = ?
</query>
```

