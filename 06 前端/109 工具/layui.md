
> 本笔记参考 layui 的[官方文档](https://www.layui.com/doc/)

# 1. 基础说明

## 1.1 开始使用

- 首先下载 layui，解压并复制到项目中
- 然后引入下列两个文件即可
```js
./layui/css/layui.css
./layui/layui.js //提示：如果是采用非模块化方式（最下面有讲解），此处可换成：./layui/layui.all.js
```
- 下面是基于 layui 的 Hello World
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>开始使用layui</title>
    <link rel="stylesheet" href="../layui/css/layui.css">
</head>
<body>

<!-- 你的HTML代码 -->

<script src="../layui/layui.js"></script>
<script>
    //一般直接写在一个js文件中
    // 引入 layer, form 两个模块，然后回调指定方法
    layui.use(['layer', 'form'], function(){
        var layer = layui.layer
            ,form = layui.form;
        layer.msg('Hello World');
    });
</script>
</body>
</html>
```
- 若是一次性加载所有模块，则引入的是 ../layui/layui.all.js 文件，然后不再需要使用 layui.use() 引入指定模块，而是可以直接在全局函数中调用需要的方法
```html
<script src="../layui/layui.all.js"></script>
<script>
//由于模块都一次性加载，因此不用执行 layui.use() 来加载对应模块，直接使用即可：
;!function(){
  var layer = layui.layer
  ,form = layui.form;
  
  layer.msg('Hello World');
}();
</script> 
```

**引入自定义模块**

- 单独创建一个目录，存放自定义的 layui 模块，例如此处的 `/res/js/modules/` 目录，我们在该目录下创建 index.js，并定义下述模块
```js
/**
 依赖 layer, form 模块自定义模块
 **/
layui.define(['layer', 'form'], function(exports){
    // 模块定义
    var layer = layui.layer
        ,form = layui.form;

    layer.msg('Hello World');

    // 导出模块，引入时要使用下面的 index 名称
    exports('index', {}); //注意，这里是模块输出的核心，模块名必须和use时的模块名一致
});
```
- 然后，在需要的页面引入自定义模块即可
```html
<script>
    layui.config({
        base: '../res/js/modules/' //你存放新模块的目录，注意，不是layui的模块目录
    }).use('index'); //加载自定义的 index 模块
</script>
```

## 1.2 底层方法

- 全局配置 `layui.config(options)`
- 定义模块 `layui.define([mods], callback)`
- 加载所需模块 `layui.use([mods], callback)`
- 动态加载 CSS `layui.link(href)`
- 获取设备信息 `layui.device(key)`，参数key是可选的
- 还有很多方法没有介绍

**本地存储**

- 本地存储是对 localStorage 和 sessionStorage 的友好封装，可更方便地管理本地数据
- localStorage 持久化存储：`layui.data(table, settings)`，数据会永久存在，除非物理删除
- sessionStorage 会话性存储：`layui.sessionData(table, settings)`，页面关闭后即失效
- 上述两个对象用法完全一致，下面是使用例子：
```js
//【增】：向test表插入一个nickname字段，如果该表不存在，则自动建立。
layui.data('test', {
  key: 'nickname'
  ,value: '贤心'
});
 
//【删】：删除test表的nickname字段
layui.data('test', {
  key: 'nickname'
  ,remove: true
});
layui.data('test', null); //删除test表
  
//【改】：同【增】，会覆盖已经存储的数据
  
//【查】：向test表读取全部的数据
var localTest = layui.data('test');
console.log(localTest.nickname); //获得“贤心”
```

## 1.3 页面元素

### 1.3.1 内置公共基础类

- 用于布局的 layui-main 等
- 用于辅助的 layui-icon 等
- 用于文本的 layui-text 等
- 用于背景色的 layui-bg-red 等

### 1.3.2 CSS 命名规范

- 使用 layui 作为前缀，使用 - 作为连接符，例如 layui-form
- layui-模块名-状态或类型 或 layui-状态或类型
- 因为有些类并非是某个模块所特有，他们通常会是一些公共类

### 1.3.3 HTML 结构

- 必须充分确保其结构是被支持的，即要保证一定的结构，有的样式才能生效（这很好理解，是由于选择器的原因）
- 你如果改变了结构，极有可能会导致功能或样式失效。所以在嵌套 HTML 的时候，你应该细读各个元素模块的相关文档
- 元素的基本交互行为，都是由模块自动开启，但有时可能需要触发不同的动作，此时需要 layui 自定义属性来作为区分，例如 lay-submit, lay-filter 即为公共属性
- lay-skin=" " : 定义相同元素的不同风格，如checkbox的开关风格
- lay-filter=" " : 事件过滤器。你可能会在很多地方看到他，他一般是用于监听特定的自定义事件。你可以把它看作是一个ID选择器
- lay-submit : 定义一个触发表单提交的 button，不用填写值

## 1.4 模块规范

**预先加载**

- Layui 的模块加载采用核心的 `layui.use(mods, callback)` 方法，当你的 JS 需要用到 Layui 模块的时候，最好采用预先加载，以避免到处写layui.use 的麻烦
```js
layui.use(['form', 'upload'], function(){  //如果只加载一个模块，可以不填数组。如：layui.use('form')
  ...
});
```

**模块命名空间**

- layui 的模块接口会绑定在 layui 对象下，每一个模块都会一个特有的名字，并且无法被占用，且各个模块互相独立，不会互相影响和覆盖
- 我们可以使用 layui 对象取出各个模块，如下述代码
```js
layui.use(['layer', 'laypage', 'laydate'], function(){
  var layer = layui.layer //获得layer模块
  ,laypage = layui.laypage //获得laypage模块
  ,laydate = layui.laydate; //获得laydate模块
  
  //使用模块
}); 
```
- 建议将所有的业务代码都写在一个大的 use 回调中，而不是将模块接口暴露给全局

**扩展一个 layui 模块**

- 在 res/js/test.js 中编写 mymod 模块，在 res/js/admin/mod1.js 中编写 mod1 模块，在 res/js/admin/mod2.js 中编写 mod2 模块，内容除了导出名称外都保持一致：
```js
/**
 扩展一个模块
 **/

layui.define(function(exports){ //提示：模块也可以依赖其它模块，如：layui.define('layer', callback);
    var obj = {
        hello: function(str){
            alert('in my mod : Hello '+ (str||'mymod'));
        }
    };

    //导出 mymod 模块
    exports('mymod', obj);
}); 
```
- 然后首先，配置一个基本的模块目录，然后再基于此导入各模块，注意由于配置了 base，则
```js
//config的设置是全局的
layui.config({
    base: '../res/js/' //假设这是你存放拓展模块的根目录
}).extend({ //设定模块别名（）
    mymod: 'test' //如果名称就是 mymod.js 且是在根目录，也可以不用设定别名
    ,mod1: 'admin/mod1' //相对于上述 base 目录的子目录
    ,mod2: 'admin/mod2'
});

//你也可以忽略 base 设定的根目录，直接在 extend 指定路径（主要：该功能为 layui 2.2.0 新增）
// layui.extend({
//     mod2: '{/}http://cdn.xxx.com/lib/mod2' // {/}的意思即代表采用自有路径，即不跟随 base 路径
// })
```
- 最后使用自己扩展的模块即可
```js
//使用拓展模块
layui.use(['mymod', 'mod1', 'mod2'], function(){
    var mymod = layui.mymod
        ,mod1 = layui.mod1
        ,mod2 = layui.mod2;

    mymod.hello('World!'); //弹出 Hello World!
    mod1.hello('World!'); //弹出 Hello World!
    mod2.hello('World!'); //弹出 Hello World!
});
```

## 1.5 常见问题

**应该如何加载模块最科学**

- js文件的代码最外层，就把需要用到的模块使用 layui.use 进行预加载，然后在内部编写回调函数和各个逻辑 

**如何使用内部jQuery**

- 内置的jquery模块去除了全局的`$`和 `jQuery`，是一个符合 layui 规范的标准模块，因此我们需要以引入模块的方式引入内置的 jQuery
```js
//主动加载jquery模块
layui.use(['jquery', 'layer'], function(){
    var $ = layui.$ //重点处
        ,layer = layui.layer;

    //后面就跟你平时使用jQuery一样
    $('body').append('hello jquery');
});

//如果内置的模块本身是依赖jquery，你无需去use jquery，所以上面的写法其实可以是：
layui.use('layer', function(){
    var $ = layui.$ //由于layer弹层依赖jQuery，所以可以直接得到
        ,layer = layui.layer;

    //……
});
```

**为什么表单不显示**

- 当你使用表单时，Layui会对select、checkbox、radio等原始元素隐藏，从而进行美化修饰处理
- 但这需要依赖于form组件，所以你必须加载 form，并且执行一个实例
- 值得注意的是：导航的Hover效果、Tab选项卡等同理（它们需依赖 element 模块）
```js
layui.use('form', function(){
    var form = layui.form; //只有执行了这一步，部分表单元素才会自动修饰成功

    //……

    //但是，如果你的HTML是动态生成的，自动渲染就会失效
    //因此你需要在相应的地方，执行下述方法来手动渲染，跟这类似的还有 element.init();
    form.render();
});
```

# 2. 页面元素

# 3. 内置模块

