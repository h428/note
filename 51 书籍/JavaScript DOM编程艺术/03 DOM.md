[TOC]

# 3.1 文档：DOM中的“D”

1. DOM是 Document Object Model（文档对象模型）的缩写
2. 当创建了一个网页并加载到Web浏览器中事，DOM就在幕后悄然生成，他将根据你编写的网页文档创建一个文档对象

# 3.2 对象：DOM中的“O”

1. JavaScript中有3种对象
    -   用户自定义对象：由程序员创建的对象，本书不讨论
    - 内建对象：內建在JavaScript语言里的对象，如Array、Math和Date等
    - 宿主对象：由浏览器提供的对象
2. JavaScript发展初期，编写JavaScript脚本时经常要使用一些非常重要的宿主对象，宿主对象中最基础的是window对象
3. window对象对应着浏览器窗口的本身，这个对象的属性和方法通常被统称为BOM（浏览器对象模型，作者认为称之为窗口对象模型更贴切）
4. BOM向程序员提供了window.open和window.blur等方法
5. 本书不讨论太多的BOM，而是着重讨论网页内容的处理以及实现这一目的所需要的载体---document对象

# 3.3 模型：DOM中的“M”

1. M，模型，也可称为地图，DOM代表被加载到浏览器窗口里的当前网页：浏览器像我们提供了当前网页的地图（模型），而我们可以使用JavaScript去读取这张地图
2. DOM将一份文档表示为一棵树（parent、child、sibling）
3. 理解家谱树（节点树的概念）

# 3.4 节点

1. 节点这个词来自于网络理论，代表网络中的一个连接点
2. 在DOM所描述的结构里，文档也是由节点构成的集合
3. 文本节点和属性节点为所属的元素节点的子节点

## 3.4.1 元素节点

1. DOM的原子是元素节点
2. 其实就是HTML或XML的标签
3. 没有包含在其他元素里的唯一元素就是`<html>`元素，它是我们的结点树的根元素

## 3.4.2 文本节点

1. 即标签里的文本内容
2. 在XHTML文档里，文本节点总是包含在元素节点的内部
3. 但并非所有的元素节点都包含有文本节点，比如<ul>一般就包含<li>而不包含文本节点

## 3.4.3 属性节点

1. 即标签的属性
2. 并非所有的元素都包含着属性，但所有的属性都会包含在元素里
3. 因此属性节点总是被包含在元素节点中
4. 还有注释节点

## 3.4.4 CSS：层叠样式表

1. 通过CSS告诉浏览器如何显示一份文档的内容
2. 使用`<style>`标签在head部分声明CSS或者使用`<link>`标签因为外部CSS
3. CSS支持继承特性，节点树上的各个元素将继承其父元素的样式属性
4. class属性； .special{}
5. id属性： #purchar{}

## 3.4.5 获取元素

> 有3种DOM方法可获取元素节点，分别是通过元素ID、通过标签名字和通过类名字

1. getElementById()方法
    - document对象相关联的函数，通过id取得节点
    - document.getElementById(id);
    - 该调用将返回一个对象，可以使用typeof运算符验证
    - typeof操作符告诉我们它的操作数是不是一个字符串- 数值、函数、布尔值或对象（即判断类型）
    - alert(typeof 操作数);
    - 不建议把JavaScript代码直接嵌入一份文档，而应该分离出去
    - 事实上，文档中的每一个元素都对应着一个对象，利用DOM提供的方法，我们可以把与这些元素相对应的任何一个对象筛选出来

2. getElementsByTagName()

    - getElementsByTagName()方法返回的是一个对象数组，每个对象分别对应着文档里的有给定标签的元素，这个方法的参数是HTML标签的名字
    - document.getElementsByTagName("li");
    - cocument.getElementsByTagName("*");

3. getElementsByClassName()

    - HTML5 DOM中新增了一个令人期待已久的方法：getElementsByClassName()
    - 这个方法能够通过class属性中的类名来访问元素
    - 不过由于该方法比较新，某些DOM实现里可能还没有，因此使用的时候要当心
    - document.getElementsByClassName("sale"); //找到所有sale类的元素
    - 可以同时查找多个元素：document.getElementsByClassName("sale important");
    - 而且类名的顺序不重要，且元素含有更多的类名也没有关系
    - 可以实现一个兼容版本的getElementsByClassName(node, classname);

```
/**
 * 兼容版本的getElementsByClassName，注意不适用于多个类名
 * @param {Object} node DOM树中的搜索起点
 * @param {Object} classname 要搜索的类型，注意只能有一个类名，
 * 不能是 "classA classB"这样的参数，因为无法像真正的getElementsByClassName忽略class顺序
 */
function getElementsByClassName(node, classname){
  if(node.getElementsByClassName){
    //使用现有方法
    return node.getElementsByClassName(classname);
  }else{
    var results = new Array();
    //获取当前节点下的所有标签
    var elems = node.getElementsByTagName("*");
    for(var i = 0; i < elems.length; ++i){
      //遍历标签，判断其class属性是否包含目标类型
      if(elems[i].className.indexOf(classname) != -1){
        results[results.length] = elems[i];
      }
    }
    return results;
  }
}
```
# 3.5 获取和设置属性

1. 文档中的每一个元素节点都是一个对象(object)
2. 一份文档就是一棵节点树
3. 节点分为不同类型：元素节点、属性节点和文本节点等
4. getElementById()将返回一个对象，该对象对应着文档里的一个特定元素节点
5. getElementByTagName()方法将返回一个对象数组，它们分别对应着文档里的一个特定的元素节点
6. 这些节点中的每一个都是一个对象

## 3.5.1 getAttribute()方法

1. 该方法取得对象的属性值
2. 只有一个参数，为查询的属性的名字
3. 取得元素节点对象后，调用对象的方法以获取属性
```
//取得文档中p元素的title属性
var paras = document.getElementByTagName("p");
for(var i = 0; i < paras.length; ++i){
//若不含title属性的p元素执行该调用将返回Null
alert(paras[i].getAttribute("title"));
}
```

## 3.5.2 setAttribute()方法

1. 设置元素的属性节点的值
2. 需传递两个参数，属性名，属性值
```
var shopping = document.getElementById("purchases");
shopping.setAttribute("title", "a list of goods");
```

# 3.6 小结

getElementById()方法
getElementsByTagName()方法
getElementsByClassName()方法
getAttribute()方法
setAttribute()方法

还有其他属性和方法，如nodeName、nodeValue、childNodes、nextSibling和parentNode等，以后会一一介绍