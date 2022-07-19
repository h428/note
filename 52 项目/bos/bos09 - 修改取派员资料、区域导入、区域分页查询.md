[TOC]

# 修改取派员资料

## 一、页面调整

1. 仿造新增弹出的div创建一个修改信息的div窗口

```
<div region="center" style="overflow:auto;padding:5px;" border="false">
<form id="editStaffForm" action="staffAction_edit.action" method="post">
<input type="hidden" name="id"/>
<table class="table-edit" width="80%" align="center">
<tr class="title">
<td colspan="2">收派员信息</td>
</tr>
<tr>
<td>姓名</td>
<td><input type="text" name="name" class="easyui-validatebox" required="true"/></td>
</tr>
<tr>
<td>手机</td>
<td><input type="text" data-options="validType:'telephone'" name="telephone" class="easyui-validatebox" required="true"/></td>
</tr>
<tr>
<td>单位</td>
<td><input type="text" name="station" class="easyui-validatebox" required="true"/></td>
</tr>
<tr>
<td colspan="2">
<input type="checkbox" name="haspda" value="1" />
是否有PDA</td>
</tr>
<tr>
<td>取派标准</td>
<td>
<input type="text" name="standard" class="easyui-validatebox" required="true"/> 
</td>
</tr>
</table>
</form>
</div>
</div>
```

2. 完善弹出框的css风格

```
// 修改取派员窗口
$('#editStaffWindow').window({
title: '添加取派员',
width: 400,
modal: true,
shadow: true,
closed: true,
height: 400,
resizable:false
});
```

3. 完善js代码

```
function doDblClickRow(rowIndex, rowData){
//打开修改取派员窗口
$('#editStaffWindow').window("open");
$('#editStaffWindow').form("load", rowData);
}


//为保存按钮添加事件
$("#edit").click(function(){
//表单校验
var validateRes = $("#editStaffForm").form("validate");
if(validateRes){
//通过则提交表单
$("#editStaffForm").submit();
}
});
```


## 二、服务端实现

1. 修改信息的建议作法是先根据ID获取信息，然后设置要修改的属性，然后再执行更新

2. 我思考的做法是：获取和更新可以在一个Service方法中实现，开启动态更新列后，这样可以利用Session的缓存，少更新列，不知是否存在问题

3. 编写StaffAction.edit

```
/**
* 修改取派员信息
* @return
*/
public String edit(){

//根据id查询原始数据
Staff staff = staffService.findById(model.getId());

staff.setName(model.getName());
staff.setTelephone(model.getTelephone());
staff.setHaspda(model.getHaspda());
staff.setStandard(model.getStandard());
staff.setStation(model.getStation());

staffService.update(staff);

return LIST;
}
```

4. 编写StaffService相关

```
@Override
public Staff findById(String id) {
return staffDao.findById(id);
}

@Override
public void update(Staff staff) {
staffDao.update(staff);
}
```

# 区域导入功能

## 一、jQuery的OCUpload

1. OCUpload(One Click Upload)

```
<script src="${pageContext.request.contextPath}/js/jquery.ocupload-1.1.2.js"></script>
```

2. 传统文件上传：

    - 页面要有form表单，action为提交地址，method="post"，注意enctype="multipart/form-data"
    - 表单内要有`<input type="file" name="myfile"/>`这样的输入框
    - 定义`<input type="submit" value="上传"/>`

3. 传统文件上传会刷新页面，使用OCUpload可以避免页面刷新

4. 传统文件上传避免刷新方法：利用iframe，这样刷新的是iframe

```
<iframe style="display: none;" name="fileUploadFrame"></iframe>
<form target="fileUploadFrame" action="xxx" enctype="multipart/form-data" method="post">
<input type="file" name="myFile"/>
<input type="submit" value="上传">
</form>
```
5. OCUpload用法：

```
<input type="button" id="myButton" value="上传"/>
```

```
<script type="text/javascript">
$(function(){
//页面加载完成后，调用插件的upload方法，动态修改了HTML页面元素，改成了和自定义的避免刷新的方法差不多
$("#myButton").upload({
action:"xxx.action",
name:"myFile"
});
});
</script>
```

## 二、apache POI技术（重要）

1. 入门案例

```
@Test
public void test1() throws Exception{

String path = "H:\\900 就业班\\11 项目一：物流BOS系统（58-71天）\\BOS-day05\\BOS-day05\\资料\\分区导入测试数据.xls";

HSSFWorkbook workbook = new HSSFWorkbook(new FileInputStream(new File(path)));

//读取文件中第一个sheet标签页
HSSFSheet hssfSheet = workbook.getSheetAt(0);
//便利标签页中的所有行
for (Row row : hssfSheet) {
//遍历每一行，cell是一个单元格cell
for (Cell cell : row) {
//获取单元格的内容
String value = cell.getStringCellValue();
System.out.print(value+",");
}
System.out.println();
}

workbook.close();

}
```

## 三、pinyin4J工具类：拼音生成工具

1. 入门样例

```
@Test
public void test1(){
//河北省 石家庄市 桥西区
String province = "河北省";
String city = "石家庄市";
String district = "桥西区";

//简码 --->HBSJZQX
province = province.substring(0, province.length()-1);
city = city.substring(0, city.length()-1);
district = district.substring(0, district.length()-1);

String info = province + city+district;
System.out.println(info);
String[] headByString = PinYin4jUtils.getHeadByString(info);

String shortcode = StringUtils.join(headByString);
System.out.println(shortcode);

//城市编码--->shijiazhuang
String cityCode = PinYin4jUtils.hanziToPinyin(city, "");
System.out.println(cityCode);
}
```

## 四、区域导入功能

1. 编写前端js

```
$(function(){
//页面加载完成后调用OCUpload插件，注意要在表格创建之后
$("#button-import").upload({
action:"regionAction_importXls.action",
name:"regionFile"
});
});
```

2. 创建RegionAction.importXls

```java
/**
* 区域导入
* @return
* @throws Exception 
*/
public String importXls() throws Exception{

List<Region> regionList = new ArrayList<Region>();

//使用POI解析Excel文件
HSSFWorkbook workbook = new HSSFWorkbook(new FileInputStream(regionFile));

HSSFSheet sheet = workbook.getSheet("sheet1");
//遍历表
for (Row row : sheet) {
//排除标题行
int rowNum = row.getRowNum();
if(rowNum == 0){
continue;
}
//读取单元格数据
String id = row.getCell(0).getStringCellValue();
String province = row.getCell(1).getStringCellValue();
String city = row.getCell(2).getStringCellValue();
String district = row.getCell(3).getStringCellValue();
String postcode = row.getCell(4).getStringCellValue();
//包装为区域对象
Region region = new Region(id, province, city, district, postcode, null, null, null);

//简码 --->HBSJZQX
province = province.substring(0, province.length()-1);
city = city.substring(0, city.length()-1);
district = district.substring(0, district.length()-1);

String info = province + city+district;
String[] headByString = PinYin4jUtils.getHeadByString(info);

String shortcode = StringUtils.join(headByString);
region.setShortcode(shortcode);

//城市编码--->shijiazhuang
String citycode = PinYin4jUtils.hanziToPinyin(city, "");
region.setCitycode(citycode);

regionList.add(region);
}
//批量保存
regionService.saveBatch(regionList);
workbook.close();
return NONE;
}
```

3. 编写RegionService，注意调用的是saveOrUpdate

```
@Override
public void saveBatch(List<Region> regionList) {
for (Region region : regionList) {
regionDao.saveOrUpdate(region);
}
}
```

4.配置RegionAction

```
<action name="regionAction_*" class="regionAction" method="{1}">
</action>
```

# 区域分页查询

## 一、页面修改

1. 更改获取分页数据的url

```
// 收派标准数据表格
$('#grid').datagrid( {
iconCls : 'icon-forward',
fit : true,
border : false,
rownumbers : true,
striped : true,
pageList: [30,50,100],
pagination : true,
toolbar : toolbar,
url : "regionAction_pageQuery.action",
idField : 'id',
columns : columns,
onDblClickRow : doDblClickRow
});
```

## 二、服务端实现

1. 实现RegionAction.pageQuery

```java
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
ServletActionContext.getResponse().setContentType("text/json;charset=utf-8");
BOSUtils.getWriter().write(json);
return NONE;
}
```

2. 实现RegionService.pageQuery

```
@Override
public void pageQuery(PageBean<Region> pageBean) {
regionDao.pageQuery(pageBean);
}
```

## 三、发现分页查询代码十分相似，可以抽取到BaseAction

1. 将PageBean抽取到父类BaseAction中

```
protected PageBean<T> pageBean = new PageBean<T>();
```

2. 将基于easyui分页的两个属性驱动变量page和rows的set方法抽取到BaseAction中，省略变量声明，并在set方法中直接设置到PageBean中

```
//注入分页相关属性
public void setRows(int rows) {
pageBean.setPageSize(rows);
}

public void setPage(int page) {
pageBean.setCurrentPage(page);
}
```

3. 在构造方法中获取到泛型时构造DetachedCriteria变量，并设置到PageBean中

```
//BaseAction的构造方法中
DetachedCriteria dc = DetachedCriteria.forClass(entityClass);
pageBean.setDetachedCriteria(dc);
```

4. 最后在父类中抽象一个对象转换json的方法，并写到响应中

```
/**
* 将对象转化为json并写到响应
* @param o 对象
* @param exclueds 排除的对象属性
*/
protected void object2JsonAndWriteToResponse(Object o, String[] exclueds){
//将pageBean转为json写到页面中
JsonConfig jsonConfig = new JsonConfig();
//设置排除属性
jsonConfig.setExcludes(exclueds);
String json = JSONObject.fromObject(pageBean, jsonConfig).toString();
ServletActionContext.getResponse().setContentType("text/json;charset=utf-8");
BOSUtils.getWriter().write(json);
}
```

5. 子类要实现分页时，只需直接调用Service的分页方法，然后再调用父类抽取的json转化方法把PageBean传递进去即可

```
/**
* 分页查询
* @return
*/
public String pageQuery(){
regionService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, new String[]{"currentPage", "detachedCriteria", "pageSize"});
return NONE;
}
```