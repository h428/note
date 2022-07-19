[TOC]

# 添加分区

## 一、基础调整

1. 删除subarea.jsp中新增窗口的分区编码一行

2. 修改Subarea.hbm.xml，主键生成策略为uuid

## 二、easyUI - combobox下拉框的使用

1. 静态页面编写（并不实用）

```
<select class="easyui-combobox">
<option>小黑</option>
<option>小白</option>
<option>小红</option>
</select>
```

2. 动态构造下拉列表

    - 在页面编写`<input>`标签，添加class为easyui-combobox，然后定义url,valueField和textField

```
<input data-options=" url:'json/combobox.json',valueField:'id', textField:'name' " class="easyui-combobox"/>
```
    - 提供和定义对应的json，用于初始化下拉列表

```
[
{"id":"100","name":"小明"},
{"id":"200","name":"小红"},
{"id":"300","name":"小白"},
{"id":"400","name":"小黑"}
]
```

## 三、添加分区-获取所有区域页面修改

1. 修改选择区域的url，动态获取区域构造区域下拉列表

```
<input class="easyui-combobox" name="region.id" 
data-options="valueField:'id',textField:'name',url:'regionAction_listajax.action'" /> 
```

## 四、添加分区-获取所有区域的服务端实现

1. 修改Region实体类，添加getName方法，用于页面展示数据

```
public String getName(){
return province+city+district;
}
```

2. 编写RegionAction.listajax返回区域数据

```
/**
* 查询所有区域
* @return
*/
public String listajax(){
List<Region> regionList = regionService.list();
list2JsonAndWriteResponse(regionList, new String[]{"subareas"});
return NONE;
}
```

3. 编写RegionService.list方法获取所有区域数据

```
@Override
public List<Region> list() {
return regionDao.list();
}
```

4. 编写抽取的BaseAction.list2JsonAndWriteResponse方法

```
protected void list2JsonAndWriteResponse(List<T> list, String[] exclueds) {
// 将pageBean转为json写到页面中
JsonConfig jsonConfig = new JsonConfig();
// 设置排除属性
jsonConfig.setExcludes(exclueds);
String json = JSONArray.fromObject(list, jsonConfig).toString();
ServletActionContext.getResponse().setContentType("text/json;charset=utf-8");
BOSUtils.getWriter().write(json);
}
```

## 五、完善添加分区-获取所有区域功能，开启输入参数的过滤

1. 发送的参数名称为q

2. 在RegionAction中添加属性驱动 q，用于接收查询条件的参数

3. 更改RegionAction.listajax

```
/**
* 根据页面输入进行模糊查询
* @return
*/
public String listajax(){
List<Region> regionList = null;

if(StringUtils.isNotBlank(q)){
regionList = regionService.listByQ(q);
}else{
regionList = regionService.list();
}

list2JsonAndWriteResponse(regionList, new String[]{"subareas"});
return NONE;
}
```

4. 编写RegionService.listByQ

```
@Override
public List<Region> listByQ(String q) {
return regionDao.listByQ(q);
}
```

5. 编写RegionDao.listByQ

```
@Override
public List<Region> listByQ(String q) {
String hql = "FROM Region r WHERE r.shortcode LIKE ? OR r.citycode LIKE ? "
+ " OR r.province LIKE ? OR r.city LIKE ? OR r.district LIKE ?";
String pattern = "%"+q+"%";

@SuppressWarnings("unchecked")
List<Region> find = (List<Region>) this.getHibernateTemplate().find(hql, 
pattern, pattern, pattern, pattern, pattern);
return find;
}
```

## 六、添加分区前端实现

1. 为保存按钮添加单击事件，进行表单提交

```
<script type="text/javascript">
$(function(){
$("#save").click(function(){
var f = $("#addSubareaForm").form("validate");
if(f){
$("#addSubareaForm").submit();
}
});
});
</script>
```

## 七、添加分区服务端实现

1. 编写SubareaAction.add方法

```
/**
* 添加分区
* @return
*/
public String add(){
subareaService.save(model);
return LIST;
}
```

2. 编写SubareaService.save方法

```
@Override
public void save(Subarea model) {
subareaDao.save(model);
}
```

# 解决区域分页查询死循环问题

类似toString的问题

将Region转换成json时，由于json中有Subarea且有数据，因此会把Subarea转化为json
而Subarea中又含有Region，转化时又会把Region转化为json，如此造成了无限的互相调用

解决办法一：

解决办法很简单，将Region中的subareas属性添加到排除域，不转化这一属性即可

解决办法二：

但是如果要使用分区信息，变不能排除subareas的转化，此时就需要关闭Hibernate的延迟加载，要立即加载分区信息