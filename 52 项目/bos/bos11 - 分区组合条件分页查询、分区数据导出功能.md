[TOC]

# 分区组合条件分页查询

## 一、没有过滤条件的分区分页查询

1. 先修改分页查询的请求地址url(#grid)

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
url : "subareaAction_pageQuery.action",
idField : 'id',
columns : columns,
onDblClickRow : doDblClickRow
});
```

2. 编写SubareaAction.pageQuery

```
/**
* 分页查询分区
* @return
*/
public String pageQuery(){
subareaService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, new String[]{"currentPage", "detachedCriteria", "pageSize", "decidedzone", "subareas"});
return NONE;
}
```

3. 编写SubareaService.pageQuery

```
@Override
public void pageQuery(PageBean<Subarea> pageBean) {
subareaDao.pageQuery(pageBean);
}
```

4. 在Subarea.hbm.xml中修改Region的延迟加载策略，禁止延迟加载

```
<many-to-one name="region" class="com.hao.bos.entity.Region" fetch="select" lazy="false">
<column name="region_id" length="32" />
</many-to-one>
```

## 二、带有过滤条件的分区分页查询


1. 提供的表单序列化函数，用于将表单中的输入项转化为json对象

```
//表单序列化函数
$(function(){
$.fn.serializeJson = function() {
var serializeObj = {};
var array = this.serializeArray();
$(array).each(function(){
if (serializeObj[this.name]) {
if ($.isArray(serializeObj[this.name])) {
serializeObj[this.name].push(this.value);
} else {
serializeObj[this.name] = [ serializeObj[this.name], this.value ];
}
} else {
serializeObj[this.name] = this.value;
}
});
return serializeObj;
};
});
```

2. 为查询窗口中的查询按钮绑定事件，处理函数内调用datagrid的load方法重新发送ajax请求，并且提交参数，参数为在查询框中输入的过滤条件（表单序列化）

```
$("#btn").click(function(){
//将制定的表单转化为json数据
var p = $("#searchForm").serializeJson();
//调用数据表格的load方法
$("#grid").datagrid("load",p);
//关闭查询窗口
$("searchWindow").window("close");
});
```

3. 修改SubareaAction.pageQuery方法，增加过滤功能

```
/**
* 分页查询分区
* @return
*/
public String pageQuery(){
//获取离线查询对象
DetachedCriteria dc = pageBean.getDetachedCriteria();

//动态添加过滤条件
String addressKey = model.getAddresskey();
if(StringUtils.isNotBlank(addressKey)){
//添加过滤条件，根据地址关键字模糊查询
dc.add(Restrictions.like("addressKey", "%"+addressKey+"%"));
}

Region region = model.getRegion();
if(region != null){
String province = region.getProvince();
String city = region.getCity();
String district = region.getDistrict();

//注意省、市、区不是分区表里的，因此要做关联查询

//类似SQL的连接操作，r为对应关联类的别名,第一个参数要求为分区对象关联的对象的属性名称（Subarea.region）
dc.createAlias("region", "r");

if(StringUtils.isNotBlank(province)){
//添加过滤条件，进行省份模糊查询 --- 涉及多表关联查询
dc.add(Restrictions.like("r.province", "%"+province+"%"));
}

if(StringUtils.isNotBlank(city)){
//添加过滤条件，进行省份模糊查询 --- 涉及多表关联查询
dc.add(Restrictions.like("r.city", "%"+city+"%"));
}

if(StringUtils.isNotBlank(district)){
//添加过滤条件，进行省份模糊查询 --- 涉及多表关联查询
dc.add(Restrictions.like("r.district", "%"+district+"%"));
}
}
subareaService.pageQuery(pageBean);
object2JsonAndWriteToResponse(pageBean, new String[]{"currentPage", "detachedCriteria", "pageSize", "decidedzone", "subareas"});
return NONE;
}
```

3. 修改BaseDaoImpl.pageQuery代码，设置涉及关联查询时，封装数据的方式

```
//指定Hibernate封装对象的方式：涉及多表查询时，以查询的目标实体类型返回
detachedCriteria.setResultTransformer(DetachedCriteria.ROOT_ENTITY);
```

# 分区数据导出功能

## 一、页面调整

1. 为页面的导出按钮绑定事件

```
//页面导出按钮对应的处理函数
function doExport(){
//因为需要弹出保存文件的框，因此要求同步请求
window.location.href = "subareaAction_exportXls.action";
}
```

## 二、服务端实现

1. 实现思路
    - 查询所有分区数据
    - 使用POI将数据写到Excel文件中
    - 使用输出流进行文件下载

2. SubareaAction.exportXls

```
/**
* 分区数据导出功能
* @return
* @throws IOException 
*/
public String exportXls() throws IOException{
//1.查询所有分区数据
List<Subarea> list = subareaService.list();

//2.使用POI将数据写到Excel文件中

//在内存中创建一个Excel文件
HSSFWorkbook workbook = new HSSFWorkbook();
//创建一个标签页
HSSFSheet sheet = workbook.createSheet("分区数据");
//创建标题行
HSSFRow headRow = sheet.createRow(0);
//创建标题行的单元格
headRow.createCell(0).setCellValue("分区编号");
headRow.createCell(1).setCellValue("开始编号");
headRow.createCell(2).setCellValue("结束编号");
headRow.createCell(3).setCellValue("位置信息");
headRow.createCell(4).setCellValue("省市区"); //关联的表

//遍历list集合填充数据
for (Subarea subarea : list) {
//在文件底部创建新行，为新的数据行
HSSFRow dataRow = sheet.createRow(sheet.getLastRowNum()+1);
//填充数据
dataRow.createCell(0).setCellValue(subarea.getId());
dataRow.createCell(1).setCellValue(subarea.getStartnum());
dataRow.createCell(2).setCellValue(subarea.getEndnum());
dataRow.createCell(3).setCellValue(subarea.getPosition());
dataRow.createCell(4).setCellValue(subarea.getRegion().getName()); //关联的表
}

//3.进行文件下载（一个流，两个头）

//根据文件名后缀动态获取ContentType
String fileName = "分区数据.xls";
String contentType = ServletActionContext.getServletContext().getMimeType(fileName);

//获取客户端浏览器类型
String agent = ServletActionContext.getRequest().getHeader("User-Agent");
//封装文件名
fileName = FileUtils.encodeDownloadFilename(fileName, agent);

//获得响应的输出流
ServletOutputStream out = ServletActionContext.getResponse().getOutputStream();
//设置响应的头信息
ServletActionContext.getResponse().setContentType(contentType);
ServletActionContext.getResponse().setHeader("content-disposition", "attachment;filename="+fileName);

//把工作簿数据写到输出流
workbook.write(out);

workbook.close();

return NONE;
}
```

3. FileUtils工具类

```
public class FileUtils {
/**
* 下载文件时，针对不同浏览器，进行附件名的编码
* 
* @param filename
* 下载文件名
* @param agent
* 客户端浏览器
* @return 编码后的下载附件名
* @throws IOException
*/
public static String encodeDownloadFilename(String filename, String agent)
throws IOException {
if (agent.contains("Firefox")) { // 火狐浏览器
filename = "=?UTF-8?B?"
+ new BASE64Encoder().encode(filename.getBytes("utf-8"))
+ "?=";
filename = filename.replaceAll("\r\n", "");
} else { // IE及其他浏览器
filename = URLEncoder.encode(filename, "utf-8");
filename = filename.replace("+"," ");
}
return filename;
}
}
```


