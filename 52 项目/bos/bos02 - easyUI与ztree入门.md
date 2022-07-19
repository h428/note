[toc]

# easyUI入门

## 引入相关文件

> 至少引入以下4个文件

    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath }/js/easyui/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath }/js/easyui/themes/icon.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.8.3.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/easyui/jquery.easyui.min.js"></script>


## 布局

1. 为body添加class="easyui-laout"，这是使用easyui进行布局的基础
2. 每一个区域使用一个div进行描述，总共包括东西南北中五个区域
3. 使用data-options的region属性进行区域描述，详细参考代码

```
<body class="easyui-layout">
<!-- 使用div元素描述每个区域 -->
<div style="height: 100px" data-options="region:'north'">北部区域</div>
<div style="width: 200px" data-options="region:'west'">西部区域</div>
<div data-options="region:'center'">中心区域</div>
<div style="width: 100px" data-options="region:'east'">东部区域</div>
<div style="height: 50px" data-options="region:'south'">南部区域</div>
</body>
```

## accordion折叠面板

1. 定义div，设置class="easyui-accordion"，即成为一个面板，若需要自适应则可以设置data-options="fit:true"	
2. 每个面板条目也是一个div，可以使用title属性描述标题，其他额外描述信息可以使用data-options进行描述
3. 例如，data-options="iconCls:'icon-cut'"可以设置图标

```
<!--制作accordion折叠面板 
fit:true----自适应(填充父容器)
-->
<div class="easyui-accordion" data-options="fit:true">
<!-- 使用子div表示每个面板 -->
<div data-options="iconCls:'icon-cut'" title="面板一">1111</div>
<div title="面板二">2222</div>
<div title="面板三">3333</div>
</div>
```
## tabs选项卡面板

1. 和折叠面板类似，定义div，设置class为easyui-tabs，data-options="fit:true"
2. 在其内部定义div，设置tital属性和data-options即可

```
<!-- 制作一个tabs选项卡面板 -->
<div class="easyui-tabs" data-options="fit:true">
<!-- 使用子div表示每个面板 -->
<div data-options="iconCls:'icon-cut'" title="面板一">1111</div>
<div data-options="closable:true" title="面板二">2222</div>
<div title="面板三">3333</div>
</div>
```

## 动态添加选项卡

1. 首先向编写静态选项卡一样，定义一个装载选项卡的div，注意要提供一个ID，一遍选择器方便拿到该对象

```
<div class="easyui-tabs" data-options="fit:true"></div>
```

2. 为需要动态添加选项卡的链接或按钮等添加单击事件，在响应函数内部完成选项卡的动态添加

3. 动态添加选项卡使用： $("选择器").tabs("add","选项卡名称");

4. 如果选项卡已经创建且没有关闭，可以只是选中而不创建： $("选择器").tabs("select","选项卡名称");

5. 判断选项卡是否存在，使用： $("选择器").tabs("exists","选项卡名称");，注意easyui根据选项卡名称判断选项卡是否存在

6. 新增的选项卡可以使用json数据描述，详细可参考样例

```
<a class="easyui-linkbutton" id="btn">系统管理</a>

<div data-options="region:'center'">
<!-- 制作一个tabs选项卡面板 -->
<div id="mytabs" class="easyui-tabs" data-options="fit:true"></div>
</div>

//单击id为btn的对象的响应函数
$("#btn").click(function(){

    //判断是否已经存在标题为系统管理的控制面板
    if($("#mytabs").tabs("exists", "系统管理")){
        //若已经存在，直接选中即可
        $("#mytabs").tabs("select", "系统管理");
    }else{
        //创建系统管理面板,面板数据使用json对象描述
        $("#mytabs").tabs("add",{
            title:"系统管理",
            iconCls:"icon-blank",
            closable:"true",
            content:"<iframe frameborder='0' height='100%' width='100%' src='https://www.baidu.com'>"
        });
    }
});
```
## messager用法

1. alert - 提示框

    - $.messager.alert("标题", "内容", "info"); 
    - info为图标，其他图标还有error,waring,question，也可以不显示图标
    - 弹出框的按钮默认为英文，若想显示中文，需要引入对应的js文件
```
<script src="${pageContext.request.contextPath}/js/easyui/locale/easyui-lang-zh_CN.js"></script>
```

2. confirm - 确认框

    - 样例：
```
$.messager.confirm("提示信息", "你确定要删除当前记录吗？", function(flag){
    //flag为true或false
    alert(flag);
});
```
    - function为回调函数，flag用于标记用户单击确定还是取消按钮，若单击确定则为true

3. show - 欢迎框

    - 样例：
```
$.messager.show({
title:"信息标题",
msg:"信息内容",
timeout:3000,
showType:"slide"
});
```
    - 信息弹出框，一般用于在右下角弹出系统通知，一定时间后消失

## menubutton用法

1. menubutton展示位一个下拉菜单
2. 可以使用a标签描述菜单头，而用一个div描述下拉菜单，使用id将两者关联起来
3. a标签添加class='easyui-menubutton'作为下拉菜单头部，其他描述信息使用data-options描述，其中menu用于关联下拉菜单
4. 定义div，并添加id，注意id要和菜单头部的data-options中menu属性描述的一致
5. 每一个列表项也是一个div，嵌套在下拉列表中，可使用data-options描述信息

```
<!-- 菜单头部 -->
<a class='easyui-menubutton' data-options=' iconCls:"icon-help", menu:"#mm" '>控制面板</a>
<!-- 使用div制作下拉菜单 -->
<div id='mm'>
<div data-options=' iconCls:"icon-edit" '>修改密码</div>
<div>联系管理员</div>
<div class='menu-sep'></div>
<div>退出系统</div>
</div>
```