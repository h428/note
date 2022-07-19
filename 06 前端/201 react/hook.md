
# 1. Hook 简介

- Hook 是 React 16.8 的新增特性，它可以让你在不编写 class 的情况下使用 state 以及其他的 React 特性
- React 16.8.0 是第一个支持 Hook 的版本。升级时，请注意更新所有的 package，包括 React DOM。 React Native 从 0.59 版本开始支持 Hook
- Hook 是一些可以让你在函数组件里“钩入” React state 及生命周期等特性的函数，使得你不使用 class 也能使用 React
- Hook 的作用 :
    - Hook 使你在无需修改组件结构的情况下复用状态逻辑，这使得在组件间或社区内共享 Hook 变得更便捷
    - Hook 将组件中相互关联的部分拆分成更小的函数（比如设置订阅或请求数据），而并非强制按照生命周期划分
    - Hook 使你在非 class 的情况下可以使用更多的 React 特性

# 2. Hook 概览

## 2.1 useState

- useState 是我们要学习的第一个 “Hook”，通过在函数组件里调用它来给组件添加一些内部 state
- useState 会返回一对值：当前状态和一个让你更新它的函数，你可以在事件处理函数中或其他一些地方调用这个函数，类似 setState
- useState 唯一的参数就是初始 state 的值，这个初始 state 参数只有在第一次渲染时会被用到，而且不同于原有的 this.state，这里的 state 不一定要是一个对象，可以是普通纸
- 例如下述例子，使用 useState 返回了 count 变量以及修改它的 setCount 函数 :
- 
```jsx
import React, { useState } from 'react';

function Example() {
  // 声明一个叫 “count” 的 state 变量。
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```
- 可以在一个组件中多次使用 State Hook 来声明多个 state 变量，例如下述例子 :
```jsx
function ExampleWithManyStates() {
  // 声明多个 state 变量！
  const [age, setAge] = useState(42);
  const [fruit, setFruit] = useState('banana');
  const [todos, setTodos] = useState([{ text: 'Learn Hooks' }]);
  // ...
}
```

## 2.2 useEffect

- useEffect 就是一个 Effect Hook，给函数组件增加了操作副作用的能力，它跟 class 组件中的 componentDidMount、componentDidUpdate 和 componentWillUnmount 具有相同的用途，只不过被合并成了一个 API
- 直观理解：state 中数据发生变化并在组件 render 完毕之后的一个生命周期回调
- 当你调用 useEffect 时，就是在告诉 React 在完成对 DOM 的更改后运行你的“副作用”函数。由于副作用函数是在组件内声明的，所以它们可以访问到组件的 props 和 state
- 默认情况下，React 会在每次渲染后调用副作用函数 —— 包括第一次渲染的时候，我们会在使用 Effect Hook 中跟 class 组件的生命周期方法做更详细的对比
- 例如，下面这个组件在 React 更新 DOM 后会设置一个页面 title :
```jsx
import React, { useState, useEffect } from 'react';

function Example() {
  const [count, setCount] = useState(0);

  // 相当于 componentDidMount 和 componentDidUpdate:
  useEffect(() => {
    // 使用浏览器的 API 更新页面标题
    document.title = `You clicked ${count} times`;
  });

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```
- setCount 和 setState 类似，除了直接使用值外，也可以改为更新函数的形式，例如：
```jsx
<button onClick={() => setCount(prevCount => prevCount + 1)}>
  Click me
</button>
```
- 此外，副作用函数还可以通过返回一个函数来指定如何“清除”副作用，在 class 组件中通常通过 componentWillUnmount 实现 :
```jsx
import React, { useState, useEffect } from 'react';

function FriendStatus(props) {
  const [isOnline, setIsOnline] = useState(null);

  function handleStatusChange(status) {
    setIsOnline(status.isOnline);
  }

  useEffect(() => {
    ChatAPI.subscribeToFriendStatus(props.friend.id, handleStatusChange);

    // 清除副作用
    return () => {
      ChatAPI.unsubscribeFromFriendStatus(props.friend.id, handleStatusChange);
    };
  });

  if (isOnline === null) {
    return 'Loading...';
  }
  return isOnline ? 'Online' : 'Offline';
}
```
- 需要注意，清除副作用的函数必定会在本次 render 销毁之后执行一次，但不一定是在下次 render 之前执行，例如下述例子，我们可以看出，react 先执行了下一次的 render 后，才调用了本次的清楚副作用函数
```jsx
import React, {useState, useEffect} from 'react';

export default () => {
    const [count, setCount] = useState(0);

    useEffect(() => {
        // 相当于 state 发生变化后的回调
        document.title = `你点击了 ${count} 次`;
        console.log(`did update : ${count}`);

        /**
         * useEffect 可以返回一个清除副作用的函数，相当于 componentWillUnmount
         * 触发调用的时机是在本次 render 销毁下一次 render 开始之前，但真正调用不一定在下一 render 之前，
         * 触发销毁时间后，该回调必定会被调用，但可能是在下一次 render 渲染完成后才调用（React 会优先做下一次 render）
         * 但里面拿到的 state 值肯定是下一次 render 之前的原来的值，这点不用担心
         * 因此，我们每次单击并在控制台观察打印，可以看到如下顺序（假设 count 由 2 -> 3）：
         *      render code : 3 （可能有多个，应该可能多次触发渲染之类的）
         *      before destroy : 2 （副作用的调用是在下次渲染之后调用，因此不能依赖渲染之前的时机）
         *      did update : 3
         */
        return () => {
            // 在下一次 render 之后执行，但拿到的 count 仍然是本次要销毁的 count 值
            console.log('before destroy : ', count);
        }
    });

    console.log('render code : ', count);

    return (
        <div>
            <p>你点击了 {count} 次</p>
            <button onClick={() => setCount(count + 1)}>
                点击
            </button>
        </div>
    );
}
```
- 跟 useState 一样，你可以在组件中多次使用 useEffect
- 通过使用 Hook，你可以把组件内相关的副作用组织在一起（例如创建订阅及取消订阅），而不要把它们拆分到不同的生命周期函数里

## 2.3 Hook 使用规则

- Hook 就是 JavaScript 函数，但是使用它们会有两个额外的规则
- 只能在函数最外层调用 Hook。不要在循环、条件判断或者子函数中调用
- 只能在 React 的函数组件中调用 Hook。不要在其他 JavaScript 函数中调用
- 还有一个地方可以调用 Hook —— 就是自定义的 Hook 中，我们稍后会学习到

## 2.4 自定义 Hook

- 有时候我们会想要在组件之间重用一些状态逻辑。目前为止，有两种主流方案来解决这个问题：高阶组件和 render props
- 自定义 Hook 可以让你在不增加组件的情况下达到同样的目的
- 使用参考官方文档


# 3. 使用 State Hook

- 简单的说，useState 让你能在函数组件中使用 this.state，以前 this.state 只能在 class 组件中使用，而通过使用 Hook，让函数组件具备了类组件的 state
- Hook 是一个特殊的函数，它可以让你“钩入” React 的特性。例如，useState 是允许你在 React 函数组件中添加 state 的 Hook
- 如果你在编写函数组件并意识到需要向其添加一些 state，以前的做法是必须将其它转化为 class。现在你可以在现有的函数组件中使用 Hook
- 前面的例子 :
```jsx
import React, { useState } from 'react';

function Example() {
  // 声明一个叫 "count" 的 state 变量
  const [count, setCount] = useState(0);

  return (
    ...
  );
}
```
- useState 是一种新方法，它与 class 里面的 this.state 提供的功能完全相同，一般来说，在函数退出后变量就会”消失”，而 state 中的变量会被 React 保留
- 我们声明了一个叫 count 的 state 变量，然后把它设为 0，React 会在重复渲染时记住它当前的值，并且提供最新的值给我们的函数，我们可以通过调用 setCount 来更新当前的 count

# 4. 使用 Effect Hook 

- 简单地说，Effect Hook 可以让你在函数组件中执行副作用操作，以前只能通过 class 组件的生命周期函数实现
- 如果你熟悉 React class 的生命周期函数，你可以把 useEffect Hook 看做 componentDidMount，componentDidUpdate 和 componentWillUnmount 这三个函数的组合
- 在 React 组件中有两种常见副作用操作：需要清除的和不需要清除的，我们来更仔细地看一下他们之间的区别

## 4.1 无需清除的 effect

- 有时我们只想在 React 更新 DOM 之后额外运行一些代码，比如发送网络请求，手动变更 DOM，记录日志，这些都是常见的无需清除的操作
- 在传统的 class 组件中，一般通过 componentDidMount 和 componentDidUpdate 两个生命周期函数达到上述目的
- 使用 Hook 后，我们直接使用不带返回值的 useEffect 即可
- useEffect 接收一个函数，该函数即为重新 render 后需要执行的额外操作，如果需要清除 effect，则只要在该函数内返回一个清除 effect 的函数即可
- useEffect 会在每次渲染后都执行（包括第一次渲染之后和每次更新之后都会执行），不用再去考虑“挂载”还是“更新”，React 保证了每次运行 effect 的同时，DOM 都已经更新完毕
- 与 componentDidMount 或 componentDidUpdate 不同，使用 useEffect 调度的 effect 不会阻塞浏览器更新屏幕，这让你的应用看起来响应更快
- 前面已经给过一个无需清除的 effect 示例，为了方便查看，再次提供该示例：
```jsx
import React, {useState, useEffect} from 'react';

export default () => {
    const [count, setCount] = useState(0);

    useEffect(() => {
        // 相当于 state 发生变化后的回调
        document.title = `你点击了 ${count} 次`;
        console.log(`did update : ${count}`);

        // 无需清除的 effect，没有返回值
    });

    console.log('render code : ', count);

    return (
        <div>
            <p>你点击了 {count} 次</p>
            <button onClick={() => setCount(count + 1)}>
                点击
            </button>
        </div>
    );
}
```

## 4.2 需要清除的 effect

- 还有一些副作用是需要清除的，例如订阅外部数据源。这种情况下，清除工作是非常重要的，可以防止引起内存泄露
- 在传统的 class 组件中，清除工作通常在生命周期函数 componentWillUnmount 中编写
- useEffect 将副作用和清除工作紧密地联系起来，你只需在副作用函数中返回一个清除函数，React 将会在执行清除操作时调用它
- 在 effect 中可以返回一个清除函数，例如可以将添加和移除订阅的逻辑放在一起，他们都属于 effect 的一部分
- React 会在组件卸载的时候执行清除操作
- 使用 Hook 其中一个目的就是要解决 class 中生命周期函数经常包含不相关的逻辑，但又把相关逻辑分离到了几个不同方法中的问题
- 还是使用前面的例子，不过这次我们在 effect 中给出返回值，用于清除副作用，其作用相当于 componentWillUnmount
```jsx
import React, {useState, useEffect} from 'react';

export default () => {
    const [count, setCount] = useState(0);

    useEffect(() => {
        // 相当于 state 发生变化后的回调
        document.title = `你点击了 ${count} 次`;
        console.log(`did update : ${count}`);

        // 返回一个清除副作用的函数，相当于 componentWillUnmount
        return () => {
            // 实际上是在下一次 render 之后执行，但拿到的 count 仍然是本次要销毁的 count 值
            console.log('before destroy : ', count);
        }
    });

    console.log('render code : ', count);

    return (
        <div>
            <p>你点击了 {count} 次</p>
            <button onClick={() => setCount(count + 1)}>
                点击
            </button>
        </div>
    );
}
```

## 4.3 effect 补充

- useEffect：state 变化 -> 组件渲染 -> 调用 effect
- 如果还需要清除副作用（相当于 componentWillUnmount），则需要在 effect 中返回一个清除函数，若不需清除则不必返回
- useEffect 和传统的类组件的 componentDidMount、componentDidUpdate、componentWillUnmount 相比，其优势在于可以将同一个关注点整合在一起，并使用多个 useEffect 分离关注点，若使用传统的生命周期函数，会使得各个关注点的更新和清除代码分别存在于不同的生命周期函数中，维护困难
- React 将按照 effect 声明的顺序依次调用组件中的每一个 effect

**解释: 为什么每次更新的时候都要运行 Effect**

- class 组件的 componentWillUnmount 只会在组件要销毁时执行一次，而 effect 中的清除函数会在每次更新值都会执行，相当于多次 componentWillUnmount
- 你或许会疑惑为什么 effect 的清除阶段在每次重新渲染时都会执行，而不是只在卸载组件的时候执行一次
- 这样设计的目的是为了减少 bug，因为在类组件中忘记正确地处理 componentDidUpdate 是 React 应用中常见的 bug 来源（我们经常只编写了 componentDidMount 却忘了编写 componentDidUpdate，而且这两个函数的逻辑往往是一样的）
- 若是使用 hook，则不会受到这种 bug 影响，hook 不需要特定的代码来处理更新逻辑，因为 useEffect 默认就会处理，它会在调用一个新的 effect 之前对前一个 effect 进行清理
- 具体的例子可参考官方文档，此处为简单描述：
```jsx
// Mount with { friend: { id: 100 } } props
ChatAPI.subscribeToFriendStatus(100, handleStatusChange);     // 运行第一个 effect

// Update with { friend: { id: 200 } } props
ChatAPI.unsubscribeFromFriendStatus(100, handleStatusChange); // 清除上一个 effect
ChatAPI.subscribeToFriendStatus(200, handleStatusChange);     // 运行下一个 effect

// Update with { friend: { id: 300 } } props
ChatAPI.unsubscribeFromFriendStatus(200, handleStatusChange); // 清除上一个 effect
ChatAPI.subscribeToFriendStatus(300, handleStatusChange);     // 运行下一个 effect

// Unmount
ChatAPI.unsubscribeFromFriendStatus(300, handleStatusChange); // 清除最后一个 effect
```
- 此默认行为保证了一致性，避免了在 class 组件中因为没有处理更新逻辑而导致常见的 bug

**提示: 通过跳过 Effect 进行性能优化**

- 我们已经知道，每次调用 effect 前都会对前一次的 effect 进行清理
- 但在某些情况下，每次渲染后都执行清理或者执行 effect 可能会导致性能问题
- 在 class 组件中，我们可以通过在 componentDidUpdate 中添加对 prevProps 或 prevState 的比较逻辑解决：
```jsx
componentDidUpdate(prevProps, prevState) {
  if (prevState.count !== this.state.count) {
    document.title = `You clicked ${this.state.count} times`;
  }
}
```
- 上述情况是很常见的需求，所以它被内置到 useEffect 的 Hook API 中，如果特定值在两次重新渲染之间没有发生变化，可以让 React 跳过对 effect 的调用，这样就避免了重复渲染
```jsx
useEffect(() => {
  document.title = `You clicked ${count} times`;
}, [count]); // 仅在 count 更改时更新
```
- 上面这个示例中，我们传入 [count] 作为第二个参数，这个参数是什么作用呢？
- 如果 count 的值是 5，而且我们的组件重渲染的时候 count 还是等于 5，React 将对前一次渲染的 `[5]` 和后一次渲染的 `[5]` 进行比较，因为数组中的所有元素都是相等的(5 === 5)，React 会跳过这个 effect，这就实现了性能的优化
- 当渲染时，如果 count 的值更新成了 6，React 将会把前一次渲染时的数组 `[5]` 和这次渲染的数组 `[6]` 中的元素进行对比。这次因为 5 !== 6，React 就会再次调用 effect
- 特别注意，如果数组中有多个元素，即使只有一个元素发生变化，React 也会执行 effect
- 下面是一个完整的例子，count1、count2 值发生变化时都会导致渲染，但只有 count1 值变化时才会调用定义的 effect
```jsx
import React, {useState, useEffect} from 'react';

export default () => {
    const [count1, setCount1] = useState(0);
    const [count2, setCount2] = useState(0);

    // count1, count2 其中的一个发生变化后，都会导致重新 render
    // 但只有 count1 的值发生变化后，才会触发 effect 的上一次清除以及本次的调用
    useEffect(() => {
        // 相当于 state 发生变化后的回调
        document.title = `你点击了 ${count1} 次 count1, ${count2} 次 count2`;
        console.log(`did update : ${count1}, ${count2}`);

        // 返回一个清除副作用的函数，相当于 componentWillUnmount
        return () => {
            // 需要特别注意这里拿到的是上一次 effect 调用时的值，因此 count2 可能不连续
            // 因为单击 count 不会导致 effect 的调用，只有的下次单击 count1 时，
            // count2 的值会从上一次单击 count1 时的销毁时的值变为该次单击 count2 时的销毁时的值
            console.log('before destroy : ', count1, count2);
        }
    }, [count1]); // 设置只有 count1 发生变化才会触发 effect 回调


    return (
        <div>
            <p>你点击了 {count1} 次 count1</p>
            <p>你点击了 {count2} 次 count2</p>
            <button onClick={() => setCount1(count1 + 1)}>
                count1
            </button> &nbsp;
            <button onClick={() => setCount2(count2 + 1)}>
                count2
            </button>
        </div>
    );
}
```


# 5. Hook 规则

- Hook 本质就是 JavaScript 函数，但是在使用它时需要遵循两条规则
- 只在函数组件内部地最顶层使用 Hook，不要在循环，条件或嵌套函数中调用 Hook， 确保总是在你的 React 函数的最顶层调用他们
- 遵守前面这条规则，你就能确保 Hook 在每一次渲染中都按照同样的顺序被调用。这让 React 能够在多次的 useState 和 useEffect 调用之间保持 hook 状态的正确
- 只在 React 函数或者自定义 Hook 中调用 Hook，不要在普通的 JavaScript 函数中调用 Hook
- 如果在 if else 中调用 Hook，可能导致运行时 Hook 的调用顺序发生变化，从而产生 bug
- 这就是为什么 Hook 需要在我们组件的最顶层调用，如果我们想要有条件地执行一个 effect，可以将判断放到 Hook 的内部
```jsx
useEffect(function persistForm() {
  // 👍 将条件判断放置在 effect 中
  if (name !== '') {
    localStorage.setItem('formData', name);
  }
});
```

# 6. 自定义 Hook

- 通过自定义 Hook，可以将组件逻辑提取到可重用的函数中
- 下面是一个简单例子
```jsx
import React, { useState, useEffect } from 'react';

const useCount = (initValue) => {

    const [count, setCount] = useState(initValue);

    // useCount 抽取的就是 effect 部分的逻辑，每个 count 值的变化都将导致 title 的刷新
    // 注意只有 count 变化才会回调，因此单击哪个最终 title 就是那个值，
    // 如果不加第二个参数 title 将始终会是 count2 的值
    useEffect(() => {
        console.log(count);
        document.title = `You clicked ${count} times`;
    }, [count]);

    return [count, setCount];
};


export default () => {
    // 利用自定义 Hook 声明两个 count，并给定不同的初始值进行观察
    const [count1, setCount1] = useCount(0);
    const [count2, setCount2] = useCount(10);

    return (
        <div>
            <p>You clicked {count1} times count1, {count2} times count2</p>
            <button onClick={() => setCount1(prevCount => prevCount + 1)}>
                count1
            </button> &nbsp;
            <button onClick={() => setCount2(prevCount => prevCount + 1)}>
                count2
            </button>
        </div>
    );
}
```

