

- class 组件风格教程

# 1. 项目搭建


## 1.1 使用 react-app 搭建 react 脚手架

- create-react-app 是 react 官方原有提供的用于搭建基于 react+webpack+es6 项目的脚手架，我们基于它搭建 react 项目 : `create-react-app client-react`
- 也可直接安装 : `npm init react-app client-react`
- 然后进入项目，启动即可 : `npm start`
- 项目结构 :
    - api : ajax 相关
    - assets : 共用资源
    - components : 非路由组件
    - config : 配置
    - pages : 路由组件
    - utils : 工具模块
    - App.js : 应用根组件
    - index.js : 入口 js
- 修改根组件 App.js 为只显示简单的文字，index.js 不动，启动测试是否成功
```js
import React, {Component} from 'react'

/**
 * 应用根组件
 */
class App extends Component {

  render() {
    return (
        <div>App</div>
    )
  }
}

export default App;
```

## 1.2 引入 and 并配置按需打包和自定义主题

- 引入 ant-d : `yarn add antd`
- 参考 [官方文档](https://ant.design/docs/react/use-with-create-react-app-cn#%E9%AB%98%E7%BA%A7%E9%85%8D%E7%BD%AE) 配置 and-d 的按需打包，首先安装依赖 `yarn add react-app-rewired customize-cra babel-plugin-import less less-loader`，然后修改 package.json 中的 scripts:
```json
"scripts": {
    "start": "react-app-rewired start",
    "build": "react-app-rewired build",
    "test": "react-app-rewired test",
    "eject": "react-scripts eject"
}
```
- 然后在根目录创建一个 `config-overrides.js` 用于修改默认配置，配置内容如下
```js
const {override, fixBabelImports, addLessLoader} = require('customize-cra');

module.exports = override(
    // 针对 antd 实现按需打包：根据 import 来打包（使用 babel-plugin-import）
    fixBabelImports('import', {
        libraryName: 'antd',
        libraryDirectory: 'es',
        style: true, // 自动打包相关的样式
    }),

    // 使用 less-loader 对源码中的 less 的变量进行重新指定，以修改默认主题
    addLessLoader({
        javascriptEnabled: true,
        modifyVars: {'@primary-color': '#1DA57A'},
    }),
);
```
- App.js 引入按钮后查看效果
```js
import React from 'react';
import {Button} from "antd";

function App() {
    return (
        <div>
            App
            <Button type='primary'>Button</Button>
        </div>
    );
}

export default App;
```


## 1.3 配置路由组件

- 首先引入路由依赖 : `yarn add react-router-dom`
- 本项目中的 React 组件分为路由组件和非路由组件，路由组件存储在 pages 目录下，主要涉及页面的跳转，非路由组件主要用于一些功能复用，存储在 components 目录下
- 在 pages 目录下创建用于登录的路由组件 pages/login/login.jsx :
```jsx
import React, {Component} from 'react'

/**
 * 用户登录的路由组件
 */
export default class Login extends Component {
    render () {
        return (
            <div>login</div>
        )
    }
}
```
- 然后创建后台管理主界面的路由组件 pages/admin/admin.jsx :
```jsx
import React, {Component} from 'react'

/**
 * 后台管理主界面的路由组件
 */
export default class Admin extends Component {
    render() {
        return (
            <div>Admin</div>
        )
    }
}
```
- 然后，我们要在 App.js 配置路由和组件的映射，以完成跳转，此处使用 BrowserRouter
```jsx
import React, {Component} from 'react'
import {BrowserRouter, Switch, Route} from 'react-router-dom'

// 引入自定义组件， login 和 admin 都是路由组件
import Login from './pages/login/login'
import Admin from './pages/admin/admin'

/**
 * 应用根组件
 */
class App extends Component {

  render() {
    return (
        <BrowserRouter>
            <Switch>
                <Route path='/login' component={Login}/>
                <Route path='/' component={Admin}/>
            </Switch>
        </BrowserRouter>
    )
  }
}

export default App;
```
- 重新启动项目，访问 / 和 /login 查看效果，若能成功跳转，则项目架子基本搭建完成，接下来就是编码


# 2. Login、Admin 组件的基本内容

**引入全局初始化的 css**

- 提供 public/css/reset.css，并在 public/index.html 中引入，注意一定要引入，不然不生效
```css

```


## 2.1 Login 组件的页面编写

- 首先导入需要的两个图片资源 logo.png 和 bg.jpg 到 login/images 目录下
- 注意静态资源的放置尽量放在与当前组件相关的目录下，例如目前只有 login 组件用到这两个静态资源，因此全都放到当前组件目录下，以后其他组件可能会用到 logo.png，到那时可以将 logo.png 统一存放到 src/assets 下，然后各个组件引用同一个资源即可，而不复用的静态资源尽量自己单独存放，例如 login.less 就只会放置到自己的 login 组件目录下，这样方便自己查找和定位
- 编写 login/login.less 用于控制 login 组件的样式 :
```less
.login {
  width: 100%;
  height: 100%;
  background-image: url('./images/bg.jpg');
  background-size: 100% 100%;
  .login-header {
    display: flex;
    align-items: center;
    height: 80px;
    background-color: rgba(21, 20, 13, 0.5);
    img {
      width: 40px;
      height: 40px;
      margin-left: 50px;
    }
    h1 {
      font-size: 30px;
      color: white;
      margin: 0 0 0 15px;
    }
  }
  .login-content {
    margin: 50px auto;
    width: 400px;
    height: 300px;
    background-color: #fff;
    padding: 20px 40px;
    h3 {
      font-size: 30px;
      font-weight: bold;
      text-align: center;
      margin-bottom: 20px;
    }
    .login-form {
      .login-form-button {
        width: 100%;
      }
    }
  }
}
```
- 然后编写 login/login.jsx 组件，完成页面的基本内容（无交互功能） :
```jsx
// 引入 React 组件
import React, {Component} from 'react'
// 引入 ant-d 组件
import {
    Form,
    Input,
    Icon,
    Button,
} from 'antd'

// 引入静态资源 logo
import logo from './images/logo.png'
// 引入静态资源 less 文件
import './login.less'

// 为方便使用，取出 Form 组件中的 Item 组件
const Item = Form.Item;

/**
 * 用户登录的路由组件
 */
class Login extends Component {
    render() {
        return (
            <div className='login'>
                <header className='login-header'>
                    <img src={logo} alt="logo"/>
                    <h1>React 项目: 后台管理系统</h1>
                </header>
                <section className='login-content'>
                    <h3>用户登陆</h3>
                    <Form onSubmit={this.login} className="login-form">
                        <Item>
                            <Input prefix={<Icon type="user" style={{color: 'rgba(0,0,0,.25)'}}/>}
                                   placeholder=" 用户名"/>
                        </Item>
                        <Item>
                            <Input prefix={<Icon type="lock" style={{color: 'rgba(0,0,0,.25)'}}/>}
                                   type="password" placeholder=" 密码"/>
                        </Item>
                        <Item>
                            <Button type="primary" htmlType="submit" className="login-form-button">
                                登录
                            </Button>
                        </Item>
                    </Form>
                </section>
            </div>
        )
    }
}
export default Login
```
- 重启项目，访问 /login 页面，验证组件和 css 文件的正确性

## 2.2 表单验证

- 由于我们使用 ant-d 提供的表单组件，因此表单的数据收集和验证也会使用该组件提供的 [api](https://ant-design.gitee.io/components/form-cn/)
- ant-d 通过高阶函数为我们自定义的 Login 组件提供 this.props.form 属性，以提供表单的相关操作，并通过高阶函数提供一些功能
- 高阶函数 : 接受一个函数，返回一个新函数，返回的新函数在原函数的基础上添加了功能
- 高阶组件 : 接受一个组件，返回一个新组件，返回的新组件在原组件的基础上添加了功能
- `Form.create()` 返回的结果就是一个高阶组件，其接受我们自定义的 Login 组件 `Form.create()(Login)`，为其添加 this.props.form 属性，然后返回新组件
- `getFieldDecorator('表单项提交时的 name', 校验位则)` 返回的结果就是一个高阶函数，其接收我们定义的 Input 组件 `getFieldDecorator()(<Input .../>)`，为其添加 value 和 onChange 事件，使得该控件的数据同步自动被 form 接管
- 基于上述内容，我们在 Login 的基础上添加表单校验和数据收集功能，代码暂时省略，统一参考完成登录后的页面



## 2.3 封装 ajax 请求并用于登录

- 我们使用 axios 做 ajax 请求，因此先引入依赖 : `yarn add axios`
- 封装 ajax 请求模块，模块功能为给定 url、请求参数、请求类型，快速执行 ajax 请求，因此我们编写 api/ajax.js 文件 :
```js
// 引入 axios 用于 ajax 请求
import axios from 'axios'
// 引入 ant-d 的组件
import {message} from 'antd'

/**
 * 能发送 ajax 请求的函数模块，其基于 axios
 * 该函数的返回值是 promise 对象，而 axios.get()/post() 返回的就是 promise 对象
 * 但我们要返回自己创建的 promise 对象，以便能 :
 *      统一处理请求异常
 *      异步返回结果数据 , 而不是包含结果数据的 response
 * @param url 请求地址
 * @param data 请求参数
 * @param method
 * @returns {Promise<unknown>}
 */
export default function ajax(url, data = {}, method = 'GET') {
    return new Promise(function (resolve, reject) {
        let promise; // 自定义的 promise 对象

        // 执行异步 ajax 请求
        if (method === 'GET') {
            // get 一般不带请求体信息，参数通过路径或路径查询参数传递
            promise = axios.get(url, {params: data}) // params 配置指定的是 query 参数
        } else if (method === 'PUT') {
            promise = axios.put(url, data)
        } else if (method === 'DELETE') {
            // delete 一般不带请求体信息，参数通过路径或路径查询参数传递
            promise = axios.delete(url, {params: data})
        }
        else { // POST 请求
            promise = axios.post(url, data)
        }

        promise.then(response => {
            // 如果请求成功，则调用 resolve(response.data)
            resolve(response.data)
        }).catch(error => { // 对所有 ajax 请求出错做统一处理 , 外层就不用再处理错误了
            // 出错后，服务器有给出响应，则可以直接提示
            if (error.response) {
                let responseData = error.response.data;

                console.log(responseData)

                if (responseData.status === 401) {
                    message.error('登录超时，请刷新页面！');
                } else if (responseData.message) {
                    message.error(responseData.message);
                }
            } else {
                message.error(error.message);
                console.log(error.message);
            }
        })
    })
}

axios.defaults.baseURL = 'http://localhost:8081/api/';
```
- 然后在 ajax 的基础上，在 src/api/index.js 封装便捷请求，每个方法对应一个 http 请求，目前只封装了登录相关的 api，使用的接口为 boot-ssm 项目的接口
```js
// 导入通用 ajax 模块执行 ajax 请求
import ajax from './ajax'

/**
 * 包含 n 个接口请求函数的模块，每个函数返回 promise
 */
const POST = 'POST';

// 登录功能
export const reqLogin = (email, userPass) =>
    ajax('login', {email, userPass}, POST);

// 校验 token
export const reqCheckToken = (userId, loginToken, refreshToken) =>
    ajax('token/check/' + userId + '/' + loginToken + '/' + refreshToken);

// 刷新 token
export const reqRefreshToken = (loginResult) =>
    ajax('token/refresh', loginResult, POST);
```

## 2.4 编写缓存工具 storageUtils

- 主要是 storageUtils, memoryUtils 等，后期可能更改为 redux
- storageUtils 中主要通过 sessionStorage, localStorage, store, redux 等工具存储一些信息共整个系统使用
- 目前暂时使用 store 保存对象，对于 localStroage, sessionStorage 只能保存 string, 如果传递是对象, 会自动调用对象的 toString() 并保存
- 一般如果要使用 localStroage, sessionStorage，在保存对象之前会执行 `JSON.stringify()` 来将对象序列化为字符串
- 我们编写提供保存、读取“登录结果”的方法，登录结果内部包含了 loginToken, refreshToken, userId，用于后续验证身份
- 编写 `src/utils/storageUtils.js` :
```js
import store from 'store'

// key
const LOGIN_RESULT_KEY = 'LOGIN_RESULT_KEY';

/**
 * 包含 n 个操作 local storage 的工具函数的模块
 */
export default {

    // 保存登录结果对象
    saveLoginResult(loginResult) {
        store.set(LOGIN_RESULT_KEY, loginResult);
    },

    // 移除登录结果对象
    removeLoginResult() {
        store.remove(LOGIN_RESULT_KEY);
    },

    // 获取登录结果对象
    getLoginResult() {
        return store.get(LOGIN_RESULT_KEY) || {};
    },

    // 获取登陆结果中的 loginToken
    getLoginToken() {
        return this.getLoginResult()['loginToken'];
    },

    // 获取登陆结果中的 refreshToken
    getRefreshToken() {
        return this.getLoginResult()['refreshToken'];
    },

    // 获取登陆结果中的 userId
    getUserId() {
        return this.getLoginResult()['userId'];
    },
}
```

## 2.5 完成 Login 组件以及自动登录和跳转功能（涉及 Admin 组件部分内容）

- 已经封装玩 ajax 和 storageUtils 后，我们可以为 Login 组件添加交互功能了
- 主要逻辑为 : 
    - 为表单添加 onSubmit 事件，提交前先校验表单
    - 校验通过后，提交登录请求，登录成功后调用 storageUtils 保存登录结果，然后可以跳转到 Admin 组件
    - 注意为了自动跳转，Login 组件要做判断，若检测到存在登录结果，则直接跳转到 Admin 组件
    - Admin 组件对存储的登录结果进行判定，若合法则继续，若 refreshToken 已失效则移除原有登录结果，跳转到 Login 重新登录
- Login 组件完整内容如下 :
```jsx
// 引入 React 组件
import React, {Component} from 'react'
import {Redirect} from 'react-router-dom'
// 引入 ant-d 组件
import {
    Form,
    Input,
    Icon,
    Button,
    message
} from 'antd'

// 引入静态资源 logo
import logo from './images/logo.png'
// 引入静态资源 less 文件
import './login.less'
import {reqLogin} from "../../api";
import memoryUtils from "../../utils/memoryUtils";
import storageUtils from "../../utils/storageUtils";

// 为方便使用，取出 Form 组件中的 Item 组件
const Item = Form.Item;

/**
 * 用户登录的路由组件
 */
class Login extends Component {

    handleSubmit = async (event) => {
        event.preventDefault(); // 阻止默认行为

        // 对所有表单字段进行检验
        this.props.form.validateFields(async (err, values) => {
            // 检验成功
            if (!err) {
                const {email, userPass} = values;
                const result = await reqLogin(email, userPass);

                message.success('登录成功');

                // 保存登录结果
                storageUtils.saveLoginResult(result);

                // 跳转到主页面
                this.props.history.replace('/')
            } else {
                message.info('请正确填写邮箱和密码')
            }
        });
    };

    // 自定义的 userPass 的校验器
    userPassValidator =  (rule, value, callback) => {
        const pwdReg = /^[a-zA-Z0-9_]+$/;

        // 对于自定义的 validator，必须调用 callback
        // callback 如果不传参代表校验成功，如果传参代表校验失败，并且会提示错误
        if (!value) {
            callback('密码不能为空');
        } else if (!pwdReg.test(value)) {
            callback('密码只能包含字母、数字、下划线');
        } else {
            // 校验通过
            callback();
        }
    };

    render() {
        // 判断是否存在登录结果，注意没有时 storageUtils.getLoginResult() 返回的是 {}，因此要判断 userId
        if (storageUtils.getUserId()) {
            return <Redirect to='/'/>;
        }

        // Login 组件自身不带 this.props.form 属性，但经 Form.create() 包装过后则带有该属性
        const {getFieldDecorator} = this.props.form;

        return (
            <div className='login'>
                <header className='login-header'>
                    <img src={logo} alt="logo"/>
                    <h1>React 项目: 后台管理系统</h1>
                </header>
                <section className='login-content'>
                    <h3>用户登陆</h3>
                    <Form onSubmit={this.handleSubmit} className="login-form">
                        <Item>
                            {
                                // getFieldDecorator 是一个高阶函数(返回值是一个函数)
                                // 用法 : getFieldDecorator(标识名称，配置对象)(被包装组件)
                                // 经过 getFieldDecorator 包装的表单控件会自动添加 value 和 onChange，
                                // 数据同步将被 form 接管
                                getFieldDecorator('email', {
                                    rules: [
                                        {required: true, whitespace: true, message: '邮箱不能为空'},
                                        {pattern: /^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,
                                            message: '邮箱格式不正确'}
                                    ]
                                })(
                                    <Input prefix={<Icon type="user" style={{color: 'rgba(0,0,0,.25)'}}/>}
                                           placeholder=" 用户名"/>
                                )
                            }
                        </Item>
                        <Item>
                            {
                                getFieldDecorator('userPass', {
                                    rules: [ // 使用自定义的校验器
                                        {validator: this.userPassValidator}
                                    ]
                                })(
                                    <Input prefix={<Icon type="lock" style={{color: 'rgba(0,0,0,.25)'}}/>}
                                           type="password" placeholder=" 密码"/>
                                )
                            }
                        </Item>
                        <Item>
                            <Button type="primary" htmlType="submit" className="login-form-button">
                                登录
                            </Button>
                        </Item>
                    </Form>
                </section>
            </div>
        )
    }
}

// 经 Form.create() 包装过的组件会自带 this.props.form 属性
export default Form.create()(Login)
```

## 2.6 Admin 组件中涉及的自动登录部分

- 为了完成自动登录功能，还需要在 Admin 组件中编写响应代码，此时 Admin 组件还只有一个简单的文字说明，但已经可以完成自动登录 :
```jsx
import React, {Component} from 'react'
import {Redirect} from 'react-router-dom'
import storageUtils from "../../utils/storageUtils";
import {reqCheckToken, reqRefreshToken} from "../../api";
import {message} from "antd";

/**
 * 后台管理主界面的路由组件
 */
export default class Admin extends Component {

    // 构造函数
    constructor(props) {
        super(props);
        this.state = {hasLogin : true}; // 已登录
    }

    // 首次挂载时的初始化
    componentDidMount() {
        this.checkHasLogin().then(null);
    }

    async checkHasLogin() {
        const {userId, loginToken, refreshToken} = storageUtils.getLoginResult();

        // token 或 userId 不存在，重新登录
        if (!userId) {
            console.log('no login')
            await this.setState({hasLogin: false})
            return;
        }

        // 校验 token 合法性
        const tokenCheck = await reqCheckToken(userId, loginToken, refreshToken)

        // loginToken, refreshToken 的校验结果按位组合
        let res = parseInt(tokenCheck.message); // 响应结果为 0, 1, 2, 3
        if (res < 2) { // < 2 表示 refresh token 不行，需要重新登录
            return this.setState({hasLogin: false});
        } else if (res === 2){ // 2 表示 refresh token 合法，但需要刷新
            // 刷新 token 并重新保存
            try {
                // 刷新 token 成功，重新设置
                const refreshResult = await reqRefreshToken(storageUtils.getLoginResult())
                // 重新保存 token
                storageUtils.saveLoginResult(refreshResult);
                return this.setState({hasLogin: true});
            } catch (error) {
                // 刷新 token 失败，重定向到 login
                return this.setState({hasLogin: false});
            }
        }
    }

    render () {

        const {hasLogin} = this.state;

        if (!hasLogin) {
            // 移除登录结果
            storageUtils.removeLoginResult();
            message.error('登录超时，请重新登录');
            return <Redirect to='/login'/>;
        }

        // 取出 userId
        let userId = storageUtils.getUserId();

        return (
            <div>
                <h2>后台管理</h2>
                <div>Hello, {userId}</div>
            </div>
        )
    }
}
```

## 2.7 目前为止，完成 Login 组件以及 Admin 的自动登录部分，接下来开始编写 Admin 组件


# 3. 完成 Admin 组件与二级路由

## 3.1 Admin 概述

- Admin 组件内部包含 4 个组件，分别是 LeftNav, Header, Footer 以及主体部分
- 其中主体部分的内容不是固定的，而是根据点击 LeftNav 菜单在主题部分显示对应的组件，这需要一个 Admin 内部的子路由进行控制
- 需要注意，LeftNav, Header, Footer 这三个组件不涉及路由跳转，因此不是路由组件，我们放置在 components 中
- 对于主体部分涉及的组件，主要和功能模块一一对应，而且这些组件涉及到二级路由跳转，也属于路由组件
- 本章的接下来主要逐步完成 LeftNav, Header, Footer, Admin 组件路由部分的编写，主体和功能部分留到下一章

**Layout 布局**

- and-d 提供了 [Layout 组件](https://ant-design.gitee.io/components/layout-cn/) 用于布局，其提供了常用布局，且内部提供了常用的 Header, Content, Footer, Sider 组件
- 我们的 Admin 组件使用利用 Layout 进行布局，并用到了其内部的 Footer, Sider, Content，但 Header 组件我们是自己编写的
- 我们的 LeftNav 组件包含在 Sider 内部，这样导航栏就会自动靠左变为导航栏，我们只需编写简单的样式即可完成导航栏编写
- 主题的内容则包含在 Content 内部，这样布局就自动完成了，我们只需编写对应组件，放置在对应的布局组件内部

**Admin 布局部分代码**

```jsx
// 省略了原有的部分依赖
import {Layout, message} from "antd";
import Header from '../../components/header'
import LeftNav from '../../components/left-nav'

const { Footer, Sider, Content } = Layout;

/**
 * 后台管理主界面的路由组件
 */
export default class Admin extends Component {

    // 省略了其他内容

    render () {

        // 省略了自动登录的代码

        return  (
            /*采用经典的左右布局，右边又划分为上中下*/
            <Layout style={{height: '100%'}}>
                <Sider> {/*Layout.Sider 内部的内容将自动变为导航栏*/}
                    <LeftNav/> {/*LeftNav 为自定义组件，编写导航栏的具体内容*/}
                </Sider>
                <Layout>
                    <Header>Header</Header> {/*此处的 Header 是自定义的 Header 而不是 Layout 提供的 Header*/}
                    {/*Layout.Content 内部为主体内容，主要放置二级路由组件*/}
                    <Content style={{backgroundColor: 'white'}}>Content {userId}</Content>
                    {/*Layout.Footer 为页脚*/}
                    <Footer style={{textAlign: 'center', color: '#aaaaaa'}}>推荐使用谷歌浏览器，
                        可以获得更佳页面操作体验</Footer>
                </Layout>
            </Layout>
        )
    }
}
```
- 有了上述布局代码后，我们后续将在其基础上完成各个成分


## 3.2 Admin 组件的子路由搭建

- 除了非路由组件 LeftNav, Header, Footer 外，Admin 内部的 Content 部分的内部应该放置路由组件
- 而且其应该属于二级路由，根据左侧 LeftNav 的点击，在 Content 展示对应的组件
- 根据 boot-ssm 的业务和接口，我们暂时划分出下述业务和对应路由 :
    - Home 页面 : /home 或 /
    - 分类管理 : /category
    - 商品管理 : 商品管理内部又是一个子路由，即三极路由
        - 主页 : /item/home
        - 添加修改商品 : /item/addOrUpdate
        - 商品详情 : /item/detail
    - 角色管理 : /role
    - 用户管理 : /user
    - 图标界面 : /chart/bar, /chart/pie, /chart/line
- 根据上述路由，我们在 pages 中定义对应的路由组件 : 
    - home/home.jsx
    - category/category.jsx, 
    - item :
        - item/home.jsx
        - item/add-update.jsx
        - item/detail.jsx
    - home/home.jsx
    - user/user.jsx
    - chart/bar.jsx, chart.pie.jsx, chart/line.jsx
- 为了需要，可能还要抽象细化组件，在添加到路由组件中
- 我们先定义出这些二级路由组件，然后在 Admin 的 Content 中填入这些路由组件，主要包括 home/home.jsx, category/category.jsx, item/item.jsx, role/role.jsx, user/user.jsx, chart/bar.jsx, chart/line.jsx, chart/pie.jsx，每个组件的内容目前大致如下 :
```jsx
import React from 'react';

export default class Home {
    render() {
        return (
            <div>Home</div>
        );
    }
}
```
- 然后，我们在 Admin 组件的 Content 内部注册路由，让该块内容根据 url 显示对应的组件
```jsx
<Content style={{backgroundColor: 'white'}}>
    <Switch>
        <Route path='/home' component={Home}/>
        <Route path='/category' component={Category}/>
        <Route path='/item' component={Item}/>
        <Route path='/role' component={Role}/>
        <Route path='/user' component={User}/>
        <Route path='/charts/bar' component={Bar}/>
        <Route path='/charts/line' component={Line}/>
        <Route path='/charts/pie' component={Pie}/>
        <Redirect to='/home' />
    </Switch>
</Content>
```
- 自此我们已经完成路由搭建，但由于左侧导航栏还没实现，因此只能在浏览器地址栏手动输入地址测试能否正常路由跳转
- 接下来 Admin 就剩余 LeftNav, Header, Home 组件待完成


## 3.3 完成 LeftNav 导航栏组件

- 导航栏为非路由组件，通过放置在 Admin 中的 Layout.Sider 内部以作为导航栏，我们将非路由组件放置在 components 中
- 我们利用 ant-d 的提供的 Menu, SubMenu, Menu.Item 组件来完成导航栏的编写，三者分别表示 : 最外层菜单、子菜单、菜单项
- 注意对于二级菜单，要先使用 SubMenu，然后将 Menu.Item 放置在 SubMenu 中，三级菜单项同理
- 总结就是 : Menu 内部可以放置 SubMenu 和 Menu.Item，SubMenu 内部可以进一步放置 SubMenu 和 Menu.Item
- LefNav 内部要使用到路径信息以展开子菜单以及选中对应的菜单项，要获取路径信息则要用到提供的高阶组件 withRouter()
- `withRouter(LeftNav)` : 该高阶组件向被包装组件传递 history/location/match 属性（在 this.props 中）
- Menu 提供 defaultOpenKeys, defaultSelectedKeys 来展开和选中初始的菜单，其他属性可以查看文档
- 为了方便，我们先将菜单的数据信息存储在 config/menuConfig.js 中，后期可能改为从服务端动态获取 :
```js
const menuList = [
  {
    title: '首页', // 菜单标题名称
    key: '/home', // 对应的path
    icon: 'home', // 图标名称
    isPublic: true, // 公开的
  },
  {
    title: '商品',
    key: '/items',
    icon: 'appstore',
    children: [ // 子菜单列表
      {
        title: '品类管理',
        key: '/category',
        icon: 'bars'
      },
      {
        title: '商品管理',
        key: '/item',
        icon: 'tool'
      },
    ]
  },

  {
    title: '用户管理',
    key: '/user',
    icon: 'user'
  },
  {
    title: '角色管理',
    key: '/role',
    icon: 'safety',
  },

  {
    title: '图形图表',
    key: '/charts',
    icon: 'area-chart',
    children: [
      {
        title: '柱形图',
        key: '/chart/bar',
        icon: 'bar-chart'
      },
      {
        title: '折线图',
        key: '/chart/line',
        icon: 'line-chart'
      },
      {
        title: '饼图',
        key: '/chart/pie',
        icon: 'pie-chart'
      },
    ]
  },

  {
    title: '订单管理',
    key: '/order',
    icon: 'windows',
  },
];

export default menuList
```

## 3.4 抽取 LinkButton 组件

- Header 组件中要用到链接样式的按钮，而其他许多组件中也可能用到这种按钮，因此将其抽取出来形成组件
- 编写 components/link-button/index.less 样式文件 :
```less
.link-button {
  border: none;
  outline: none;
  background-color: transparent;
  color: #1DA57A;
  cursor: pointer;
}
```
- 然后编写 components/link-button/index.jsx 文件 :
```jsx
import React from 'react'
import './index.less'

/**
 * 看起来像链接的 Button 组件
 * @param props
 * @returns {*}
 * @constructor
 */
export default function LinkButton (props) {
    return <button {...props} className='link-button'></button>
}
```

## 3.5 完成自定义 Header 组件

- 注意我们使用自定义的 Header 组件而不是 ant-d 提供的 Header 组件
- 自定义 Header 组件主要包含下述内容 :
    - 右侧登录信息展示用户名 : 获取当前登录用户信息，并存储在缓存中，然后取出展示
    - 右侧退出登录按钮 : 为按钮添加事件函数并完成功能
    - 根据当前点击的导航栏在标题显示对应的标题 : 根据 path 从导航栏元数据中找到对应的标题并展示
    - 定时刷新系统时间 : 定义定时器并定时显示时间
    - 请求并显示天气信息 : jsonp 获取天气信息并展示


### 3.5.1 jsonp 与获取天气 api

- 先引入 json : `yarn add jsonp`
- 我们使用 [百度地图天气预报在线接口](http://api.map.baidu.com/telematics/v3/weather?location=xxx&output=json&ak=3p49MVra6urFRGOT9s8UBWr2) 作为获取天气的 api，改接口基于 jsonp 请求，因此我们先在 api/index.js 中定义请求接口，注意不再使用 axios 封装的 ajax.js 模块而是使用 jsonp 模块
```js
import jsonp from 'jsonp'

// 省略其他 req 方法

// 通过 jsonp 请求获取天气信息
export function reqWeather(city) {
    const url = `http://api.map.baidu.com/telematics/v3/weather?location=${city}&output=json&ak=3p49MVra6urFRGOT9s8UBWr2`
    return new Promise((resolve, reject) => {
        jsonp(url, {
            param: 'callback'
        }, (error, response) => {
            if (!error && response.status === 'success') {
                const {dayPictureUrl, weather} = response.results[0].weather_data[0]
                resolve({dayPictureUrl, weather})
            } else {
                reject('获取天气信息失败');
            }
        })
    })
}
```

### 3.5.2 dateUtils 工具及 Admin 组件页面微调

- 标题要用到格式化时间函数，在 src/utils/dateUtils.js 文件添加下述内容:
```js
// 格式化日期
export function formateDate(time) {
    if (!time) return '';
    let date = new Date(time);
    return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate()
        + ' ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
}
```
- 微调 Admin 组件中的 Content 组件的 margin 以突出标题中的三角箭头，Content 组件用于显示主体信息的
```jsx
<Content style={{backgroundColor: 'white', margin: '20px 20px 0'}}>
```

### 3.5.3 编写样式文件 components/header/index.less

```less
.header {
  height: 80px;
  background-color: #fff;

  .header-top {
    height: 40px;
    line-height: 40px;
    text-align: right;
    padding-right: 20px;
    border-bottom: 1px solid #1DA57A;
  }

  .header-bottom {
    display: flex;
    align-items: center;
    height: 40px;

    .header-bottom-left {
      position: relative;
      width: 25%;
      font-size: 20px;
      text-align: center;

      &::after {
        content: '';
        position: absolute;
        top: 30px;
        right: 50%;
        transform: translateX(50%);
        border-top: 20px solid white;
        border-right: 20px solid transparent;
        border-bottom: 20px solid transparent;
        border-left: 20px solid transparent;
      }
    }

    .header-bottom-right {
      width: 75%;
      text-align: right;
      margin-right: 30px;

      img {
        width: 30px;
        height: 20px;
        margin: 0 15px;
      }
    }
  }
}
```

### 3.5.4 编写 Header 组件，即 components/header/index.jsx 文件

- 前面提到的所有功能都在该组件中编写，注意阅读注释
```jsx
import React, {Component} from 'react'
import {Modal} from 'antd'
import {withRouter} from 'react-router-dom'
import LinkButton from '../link-button'
import menuList from '../../config/menuConfig'
import {reqWeather} from '../../api'
import {formateDate} from '../../utils/dateUtils'
import memoryUtils from '../../utils/memoryUtils'
import storageUtils from '../../utils/storageUtils'
import './index.less'


/**
 * 头部组件
 */
class Header extends Component {
    state = {
        sysTime: formateDate(Date.now()), // 系统时间
        dayPictureUrl: '', // 天气图片的 url
        weather: '' // 天气状态
    };

    // 发异步 ajax 获取天气数据并更新状态
    initWeather = async () => {
        const {dayPictureUrl, weather} = await reqWeather(' 北京')
        this.setState({
            dayPictureUrl,
            weather
        })
    };

    // 启动循环定时器 , 每隔 1s 更新一次 sysTime
    initSysTime = () => {
        this.intervalId = setInterval(() => {
            this.setState({
                sysTime: formateDate(Date.now())
            })
        }, 1000)
    };

    // 退出登陆
    logout = () => {
        Modal.confirm({
            content: ' 确定退出吗?',
            onOk: () => {
                // 移除保存的 user
                storageUtils.removeLoginResult();
                memoryUtils.user = {}; // 同时删除 memoryUtils 中的缓存
                // 跳转到 login
                this.props.history.replace('/login')
            },
            onCancel() {
                // 取消则什么也不做
            },
        })
    };

    // 根据请求的 path 得到对应的标题
    getTitle = (path) => {
        let title = '';
        menuList.forEach(menu => {
            if(menu.key===path) {
                title = menu.title
            } else if (menu.children) {
                menu.children.forEach(item => {
                    if(path.indexOf(item.key)===0) {
                        title = item.title
                    }
                })
            }
        });
        return title;
    };

    // 生命周期函数，在首次 render 之后会调用一次
    componentDidMount () {
        this.initSysTime(); // 初始化时间信息
        this.initWeather().then(null); // 初始化天气信息
    }

    // 生命周期函数 : 关闭前的清除
    componentWillUnmount () {
        // 清除定时器
        clearInterval(this.intervalId)
    }
    
    render() {
        const {sysTime, dayPictureUrl, weather} = this.state;
        // 得到当前用户（已登录则已经得到初始化）
        const user = memoryUtils.user;
        // 得到当前请求的路径
        const path = this.props.location.pathname;
        // 根据路径，在元数据中搜索到对应的标题，并在页面显示
        const title = this.getTitle(path);
        return (
            <div className="header">
                <div className="header-top">
                    <span>欢迎, {user.userName}</span>
                    <LinkButton onClick={this.logout}>退出</LinkButton>
                </div>
                <div className="header-bottom">
                    <div className="header-bottom-left">{title}</div>
                    <div className="header-bottom-right">
                        <span>{sysTime}</span>
                        <img src={dayPictureUrl} alt="weather"/>
                        <span>{weather}</span>
                    </div>
                </div>
            </div>
        )
    }
}

export default withRouter(Header);
```


## 3.6 完成 Home 页面

- Home 页面只展示最基本的信息
- src/pages/home.less 文件 :
```less
.home{
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
}
```
- Home 组件无其他内容，只展示一下文字，主要是为了帮助 Admin 的布局，其放置在 Admin 的 Content 组件中
```jsx
import React from 'react';
import './home.less';

/**
 * Home 路由组件
 */
export default class Home extends React.Component {
    render() {
        return (
            <div className="home">
                欢迎使用后台管理系统
            </div>
        );
    }
}
```


# 4. 分类管理

- 分类管理主要涉及分类的增删改查，其中 Category 组件主要用于展示分类，分类的增加和修改不涉及路由，而是通过两个 ant-d Modal 完成的
- 下面分别介绍各个文件内容，详细的功能请参考注释

## 4.1 分类管理涉及的 api

- api 在 src/api/index.js 中编写，下面是分类管理涉及的 api
```js
// 根据 parentId 请求 category 信息，接口自带后台分页，为了模拟前台分页，此处设置较大的 pageSize
export const reqCategories = (pid) =>
    ajax('category?pid=' + pid + '&pageSize=200');

// 根据父 id 和名称添加类别
export const reqAddCategory = (pid, name) =>
    ajax('category', {pid, name}, POST);

// 根据 id 更新类别
export const reqUpdateCategory = (id, name) =>
    ajax('category/' + id, {name}, PUT);

// 根据 id 删除分类
export const reqDeleteCategory = (id) =>
    ajax('category/' + id, {}, DELETE);

// 获取一级分类下的二级分类数
export const reqSubCategoryNum = (id) =>
    ajax('category/subCategoryNum/' + id);

// 根据 id 获取分类
export const reqCategory = (id) =>
    ajax('category/' + id);
```

## 4.2 AddForm 组件实现

- AddForm 组件主要内容为新增类别的表单
- 在 Category 组件中有一个 Modal，其内部内容即为 AddForm 组件，用于添加分类，默认情况下不展示，只有单击创建按钮时才展示
- src/pages/category/add-form.jsx 文件内容主要如下 :
```jsx
import React, {Component} from 'react'
import PropTypes from 'prop-types';
import {
  Form,
  Select,
  Input
} from 'antd'

const Item = Form.Item;
const Option = Select.Option;

/**
 * 自定义 AddForm 组件，用于添加分类
 */
class AddForm extends Component {

  // 组件向外提供的参数，使用组件时提供
  static propTypes = {
    setForm: PropTypes.func.isRequired, // 用来传递form对象的函数
    categories: PropTypes.array.isRequired, // 一级分类的数组
    parentId: PropTypes.string.isRequired, // 父分类的ID
  };

  // 初始化内容
  componentDidMount () {
    // 把 form 对象传递给外层组件，使得外层使用者能通过 this.props.form 收集表单数据，校验表单等
    // 当然，这个 this.props.form 是由高阶组件 Form.create() 提供的
    this.props.setForm(this.props.form);
  }

  render() {
    const {categories, parentId} = this.props; // 取出外层组件提供的数据
    const { getFieldDecorator } = this.props.form; // Form.create() 提供的 form

    return (
      <Form>
        <Item>
          {
            // getFieldDecorator 详细注释参 login 组件
            getFieldDecorator('parentId', {
              initialValue: parentId // 设置 parentId 初始 value，即默认的父分类
            })(
              <Select>
                <Option value='0' key='0'>一级分类</Option>
                {
                  // 遍历数据生成一级分类列表，创建二级分类时使用
                  categories.map(c => <Option value={c.id} key={c.id}>{c.name}</Option>)
                }
              </Select>
            )
          }
        </Item>

        <Item>
          {
            getFieldDecorator('categoryName', {
              initialValue: '', // 初始值
              rules: [ // 校验规则
                {required: true, message: '分类名称必须输入'}
              ]
            })(
              <Input placeholder='请输入分类名称'/>
            )
          }
        </Item>
      </Form>
    )
  }
}

export default Form.create()(AddForm)
```

## 4.3 UpdateForm 组件实现

- 和 AddForm 类似，我们还有一个 UpdateForm 组件用于更新类别信息
- 类似的，Category 组件内部有一个 Modal，其内部放置了 UpdateForm 组件，默认也不显示，单击修改标题时才弹出
```jsx
import React, {Component} from 'react'
import PropTypes from 'prop-types'
import {
  Form,
  Input
} from 'antd'

const Item = Form.Item

/**
 * UpdateForm 组件，用于更新分类
 */
class UpdateForm extends Component {

  // 向外提供的数据接口，由使用者提供参数
  static propTypes = {
    categoryName: PropTypes.string.isRequired,
    setForm: PropTypes.func.isRequired
  };

  componentDidMount() {
    // 将 form 对象通过 setForm() 传递父组件，其中 this.props.form 是由高阶组件提供的
    this.props.setForm(this.props.form)
  }

  render() {
    const {categoryName} = this.props; // 取出使用者给定的数据
    const { getFieldDecorator } = this.props.form; // 取出高阶函数 getFieldDecorator

    return (
      <Form>
        <Item>
          {
            // getFieldDecorator 详细注释参 login 组件
            getFieldDecorator('categoryName', {
              initialValue: categoryName, // 设置标题的初始值
              rules: [ // 校验规则
                {required: true, message: '分类名称必须输入'}
              ]
            })(
              <Input placeholder='请输入分类名称'/>
            )
          }
        </Item>
      </Form>
    )
  }
}

export default Form.create()(UpdateForm)
```

## 4.4 Category 组件实现

- Category 组件主体内容为 ant-d Card，内部再包含一个用于展示分类数据的 Table
- 此外前面提到，还有两个 Modal，分别放置 AddForm, UpdateForm，默认隐藏，单击对应按钮弹出对应的 Modal
- 一般较为简单的展示和收集信息可以利用 Modal 进行放置，如果较为复杂的页面则可能要考虑额外扩充一级路由进行显示，例如后面的 Item 组件相关
- 下面是 src/pages/category/category.jsx 内容 :
```jsx
// react & ant-d
import React, {Component} from 'react'
import {
    Card,
    Table,
    Button,
    Icon,
    Modal, message
} from 'antd'
// components & pages
import UpdateForm from './update-form'
import AddForm from './add-form'
import LinkButton from '../../components/link-button'
// api & utils
import {reqCategories, reqAddCategory, reqUpdateCategory, reqDeleteCategory, reqSubCategoryNum} from "../../api";

/**
 * 分类管理路由组件
 */
export default class Category extends Component {
    state = {
        categories: [], // 一级分类列表
        subCategories: [], // 二级分类列表
        parentId: '0', // 当前展示的列表的父分类的 ID，默认展示一级分类，即 pid = 0
        parentName: '', // 父分类的名称
        loading: false, // 标识是否正在加载中
        showStatus: 0, // 是否显示对话框 0: 都不显示 , 1: 显示添加 AddForm , 2: 显示更新 UpdateForm
    };

    // 根据 parentId 异步更新分类列表信息，如果没有指定 parentId 使用 state 中的 parentId
    refreshCategories = async (parentId) => {
        // 更新 loading 状态 : 加载中
        this.setState({
            loading: true
        });
        // 优先使用指定的 parentId,
        parentId = parentId || this.state.parentId;

        // 异步获取分类列表
        const responseData = await reqCategories(parentId); // {status: 0, data: []}

        // 更新 loading 状态 : 加载完成
        this.setState({
            loading: false
        });

        const categories = responseData.list; // 响应数据中的 list 即为数据信息

        if (parentId === '0') {
            // 如果 parentId === 0 进一步对所有一级标题判断是否存在子标题
            for (const category of categories) {
                const responseData = await reqSubCategoryNum(category.id);
                if (responseData.message === '0') {
                    // 该一级分类下无二级分类
                } else {
                    category['hasSubCategory'] = true;
                }
            }

            // 更新一级分类列表
            this.setState({
                categories
            });
        } else {
            // 更新二级分类列表
            this.setState({
                subCategories: categories
            })
        }
    };

    // 显示一级列表
    showCategories = () => {
        this.setState({
            parentId: '0',
            parentName: '',
            subCategories: [],
            showStatus: 0,
        })
    };

    // 指定 pid，显示指定分类的二级分类列表
    showSubCategories = (category) => {
        // 更新状态 : state 中的数据是异步更新 (不会立即更新 state 中的数据 )
        this.setState({
            parentId: category.id,
            parentName: category.name
        }, () => { // 该回调在状态更新之后执行, 在回调函数中能得到最新的状态数据
            // 注意使用 this.state.parentId，不用再提供 parentId
            this.refreshCategories(null).then(null);
        })
    };


    // 显示 AddForm 组件，用于添加 category
    showAdd = () => {
        this.setState({
            showStatus: 1
        })
    };

    // 显示 UpdateForm 组件，用于修改 category
    showUpdate = (category) => {
        // 保存当前选中的要修改的 category
        this.category = category;
        // 更新状态，显示 UpdateForm
        this.setState({
            showStatus: 2
        });
    };

    // 执行添加分类
    addCategory = async () => {
        // 得到数据，this.form 为 AddForm 组件中的高阶组件提供的对象
        const {parentId, categoryName} = this.form.getFieldsValue();
        // 关闭对话框
        this.setState({
            showStatus: 0
        });
        // 重置表单
        this.form.resetFields();
        // 异步请求添加分类
        await reqAddCategory(parentId, categoryName);
        // 添加成功后刷新数据

        // 由于涉及删除按钮，因此一级标题列表必定刷新
        this.refreshCategories('0');

        // 若是当前在查看二级分类列表且添加的就是当前列表下的二级分类，则刷新当前二级分类列表
        if (parentId !== '0' && parentId === this.state.parentId) {
            // 两个 parentId 相等说明当前添加的项就属于当前查看的列表，需要刷新
            this.refreshCategories(parentId);
        }
    };

    // 执行更新分类
    updateCategory = async () => {
        // 得到数据
        const categoryId = this.category.id;
        const {categoryName} = this.form.getFieldsValue();
        // 关闭对话框
        this.setState({
            showStatus: 0
        });
        // 重置表单
        this.form.resetFields();
        // 异步请求更新分类
        await reqUpdateCategory(categoryId, categoryName);
        // 重新获取列表
        this.refreshCategories();
    };

    // 根据 categoryId 删除分类
    deleteCategory = (categoryId) => {
        const outer = this; // 记录当前 this

        Modal.confirm({
            title: '确认删除？',
            async onOk() {
                // 删除分类
                const responseData = await reqDeleteCategory(categoryId);
                message.success(responseData.message);
                // 由于涉及删除，一级分类必定要刷新
                outer.refreshCategories('0').then(null);
                // 若当前查看的是二级分类列表，还要刷新二级分类列表
                if (outer.state.parentId !== '0') {
                    outer.refreshCategories(outer.state.parentId).then(null);
                }
            },
            onCancel() {},
        });
    };

    // 初始化列的信息，主要是操作列要根据一二级动态显示内容
    initColumns = () => {

        // 根据 category 动态判断是否要显示删除按钮，属于列的元数据的一部分
        // category.hasSubCategory 已经 refreshCategories() 中初始化
        const deleteButton = (category) => {
            return category.hasSubCategory ? null :
                <LinkButton onClick={() => this.deleteCategory(category.id)} style={{color: '#ff4d4f'}}>
                    删除
                </LinkButton>
        };

        // 列的元数据，构造 Table 组件时要用到
        this.columns = [
            {
                title: ' 分类名称',
                dataIndex: 'name', // 该列展示 name (dataSource 中的每行对象的属性)
            },
            {
                title: ' 操作',
                width: 300,
                render: (category) => (
                    <span>
                        <LinkButton onClick={() => this.showUpdate(category)}>
                            修改分类
                        </LinkButton> &nbsp;&nbsp;
                        {this.state.parentId === '0' ?
                            <LinkButton onClick={() => this.showSubCategories(category)}>查看子分类</LinkButton>
                            : null} &nbsp;
                        {deleteButton(category)}
                    </span>
                )
            }
        ];
    };

    componentDidMount() {
        this.initColumns(); // 初始化列的元数据
        this.refreshCategories().then(null); // 初始化列表数据
    }

    render() {
        // 从状态中取数据
        const {categories, subCategories, parentId, parentName, loading, showStatus} = this.state;

        // 取出当前选择的 category，主要用于传递给 UpdateForm，注意可能为 null，因此要处理
        const category = this.category || {}; //

        // Card 的左侧标题，根据是一二级分类动态显示内容
        const title = parentId === '0' ? ' 一级分类列表' : (
            <span>
                <LinkButton onClick={this.showCategories}>一级分类列表</LinkButton> &nbsp;&nbsp;
                <Icon type='arrow-right'/>&nbsp;&nbsp;
                <span>{parentName}</span>
            </span>
        );

        // Card 的右侧添加按钮
        const extra = (
            <Button type='primary' onClick={this.showAdd}>
                <Icon type='plus'/> 添加
            </Button>
        );

        // Category 是一个 Card 组件，内容为 Table
        // 添加和更新则各是一个 Modal，单击对应按钮弹出，内容为 add-form, update-form 组件
        return (
            <Card title={title} extra={extra}>
                <Table
                    bordered // 带边框
                    rowKey='id' // 设置 key，否则会有警告
                    dataSource={parentId === '0' ? categories : subCategories} // 要展示的数据
                    columns={this.columns} // 列的描述信息
                    loading={loading} // 表格是否在加载中，
                    pagination={{pageSize: 5, showQuickJumper: true, showSizeChanger: true}} // 前台分页
                />
                <Modal // 添加分类的 ant-d Modal
                    title=" 添加分类" // 标题
                    visible={showStatus === 1} // 根据 showStatus 判断是否显示该 Modal
                    onOk={this.addCategory} // 单击确定后收集数据，执行添加分类操作
                    onCancel={() => this.setState({showStatus: 0})} // 单击取消后隐藏该 Modal
                >
                    <AddForm // Modal 中的内容为自定义的 AddForm 组件
                        categories={categories} // 提供一级标题数据给 AddForm
                        parentId={parentId} // 提供当前 parentId 个 AddForm
                        setForm={form => this.form = form} // 提供 setForm 函数给 AddForm，让其能将 form 传回来（收集表单数据时要用到）
                    />
                </Modal>
                <Modal // 修改分类的 ant-d Modal
                    title=" 修改分类" // 标题
                    visible={showStatus === 2} // 根据 showStatus 判断是否显示该 Modal
                    onOk={this.updateCategory} // 单击确定后收集数据，执行更新分类操作
                    onCancel={() => {
                        this.setState({showStatus: 0}); // 单击取消后隐藏该 Modal
                        this.form.resetFields() // 清空表单数据，否则有缓存
                    }}
                >
                    <UpdateForm // Modal 中的内容为自定义的 UpdateForm 组件
                        categoryName={category.name} // 将原有的 categoryName 传递过去
                        setForm={form => this.form = form} // 提供 setForm 函数给 UpdateForm，让其能将 form 传回来（收集表单数据时要用到）
                    />
                </Modal>
            </Card>
        )
    }
}
```

# 5. 商品管理

- 商品管理是本系统最复杂、最核心的功能，涉及商品的增删改查，以及商品的搜索功能
- 需要注意的是，商品的搜索在后台通过 MySQL 全文索引实现，其联合了商品的 name, description, detail，因此只有一种搜索类型，而前台页面搜索类型有两种只是为了前台实现，后台没有用到
- 商品管理的商品添加/更新、商品详情都属于比较复杂的页面，因此此处没有选择使用 Modal 展示对应内容，而是为其单独添加一级路由进行管理
- 根据增删改查需求，商品下细分三个路由 : /item, /item/add-update, /item/detail 三个路由
- 商品的添加/修改、商品详情两个组件都需要展示商品的图片，因此为了复用，抽取 PicturesWall 组件供 ItemAddUpdate, ItemDetail 组件使用
- 此外 ItemAddUpdate 组件的商品详情需要使用富文本编辑器进行输入，因此还要两家两个依赖 : `yarn add react-draft-wysiwyg draftjs-to-htm`
- 组件结构大致如下 :
- Item
    - ItemHome (/item 路由)
    - ItemAddUpdate (/item/add-update 路由)
        - PicturesWall
        - RichTextEditor
    - ItaemDetail (/item/detail 路由)
        - - PicturesWall
- 文件内容参考源码，此处不再复制


# 6. 角色管理


# 7. 用户管理

# 8. redux 管理状态


# 9. 可视化图表


# 10. 其他