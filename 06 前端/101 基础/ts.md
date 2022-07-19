
# 1. 概述

## 简介

- TypeScrip（ts） 是 JavaScript（js） 的超集，添加了新特性，主要添加了为 JS 添加了类型信息，使得编写 JS 和编译器推断更加轻松，减少项目 bug
- 浏览器、node.js 等环境并不支持 ts，因此需要编译，将 ts 编译为 js，以让他们能够运行
- TS 带有具体类型，可以让编译器识别语法错误并给出提示，例如下面这个例子为 js 中最常见的语法错误，我们获取的输入框的值都为 string，执行函数后变为字符串拼接，如果添加了类型信息则很大概率能在编译器就捕捉到这种错误
```js
function add(num1, num2) {
    return num1 + num2;
}

// 结果会变成 23 而不是 5，这在 js 中是很常见的
console.log(add('2', '3'));
```
- TypeScript 是添加了类型系统的 JavaScript，适用于任何规模的项目。
- TypeScript 是一门静态类型、弱类型的语言。
- TypeScript 是完全兼容 JavaScript 的，它不会修改 JavaScript 运行时的特性。
- TypeScript 可以编译为 JavaScript，然后运行在浏览器、Node.js 等任何能运行 JavaScript 的环境中。
- TypeScript 拥有很多编译选项，类型检查的严格程度由你决定。
- TypeScript 可以和 JavaScript 共存，这意味着 JavaScript 项目能够渐进式的迁移到 TypeScript。
- TypeScript 增强了编辑器（IDE）的功能，提供了代码补全、接口提示、跳转到定义、代码重构等能力。
- TypeScript 拥有活跃的社区，大多数常用的第三方库都提供了类型声明。
- TypeScript 与标准同步发展，符合最新的 ECMAScript 标准（stage 3）。




## 安装

- 全局安装 ts：`npm install -g typescript`，其会在全局环境安装 `tsc` 命令，安装完成后就可以使用 `tsc` 编译 ts 文件并转化为 js 文件了
- 新建一个目录，创建 hello.ts 文件，编写内容如下：
```ts
function sayHello(person: string) {
    if (typeof person === 'string') {
        return 'Hello, ' + person;
    } else {
        throw new Error('person is not a string');
    }
}

let user = 'Tom';
console.log(sayHello(user));
```
- 之后执行 `tsc hello.ts` 进行编译，即可得到 hello.js 文件，可以执行 `node hello.js` 查看结果
- 如果不想编译，可以使用 `npm install -g ts-node` 命令全局安装 ts-node 后使用 `ts-node hello.ts` 直接执行 ts 文件


# 2. 基础内容

- 类型注解：赋予函数参数、变量一个类型
```ts
function greeter(person: string) {
    return "Hello, " + person;
}
```
- 接口：确保目标对象拥有指定的域以及类型符合条件
- 类：确保指定域以及方法，含有构造函数


# 参考文献

- [《TypeScript 入门教程》](https://ts.xcatliu.com/introduction/index.html)