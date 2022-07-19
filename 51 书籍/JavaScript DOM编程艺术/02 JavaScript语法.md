

## JavaScript语法

------

### 2.1 准备工作

- 环境：文本编辑器+Web浏览器
- 可在<head>标签内内嵌<script>以执行JavaScript
```
<head>
	<script>
		...
	</script>
</head>
```
- 更好的办法是先把JavaScript代码存入一个单独的文件（最好以.js为扩展名），再利用<script>标签的src属性指向该文件
```
<head>
	<script src="file.js"></script>
</head>
```
- 基于HTML5的页面模板
```
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
  <title>Insert Title Here</title>
</head>
<body>

</body>
</html>
```

### 2.2 语法
	
#### 2.2.1 语句
	
- JavaScript程序由一系列指令组成，这些指令叫作语句
- 语句是构成JavaScript脚本的基本单位
- 建议每一行编写一条JavaScript语句，并且以分号结尾，这是一种好的编程习惯
	
#### 2.2.2 注释

- 行注释： //这是注释 或 <!-- 这是注释
- 块注释： /*这是注释*/
- 注意JavaScript中的 <!-- 是行注释， 和//一样， 并且不要求以-->结尾
- 由于JavaScript解释器在处理<!--风格注释时与HTML做法不同，因此为避免混淆，尽量避免使用<!--风格注释
	
#### 2.2.3 变量
	
- 变量即值会发生变化的量
- 通过赋值操作更改变量的值； mood = "happy"; age = 33;
- JavaScript允许程序员直接对变量赋值而无需声明，但此时这个变量自动被声明为全局变量（即使是在函数内）
- 下属代码，a是局部变量，而b是全局变量
    ```
    function init(){
      var a = 1;
      b = 2;
    }
    ```
- JavaScript区分大小写，变量名只能包含字母、数字、美元符号、下划线，且不能以数字开头
- 函数名、方法名以及对象属性名建议采用驼峰命名法

#### 2.2.4 数据类型
	
- JavaScript是一种弱类型语言，不需要进行类型声明
- 以下是JavaScript重要的几种数据类型
	
    1. 字符串
    	- 由另个或多个字符构成
    	- 包括在引号里，可以是单引号或双引号
    	- 可以使用转义字符
    	
    2. 数值
        ```
    	var age = 33.25;
    	var temp = -20;
    	var temp2 = -20.3333;
    	```
    	
    3. 布尔值
    
    	- var married = true;
    	- 注意不要写成字符串类型： var married = "true"; 是字符串类型，不是布尔类型
		
#### 2.2.5 数组
	
- 字符串、数值和布尔值都是标量
- 标量在任意时刻只能有一个值
- 如果想存储一组值，就需要使用数组
    - `var beatles = Array();`
- 给定数组下标和元素值可以用元素填充数组：
    - `array[index] = element;`
    - `var array = ["value", "value", "value", "value"];`
    - 
        ```
        var beatles = new Array(4);
        batles[0] = "John";
        batles[1] = "Paul";
        batles[2] = "George";
        batles[3] = "Ringo";
        
        var beatles = new Array("John", "Paul", "George", "Ringo");
        var beatles = ["John", "Paul", "George", "Ringo"];
        
        var years = new Array(1940,1941,1942,1943);
        var lennon = new Array("John", 1940, false);
        ```

### 关联数组

```	
var lennon = new Array();
	lennon["name"] = "John";
	lennon["year"] = 1940;
	lennon["living"] = false;
```
- 数值数组可以理解为关联数组的特例，从数组下标到数组元素值的映射
- 采用关联数组可以大大提高可读性
```
var beatles = new Array();
beatles["vocalist"] = lennon;
```
- 但是，使用关联数组并不是一个好习惯，不推荐大家使用
- 本质上，创建关联数组时，创建的是Array对象的属性
- 在JavaScript中，所有的变量实际上都是某种类型的对象，
- 比如一个布尔值就是一个Boolean类型的对象，一个数组就是一个Array类型的对象
- 因此上述代码实际上是给lennon数组添加了name、year、和living三个属性
- 理想情况下，不应该修改Array对象的属性，而应该使用通用的对象Object

#### 2.2.6 对象
	
- 与数组类型，对象也是使用一个名字表示一组值（对象的属性）
- 对象的每个值都是对象的属性
- 
    ```
    var lennon = Object();
    lennon.name = "John";
    lennon.year = 1940;
    lennon.living = false;
    ```
- 上述方法使用Object关键字创建对象，
- 还有另一种更简洁的方法创建对象，即花括号语法：
    - `var lonnon = {name:"John", year:1940, living:false};`
- 属性名命名规则和JavaScript变量相同，类型可以是任何JavaScript值，包括其他对象
- 用对象来代替传统的数组可以通过元素的名字而不是下标来引用它们，增强脚本的可读性
- 
    ```
    var beatles = Array();
    beatles[0] = lennon;
    ```
- 
    ```
    var beatles = {};
    beatles.vocalist = lennon;
    ```
			
### 2.3 操作

#### 算术操作符
	
- `+ - * /`
- +还可以用于字符串的拼接


### 2.4 条件语句

- 
    ```
    if(condition){
    	statements;
    }
    ```

#### 2.4.1 比较操作符

- `> < >= <= `
- `== != === !==`

#### 2.4.2 逻辑操作符

- `&& || !`

### 2.5 循环语句

#### 2.5.1 while循环

```	
car count = 1;
while(count < 11){
	alert(count);
	++count;
}
```

#### 2.5.2 do...while

```	
var count = 1;
do{
	alert(count);
	alert++;
}while(count < 11);
```
#### 2.5.3 for循环

```
for(var count = 1; count <=11; ++count){
	alert(count);
}

var beatles = new Array("John", "Paul", "George", "Ringo");
for(var count = 0; count < beatles.length; ++count){
	alert(beatles[count]);
}
```

### 2.6 函数

- 函数就是一组允许你在代码里随时调用的语句
- 从效果上看，每个函数都相当于一个短小的脚本
- 函数应该先定义后使用
- 示例：
    ```
    function shout(){
    	var beatles = new Array("John", "Paul", "George", "Ringo");
    	for(var count = 0; count < beatles.length; ++count){
    		alert(beatles[count]);
    	}
    }
    ```
- 函数可以提供参数，多个参数采用逗号分开，并且不需要声明类型
    ```
    function multiply(num1, num2){
    	var total = num1 * num2;
    	alert(total);
    }
    
    multiply(10, 2);
    ```

- 函数可以有返回值，返回值不需要额外声明，直接返回即可，例如以下的华氏温度转化为摄氏温度的小程序
    ```
    function convertToCelaius(temp){
    	var res = temp - 32;
    	res = res / 1.8;
    	return res;
    }
    ```

#### 变量的作用域：

- 全局变量：一旦在某个脚本里声明了一个全局变量，你就可以从这个脚本的任何位置，包括有关函数的内部引用它，全局变量的作用域是整个脚本（当然最好先声明后使用）
	
- 局部变量：只存在于对它做出声明的那个函数的内部，那个函数的外部是无法引用它的

- 局部变量会覆盖全局变量

- 在函数里最好显示声明变量，直接使用可能导致错误地引用全局变量而产生隐患
	
- 未声明就使用的变量，默认被声明为全局变量


#### 2.7 对象

- 对象就是由一些彼此相关的属性和方法集合在一起而构成的一个数据实体
- 在JavaScript中，数据和属性使用运算符 . 来访问
- 使用new关键字创建一个对象`var jeremy = new Person;`

##### 2.7.1 內建对象

- 数组Array就是內建对象
- 使用Array的length属性来获取数组的长度
- Math.round() 四舍五入
- var current = new Date(); //创建当前日期的对象
- Date对象提供了以下常用方法：
    - getDay()		获取星期
	- getHours()		小时		
	- getMonth()		月份

##### 2.7.2 宿主对象

- 由Web浏览器提供的预定义对象被称为宿主对象
- 宿主对象主要包括Form、Image和Element，可以使用这些对象获取关于某个给定网页上的表单、图像和各种表单元素的信息
- 本书不使用这些宿主对象获取这些信息，而是采用DOM标准的document对象来获取

