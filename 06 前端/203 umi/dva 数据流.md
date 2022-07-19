
# 1. dva 数据流流程

- dva 数据流主要通过各个 model 实现，每个 model 的结构基本是一致的
- model 中主要包含下列成分：
    - namespace：model 的命名空间，必须唯一，各个 model 的 namespace 不得相同
    - state：当前 model 的数据，共路由组件和公共组件使用，model 在收到 action 后会更新数据
    - effects：处理异步逻辑，一般在收到 action 后会从服务器取数据，如果需要更新 state 则还会进一步通过发送同步 action 来调用 reducer
    - reducers：reducer 处理同步逻辑，一般只需要一个 reducer 就够了，就是根据 action 的数据 payload 覆盖 state 中的旧数据得到最新的 state
- 在外部组件中，通过 connect 函数将数据传到组件的 props 中，同时还传递了一个 dispatch 函数，用于发送 action 以调用对应 model 中的 effects 和 reducers 更新 state
- 数据流更新大致如下：
    - 路由组件通过 connect 以获取 model 中的 state 以及 dispatch
    - 路由组件通过 dispatch 发送 action，让 model 调用 effects 或者 reducers，更新 state
    - 其中，effects 获取到服务器数据后，往往需要进一步发送 action 触发 reducer 的调用以更新 state
    - state 变化后，数据会自动得到回显

# 2. effects 与 reducers

- effects 与 reducers 用于接收 action 并作出响应，最终更新自己的 state
- effects 主要处理异步逻辑，例如从服务器取数据，去到数据后，最终往往还会发送一次同步 action 来调用 reducer，以将最新的数据更新到 state 中
- reducers 处理同步逻辑，一般只需提供一个 reducer 即可，该 reducer 根据原有 state 以及最新的 payload 来更新 state
- 只要通过 dispatch 或者 put 发送 action，会自动触发对应 effect 或 reducer 的调用

## 2.1 effects 

- 我们已知，effects 处理异步逻辑，因此内部往往包含异步请求，因此其往往是一个异步函数，从外观上看则为函数前有 * 修饰符，如下面的例子
```js
export default {
  effects: {
    *fetchBasic({ payload }, { call, put }) {
      const response = yield call(queryBasicProfile, payload);
      yield put({
        type: 'show',
        payload: response,
      });
    },
    *fetchAdvanced(_, { call, put }) {
      const response = yield call(queryAdvancedProfile);
      yield put({
        type: 'show',
        payload: response,
      });
    },
  },
};
```

- effect 函数有两个参数 `(action, effects)`
    - 第一个参数即为 action，其内部包含了两个常用的属性，type 和 payload，表示本次 action 的类型（会对应到 effect 或 reducer 的名称）和数据
    - 第二个参数即为 dva 中提供的一些默认函数，主要用于在 effect 函数内部，常见的有 call, put, select
    - call 通过 api 以及 umi-request 发起 ajax 请求并拿到数据
    - put 用于触发 action（等同于在外部组件使用的 dispatch 函数）
    - select 用于从 state 中取数据
    - 对他们的调用一般都要加上 yield 关键字

## 2.2 reducers

- reducers 处理同步逻辑，其有两个参数 `(state, action)`
    - state 即为原有 state
    - action 等同于 effects 中的 action，在 reducer 中主要用到 payload，将 payload 覆盖原有的 state 部分即可
- 因此 reducer 往往只需要一个实现，即根据 state 和 payload 刷新 state
```js
reducers: {
    show(state, { payload }) {
        return {
        ...state,
        ...payload,
        };
    },
},
```
