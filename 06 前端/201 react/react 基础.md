# 概述与安装

## 概述

React 是用于构建用户界面的 JavaScript 库，其起源于 Facebook 的内部项目，用于架设 Instagram 并后续开源，可分别访问[英文官网](https://reactjs.org)和[中文官网](https://react.docschina.org/)了解详情。

从前后端整体的 MVC 角度看，React 仅仅是视图层（V），也就是只负责视图的渲染。

React 具有如下特点：

- 声明式：只需要描述 UI 看起来是什么样的，就像写 HTML 一样，由 React 负责渲染 UI 并在数据变化时自动更新
- 基于组件：组件时 React 最重要的内容，使用组件表示页面的各个内容，并进行复用
- 学习一次，随处使用：可以 React Native 或其他框架开发 Web app 应用
- 具备高校的 Diffing 算法

React 高效的原因：

- React 使用虚拟 DOM（Virtual DOM）, 不总是直接操作页面真实 DOM
- React 实现了 DOM Diffing 算法，对 DOM 进行最小化页面重绘，即只有发生变化的 DOM 才会重绘

## hello, world

### html 单页面引入

对于 html 页面，主要通过引入 js 文件的方式使用 react，涉及的 js 文件包主要包括 react.js, react-dom.js 和 babel.js，其中 react.js 包是核心包，提供创建元素、组件等功能，react-dom 包提供 DOM 相关功能，babel 使得浏览器支持 ES6 和 JSX 语法。可以提前下载 js 文件并在 html 引入，也可以使用命令安装模块，然后在 node_modules 中找到相关 js 文件进行引入。

安装上述三个模块的命令为：

```bash
npm init -y
npm i react react-dom @babel/standalone
```

下载完毕后，在页面上引入 react 和 react-dom 两个 js 文件，使用全局 React 变量创建 React 元素，之后使用 ReactDOM 渲染创建的元素，完整的 demo 代码如下：

```html
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <title>React Demo</title>
  </head>
  <body>
    <!--承载 React 的根节点-->
    <div id="root"></div>

    <!--引入 React 核心库-->
    <script src="node_modules/react/umd/react.development.js"></script>
    <!--引入 react-dom 用于支持 React 操作 DOM-->
    <script src="node_modules/react-dom/umd/react-dom.development.js"></script>
    <script>
      // 创建虚拟 DOM
      const element = React.createElement("h1", null, "Hello, React");
      // 通过 id 选择器找到承载的容器
      const root = document.getElementById("root");
      // 渲染虚拟 DOM 到页面，React18+ 使用该接口会警告
      // ReactDOM.render(element, root);
      // React 18+ 推荐使用 ReactDOM.createRoot 进行元素渲染，不再支持 ReactDOM.render
      ReactDOM.createRoot(root).render(element);
    </script>
  </body>
</html>
```

> 注意：大部分教程在将虚拟 DOM 渲染到页面时使用的是 `ReactDOM.render(element, root)` 这个方法，这是老版本的 React 推荐的写法，若使用的是 React 18+ 版本，推荐的写法是 `ReactDOM.createRoot(root).render(element)`

### Babel 作用

前面的代码我们没有引入 babel，其在支持 ES6 的浏览器中可以正常运行，但没有引入 babel，所有的 React 相关代码必须使用标准 js 的语法编写，这样当我们需要创建多层元素时，必须嵌套调用 React.createElement，代码将极其复杂，因此官方引入了 JSX 语法。如果我们引入了 Babel 库，其不但可以让代码运行在 ES5 环境，还可以让 js 代码块变为支持 jsx 语法，从而可以很便捷的编写 React 元素。

```html
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <title>React Demo</title>
  </head>
  <body>
    <!--承载 React 的根节点-->
    <div id="root"></div>

    <!--引入 React 核心库-->
    <script src="node_modules/react/umd/react.development.js"></script>
    <!--引入 react-dom 用于支持 React 操作 DOM-->
    <script src="node_modules/react-dom/umd/react-dom.development.js"></script>
    <!--引入 babel 使得页面支持 jsx 语法，以及可以让不支持 ES6 的浏览器支持 ES6（会将 ES6 编译为 ES5）-->
    <script src="node_modules/@babel/standalone/babel.js"></script>
    <!--type 必须设置为 text/babel，这样才会通过 babel 进行编译转换-->
    <script type="text/babel">
      // 创建虚拟 DOM，可以直接使用 jsx 语法而不需要在手动调用 React.createElement，故 jsx 可以看成是一种语法糖
      const element = <h1>Hello, React!</h1>;
      // 通过 id 选择器找到承载的容器
      const root = document.getElementById("root");
      // 渲染虚拟 DOM：React 18+ 推荐使用 ReactDOM.createRoot 进行元素渲染，不再支持 ReactDOM.render
      ReactDOM.createRoot(root).render(element);
    </script>
  </body>
</html>
```

### 使用脚手架创建 react 项目

我们可以基于 React 进行组件式开发，这种情况下我们一般会使用各种各样的脚手架创建项目，可以是官方脚手架 create-react-app，也可以是其他构建工具如 vite 提供的脚手架。

```bash
# 官方脚手架：方式一
npm install -g create-react-app # 全局下载工具
create-react-app react-admin # 下载项目模板
cd react-admin
npm start

# 官方脚手架：方式二
npx create-react-app my-app
cd my-app
npm start
npm run eject # 暴露配置项，之后可以进行 webpack 配置
```

观察控制台，若可以看到 yarn 的相关指令说明安装成功，可以 npm/yarn 启动后访问对应端口，脚手架一般包含初始 index.html, App.jsx 以及相关配置目录等内容，不同的脚手架具体位置也不尽相同：

- `config/webpack.config.js` 中包含了一系列配置，包括入口文件，html 模板等，其中 `src/index.js` 为入口文件，`public/index.html` 为页面模板
- 在入口文件 `src/index.js` 中，我们可以看到其依赖了 React 和 ReactDOM，ReactDOM 会绘制虚拟 DOM 并转化为 tag 插入到选择器选中的节点中
  - React 负责逻辑控制：数据 -> VDOM
  - ReactDOM 负责渲染实际的 DOM，VDOM -> DOM
  - React 通过 jsx 来描述 UI
  - babel-loader 把 jsx 编译为对应的 js，React.createElement 再把这个 js 对象构造成 React 需要的虚拟 DOM

# JSX 简介

JSX 全称为 JavaScript XML，是 React 定义的一种类似 XML 的 JavaScript 语法扩展，其本质是 `React.createElement(component, props, ...children)` 方法的语法糖。在标准 JS 中，我们只能使用 React.createElement 创建虚拟 DOM，但通过 JSX 语法，则可以直接在 JS 代码中使用 HTML 代码片段来创建虚拟 DOM，babel 之类的库会自动为我们转化。官方建议在 React 中配合使用 JSX，JSX 可以简化创建虚拟 DOM，同时由于其是 js 和 html 混用的一种语法，使得我们可以很好地描述 UI 应该呈现出它应有交互的本质形式。

## 虚拟 DOM 与真实 DOM 对比

虚拟 DOM 的本质是 Object 类型的对象，其相比真实 DOM 更加轻量级，因为虚拟 DOM 是在 React 内部使用，无需真实 DOM 上那么多的属性，因此其比起真实 DOM 更加高效。React 最终会将虚拟 DOM 转化为真实 DOM 并呈现在页面上。

## 在 jsx 中嵌入表达式

- 例如下述例子，定义变量 name，遇到 `h1` 则解析为 html 然后在内部遇到 `{` 又进一步解析为 js，可以引用 name

```jsx
const name = "hao";
const element = <h1>Hello, {name}</h1>;

ReactDOM.render(element, document.getElementById("root"));
```

- 大括号内可以放置任何合法的 js 表达式，因此也可以直接填写一个变量或者调用函数取得返回值

# 元素渲染

- React 元素是构成 React 应用的最小砖块，与浏览器的 DOM 元素不同，React 元素是创建开销极小的普通对象，React DOM 会负责更新 DOM 来与 React 元素保持一致
- 想要将一个 React 元素渲染到根 DOM 节点 `div#root` 中，只需把它们一起传入 `ReactDOM.render()`

```jsx
const element = <h1>Hello, world</h1>;
ReactDOM.render(element, document.getElementById("root"));
```

- React 元素是不可变对象。一旦被创建，你就无法更改它的子元素或者属性，因此根据目前已有的知识，更新 UI 唯一的方式是创建一个全新的元素，并将其传入 `ReactDOM.render()`
- 例如下面是一个计时器的例子，setInterval() 在回调函数中，每秒都调用 ReactDOM.render() :

```jsx
function tick() {
  const element = (
    <div>
      <h1>Hello, world!</h1>
      <h2>It is {new Date().toLocaleTimeString()}.</h2>
    </div>
  );
  ReactDOM.render(element, document.getElementById("root"));
}

setInterval(tick, 1000);
```

- React 只更新它需要更新的部分，React DOM 会将元素和它的子元素与它们之前的状态进行比较，并只会进行必要的更新来使 DOM 达到预期的状态

# 4. 组件与 props

- 组件允许你将 UI 拆分为独立可复用的代码片段，并对每个片段进行独立构思
- 组件从概念上类似于 JavaScript 函数，它接受任意的入参（即 “props”，组件的属性都会被收集到 props 中），并返回用于描述页面展示内容的 React 元素
- 注意组件必须以大写字母开头，否则会被当做原生 DOM 标签
- 组件有两种类型：class 组件和 function 组件，现推荐使用 function 组件

## 类组件

- 可以使用 es6 的 class 来定义组件，必须继承 React.Component，现在不再推荐该种方式

```jsx
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```

- class 组件具有额外的特性 : state 和生命周期，以可以动态改变数据
- 但 React16.8 之后引入 Hook，使得函数组件也具有了 state 和声明周期的特性，在这之后，官方推荐使用函数组件

## 函数组件

- 定义组件最简单的方式就是编写 JavaScript 函数 :

```jsx
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}
```

- 该函数是一个有效的 React 组件，因为它接收唯一带有数据的 “props”（代表属性）对象与并返回一个 React 元素
- 这类组件被称为“函数组件”，因为它本质上就是 JavaScript 函数
- 注意，当时用该组件时 `<Welcome prop1="val1" ... />`，填写的属性会被收集到 props 中
- 最开始的函数组件无状态，但从 React 16.8 开始引⼊入了 hooks，函数组件也能够拥有状态，因此后续都推荐采用函数组件 + hook 的方式创建组件
- 提示: 如果你熟悉 React class 的⽣生命周期函数，你可以把 useEffect Hook 看做 componentDidMount，componentDidUpdate 和 componentWillUnmount 这三个函数的组合

## 渲染组件

- 要渲染我们自定义的组件，只需将其作为标签传递给 ReactDOM.render 函数即可，注意要提供需要的属性
- 例如对于 4.1 中定义的 Welcome 组件我们可以这样渲染 :

```jsx
const element = (
  <div>
    <Welcome name="hao" />
  </div>
);
ReactDOM.render(element, document.getElementById("root"));
```

## 4.3 组合和抽取组件

- 组件内部可以引用其他组件，这使得我们可以抽取任意层次的组件，然后按一定的关系组装起来，构成最终页面
- 在 React 应用程序中，按钮，表单，对话框甚至整个屏幕的内容，通常都会以组件的形式表示
- 例如，我们可以定义一个 App 组件，然后在其内部多次引用 Welcome 组件，最终渲染 App 组件 :

```jsx
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

function App() {
  return (
    <div>
      <Welcome name="cat" />
      <Welcome name="dog" />
      <Welcome name="pig" />
    </div>
  );
}

ReactDOM.render(<App />, document.getElementById("root"));
```

- 很显然，通过组件，我们达到了复用的目的
- 一般来说，在 React 项目中，我们需要将页面拆分为多个细小的组件，以达到复用结构的目的，而变化的内容则通过 props 提供

## 4.4 props 的只读性

- 组件无论是使用函数声明还是通过 class 声明，都决不能修改自身的 props
- 所有 React 组件都必须像纯函数一样保护它们的 props 不被更改

# 5. state 与生命周期

## 5.1 state 概述

- 在前面的例子中，我们通过重复调用 ReactDOM.render() 来修改我们想要渲染的元素，但组件自身无法调用渲染代码，因此我们需要一个能存储变化数据的地方，这就是 state
- 没有引入 Hook 以前，只有在类组件中才能使用 state，也只有类组件才具有生命周期函数
- 一般，我们会在构造函数中初始化 state，然后可能配合生命周期函数初始化一些其他内容，配合使用构造函数、state、生命周期函数可以达到强大的功能
- React 会读取到 state 的变化，然后自动重新 render 组件
- 以前面的动态更新时间为例，我们封装一个 Clock 组件，state 内部维护日期，并在生命周期函数中调用定时器来定时刷新 state 中的日期 :

```jsx
class Clock extends React.Component {
  constructor(props) {
    super(props);
    // 定义 state
    this.state = { date: new Date() };
  }

  // 更新 state 中 date 的方法
  tick() {
    // 更新 state 中的 date，React 发现 state 中的数据发生变化后会自动重新渲染
    this.setState({
      date: new Date(),
    });
  }

  // 生命周期方法 : 在组件已经被渲染到 DOM 中后调用
  componentDidMount() {
    // 设置计时器
    this.timerId = setInterval(() => this.tick(), 1000);
  }

  // 生命周期方法 : 组件被卸载前调用
  componentWillUnmount() {
    // 清除计时器
    clearInterval(this.timerId);
  }

  render() {
    return (
      <div>
        <h1>Hello, world!</h1>
        <h2>It is {this.state.date.toLocaleTimeString()}.</h2>
      </div>
    );
  }
}

ReactDOM.render(<Clock />, document.getElementById("root"));
```

## 5.2 正确使用 State

- 不要直接修改 state，而是应该使用 setState() : `this.setState({comment: 'Hello'});`
- 构造函数是唯一可以给 this.state 赋值的地方
- State 的更新可能是异步的，而且处于性能考虑，React 可能会把多个 setState() 调用合并成一个调用
- 由于 this.props 和 this.state 可能会异步更新，所以你不要依赖他们的值来更新下一个状态
- state 的更新会被合并，即不会完全替换 state

## 5.3 数据流是向下流动的

- 不管是父组件或是子组件都无法知道某个组件是有状态的还是无状态的，并且它们也并不关心它是函数组件还是 class 组件
- 因此 state 称为局部或封装，因为除了拥有它的组件，其他组件都无法访问
- 组件可以将它的 state 作为 props 传递到子组件中，这样子组件会在 props 中接收到参数，但是子组件本身无法知道它是来自于父组件的 state 还是手动输入的 props
- 这种数据流动方式成为“自上而下”或是“单向”的数据流，任何 state 总是属于特定的组件，且只能影响低于他们的组件

# 6. 事件处理

- React 元素的事件处理和 DOM 元素的很相似，但是有一点语法上的不同 :
  - React 事件的命名采用小驼峰式（camelCase），而不是纯小写
  - 使用 JSX 语法时你需要传入一个函数作为事件处理函数，而不是一个字符串

```jsx
<button onClick={activateLasers}>Activate Lasers</button>
```

- React 中另一个不同点是你不能通过返回 false 的方式阻止默认行为。你必须显式的使用 preventDefault :

```jsx
function ActionLink() {
  function handleClick(e) {
    e.preventDefault();
    console.log("The link was clicked.");
  }

  return (
    <a href="#" onClick={handleClick}>
      Click me
    </a>
  );
}
```

- 使用 React 时，你一般不需要使用 addEventListener 为已创建的 DOM 元素添加监听器，事实上，你只需要在该元素初始渲染的时候添加监听器即可
- 在 class 组件中，通常会将事件处理函数单独抽象成 class 的方法，然后在定义元素时在属性中设置对应的处理函数即可
- 例如，下述 Toggle 组件会渲染一个让用户切换开关状态的按钮 :

```jsx
class Toggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = { isToggleOn: true };

    // 为了在回调中使用 `this`，这个绑定是必不可少的
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.setState((state) => ({
      isToggleOn: !state.isToggleOn,
    }));
  }

  render() {
    return (
      <button onClick={this.handleClick}>
        {this.state.isToggleOn ? "ON" : "OFF"}
      </button>
    );
  }
}

ReactDOM.render(<Toggle />, document.getElementById("root"));
```

- 注意，在 js 中 class 的方法默认不会绑定 this，如果忘记绑定 this.handleClick 并将其传入了 onClick，此时调用这个函数时 this 的值为 undefined
- 这并不是 React 特有的行为；这其实与 JavaScript 函数工作原理有关，通常情况下，如果你没有在方法后面添加 ()，例如 `onClick={this.handleClick}`，你应该为这个方法绑定 this，因为前面的代码并没有调用，本质是传递了一个没有绑定 this 的函数
- 如果觉得使用 bind 很麻烦，可以使用实验性的 public class fields 语法，其写法很像箭头函数

```jsx
class LoggingButton extends React.Component {
  // 此语法确保 `handleClick` 内的 `this` 已被绑定。
  // 注意: 这是 *实验性* 语法。
  handleClick = () => {
    console.log("this is:", this);
  };

  render() {
    return <button onClick={this.handleClick}>Click me</button>;
  }
}
```

# 7. 条件渲染

- 在 React 中，你可以创建不同的组件来封装各种你需要的行为。然后，依据应用的不同状态，你可以只渲染对应状态下的部分内容
- 利用 if else 进行条件渲染，例如下面示例根据 isLoggedIn 的值来渲染不同的问候语

```jsx
function Greeting(props) {
  const isLoggedIn = props.isLoggedIn;
  if (isLoggedIn) {
    return <UserGreeting />;
  }
  return <GuestGreeting />;
}

ReactDOM.render(
  // Try changing to isLoggedIn={true}:
  <Greeting isLoggedIn={false} />,
  document.getElementById("root")
);
```

- 利用 && 运算符，可以很方便地进行条件渲染，前面为一个逻辑条件，如果为 true 则渲染后面的代码，否则由于 && 运算符的短路特性，不会渲染后面的代码
- 此外也可以利用三目运算符 `condition ? true : false` 进行条件渲染，其本质就是 if else
- 阻止组件渲染 : 让 render 方法直接返回 null，从而不进行任何渲染

# 8. 列表 & Key

## 8.1 列表

- 在 js 中，我们通常利用 map 转化列表
- 对于纯数据数组，我们利用 map 组装成对应的结构，存储到一个变量中，然后在渲染时直接使用该变量即可

```jsx
const numbers = [1, 2, 3, 4, 5];
const listItems = numbers.map((number) => <li>{number}</li>);

ReactDOM.render(<ul>{listItems}</ul>, document.getElementById("root"));
```

## 8.2 key

- key 帮助 React 识别哪些元素改变了，比如被添加或删除。因此你应当给数组中的每一个元素赋予一个确定的标识
- 一个元素的 key 最好是这个元素在列表中拥有的一个独一无二的字符串。通常，我们使用数据中的 id 来作为元素的 key

```jsx
const todoItems = todos.map((todo) => <li key={todo.id}>{todo.text}</li>);
```

- 当元素没有确定 id 的时候，万不得已你可以使用元素索引 index 作为 key :

```jsx
const todoItems = todos.map((todo, index) => (
  // Only do this if items have no stable IDs
  <li key={index}>{todo.text}</li>
));
```

- 如果列表项目的顺序可能会变化，我们不建议使用索引来用作 key 值，因为这样做会导致性能变差，还可能引起组件状态的问题，如果你选择不指定显式的 key 值，那么 React 将默认使用索引用作为列表项目的 key 值
- key 应该在数组的上下文中被指定，一个好的经验法则是：在 map() 方法中的元素需要设置 key 属性

# 9. 表单 & 受控组件

- 表单元素内部通常需要保持一些内部的 state，用于控制表单项的值，这些表单项即为受控组件

## 9.1 受控组件

- 在 HTML 中，表单元素 input, textarea, select 通常自己维护 state，并根据用户输入进行更新
- 但在 React 中，可变状态通常保存在组件的 state 中，并只能通过 setState 进行更新
- 我们可以将两者结合起来，使得 React 的 state 称为唯一数据源，渲染表单的 React 组件还控制这用户输入过程表单大圣的操作，这种 React 控制的输入元素就称作受控组件
- 受控组件通常对应一个 handleChange，当用户输入时，handleChange 响应到变化，将最新的 value 设置到 state 中，而组件 state 一改变则自动渲染到受控组件的显示值
- 例如下面例子，姓名的输入框的 value 直接设置为 state 中的 value，handleChange 方法处理用户输入，并将最新的值同步到 state 中的 value 中 :

```jsx
class NameForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { value: "" };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({ value: event.target.value });
  }

  handleSubmit(event) {
    alert("提交的名字: " + this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          名字:
          <input
            type="text"
            value={this.state.value}
            onChange={this.handleChange}
          />
        </label>
        <input type="submit" value="提交" />
      </form>
    );
  }
}
```

- input, textarea, select 等含有输入性质的元素都可以通过上述方式变为受控组件
- 但 type=file 的 input，其 value 只读，因此是一个非受控组件，将在后文继续讨论
- 在受控组件上指定 value 可以阻止用户更改输入，value 即为指定值，但如果指定了 value 却仍然可以修改值，则可能是不小心将 value 设置为 null 或者 undefined 导致的
- 有时使用受控组件会很麻烦，因为你需要为所有的输入框编写 handleChange 函数，某些情况下你可能想要使用非受控组件，非受控组件的表单数据由 DOM 管理，React 只在需要提交时获取到其 value 后提交
- 一般使用非受控组件会先在构造函数中定义一个组件容器 `this.input = React.createRef();`，然后在对应的输入元素上使用 ref 指定 : `<input type="text" ref={this.input} />`，最后提交时，直接通过容器获取到元素的值即可 : `this.input.current.value`

# 10. 状态提升

- 通常，多个组件需要反映相同的变化数据，这时我们建议将共享状态提升到最近的共同父组件中去
- 在 React 应用中，任何可变数据应当只有一个相对应的唯一“数据源”。通常，state 都是首先添加到需要渲染数据的组件中去。然后，如果其他组件也需要这个 state，那么你可以将它提升至这些组件的最近共同父组件中。你应当依靠自上而下的数据流，而不是尝试在不同组件间同步 state
- 虽然提升 state 方式比双向绑定方式需要编写更多的“样板”代码，但带来的好处是，排查和隔离 bug 所需的工作量将会变少。由于“存在”于组件中的任何 state，仅有组件自己能够修改它，因此 bug 的排查范围被大大缩减了。此外，你也可以使用自定义逻辑来拒绝或转换用户的输入
- 例如下面的华氏温度、摄氏温度转化的例子 :

```jsx
// f -> c
function toCelsius(fahrenheit) {
  return ((fahrenheit - 32) * 5) / 9;
}

// c -> f
function toFahrenheit(celsius) {
  return (celsius * 9) / 5 + 32;
}

// 字符串温度转换函数
function tryConvert(temperature, convert) {
  const input = parseFloat(temperature);
  if (Number.isNaN(input)) {
    return "";
  }
  const output = convert(input);
  const rounded = Math.round(output * 1000) / 1000;
  return rounded.toString();
}

// 判断摄氏温度沸腾组件
function BoilingVerdict(props) {
  if (props.celsius >= 100) {
    return <p>The water would boil.</p>;
  }
  return <p>The water would not boil.</p>;
}

const scaleNames = {
  c: "Celsius",
  f: "Fahrenheit",
};

// 温度输入框组件
class TemperatureInput extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    this.props.onTemperatureChange(e.target.value);
  }

  render() {
    const temperature = this.props.temperature;
    const scale = this.props.scale;
    return (
      <fieldset>
        <legend>Enter temperature in {scaleNames[scale]}:</legend>
        <input value={temperature} onChange={this.handleChange} />
      </fieldset>
    );
  }
}

class Calculator extends React.Component {
  constructor(props) {
    super(props);
    this.handleCelsiusChange = this.handleCelsiusChange.bind(this);
    this.handleFahrenheitChange = this.handleFahrenheitChange.bind(this);
    // 保存最新输入的温度值和单位
    this.state = { temperature: "", scale: "c" };
  }

  // 处理摄氏温度变化的函数，传递给子组件用于同步最新输入
  handleCelsiusChange(temperature) {
    this.setState({ scale: "c", temperature });
  }

  // 处理华氏温度变化的函数，传递给子组件用于同步最新输入
  handleFahrenheitChange(temperature) {
    this.setState({ scale: "f", temperature });
  }

  render() {
    const scale = this.state.scale;
    const temperature = this.state.temperature;
    // 只有其中一个会做转化
    const celsius =
      scale === "f" ? tryConvert(temperature, toCelsius) : temperature;
    const fahrenheit =
      scale === "c" ? tryConvert(temperature, toFahrenheit) : temperature;

    // 最终根据摄氏度判断是否沸腾
    return (
      <div>
        <TemperatureInput
          scale="c"
          temperature={celsius}
          onTemperatureChange={this.handleCelsiusChange}
        />
        <TemperatureInput
          scale="f"
          temperature={fahrenheit}
          onTemperatureChange={this.handleFahrenheitChange}
        />
        <BoilingVerdict celsius={parseFloat(celsius)} />
      </div>
    );
  }
}

ReactDOM.render(<Calculator />, document.getElementById("root"));
```

# 11. 组合 & 继承

- React 有十分强大的组合模式，我们推荐使用组合而非继承来实现组件间的代码重用
- 有些组件我们无法提前知道它子组件的具体内容，在侧边栏、包裹层等展现通用容器的组件中特别容易遇到这种情况，此时我们可以利用特殊的 children 属性来将子组件渲染到结果中
- 例如下述代码，我们定义 FancyBorder 组件并使用了 props.children 属性，其就表示使用 FancyBorder 组件时期内部的所有不确定内容

```jsx
function FancyBorder(props) {
  return (
    <div className={"FancyBorder FancyBorder-" + props.color}>
      {props.children}
    </div>
  );
}
```

- 对于组件的特例，也是推荐使用组合进行复用，而不推荐使用继承
