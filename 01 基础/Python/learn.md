
# 1. 面向过程

## 1.1 标准输入输出、变量和顺序结构

1. 利用 `c=5/9(f-32)` 将华氏温度转换为摄氏温度
```py
f = input()
f = float(f)
c = 5 / 9 * (f - 32)
print("f = %f" % c)
```
2. 本金 1000 元，按下述 3 种方法存款，分别计算一年后的本息和
    1. 活期，年利率为 r1(0.0036)
    2. 一年定期，年利率为 r2(0.0225)
    3. 两次半年定期，年利率为 r3(0.0198)
```py
base = 1000
r1 = 1 + 0.0036
r2 = 1 + 0.0225
r3 = 1 + 0.0198
f1 = base * r1
f2 = base * r2
f3 = (base * r3) * r3

print("f1 = {}, f2 = {}, f3 = {}".format(f1, f2, f3))
```
3. 给定三角形的三条边，计算面积
```py
import math

# 只能单个数输入
a = float(input())
b = float(input())
c = float(input())

p = (a + b + c) / 2
square = math.sqrt(p*(p-a)*(p-b)*(p-c))  # 海伦公式

print("square is {}".format(square))
```
4. 输入a、b、c，求方程 ax^2+bx+c=0 的实根（保证实根存在）
```py
import math

# 只能单个数输入
a = float(input())
b = float(input())
c = float(input())

delta = b ** 2 - 4 * a * c  # py 支持指数运算 **
x1 = (-b + math.sqrt(delta)) / (2 * a)
x2 = (-b - math.sqrt(delta)) / (2 * a)

print("x1 = {}, x2 = {}".format(x1, x2))
```
5. 从键盘输入字符串，并打印输入的字符串
```py
# 默认输入就是字符串
strIn = input()
print(strIn)  # 直接打印
```
6. 从键盘输入一个大写字母，并将其转换为小写字母
```py
data = input()
print(type(data[0]))  # py 无字符类型，data[0] 也是字符串类型
print(data[0].upper())  # 大写
print(data[0].lower())  # 小写
```
7. 输入一个字符，输出对应的 ASCII 码
```py
# ASCII 与字符串(实际上就是字符，长度必须为1，py无字符类型)相互转换
ch = "A"
print(ord(ch))  # char -> ASCII

num = 97
print(chr(num))  # ASCII -> char
```


## 1.2 选择结构

1. 输入 a、b、c，求方程 ax^2+bx+c=0 的解，包括讨论 a=0 和共轭复根的情况
```py
import math

a = float(input())
b = float(input())
c = float(input())

delta = b ** 2 - 4 * a * c

if a == 0:
    print("不是一元二次方程， x = {}".format(-b/c))
elif delta < 0:
    p1 = -b/(2*a)
    p2 = math.sqrt(-delta) / (2*a)
    print("共轭复根 : x1 = {} + {}i, x2 = {} - {}i".format(p1, p2, p1, p2))
elif delta == 0:
    x = -b / (2 * a)
    print("x1 = x2 = {}".format(x))
else:
    x1 = (-b + math.sqrt(delta)) / (2 * a)
    x2 = (-b - math.sqrt(delta)) / (2 * a)
    print("x1 = {}, x2 = {}".format(x1, x2))
```
2. 输入两个实数，并按从小到大输出
```py
# 输入并转化对应类型
a = float(input())
b = float(input())

if a < b:
    print("{}, {}".format(a, b))
else:
    print("{}, {}".format(b, a))
```
3. 输入 3 个数 a，b，c，并按从小到大输出
```py
def min_two(a, b):
    if a < b:
        return a
    else:
        return b


def max_two(a, b):
    if a < b:
        return a
    else:
        return b


# 输入并转化对应类型
a = float(input())
b = float(input())
c = float(input())

m1 = min(min(a, b), c)
m2 = max(max(a, b), c)

print("m1 = {}, m2 = {}, m3 = {}".format(m1, a + b + c - m1 - m2, m2))
```
4. 输入一个字符，判定其是否为大写字母，是的话将其转换为小写字母，否则直接打印该字符
```py
# 输入并转化对应类型
a = float(input())
b = float(input())
c = float(input())

m1 = min(min(a, b), c)  # 求最小值
m2 = max(max(a, b), c)  # 求最大值

print("m1 = {}, m2 = {}, m3 = {}".format(m1, a + b + c - m1 - m2, m2))
```
5. 输入 x，输出符号 sgm 函数的值：x < 0, y = -1, x = 0, y = 0, x > 0, y = 1
```py
x = float(input())

if x < 0:
    y = -1
elif x == 0:
    y = 0
else:
    y = 1

print("y = {}".format(y))
```
6. 利用 switch/多重if else 输入成绩，输出等级 A(>85), B(70-84), C(60-69), D(<60)
```py
x = float(input())

if x < 60:
    print("D")
elif x < 70:
    print("C")
elif x < 85:
    print("B")
else:
    print("A")
```
7. 输入年份，判定是否为闰年
```py
x = int(input())

if (x % 4 == 0 and x % 100 != 0) or (x % 400 == 0):
    print("{} is leap year".format(x))
else:
    print("{} is not leap year".format(x))
```
8. 输入两个整数，求值较大的平方根
```py
import math

a = float(input())
b = float(input())

if b > a:
    a = b

print("val = {}".format(math.sqrt(a)))
```
9. 输入 4 个实数，求平均值
```py
a = float(input())
b = float(input())
c = float(input())
d = float(input())

print("avg = {}".format((a + b + c + d) / 4))
```
10. 输入三角形三条边，判断是否构成三角形，是否构成直角三角形
```py
a = float(input())
b = float(input())
c = float(input())

if a + b > c and a + c > b and b + c > a:
    # 进一步判断是否直角三角形
    if a ** 2 + b ** 2 == c ** 2 or a ** 2 + c ** 2 == b ** 2 or b ** 2 + c ** 2 == a ** 2:
        print("直角三角形")
    else:
        print("普通三角形")
else:
    print("不能构成三角形")
```
11. 随机生成两个数 x, y 并完成交换
```py
import random

val1 = random.random()
val2 = random.randint(0, 9)

print("origin : {}, {}", val1, val2)

val1, val2 = val2, val1
print("swap : {}, {}", val1, val2)
```

## 1.3 循环、函数、数组


**循环**

> 序列

1. 求 `1!+2!+3!+...` 的 20 项的和
```py
sum = 0
for i in range(1, 21):
    # 求阶乘
    fac = 1
    for j in range(1, i+1):
        fac *= j
    sum += fac

print("res = {}".format(sum))
```
2. 计算 `1-3+5-7+...+101` 的值并输出
```py
sum = 0
sign = -1
for i in range(1, 102, 2):
    sign *= -1
    item = sign * i
    sum += item

print("res = {}".format(sum))
```
3. 求序列 (2/1, 3/2, 5/3, 8/5, 13/8, 21/13) 这个数列的前 20 项之和
```py
sum = 0
numerator = 1
denominator = 1
for i in range(20):
    denominator, numerator  = numerator, numerator + denominator
    sum += numerator / denominator
    print("{}/{}".format(numerator, denominator))

print("res = {}".format(sum))
```
4. 输出 A - Z 的所有字符，每行打印  8 个字符
```py
for i in range(26):
    print(chr(ord("A")+i), end="")
    if (i + 1) % 8 == 0:
        print()
```
5. 求 1 到 100 的累加和(5050)
```py
sum = 0
for i in range(101):
    sum += i

print(sum)
```
6. 打印斐波那契数列的前 40 个数
```py
f1 = 0
f2 = 1
for i in range(41):
    f1, f2 = f2, f1 + f2
    print(f2)
```

> 各种数

1. 输入一个大于 3 的整数，判定其是否为素数
```py
x = int(input())

# 素数判定
flag = True
for i in range(2, x):
    if x % i == 0:
        flag = False
        break

if flag:
    print("{} is a prime num".format(x))
else:
    print("{} is not a prime num".format(x))
```
2. 求 100-200 间的全部素数
```py
for x in range(100, 201):
    # 素数判定
    flag = True
    for i in range(2, x):
        if x % i == 0:
            flag = False
            break

    if flag:
        print("{} is a prime num".format(x))
    else:
        print("{} is not a prime num".format(x))
```
3. 输出 100-200 之间不能被 3 整除的数
```py
for x in range(100, 201):
    if x % 3 == 0:
        print("{} 能整除 3".format(x))
    else:
        print("{} 不能整除 3".format(x))
```
4. 求 100-1000 的水仙花数
```py
for x in range(100, 1000):
    n1 = x % 10
    n2 = x // 10 % 10 # 整除要用 //
    n3 = x // 100 % 10

    if (n1 ** 3 + n2 ** 3 + n3**3) == x:
        print("{} 是水仙花数".format(x))
```
5. 求 0-10000 的完数（所有真因子之和等于本身，如 6=1+2+3），并打印数和因子
```py
for x in range(1, 10000):

    sum = 0
    for i in range(1, x): # 计算因子累加和
        if x % i == 0:
            sum += i
    if sum == x:
        print(x)
```
6. 输出 1 到 99999 的所有回文数
```py
for x in range(1, 100000):
    arr = []
    idx = 0
    tmp = x
    while tmp :
        arr.append(tmp % 10)
        tmp //= 10
    flag = True
    for i in range(0, len(arr)):
        if arr[i] != arr[len(arr)-1-i]:
            flag = False
            break
    if flag:
        print(x)
```

> 处理与计算

1. 一个球从 100 米高度自由落下，每次落地后反弹回元高度的一半，求他在第 10 次落地时，共经过多少米，第 10 次反弹多高
2. 给定十进制，返回 2/8/16 进制
3. 输入一个不大于 100000 的正整数，计算该整数的位数及各位数之和
4. 在全部 1000 名学生中募捐，当捐款金额达到 10 万元时结束，此时统计捐款人数，并打印平均募捐金额
5. 用近似公式 `pi/4 = 1 - 1/3 + 1/5 - 1/7 + ...` 求 pi，直到某一项的绝对值小于 10^-6
6. 给定 n, k，求解整数 n 从右边开始的第 k 个数

> 打印

1. 打印如下 4*5 矩阵
```
1 2 3 4 5
2 4 6 8 19
3 6 9 12 15
4 8 12 16 20
```
2. 输入 n，打印由字符 `*` 组成的塔，第 i 行有 i 个 `*`
3. 打印 99 乘法表
4. 输出杨辉三角
5. 输出 n 阶幻方

> 其他

1. 给定 n 个数，求 n 个数的和、平均成绩、最大值、最大值对应下标、最小值、最小值对应下标
2. 实现排序算法(冒泡、选择、插入、归并、快排)

**数组**

1. 使用数组完成前面循环的所有操作
2. 输入二维数组，返回最大值（和对应的坐标）
3. 手动实现二维数组的转置
4. 给定年月日，判定是该年第几天
5. 依次输入 10 个数字，然后逆序存储，最后输出
6. 求矩阵的对角线元素之和

**函数**

1. 将前面循环、数组的练习全部改造成合适的函数调用方式
2. 比较两个数的大小，返回最大值
3. 比较三个数的大小，返回最大值
4. 递归方法求 n!
5. 解决汉诺塔问题

## 1.5 字符串

1. 字符串基本操作：取字符、求长度、拷贝、比较、大小写转换、连接等
2. 输入字符串，输出其对应的 ASCII 码，以空格分隔
3. 输入一行字符，统计其有多少单词，单词之间使用空格分开（编写手动编写和利用 split 两种实现）
4. 输入 3 个字符串，找到其中的最大者
5. 输入一行文本，统计该文本中 A-Z 的个数（忽略大小写）
6. 判断一个字符串是否回文串
7. 正则表达式的使用方法：匹配手机号，邮箱，标识符
8. 给定两个字符串，将一个字符串中的元音添加到另一个字符串末尾

# 2. 容器类型

1. List（顺序表, 链表）, Set（HashSet, TreeSet）, Map（HashMap, TreeMap） 的基本操作：定义，增加元素，在指定位置增加元素，遍历元素，取出对应元素
2. 对各个容器类型的排序

# 3. 文件操作

1. 读写文本文件（字符串）
2. 读写二进制（基本类型、结构体等）
3. 长度为 10 的整型数组，存入文件，每行一个数，然后再读取出来放到数组中
4. 维度为 (3, 4) 的浮点型矩阵，分别以分隔符空格和逗号，存入两个文件，然后从两个文件中读取出来对应的数并存储矩阵
5. 对上述需求使用二进制方式进行读写，二进制则无所谓行

# 4. 面向对象

1. 测试封装、继承、多态特性
2. 定义学生类，含有学号，姓名，以及三门课的成绩，编写方法完成输入、输出，定义比较函数，并调用函数库进行排序
3. 定义复数类，完成基本的操作
4. 定义时间类，完成基本的操作
5. 练习继承，Person 类和 Student 类

# 5. 数据结构

1. 线性表（顺序表和链表）
2. 栈和队列
3. 二叉树

# 6. 设计模式

1. 单例模式
2. 观察者模式
3. 装饰模式
4. 职责链模式
5. 适配器模式
6. 工厂模式