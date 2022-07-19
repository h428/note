

# 1. 概述与引用

- 本篇笔记所有测试请求地址均使用 boot-ssm 中的 TestController 下的 api
- [参考地址](https://www.kancloud.cn/yunye/axios/234845#handling-errors)
- 单页面文件模板见笔记底部

# 2. 执行请求


## 2.1 使用 axios 函数发送请求

- axios 函数可以直接发送请求，请求的详细内容通过 config 进行配置，因此 config 可称为请求配置对象，axios 有下列两种形式
    - `axios(config)`
    - `axios(url[, config])`
- url 即为请求地址，config 为请求配置对象，若不指定 config 将使用全局默认 config，这个我们后面再讲
- 注意对于 `axios(url[, config])` 方法，函数参数 url 会覆盖 config 中的 url，因此可选参数 config 中即使配置 url 也不生效

**axios(config) 示例**

```js
let url = 'http://localhost:8081/api/test/item?id=5';

let config = {
    method: 'get',
    url: url,
};

axios(config)
    .then(response => {
        console.log("response : ", response);
    }).catch(error => {
    console.log("error : ", error.response);
});
```
- 需要注意，对于 get 类型请求，无法配置 data，请求参数在路径中体现，data 为请求体内容

**axios(url[, config]) 示例**

- 注意对于 `axios(url[, config])`，参数中的 url 会覆盖 config 中的 url

```js
let url = 'http://localhost:8081/api/test/res200';

let config = {
    method: 'get',
    url: 'http://localhost:8081/api/test/res404', // 该 url 会被覆盖而不生效
};

axios(url, config) // url 会覆盖 config 中的 url
    .then(response => {
        console.log("response : ", response);
    }).catch(error => {
    console.log("error : ", error.response);
});
```

## 2.2 使用别名函数发送请求


- 但为了方便起见，在上述方法的基础上， axios 还定义了一些常见的请求方法，包括 :
    - `axios.request(config)`
    - `axios.get(url[, config])`
    - `axios.delete(url[, config])`
    - `axios.head(url[, config])`
    - `axios.post(url[, data[, config]])`
    - `axios.put(url[, data[, config]])`
    - `axios.patch(url[, data[, config]])`
- 同理，url 表示请求地址，data 和 config 都是可选参数，data 为请求体，config 为请求配置对象
- 注意上述内容中，get, delete, head 默认不带 data 的，因为这些请求是简单请求，不带请求体，参数直接通过 url 体现
- 在使用别名方法时，url、method、data 这些属性都不必在配置 config 中指定，而是直接在函数参数中指定，因为函数参数中的内容会覆盖 config 中对应的内容
- 对于已经明确请求类型的，这些别名方法比 axios 更加直观，此时建议采用这些方法
- 对于未明确请求类型时，`axios.request(config)` 和 `axios(config)` 完全等价，请求的详细信息通过 config 配置，使用哪个都可以

**axios.request(config) 示例**

```js
let url = 'http://localhost:8081/api/test/res404';

let config = {
    method: 'get',
    url: url,
};

axios.request(config)
    .then(response => {
        console.log("response : ", response);
    }).catch(error => {
    console.log("error : ", error.response);
});
```


**axios.get(url[, config]) 示例**

```js
let url = 'http://localhost:8081/api/test/res200';

axios.get(url)
    .then(response => {
        console.log("response : ", response);
    }).catch(error => {
    console.log("error : ", error.response);
});
```

**axios.post(url[, data[, config]]) 带参数示例**

```js
let url = 'http://localhost:8081/api/test/item/';

// post 请求体（请求参数），即为函数参数中的 data
let item = {
    "name": "皮卡丘",
    "price": 999,
    "note": "皮卡皮卡",
    "status": 0,
    "cid": "10086"
};

axios.post(url, item)
    .then(response => {
        console.log("response : ", response);
    }).catch(error => {
    console.log("error : ", error.response);
});
```

- 其他示例基本类似，此处省略


## 2.3 利用自定义实例创建请求

- 有时对于许多请求，我们可能会共享一些配置，此时我们可以自定义新建一个 axios 实例，然后填入自己的配置，然后使用该新实例执行请求
- 使用函数 `axios.create([config])` 创建一个新实例，config 即为该实例的配置对象
- 对于新建的请求实例和 axios 几乎完全等价，只不过使用的是自定义 config 对象而不是全局的默认 config 对象，对于新实例，我们可以直接使用变量名执行请求，也可以使用所有的别名方法 request, get, post, .... 等执行请求

**axios.create([config]) 示例**

- 对于该示例，创建 instance 时指定 baseURL，表示之后使用 instance 执行的请求都基于该前缀

```js
// 此时 instance 就相当于一个 axios 对象
let instance = axios.create({
    baseURL: 'http://localhost:8081/api/test/item', // 配置前缀
    timeout: 1000,
    headers: {'Authorization': 'token....'}
});

let config = {
    url: "/2"
};

// post 请求体（请求参数），即为函数参数中的 data
let item = {
    "name": "皮卡丘",
    "price": 999,
    "note": "皮卡皮卡",
    "status": 0,
    "cid": "10086"
};

// 直接使用 instance 请求
instance(config)
    .then(response => {
        console.log("instance response : ", response);
    }).catch(error => {
    console.log("instance error : ", error.response);
});

// 直接使用 instance 请求，url 会覆盖 config 中的 url
instance("/5", config)
    .then(response => {
        console.log("instance response : ", response);
    }).catch(error => {
    console.log("instance error : ", error.response);
});

// 使用 instance.request 请求，和 instance(config) 等价
instance.request(config)
    .then(response => {
        console.log("instance response : ", response);
    }).catch(error => {
    console.log("instance error : ", error.response);
});

// 根据 id 请求 item 不存在会返回 404
instance.get("/1")
    .then(response => {
        console.log("get response : ", response);
    }).catch(error => {
    console.log("get error : ", error.response);
});

// 新增 item
instance.post("", item)
    .then(response => {
        console.log("post response : ", response);
    }).catch(error => {
    console.log("post error : ", error.response);
});

// 根据 id 更新 item，不存在会返回 404
instance.put("/2", item)
    .then(response => {
        console.log("put response : ", response);
    }).catch(error => {
    console.log("put error : ", error.response);
});

// 根据 id 删除 item，不存在会返回 404
instance.delete("/10086")
    .then(response => {
        console.log("delete response : ", response);
    }).catch(error => {
    console.log("delete error : ", error.response);
});

// 查询所有 item 列表，只查询出 id < 5000 的 item
instance.get("?id=5")
    .then(response => {
        console.log("list response : ", response);
    }).catch(error => {
    console.log("list error : ", error.response);
});
```


## 2.4 并发

- 处理并发请求的助手函数
- axios.all(iterable)
- axios.spread(callback)


## 2.5 总结

- 可以直接使用 axios 函数发请求，也可以利用方便的别名函数 request, get, post 等发请求，其中 request 和 axios 等价
- 对于可能需要共享部分配置的部分请求，可以使用 `axios.create(config)` 创建一个新实例，然后使用这个新实例发送请求即可，这个新实例的用法和 axios 完全一致


# 3. 请求配置对象 config


## 3.1 config 详细

- 从前面的内容可以看到，请求的所有配置项都是通过 config 进行配置的
- 关于 config，只有 url 是必需的，如果没有指定 method，请求将默认使用 get 方法
- 响应结果中也包含了本次请求 config，我们可以通过响应结果拿到本次请求的 config ，关于响应结构我们后面再谈
- config 是一个 js 对象，这里介绍一些常用的属性，完整的参考下面的代码 :
    - url : 请求地址
    - method : 请求类型，get, post, put, delete, head 等，默认是 get
    - baseURL : 将自动加在 url 前面，除非 url 是一个绝对 URL
    - headers : 自定义请求头
    - data : 请求体，只适用于这些请求方法 'PUT', 'POST', 和 'PATCH'
    - params : 请求参数，必须是一个无格式对象(plain object)或 URLSearchParams 对象
    - timeout : 超时时间(0 表示无超时时间)
    - auth : 设置一个 `Authorization` 头，注意会覆写掉现有的任意使用 `headers` 设置的自定义 `Authorization` 头

- config 配置对象的完整内容

```js
let config = {
    // `url` 是用于请求的服务器 URL
    url: '/user',

    // `method` 是创建请求时使用的方法
    method: 'get', // 默认是 get

    // `baseURL` 将自动加在 `url` 前面，除非 `url` 是一个绝对 URL。
    // 它可以通过设置一个 `baseURL` 便于为 axios 实例的方法传递相对 URL
    baseURL: 'https://some-domain.com/api/',

    // `transformRequest` 允许在向服务器发送前，修改请求数据
    // 只能用在 'PUT', 'POST' 和 'PATCH' 这几个请求方法
    // 后面数组中的函数必须返回一个字符串，或 ArrayBuffer，或 Stream
    transformRequest: [function (data) {
        // 对 data 进行任意转换处理

        return data;
    }],

    // `transformResponse` 在传递给 then/catch 前，允许修改响应数据
    transformResponse: [function (data) {
        // 对 data 进行任意转换处理

        return data;
    }],

    // `headers` 是即将被发送的自定义请求头
    headers: {'X-Requested-With': 'XMLHttpRequest'},

    // `params` 是即将与请求一起发送的 URL 参数
    // 必须是一个无格式对象(plain object)或 URLSearchParams 对象
    params: {
        ID: 12345
    },

    // `paramsSerializer` 是一个负责 `params` 序列化的函数
    // (e.g. https://www.npmjs.com/package/qs, http://api.jquery.com/jquery.param/)
    paramsSerializer: function (params) {
        return Qs.stringify(params, {arrayFormat: 'brackets'})
    },

    // `data` 是作为请求主体被发送的数据
    // 只适用于这些请求方法 'PUT', 'POST', 和 'PATCH'
    // 在没有设置 `transformRequest` 时，必须是以下类型之一：
    // - string, plain object, ArrayBuffer, ArrayBufferView, URLSearchParams
    // - 浏览器专属：FormData, File, Blob
    // - Node 专属： Stream
    data: {
        firstName: 'Fred'
    },

    // `timeout` 指定请求超时的毫秒数(0 表示无超时时间)
    // 如果请求话费了超过 `timeout` 的时间，请求将被中断
    timeout: 1000,

    // `withCredentials` 表示跨域请求时是否需要使用凭证
    withCredentials: false, // 默认的

    // `adapter` 允许自定义处理请求，以使测试更轻松
    // 返回一个 promise 并应用一个有效的响应 (查阅 [response docs](#response-api)).
    adapter: function (config) {
        /* ... */
    },

    // `auth` 表示应该使用 HTTP 基础验证，并提供凭据
    // 这将设置一个 `Authorization` 头，覆写掉现有的任意使用 `headers` 设置的自定义 `Authorization`头
    auth: {
        username: 'janedoe',
        password: 's00pers3cret'
    },

    // `responseType` 表示服务器响应的数据类型，可以是 'arraybuffer', 'blob', 'document', 'json', 'text', 'stream'
    responseType: 'json', // 默认的

    // `xsrfCookieName` 是用作 xsrf token 的值的cookie的名称
    xsrfCookieName: 'XSRF-TOKEN', // default

    // `xsrfHeaderName` 是承载 xsrf token 的值的 HTTP 头的名称
    xsrfHeaderName: 'X-XSRF-TOKEN', // 默认的

    // `onUploadProgress` 允许为上传处理进度事件
    onUploadProgress: function (progressEvent) {
        // 对原生进度事件的处理
    },

    // `onDownloadProgress` 允许为下载处理进度事件
    onDownloadProgress: function (progressEvent) {
        // 对原生进度事件的处理
    },

    // `maxContentLength` 定义允许的响应内容的最大尺寸
    maxContentLength: 2000,

    // `validateStatus` 定义对于给定的HTTP 响应状态码是 resolve 或 reject  promise 。如果 `validateStatus` 返回 `true` (或者设置为 `null` 或 `undefined`)，promise 将被 resolve; 否则，promise 将被 rejecte
    validateStatus: function (status) {
        return status >= 200 && status < 300; // 默认的
    },

    // `maxRedirects` 定义在 node.js 中 follow 的最大重定向数目
    // 如果设置为0，将不会 follow 任何重定向
    maxRedirects: 5, // 默认的

    // `httpAgent` 和 `httpsAgent` 分别在 node.js 中用于定义在执行 http 和 https 时使用的自定义代理。允许像这样配置选项：
    // `keepAlive` 默认没有启用
    httpAgent: new http.Agent({keepAlive: true}),
    httpsAgent: new https.Agent({keepAlive: true}),

    // 'proxy' 定义代理服务器的主机名称和端口
    // `auth` 表示 HTTP 基础验证应当用于连接代理，并提供凭据
    // 这将会设置一个 `Proxy-Authorization` 头，覆写掉已有的通过使用 `header` 设置的自定义 `Proxy-Authorization` 头。
    proxy: {
        host: '127.0.0.1',
        port: 9000,
        auth: {
            username: 'mikeymike',
            password: 'rapunz3l'
        }
    },

    // `cancelToken` 指定用于取消请求的 cancel token
    // （查看后面的 Cancellation 这节了解更多）
    cancelToken: new CancelToken(function (cancel) {
    })
}
```

## 3.2 config 的默认值

- 可以指定将被用在各个请求的配置默认值

**全局 axios 对象默认值**

- 全局默认值通过 axios.default 进行设置
```js
axios.defaults.baseURL = 'https://api.example.com';
axios.defaults.headers.common['Authorization'] = AUTH_TOKEN;
axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded';
```

**自定义实例默认值**

- 自定义实例的默认值通过创建时提供的 config 对象指定，在创建之后，则通过实例的 defaults 属性修改
```js
// 创建实例时设置配置的默认值
var instance = axios.create({
    baseURL: 'https://api.example.com'
});

// 在实例已创建后修改默认值
instance.defaults.headers.common['Authorization'] = AUTH_TOKEN;
```

## 3.3 配置生效的顺序

- 配置会以一个优先顺序进行合并，这个顺序是 : 
    - 在 lib/defaults.js 找到的库的默认值
    - 然后是实例的 defaults 属性
    - 最后是请求的 config 参数
    - 后者将优先于前者
- 样例如下 :
```js
// 使用由库提供的配置的默认值来创建实例
// 此时超时配置的默认值是 `0`
let instance = axios.create();

// 覆写库的超时默认值
// 现在，在超时前，所有请求都会等待 2.5 秒
instance.defaults.timeout = 2500;

// 为已知需要花费很长时间的请求覆写超时设置
instance.get('/longRequest', {
    timeout: 5000
});
```



# 4. 响应结构

- 使用 axios 请求得到的结果为 promise 对象，其 then 中回调函数的参数即为 response 对象，而 catch 中回调函数的参数即为 error 对象
```js
axios.get('xxx')
    .then(response => {
        // 正确处理的请求拿到的是 response 对象
        // 正确请求的状态码一般为 2XX
    }).catch(error => {
        // 出错的请求拿到的是 error 对象，error 中可能包含了前面的 response（如果有）
        // 出错的请求状态码一般为 4XX, 5XX
})
```

**response**

- 某个请求的响应结构包含下列信息 :
```js
let response = {
    // `data` 由服务器提供的响应
    data: {},

    // `status` 来自服务器响应的 HTTP 状态码
    status: 200,

    // `statusText` 来自服务器响应的 HTTP 状态信息
    statusText: 'OK',

    // `headers` 服务器响应的头
    headers: {},

    // `config` 是为本次请求提供的配置信息
    config: {}
};
```

**error**

- 对于出错的请求，如果服务器已经给出响应体，则我们可以拿到 error 中的 response
- 一般 error 的处理流程大致如下 :
```js
axios.get('http://localhost:8081/api/test/res401')
    .catch(function (error) {
        if (error.response) {
            // 请求已发出，但服务器响应的状态码不在 2xx 范围内
            console.log('响应体', error.response.data);
            console.log('状态码', error.response.status);
            console.log('响应头', error.response.headers);
        } else {
            // Something happened in setting up the request that triggered an Error
            console.log('Error', error.message);
        }
        console.log('config', error.config);
    });
```

**出错处理**

- 可以使用 validateStatus 配置选项定义一个自定义 HTTP 状态码的错误范围
```js
axios.get('/user/12345', {
  validateStatus: function (status) {
    return status < 500; // 状态码在大于或等于500时才会 reject
  }
})
```



# 5. 拦截器

- 拦截器用于在请求或响应被 then 或 catch 处理前拦截它们
- 通过实例的 interceptors 属性来定义拦截器
```js
// 添加请求拦截器
axios.interceptors.request.use(function (config) {
    // 在发送请求之前做些什么
    return config;
}, function (error) {
    // 对请求错误做些什么
    return Promise.reject(error);
});

// 添加响应拦截器
axios.interceptors.response.use(function (response) {
    // 对响应数据做点什么
    return response;
}, function (error) {
    // 对响应错误做点什么
    return Promise.reject(error);
});
```
- 如果你想在稍后移除拦截器，可以这样：
```js
var myInterceptor = axios.interceptors.request.use(function () {/*...*/});
axios.interceptors.request.eject(myInterceptor);
```
- 可以为自定义 axios 实例添加拦截器 :
```js
var instance = axios.create();
instance.interceptors.request.use(function () {/*...*/});
```


**请求拦截器示例**

```js
// 添加请求拦截器（注意拦截方法每次发送请求都会执行）
axios.interceptors.request.use(function (config) {
    // 在发送请求之前做些什么

    // 若是 get 请求，则添加前缀
    // 拦截器一般用于需要动态根据请求处理一些内容
    // 比如请求前不知 method，不知道是否需要添加前缀，因此无法统一写在全局路径中
    if (config.method === 'get') {
        config.baseURL = 'http://localhost:8081/api/test/'
    }

    return config;
}, function (error) {
    // 对请求错误做些什么
    return Promise.reject(error);
});

axios.get("res200") // 由于拦截器添加了 baseURL 因此可以成功
    .then(response => {
        console.log("get response : ", response);
    }).catch(error => {
    console.log("get error : ", error.response);
});
```

**响应拦截器示例**

```js
// 添加响应拦截器
axios.interceptors.response.use(function (response) {
    // 对响应数据做点什么
    return response;
}, function (error) {
    // 对响应错误做点什么
    if (error.response && error.response.status === 401) {
        // 服务器返回 401 ，重新授权
        // 一般用于刷新token let newToken = await ...

        // 此处直接改地址
        error.response.config.url = 'http://localhost:8081/api/test/item/1';
        // 直接返回新请求的 Promise 对象
        return axios.request(error.response.config)
            .then(resp => {
                console.log('resp', resp)
                return resp;
            })
            .catch(er => {
                return er;
            })
    } else {
        return Promise.reject(error);
    }
});

// 401 响应被拦截，并替换为新请求的响应
axios.get("http://localhost:8081/api/test/res401")
    .then(response => {
        console.log("get response : ", response);
    }).catch(error => {
    console.log("get error : ", error.response);
});
```



# 9. 文件模板

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>测试</title>

    <!-- 引入 axios，像这样引入后可以直接在控制台中使用，但还是建议写在文件中 -->
    <script src="node_modules/axios/dist/axios.min.js"></script>
    <!--或者直接使用 cdn -->
    <!--    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>-->
</head>
<body>

<script>

    axios.defaults.baseURL = 'http://localhost:8081/api/test/';

    function ajax(url, data = {}, method = 'GET') {
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

                    // todo 删除
                    // console.log(responseData)

                    if (responseData.status === 401) {
                        console.log('登录超时，请刷新页面！')
                    } else if (responseData.message) {
                        // console.log(responseData.message);
                        reject(responseData.message);
                    }
                } else {
                    console.log('服务器无响应，请联系网站管理员')
                    console.log(error.message);
                }
            })
        })
    }


    const reqTest = () =>
        ajax('res400');


    async function test() {
        try {
            let res = await reqTest()
            console.log('响应', res)
            console.log('aaa');
        } catch (e) {
            console.log(e)
            console.log('bbb')
        }

    }


    test();


</script>
</body>
</html>
```