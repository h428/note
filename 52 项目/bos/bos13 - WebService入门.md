[TOC]

# WebService入门

## 一、什么是WebService

1. Web service是一个平台独立的，低耦合的，自包含的、基于可编程的web的应用程序，
可使用开放的XML标准来描述、发布、发现、协调和配置这些应用程序，
用于开发分布式的互操作的应用程序。

2. 简单理解就是两个系统之间的远程调用技术

3. 并且WebService之间的调用可以实现跨语言调用，因为调用使用的是http协议，传输的数据格式为xml

## 二、调用网络上的WebService服务

1. 打开命令行 进入`E:\\test`，输入`wsimport -s . http://ws.webxml.com.cn/WebServices/MobileCodeWS.asmx?wsdl`

2. 此时，该目录会生成.class文件和.java文件，删除class文件，把java文件复制到一个简单的java项目

3. 编写以下调用代码

```
/**
* 远程调用Web Service服务
*/
public class App {

public static void main(String[] args) {
MobileCodeWS ss = new MobileCodeWS();
MobileCodeWSSoap soap = ss.getMobileCodeWSSoap();
String res = soap.getMobileCodeInfo("15659789999", null);
System.out.println(res);
}
}
```

## 三、WebService介绍

WebService调用是基于HTTP协议的
调用时传输的数据是XML格式的，因此可以实现跨语言调用

## 四、HTTP介绍

HTTP请求格式如下：
```
<request-line> //请求行
<headers> //请求头
<blank line> //空行
[<request-body>] //请求体,不一定有
```

在HTTP请求中，第一行必须是一个请求行，用来说明请求类型(get、post)、要访问的资源(url)以及使用的HTTP版本
紧接着是一个首部小节,用来说明服务器要使用的附加信息,在首部之后是一个空行，再此之后可以添加任意的其他数据[称之为主体(body)]
```
POST /getinfo.action HTTP/1.1
HOST www.hao.com
UserAgent ...
contentType application/x-www-form-urlencoded
//这里有一个空行
id=001&name=hao&age=20
```
## 五、SOAP概念

SOAP(Simple Object Access Protocal)，简单对象访问协议
SOAP是基于HTTP的，属于HTTP的范畴

```
POST /getinfo.action HTTP/1.1
HOST www.hao.com
UserAgent ...
Content-Type text/xml; charset=utf-8
Connection keep-alive
//这里有一个空行
```

```
<xml数据>
SOAP对传输的XML进行了约束,同时规定了请求和响应的XML数据格式,envelop和body是固定的
<envelop>
<body>
<!--方法名-->
<getInfo>
<id>01</id>
<getInfo>
<body>
</envelop>
```

## 六、WSDL概念

WSDL(WebService Description Language):Web服务描述语言
就是一个xml文档，用于描述当前服务的一些信息(服务名称、服务发布地址、服务提供的方法、方法的参数类型、方法的返回值类型)
服务名字：wsdl:service
提供的方法：wsdl:operation
WSDL相当于Web服务的使用说明书

## 七、WebService程序

简单的网络应用使用单一的语言写成，它的唯一外部程序就是他所以来的数据库
复杂的网络应用，一般对外公布Service层，其他各个终端共同调用

## 八、基于JDK1.7发布一个简单的WebService服务

```
@WebService
public class HelloService {

public String sayHello(String name){
System.out.println("服务端的sayHello方法被调用了...");
return "hello,"+name;
}

public static void main(String[] args) {
String address = "http://192.168.1.2:8989/hello";
//对应的wsdl为http://192.168.1.2:8989/hello?wsdl
Object implementor = new HelloService();
Endpoint.publish(address, implementor);

}
}
```

## 九、使用JDK的wsimport命令生成本地代码调用WebService服务

wsimport命令用于解析wsdl文件，生成客户端本地代码
-s用于指定目标代码放置在哪
-p用于指定目标的报名，若不指定则和服务器的包名一致
无论服务端的代码使用什么语言写的，都在客户端生成Java代码
```
wsimport -s . -p com.hao.webservice http://192.168.1.2:8989/hello?wsdl
```

## 十、客户端调用代码

```
/**
* 1.通过wsimport命令解析wsdl文件生成本地代码
* 2.通过本地代码创建一个代理对象
* 3.通过代理对象实现远程调用
*/
public class App {

public static void main(String[] args) {
HelloServiceService ss = new HelloServiceService();
//创建客户端代理对象用于远程调用
HelloService proxy = ss.getHelloServicePort();
System.out.println(proxy.sayHello("小明"));
}
}
```


