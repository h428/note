
# 概述

- Less 扩展了 CSS，用于更加快速和方便地编写 CSS

# 变量

- Less 中可以定义变量，使用符号 `@` 定义变量，变量支持基本的运算
- 例如：
```less
@width: 10px;
@height: @width + 10px;

#header {
  width: @width;
  height: @height;
}
```
- 编译为下述内容，其中 `@width` 和 `@height` 是自定义的变量
```css
#header {
  width: 10px;
  height: 20px;
}
```

# 混合

- 混合将一个定义好的 class A 轻松的引入到另一个 class B 中，从而简单实现 class B 继承 class A 中的所有样式
- 抽象父类时还设置变量，然后复用时传递值
```less
.base(@height:100px, @width:100px) {
  height: @height;
  width:@width;
}

.div1{
  .base(50px, 50px);
}

.div2{
  .base();
}

.div3{
  .base(50%, 50%);
}

// 编译结果
.div1 {
  height: 50px;
  width: 50px;
}
.div2 {
  height: 100px;
  width: 100px;
}
.div3 {
  height: 50%;
  width: 50%;
}
```

# 嵌套

- 嵌套主要用于定义子类关系，如下述 less
```less
#header {
  color: black;
  .navigation {
    font-size: 12px;
  }
  .logo {
    width: 300px;
  }
}

// 编译结果
#header {
  color: black;
}
#header .navigation {
  font-size: 12px;
}
#header .logo {
  width: 300px;
}
```
- 嵌套在括号内部默认采用的是后代选择器，如果要使用子元素选择器、相邻兄弟选择器、伪类选择器等选择器，则要利用 `&` 符号，在嵌套内部，`&` 表示的就是外层的那个选择器，在其后添加 `+`, `>`, `:` 等来使用对应选择器即可
- 例如下述列子：
```less
.out {
  // 后代选择器
  div {
    background: green;
  }

  // 子元素选择器
  & > div {
    background-color: aqua;
  }
  // 相邻兄弟选择器
  & + div {
    background-color: gray;
  }

  // 伪类选择器
  &:hover {
    color: blue;
  }
}

// 编译结果
.out div {
  background: green;
}
.out > div {
  background-color: aqua;
}
.out + div {
  background-color: gray;
}
.out:hover {
  color: blue;
}
```
- 此外，还可以在内部编写媒体查询代码，对不同设备设置不同样式

# Escaping

- Escaping 可以理解为字符串的替换，有点类似前面的定义变量

# 函数

- Less 内置许多函数用于颜色、处理字符串、算数运算等

# Namespaces and Accessors

- 根据代码大意，可以推断是，对于我们抽象的类型，我们可以只复用抽象类内部的部分选择器即可，只要在对应的命名空间调用对应的选择器即可

# Maps

- 在 Less 3.5 后，可以抽象 Map
- 根据代码大意，推断是：抽象的不一定是样式，而可以是一个 map，在子类中调用时当做一个 map 传入不同的 key 取得不同的值
- 我拿在线网站测试不出效果，可能是版本不够
```less
#colors() {
  primary: blue;
  secondary: green;
}

.button {
  color: #colors[primary];
  border: 1px solid #colors[secondary];
}

.button {
  color: blue;
  border: 1px solid green;
}
```

# 作用域

- 根据代码大意，可以看出可以在内部定义变量，并覆盖外部的变量

# 注释

- 和 C 一样

# 导入

- 可以导入 less 或 css
```less
@import "library"; // library.less
@import "typo.css";
```

