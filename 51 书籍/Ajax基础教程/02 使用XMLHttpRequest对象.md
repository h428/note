
## 使用XMLHttpRequest对象

---

### 2.1 XMLHttpRequest对象概述


- 创建代码如下：
```
var xmlHttp;

function createXMLHttpRequest(){
	if(window.ActiveXObject){
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else if(window.XMLHttpRequest){
		xmlHttp = new XMLHttpRequest();
	}
}
```

### 2.2 方法和属性

#### 1、XMLHttpRequest方法：
		
- open(string method, string url, boolean asynch, string username, string password)
    - 建立对服务器的调用，method可以是GET、POST、PUT，这个方法还可以包括3个可选参数
	- asynch设置该调用是同步的还是异步的，默认为true，表示请求本质上是异步的
	- 如果为false，处理就会等待，直到从服务器返回响应为止
	- 由于异步调用是使用Ajax的主要优势之一，倘若设置为false，则失去了异步的功效，更像是一次同步的HTTP请求

- send(content)						
    - 向服务器发送请求
    - 如果请求声明为异步的，这个方法就会立即返回，否则它会等待知道接收到响应为止
    - 可选参数可以是DOM对象的实例、输入流，或者串
    - 传入这个方法的内容会作为请求体的一部分发送

- setRequestHeader(string header, string value)	
	- 该方法用于设置请求首部， header/value键值对表示首部信息
	- 该方法必须调用open()之后才能调用
	
- abort()	
	- 停止当前请求
	
- string getAllResponseHeaders()	
	- 该方法返回一个串，包含HTTP请求的所有响应首部

- string getResponseHeader(string header)		
	-取得指定的响应首部

#### 2、XMLHttpRequest属性

- onreadystatechange		           
    - 每个状态改变都会出发这个事件处理器，通常会调用一个JavaScript函数（成为回调函数，callback）readyState	
    - 请求的状态，有5个可取值：0=未初始化，1=正在加载，2=已加载，3=交互中，4=完成
- responseText			
    - 服务器的响应，表示为一个串
- responseXML				
    - 服务器的响应，表示为XML，这个对象可以解析为DOM对象status
    - 服务器的HTTP状态码（200对应OK，404对应Not Found等等）
- statusText
    - HTTP状态码的相应文本（OK或Not Found等等）

### 2.3 交互示例

1. 客户端时间出发一个Ajax事件，典型的就是按钮的点击
    - `<button type="button" value="提交" onclick="validateEmail()">`

2. 创建XMLHttpRequest对象实例，调用open方法，设置URL以及HTTP方法，设置回调函数，并调用send函数触发

3. 向服务器做出请求，可能调用Servlet、CGI等服务端技术
	
4. 服务器进行业务逻辑操作、访问数据库等

5. 请求返回到浏览器。
	- Content-Type设置为text/html，XMLHttpRequest对象只能处理text/html类型的结果
	- 服务端需要设置浏览器不会在本地缓存结果
        ```
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Prama", "no-cache"); //为了保证向后兼容性
        ```
6. XMLHttpRequest调用回调函数

### 2.4 GET与POST

- GET请求是幂等的，POST请求不是幂等的
- 幂等指多个请求返回相同的结果
- 如果需要改变服务器、数据库状态，一般要使用POST方法
- 使用Ajax做POST请求时，要使用xmlHttp额外设置一个请求头：
    - `xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");`
- POST不会限制发送给服务器的数据大小，而且POST不能保证请求是幂等的

### 2.5 远程脚本
	
	略

### 2.6 如何发送简单请求

#### 使用XMLHttpRequest对象发送请求的基本步骤如下：

- 为得到XMLHttpRequest对象，可以创建一个新的实例，或者使用一个已经存在的变量
- 告诉XMLHttpRequest，哪个函数会处理XMLHttpRequest对象状态的改变（回调函数）
    - `xmlHttp.onreadystatechange = callback();`
- 指定请求的属性：
    - `xmlHttp.open("POST", url, true);`
- 将请求发送给服务器
    - `xmlHttp.send(参数串);`
	
#### 简单请求示例
	
```
var xmlHttp;

//根据浏览器创建对应的XMLHttpRequest对象
function createXMLHttpRequest(){
	if(window.ActiveXObject){
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else if(window.XMLHttpRequest){
		xmlHttp = new XMLHttpRequest();
	}
}

function startRequest(){
	createXMLHttpRequest();
	//设置回调函数
	xmlHttp.onreadystatechange = callback;
	//指定请求属性
	var url = "";
	xmlHttp.open("GET", url, true);
	xmlHttp.send(null);
}

function callback(){
	if(xmlHttp.readyState == 4){
		if(xmlHttp.status == 200){
			alert("服务器返回："+xmlHttp.responseText);
		}
	}
}
```
	
	
	
	
	
	