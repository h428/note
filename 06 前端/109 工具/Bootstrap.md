

# 1. 布局基础

- 基于 CDN 的模板代码如下：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>Bootstrap Template</title>

    <link href="https://cdn.bootcss.com/twitter-bootstrap/3.3.7/css/bootstrap.css" rel="stylesheet">

    <!-- HTML5 shim 和 Respond.js 是为了让 IE8 支持 HTML5 元素和媒体查询（media queries）功能 -->
    <!-- 警告：通过 file:// 协议（就是直接将 html 页面拖拽到浏览器中）访问页面时 Respond.js 不起作用 -->
    <!--[if lt IE 9]>
    <script src="https://cdn.bootcss.com/html5shiv/3.7.3/html5shiv.js"></script>
    <script src="https://cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>

<!-- jQuery (Bootstrap 的所有 JavaScript 插件都依赖 jQuery，所以必须放在前边) -->
<script src="https://cdn.bootcss.com/jquery/1.12.4/jquery.min.js"></script>
<!-- 加载 Bootstrap 的所有 JavaScript 插件。你也可以根据需要只加载单个插件。 -->
<script src="https://cdn.bootcss.com/twitter-bootstrap/3.3.7/js/bootstrap.min.js"></script>
</body>
</html>
```

- - Bootstrap 的响应式布局主要通过布局容器配合栅格系统完成

**布局容器**

- 容器包括 `.container` 和 `.container-fluid` 两种，其中 `.container` 是根据当前设备宽度而固定一个宽度，而 `.container-fluid` 这将占据整个视口，二者都可以配合栅格系统实现响应式布局
- `.container` 利用媒体查询，根据最小设备宽度来动态定义 `.container` 的宽度，以达到响应式的目的
- 此外，布局容器都添加了 15px 的左右 padding，但在 `.row, .navbar-header, .navbar-collapse` 这样的类中，又设置了 15px 的左右 margin 用于抵消 padding，如下述是 `.containner` 的部分设置
```css
.container {
  padding-right: 15px;
  padding-left: 15px;
  margin-right: auto;
  margin-left: auto;
}
```

**栅格系统**

- 栅格系统通过一系列的行（row）与列（column）的组合来创建页面布局，行即为 `.row`，而列是响应式的，它们的名称为 `.col-xs/sm/md/lg-*`，其中 xs, sm, md, lg 是和设备宽度有关的对应类，后面的 * 是数字
- 注意 `.row` 必须放在 `.container` 或 `.container-fluid` 内部，`.row` 内部则可以放置多个 `col-xxx`
- 注意 `.row` 中设置了 -15px 的左右 margin，抵消了 `.container` 和 `.container-fluid` 类中的 padding
- 每一个 row 被定义为 12 列，通过 col 类的组合，最终完成一个 12 列的 col，例如 3 个 `col-sm-4` 可以在一个 row 内划分出 3 个均等的 div
```html
<div class="container">
    <div class="row">
        <div class="col-md-4">.col-xs-6 .col-md-4</div>
        <div class="col-md-4">.col-xs-6 .col-md-4</div>
        <div class="col-md-4">.col-xs-6 .col-md-4</div>
    </div>
</div>
```
- xs, sm, md, lg 分别对应 768px, 992px, 1200px 三个分界宽度，下面和响应式相关的类都用不在每种都列出，只挑一种距离
- 可利用形如 `col-sm-offset-2` 这样的类对 div 进行列偏移， offset 的偏移是使用 margin-left 实现的，因此偏移产生的空白区域是属于加了该类的标签的一部分
- 此外 `col-md-push-3` 和 `col-md-pull-9` 也可以对列完成偏移和换序，他们是利用 `position:relative` 并配合 left 或 right 达到往左 pull 或向右 push 的目的，因此他们的标准文档流仍然占据远处，只不过通过偏移实现了覆盖
- 如果一“行（row）”中包含了的“列（column）”大于 12，多余的“列（column）”所在的元素将被作为一个整体另起一行排列
- 栅格类适用于与屏幕宽度大于或等于分界点大小的设备 ， 并且针对小屏幕设备覆盖栅格类。 因此，在元素上应用任何 `.col-md-*` 栅格类适用于与屏幕宽度大于或等于分界点大小的设备 ， 并且针对小屏幕设备覆盖栅格类。 因此，在元素上应用任何 `.col-lg-*` 不存在， 也影响大屏幕设备
- 注意这些 col 布局的设计都是基于浮动而实现的，因此必要时要学会清楚浮动，例如下面的例子
- 下面是官网给出的一个响应式布局的样例，其中 `.clearfix` 用于清楚浮动，`visible-xs-block` 用于设置这个清楚浮动的 div 仅 xs 下可用，即只有 xs 下才会清楚浮动
```html
<div class="container">
    <div class="row">
        <div class="col-xs-6 col-sm-3 yellow">Resize your viewport or check it out on your phone for an example.</div>
        <div class="col-xs-6 col-sm-3 blue">.col-xs-6 .col-sm-3</div>

        <!-- 若这里不清楚浮动，由于第一个 div 比较宽将会使得第三个 div 出现在第一个div 的右边，第二个 div 的下边 -->
        <!-- visible-xs-block 是响应式工具类，若不设置仅 xs 下可见，由于清楚浮动，将导致 sm 情况第三个元素也会换行-->
        <div class="clearfix visible-xs-block"></div>

        <div class="col-xs-6 col-sm-3 green">.col-xs-6 .col-sm-3</div>
        <div class="col-xs-6 col-sm-3 cyan">.col-xs-6 .col-sm-3</div>
    </div>
</div>
```
- 有一个问题就是，由于框架对工具类的设置，比如对于 `visible-xs-block` 设置为只有在设备小于等于 767px 时才生效，即小于等于 767 px 时才清楚浮动，但我在谷歌中测试时，由于谷歌浏览器的 767 实际上是 767.2 这导致该类并不起作用，且由于 sm 相关类只有大于等于 768px 时才生效，因此对于这之间的值将会使得第三个 div 挤到上方

# 2. 样式

## 2.1 基础元素

- Bootstrap 为大量元素设置了预定义样式，你可以直接使用它们而不需额外的设置，有些直接使用标签即可，有些稍微繁琐一点，添加一定的 class 即可
- 标题：h1 ^ h6 标签都预设了样式，且提供了 .h1 ~ .h6 类用于给内联文本设置标题的样式，此外还可以内部使用 small 元素设置副标题
- 文字：全局 font-size 设置为 14px，line-height 设置为 1.428，p 元素还被设置了等于 1/2 行高（即 10px）的底部外边距（margin）
- 段落突出：通过添加 .lead 类可以让段落突出显示

**文本基础特效**

- 高亮：使用 mark 元素，如 `<mark>highlight</mark>`
- 被删除：使用 del 元素，如 `<del>del text.</del>`
- 无用文本（和被删除一样）：使用 s 元素，如 `<s>useless text</s>`，del 和 s 都是使用 `text-decoration: line-through;` 设置的
- 插入文本（效果是下划线）：使用 ins 元素，如 `<ins>ins test</ins>`
- 下划线文本：使用 u 元素，如 `<u>underline text</u>`，u 和 ins 都是使用 `text-decoration: underline;` 设置的
- 小号文本：.small 类或者 small 元素，
- 着重：strong 元素
- 斜体：em 元素
- 对齐：主要是 text-left, text-center, text-right, text-justify, text-nowrap 这几个类
- 改变大小写：text-lowercase, text-uppercase, text-capitalize 这几个类
- 缩略语：`<abbr title="attribute">attr</abbr>`
- 首字母缩略语： `<abbr title="HyperText Markup Language" class="initialism">HTML</abbr>`
- 地址：
```html
<address>
    <strong>Twitter, Inc.</strong><br>
    1355 Market Street, Suite 900<br>
    San Francisco, CA 94103<br>
    <abbr title="Phone">P:</abbr> (123) 456-7890
</address>

<address>
    <strong>Full Name</strong><br>
    <a href="mailto:#">first.last@example.com</a>
</address>
```
- 引用：将任何 HTML 元素包裹在 blockquote 中即可表现为引用样式。对于直接引用，我们建议用 p 标签
```html
<blockquote>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.</p>
</blockquote>
```
- 多种引用样式，对于标准样式的 blockquote，可以通过几个简单的变体就能改变风格和内容，例如添加 footer 用于标明引用来源，来源的名称可以包裹进 cite 标签中
```html
<blockquote>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.</p>
    <footer>Someone famous in <cite title="Source Title">Source Title</cite></footer>
</blockquote>
```

**列表**

- 列表：即 ul, ol, li 等，无样式列表可添加 `list-unstyled` 类
- 内联列表：list-inline 类，内联列表可以用于设置导航栏
- 描述：抵用 dl, dt, dd ，还有水平排列的描述 .dl-horizontal
> 通过 text-overflow 属性，水平排列的描述列表将会截断左侧太长的短语，显示为 ...，在较窄的视口（viewport）内，列表将变为默认堆叠排列的布局方式

## 2.2 代码

- 内联代码：使用 code 元素设置，如 `<code>&lt;section&gt;</code>`
- 用户输入：使用 kbd 元素设置
- 代码块：使用 pre 元素
- 变量：使用 var 元素
- 程序输入：使用 samp 元素

## 2.3 表格

- 基本表格：为 table 标签添加 .table 类可以为其赋予基本的样式，包含少量的 padding 和水平方向的分隔线
- 条纹状的表格：添加 .table-striped 类，其基于 :nth-child 选择器实现
- 带边框的表格：添加 .table-bordered 类
- 鼠标悬停响应表格：添加 .table-hover ，当鼠标悬停在某行时会使得当前行背景加深
- 紧缩表格：添加.table-condensed 类，该类使得表格更加紧凑，单元格内的 padding 都会减半
- 状态类：可以为表格的行添加状态类来为不同的行设置不同的背景色，状态类主要包括 active, success, warning, danger, info 五个类
- 响应式表格：添加 .table-responsive 设置响应式表格，当表格的列太多且屏幕太小时，响应式表格会在小屏幕设备上水平滚动，当屏幕宽度大于 768px 时，水平滚动条消失
- 注意 .table-responsive 要在表格外部添加一个 div 进行设置
- 下面是一个表格的综合例子，除了条纹状，其他内容基本都用到了
```html
<div class="table-responsive">
    <table class="table table-hover table-bordered table-condensed">
        <thead>
        <tr>
            <th>#</th>
            <th>姓名</th>
            <th>性别</th>
            <th>职业</th>
        </tr>
        </thead>
        <tbody>
        <tr class="success">
            <td>1</td>
            <td>令狐冲</td>
            <td>男</td>
            <td>程序员</td>
        </tr>
        <tr class="info">
            <td>2</td>
            <td>郭靖</td>
            <td>男</td>
            <td>律师</td>
        </tr>
        <tr class="danger">
            <td>3</td>
            <td>黄蓉</td>
            <td>女</td>
            <td>医生</td>
        </tr>
        <tr class="warning">
            <td>4</td>
            <td>岳不群</td>
            <td>男</td>
            <td>记者</td>
        </tr>
        </tbody>
    </table>
</div>
```

## 2.4 表单

- 单独的表单控件会被自动赋予一些全局样式
- Bootstrap 的表单大概遵循这样的应用步骤，一些细节类可能发生变化：
    - 首先是 form 标签，可以使用默认 from 或者为其添加一些类更改为内联表单、水平表单等
    - 在 from 内，每块输入控件外层要先套一个 div.form-group 或者 div.checkbox 这样的类
    - 然后在 div 内，才是设置 label, input 等内容
    - 注意，多个 input, radio, checkbox 之间不共享 form-group 或 checkbox，要为每一个都设置（但是拥有同样 name 的一组 radio 或 checkbox 是算同一个的）
- .form-control 主要用于包裹 3 种控件： input, textarea, select，所有设置了 .form-control 类的 input、textarea 和 select 元素都将被默认设置宽度属性为 width: 100%;
- 而 div.checkbox 和 div.radio 则用于包裹 checkbox 和 radio
- 一般需要将 label 元素和 input 包裹在 .form-group 中，但由于控件的 width 占据 100% 的父元素，因此它们会分别占据两行，若想同一行可以使用水平表单 .form-horizontal
- 下面是一个基本表单样例：
```html
<form>
    <!--用户名-->
    <div class="form-group">
        <label for="username">Username</label>
        <input type="text" class="form-control" id="username" placeholder="用户名">
    </div>
    <!--密码-->
    <div class="form-group">
        <label for="password">Password</label>
        <input type="password" class="form-control" id="password" placeholder="密码">
        <p class="help-block">帮助文本类型：在此处输入密码</p>
    </div>
    <!--checkbox-->
    <div class="checkbox">
        <label>
            <input type="checkbox"> checkbox：记住密码？
        </label>
    </div>
    <div class="checkbox disabled">
        <label>
            <input type="checkbox" value="" disabled>
            被禁用的 checkbox
        </label>
    </div>
    <!--水平 checkbox 组-->
    <div class="checkbox">
        <label class="checkbox-inline">
            <input type="checkbox" name="fruit" value="op1">1
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="fruit" value="op2">2
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="fruit" value="op3">3
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="fruit" value="op4">4
        </label>
    </div>
    <!--水平radio组-->
    <div class="radio">
        <label class="radio-inline">
            <input type="radio" name="fruit" value="op1">1
        </label>
        <label class="radio-inline">
            <input type="radio" name="fruit" value="op2">2
        </label>
        <label class="radio-inline">
            <input type="radio" name="fruit" value="op3">3
        </label>
        <label class="radio-inline">
            <input type="radio" name="fruit" value="op4">4
        </label>
    </div>
    <!--提交按钮-->
    <button type="submit" class="btn btn-default">默认按钮：提交</button>
</form>
```

### 2.4.1 内联表单

- 内联表单中的多个输入内容都展现在一行，一般用于页面头尾部的搜索和提交信息等
- 为 form 元素添加 .form-inline 类可使其内容左对齐并且表现为 inline-block 级别的控件
- 内联表单只适用于 viewport 至少在 768px 宽度时，视口宽度再小的话就会使表单折叠
- 在 Bootstrap 中，输入框和单选/多选框控件默认被设置为 `width: 100%;` 宽度，但在内联表单，我们将这些元素的宽度设置为 `width: auto;`，因此，多个控件可以排列在同一行
- 如果你没有为每个输入控件设置 label 标签，屏幕阅读器将无法正确识别
- 如果你不需要 label 标签，可以通过为 label 设置 .sr-only 类将其隐藏，但不建议直接省略它们
- 如果没有 label 标签，还有一些其他辅助技术可以作为替代方案，比如屏幕阅读器可能会尝试 aria-label, aria-labelledby 或 title 属性
- 如果上述内容都不存在，屏幕阅读器可能会采取使用 placeholder 属性，但这种方式实际上是不合适的，因此应该至少定义上述内容中的一种，以让屏幕阅读器能够正确处理
```html
<!--内联表单-->
<form class="form-inline">
    <!--用户名-->
    <div class="form-group">
        <label for="username">Username</label>
        <input type="text" class="form-control" id="username" placeholder="用户名">
    </div>
    <!--邮箱-->
    <div class="form-group">
        <label for="email">Email</label>
        <input type="email" class="form-control" id="email" placeholder="邮箱">
    </div>
    <!--提交按钮-->
    <button type="submit" class="btn btn-default">发送邀请</button>
</form>
```

### 2.4.2 水平排列的表单

- 水平表单表示为同一 group 的 label 和 input 显示在同一行，并且可以使用栅格类中的 col 控制它们的宽度
- 为表单添加 .form-horizontal 类，并联合使用 Bootstrap 预置的栅格类，可以将 label 标签和控件组水平并排布局
- .form-horizontal 这会改变 .form-group 的行为，使其表现为栅格系统中的 row，因此就无需再额外添加 .row 了，只需设置 col 即可
- 相比较于普通的表单，.form-horizontal 内部仍然需要使用 form-group，然后在 form-group 内包含 label 和 input
- 其中，需要为 label 添加 control-label 和对应的 col 类，input 则要外包一个 div，并添加对应的 col 类，来控制宽度
- 下面是一个水平排列表单的例子：
```html
<!--水平表单-->
<form class="form-horizontal">
    <!--用户名-->
    <div class="form-group">
        <!--label必须设置 control-label 和对应的 col 类-->
        <label for="username" class="control-label col-xs-3">Username</label>
        <!--input 必须使用一个 col 包裹起来-->
        <div class="col-xs-9">
            <input type="text" class="form-control" id="username" placeholder="用户名">
        </div>
    </div>
    <!--邮箱-->
    <div class="form-group">
        <label for="email" class="control-label col-xs-3">Email</label>
        <!--输入框组件示例-->
        <div class="col-xs-9">
            <div class="input-group">
                <span class="input-group-addon">$</span>
                <input type="email" class="form-control" id="email" placeholder="邮箱">
                <!--输入框组件示例-->
                <span class="input-group-addon">@example.com</span>
            </div>
        </div>
    </div>
    <!--提交按钮-->
    <div class="form-group">
        <div class="col-xs-9 col-xs-offset-3">
            <button type="submit" class="btn btn-default">发送邀请</button>
        </div>
    </div>
</form>
```

### 2.4.3 支持的控件

**输入框**

- 包括大部分表单控件、文本输入域控件，还支持所有 HTML5 类型的输入控件： text、password、datetime、datetime-local、date、month、time、week、number、email、url、search、tel 和 color
- 必须添加类型声明，只有正确设置了 type 属性的输入控件才能被赋予正确的样式
- 如需在文本输入域 input 前面或后面添加文本内容或按钮控件，请参考输入控件组
- `<input type="text" class="form-control" placeholder="Text input">`

**文本域**

- 支持多行文本的表单控件。可根据需要改变 rows 属性
- `<textarea class="form-control" rows="3"></textarea>`

**多选和单选框**

- 多选框（checkbox）用于选择列表中的一个或多个选项，而单选框（radio）用于从多个选项中只选择一个
- 需要注意还是要提供 label 标签并在内部包含选项
- 可以配合 disabled 类禁用某选项
- 内联单选和多选框：通过将 .checkbox-inline 或 .radio-inline 类应用到一系列的多选框（checkbox）或单选框（radio）控件上，可以使这些控件排列在一行
- 若 checkbox 或 radio不带 label 文本，仍然需要为使用辅助技术的用户提供某种形式的 label（例如，使用 aria-label）

**下拉列表**

- 下面是一个用在水平表单的下拉列表的例子
```html
<div class="form-group">
    <label for="fruit" class="control-label col-xs-3">下拉列表</label>
    <div class="col-xs-9">
        <select class="form-control" name="fruit" id="fruit">
            <option>1</option>
            <option>2</option>
            <option>3</option>
            <option>4</option>
            <option>5</option>
        </select>
    </div>
</div>
```
- 对于标记了 multiple 属性的 select 控件来说，默认显示多选项

**静态控件**

- 如果需要在表单中将一行纯文本和 label 元素放置于同一行，为 p 元素添加 .form-control-static 类即可
- 下面是基于水平表单的静态控件样例
```html
<div class="form-group">
    <label class="control-label col-xs-3">邮箱</label>
    <div class="col-xs-9">
        <p class="form-control-static">email@example.com</p>
    </div>
</div>
```

**焦点状态**

- Bootstrap 为输入空间的焦点设置了样式，取消默认 outline 并增加了 `#66afe9` 颜色的 border，此外还设置了 box-shadow

**禁用状态**

- 为输入框设置 disabled 属性可以禁止其与用户有任何交互（按钮也是同样的方法）
- 被禁用的输入框颜色更浅，并且还添加了 not-allowed 鼠标状态
- 还可以通过 fieldset 禁用控件，通过设置 fieldset 的 disabled 属性,可以禁用 fieldset 中包含的所有控件，但注意对于 a 标签只影响其样式，但其仍然可点击，因此建议通过 js 来禁用这些内容

**只读状态**

- 用于输入框，大致样子和禁用差不多，除了鼠标仍然保持正常的样式而不是禁用的样式
- 为输入框设置 readonly 属性即可获得只读状态的样式

**帮助文本**

- 使用 help-block 类来设置帮助文本，其可用于提示，可以配合状态类做输入校验
- 下面是一个基于水平表单的帮助文本配合校验状态类的例子
```html
<div class="form-group has-error">
    <label for="username" class="control-label col-xs-2">Username</label>
    <div class="col-xs-6">
        <input type="text" class="form-control" id="username" placeholder="用户名">
    </div>
    <!--设置 padding 是为了和 form-control 对齐，form-control 设置了 6px 的 padding 和 1px 的 border-->
    <!--但 help-block 自带了 5px 的 margin-top，因此设置 2px 的 padding，为了好看，提示文本稍微往下 1px，设置为 3px-->
    <!--理论上应该设置为外部样式，但为了学习和记笔记方便直接设置为内部样式-->
    <div class="col-xs-4">
        <span class="help-block" style="padding-top: 3px;">用户名输入有误！</span>
    </div>
</div>
```

**校验状态**

- Bootstrap 对表单控件的校验状态，如 error、warning 和 success 状态，都定义了样式，添加 .has-warning、.has-error 或 .has-success 类到 form-group 的那个 div 即可应用对应的状态样式
- 任何包含在此元素之内的 .control-label、.form-control 和 .help-block 元素都将接受这些校验状态的样式
- 单纯使用该种校验状态，部分用户可能无法得到反馈，例如色盲用户，因此因此一般需要配合帮助文本或反馈图标进行校验状态的反馈

**反馈图标**

- 为 form-group 的 div 添加 has-feedback 类，然后添加反馈图标到 input 后并设置反馈样式 form-control-feedback 即可
- 注意不设置反馈样式只会单纯导入图标，十分突兀
- 强烈建议为所有输入框添加 label 标签。如果你不希望将 label 标签展示出来，可以通过添加 .sr-only 类来实现
- 如果的确不能添加 label 标签，请调整图标的 top 值。对于输入框组，请根据你的实际情况调整 right 值
- 为了让类似屏幕阅读器这样的设备也能理解一个图标的含义，我们需要设置额外的隐藏的文本，其包含在 .sr-only 类中，并通过表单控件的 aria-describedby 属性关联它们
- 下面是基于水平表单，结合帮助文本、校验状态和反馈图标做的反馈的例子：
```html
<!--用户名-->
<div class="form-group has-success has-feedback">
    <label for="username" class="control-label col-xs-2">Username</label>
    <div class="col-xs-6">
        <input type="text" class="form-control" id="username" placeholder="用户名" aria-describedby="usernameStatus">
        <span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>
        <span id="usernameStatus" class="sr-only">(success)</span>
    </div>
    <!--设置 padding 是为了和 form-control 对齐，form-control 设置了 6px 的 padding 和 1px 的 border-->
    <!--但 help-block 自带了 5px 的 margin-top，因此设置 2px 的 padding，为了好看，提示文本稍微往下 1px，设置为 3px-->
    <!--理论上应该设置为外部样式，但为了学习和记笔记方便直接设置为内部样式-->
    <div class="col-xs-4">
        <span class="help-block" style="padding-top: 3px;">用户名输入正确！</span>
    </div>
</div>
<!--电子邮箱-->
<div class="form-group has-error has-feedback">
    <label for="email" class="control-label col-xs-2">Email</label>
    <div class="col-xs-6">
        <input type="email" class="form-control" id="email" placeholder="电子邮箱" aria-describedby="emailStatus">
        <span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>
        <span id="emailStatus" class="sr-only">(error)</span>
    </div>
    <!--设置 padding 是为了和 form-control 对齐，form-control 设置了 6px 的 padding 和 1px 的 border-->
    <!--但 help-block 自带了 5px 的 margin-top，因此设置 2px 的 padding，为了好看，提示文本稍微往下 1px，设置为 3px-->
    <!--理论上应该设置为外部样式，但为了学习和记笔记方便直接设置为内部样式-->
    <div class="col-xs-4">
        <span class="help-block" style="padding-top: 3px;">电子邮箱格式有误！</span>
    </div>
</div>
```

**控件尺寸**

- 通过类似 .input-lg 的类可以为控件设置高度，通过 .col-lg-* 类似的类可以为控件设置宽度
- 可以通过添加 .form-group-lg 或 .form-group-sm 类，为 .form-horizontal 包裹的 label 元素和表单控件快速设置尺寸
```html
<div class="form-group form-group-lg">
    <label class="col-xs-2 control-label" for="largeInput">Large label</label>
    <div class="col-sm-6">
        <input class="form-control" type="text" id="largeInput" placeholder="大块输入域">
    </div>
</div>
```
- 用栅格系统中的列（column）包裹输入框或其任何父元素，都可很容易的为其设置宽度

## 2.5 按钮

### 2.5.1 可作为按钮使用的标签或元素

- 为 a, button 或 input 元素添加按钮类即可使用 Bootstrap 提供的样式，如下述例子：
```html
<a class="btn btn-default" href="#" role="button">Link</a>
<button class="btn btn-default" type="submit">Button</button>
<input class="btn btn-default" type="button" value="Input">
<input class="btn btn-default" type="submit" value="Submit">
```
- 按钮类可以应用到 a 和 button 元素上，但是，导航和导航条组件只支持 button 元素
- 当将 a 作为 button 使用且是用于触发某些功能而不是用作链接时，需要为其设置 role="button" 属性
- 强烈建议尽可能使用 button 元素来获得在各个浏览器上获得相匹配的绘制效果

### 2.5.2 样式

- 作为一个按钮首先要添加 btn 类，然后再为其添加你想要的样式
- 按钮样式包括 btn-default, btn-primary, btn-success, btn-info, btn-warning, btn-danger, btn-link
- 对于使用辅助技术，例如屏幕阅读器的用户来说，颜色是不可见的，因此建议确保通过颜色表达的信息或者通过内容自身表达出来（按钮上的文字），或者通过其他方式，例如通过 .sr-only 类隐藏的额外文本表达出来

### 2.5.3 尺寸

- 使用 btn-lg, btn-sm, btn-xs 设置尺寸，若不设置则为默认尺寸
- 给按钮添加 .btn-block 类可以将其拉伸至父元素 100% 的宽度，而且按钮也变为了块级元素

### 2.5.4 状态

**激活状态**

- 当按钮处于激活状态时，其表现为被按压下去（底色更深、边框夜色更深、向内投射阴影）
- 若想让按钮正常情况下也表现得像 :active 状态下一样，可以为按钮添加 active 类
- 同样也可以为基于 a 元素创建的按钮添加 .active 类

**禁用状态**

- 通过为按钮的背景设置 opacity 属性改变透明度就可以呈现出无法点击的效果，而 cursor: not-allowed; 使得无法点击
- 为 button 元素添加 disabled 属性，使其表现出禁用状态
- 对于 a 元素创建的按钮，为其添加 .disabled 类来添加禁用状态
- active, disabled 两个类实际上是工具类，用于控制组件状态的
- 需要注意的是，对于链接，在样式上虽然已经禁用了，但实际上其仍然可以点击，因此，为了安全起见，建议通过 JavaScript 代码来禁止链接的原始功能
- 下面是按钮的综合例子：
```html
<button class="btn btn-default">默认</button>
<button class="btn btn-primary">普通</button>
<button class="btn btn-warning">未激活</button>
<button class="btn btn-warning active">激活</button>
<button class="btn btn-danger" disabled="disabled">禁用</button>
<button class="btn btn-lg btn-primary">超大</button>
<a class="btn btn-primary" href="#">链接显示为按钮</a>
<button class="btn btn-link">按钮显示为链接</button>
```

## 2.6 图片

**响应式图片**

- 为图片添加 .img-responsive 类可以让图片支持响应式布局
- 其实质是为图片设置了 max-width: 100%;、 height: auto; 和 display: block; 属性，从而让图片在其父元素中更好的缩放
- 如果需要让使用了 .img-responsive 类的图片水平居中，请使用 .center-block 类，不要用 .text-center
- `<img src="..." class="img-responsive" alt="Responsive image">`

**图片形状**

- 通过为 img 元素添加以下相应的类，可以让图片呈现不同的形状
```html
<img src="..." alt="..." class="img-rounded">
<img src="..." alt="..." class="img-circle">
<img src="..." alt="..." class="img-thumbnail">
```

## 2.7 辅助类

**情境文本**

- 情境文本主要给文本添加颜色，使其带有一定的情境色彩
- 有时情境文本可能不生效，此时可以配合 span 元素并添加对应类
```html
<p class="text-muted">...</p>
<p class="text-primary">...</p>
<p class="text-success">...</p>
<p class="text-info">...</p>
<p class="text-warning">...</p>
<p class="text-danger">...</p>
```

**情境背景**

- 情境背景和情景文本类似，只不过设置的是背景色
```html
<p class="bg-primary">...</p>
<p class="bg-success">...</p>
<p class="bg-info">...</p>
<p class="bg-warning">...</p>
<p class="bg-danger">...</p>
```

**其他辅助**

- 关闭按钮：通过使用一个象征关闭的图标，可以让模态框和警告框消失
```html
<button type="button" class="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>
```
- 三角符号：通过使用三角符号可以指示某个元素具有下拉菜单的功能。注意，向上弹出式菜单中的三角符号是反方向的
```html
<span class="caret"></span>
```

**布局相关**

- 快速浮动：通过添加一个类，可以将任意元素向左或向右浮动。!important 被用来明确 CSS 样式的优先级
```html
<div class="pull-left">...</div>
<div class="pull-right">...</div>
```
- 上述内容不可以用于导航条中的组件，但可以使用 .navbar-left 或 .navbar-right
- 让内容块居中：center-block 通过设置 display 为 block 且左右 margin 为 auto 来达到居中的效果，因此对于像居中的元素，只需为其添加 center-block 类即可
```html
<div class="center-block">...</div>
```
- 注意 center-block 将元素设置为块级元素，并相对其父级元素居中，而 text-center 设置的是 text-align: center;，因此其是让元素内部的内容居中
- 清除浮动：添加 .clearfix 类即可，其设置了左右都清除浮动 `<div class="clearfix">...</div>`

**显示或隐藏内容**

- .show 和 .hidden 类可以强制任意元素显示或隐藏(对于屏幕阅读器也能起效)
- 若想在正常设备隐藏，只在类似屏幕阅读器这种设备上生效，可以使用 .sr-only 类
- .invisible 类可以被用来仅仅影响元素的可见性，其 display 属性不被改变，该元素仍然处于正常文档流中，影响正常文档流的布局

**屏幕阅读器和键盘导航**

- .sr-only 类可以对屏幕阅读器以外的设备隐藏内容。.sr-only 和 .sr-only-focusable 联合使用的话可以在元素有焦点的时候再次显示出来（例如，使用键盘导航的用户）
- `<a class="sr-only sr-only-focusable" href="#content">Skip to main content</a>`

**图片替换**

- 使用 .text-hide 类或对应的 mixin 可以用来将元素的文本内容替换为一张背景图（我也不知道干嘛的）
- `<h1 class="text-hide">Custom heading</h1>`

## 2.8 响应式工具

- 可以响应式的显示或隐藏一些内容，主要利用 .visible-xs-*, .hidden-xs (xs 只是举例，可以替换为其他)
- 后面的 * 还可以选择为 block, inline, inline-block，如 .visible-xs-block, .visible-sm-inline 等，它们是通过 display 设置的

**打印类**

- .visible-print-block, .visible-print-inline, .visible-print-inline-block, .hidden-print 主要涉及这四个类
- visible-* 正常情况下将 display: none; 然后通过媒体查询，设置 print 时的 display 为对应的 block 或 inline 等

# 3. 组件

## 3.1 字体图标

- 包括250多个来自 Glyphicon Halflings 的字体图标供 Bootstrap 免费使用
- 样例：`<span class="glyphicon glyphicon-search" aria-hidden="true"></span>`
- 注意，为了设置正确的 padding，务必在图标和文本之间添加一个空格
- 图标类不能和其它组件直接联合使用，即不能再同一个元素中和其他类共同存在，因此应该创建一个单独的 span 标签，并将图标类应用到这个 span 标签上
- 还要注意图标类只能应用在不包含任何文本内容或子元素的元素上，即 span 中间不能含有内容
- 可以把图标应用到按钮、工具条中的按钮组、导航或输入框等地方，例如，可以将图标放置到 button 内部为 button 设置图标
```html
<button type="button" class="btn btn-default" aria-label="Left Align">
    <span class="glyphicon glyphicon-align-left" aria-hidden="true"></span>
</button>
<button type="button" class="btn btn-primary btn-lg">
    <span class="glyphicon glyphicon-star" aria-hidden="true"></span> Star
</button>
```
- alert 组件中所包含的图标是用来表示这是一条错误消息的，通过添加额外的 .sr-only 文本就可以让辅助设备知道这条提示所要表达的意思
```html
<div class="alert alert-danger" role="alert">
    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
    <span class="sr-only">Error:</span>
    Enter a valid email address
</div>
```

## 3.2 下拉菜单








