[TOC]

# 添加定区功能

## 一、使用combobox展示取派员数据

1. 修改定区页面中combobox下拉框的url地址

```
<input class="easyui-combobox" name="staff.id" 
data-options="valueField:'id',textField:'name',url:'staffAction_listajax.action'" /> 
```

2. 在staffAction中提供listajax.方法，查询所有未删除的取派员，返回json数据

```
/**
* 查询所有未删除的取派员，返回json
* @return
*/
public String listajax(){
List<Staff> staffList = staffService.listNotDelete();
list2JsonAndWriteResponse(staffList, new String[]{"decidedzones"});
return NONE;
}
```


3. StaffService.listNotDelete方法

```
@Override
public List<Staff> listNotDelete() {
DetachedCriteria dc = DetachedCriteria.forClass(Staff.class);
//添加未删除的条件
dc.add(Restrictions.eq("deltag", '0'));
return staffDao.findByCriteria(dc);
}
```

4. BaseDaoImpl扩展通用的根据离线对象查询数据的方法

```
@Override
public List<T> findByCriteria(DetachedCriteria detachedCriteria) {
@SuppressWarnings("unchecked")
List<T> res = (List<T>) getHibernateTemplate().findByCriteria(detachedCriteria);
return res;
}
```


## 二、使用datagrid展示分区数据

1. 修改页面中datagrid的url地址

```
<table id="subareaGrid" class="easyui-datagrid" border="false" style="width:300px;height:300px" 
data-options="url:'subareaAction_listajax.action',fitColumns:true,singleSelect:false">
```

2. 编写SubareaAction.listajax返回所有未关联定区的分区数据，返回json数据
3. 
```
/**
* 查询所有未关联定区的分区，并返回json
* @return
*/
public String listajax(){
List<Subarea> list = subareaService.listNotAssociation();
list2JsonAndWriteResponse(list, new String[]{"region"});
return NONE;
}
```

3. 编写SubareaService.listNotAssociation方法，查询未关联定区的分区，注意过滤条件的封装

```
@Override
public List<Subarea> listNotAssociation() {
DetachedCriteria dc = DetachedCriteria.forClass(Subarea.class);
//SQL：查询定区id为null的的分区
//Hibernate：分区中decidedzone属性为空
dc.add(Restrictions.isNull("decidedzone"));
return subareaDao.findByCriteria(dc);
}
```


## 三、实现增加定区功能

1. 为保存按钮绑定事件，提交表单

2. 提交的表单中存在多个名为id的参数解决

对datagrid中的field进行修改，更改参数名称，如subareaid，但又会导致其value丢失，因为服务器返回的json不存在subareaid的键而只有id
解决：在Subarea类中提供一个get方法，名为getSubareaid()，这样返回的json就会有subareaid了

3. 编写DecidedzoneAction.add

```
/**
* 添加定区
* @return
*/
public String add(){
decidedzoneService.save(model, subareaid);
return LIST;
}
```

4. 编写DecidedzoneService.save

```
/**
* 添加定区，同时关联分区
*/
@Override
public void save(Decidedzone model, String[] subareaid) {
decidedzoneDao.save(model);
for (String id : subareaid) {
Subarea subarea = subareaDao.findById(id);
//由多的一方负责维护外键
subarea.setDecidedzone(model);
//由于Hibernate Session，此时subarea处于持久态，会自动发送更新语句
}
}
```

# 定区分页查询

1. 修改请求定区数据的URL

url : "decidedzoneAction_pageQuery.action",

2. 修改Decidedzone.hbm.xml，立即加载关联的Staff

```
<many-to-one name="staff" class="com.hao.bos.entity.Staff" fetch="select" lazy="false">
<column name="staff_id" length="32" />
</many-to-one>
```

3. 编写DecidedzoneAction.pageQuery

```
/**
* 定区分页查询
*/
public String pageQuery(){
decidedzoneService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, new String[]{"currentPage", "detachedCriteria", "pageSize", "subareas", "decidedzones"});
return NONE;
}
```

4. 编写DecidedzoneService.pageQuery

```
@Override
public void pageQuery(PageBean<Decidedzone> pageBean) {
decidedzoneDao.pageQuery(pageBean);
}
```

# json转化死循环问题总结

大致分为以下两种情况

1.页面不需要展示关联数据时

解决：将关联对象的属性直接排除，这样转化为json时就不会执行SQL

2.页面需要展示关联数据时

解决：将关联对象改为立即加载(lazy="false")，并且将关联对象中的属性排除



