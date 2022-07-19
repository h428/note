
# 0. 说明

- 本教程来自于莫烦 Python
- 使用先前导入 numpy 模块：`import numpy as np`
- 对于许多操作，axis 表示其操作方向，不能死记为对行或对列的操作，而是要理解
- axis 指明了操作方向，axis=0 表示从上往下操作（按行方向），axis=1 表示从左往右操作（按列方向）
- 比如，对于求和 np.sum，axis=0，从上往下，按行方向求和，那就是对每一列求和
- 比如，对于 df.dropna(axis=0) ，从上往下 drop，那就是扔掉包含 NaN 的行
- 同样是 axis=0，np.sum 体现为对列求和，df.dropna 体现为扔掉行，因此不能死记硬背



# 1. numpy 基础


## 1.1 ndarray 对象

- ndarray 是 numpy 中的 N 维数组对象，它是一系列同类型数据的集合，下标从 0 开始索引
- ndarray 是用于存放相同类型元素的多维数组，其中的每个元素在内存中占据相同的存储大小
- numpy 内部由以下内容组成：
    - 指向数据区域的指针
    - 数据类型 dtype
    - 描述数组形状的元组，其存储了数组的各维度大小 shape
    - 一个跨度元祖 stride，其各个值描述为了前进到当前维度下一个元素需要"跨过"的字节数
- 跨度可以是负数，这样会使数组在内存中后向移动，切片中 `obj[::-1]` 或 `obj[:,::-1]` 就是如此

## 1.2 数据类型

- numpy 支持的数据类型比 Python 内置的类型要多很多，基本上可以和 C 语言的数据类型对应上，其中部分类型对应为 Python 内置的类型，可查看 [numpy数据类型](http://www.runoob.com/numpy/numpy-dtype.html)
- numpy 的数值类型实际上是 dtype 对象的实例，并对应唯一的字符，包括 np.bool_，np.int32，np.float32，等等

**数据类型对象 np.dtype**

- 数据类型对象用于描述 ndarray 对应的内存区域如何使用，其依赖以下方面：
    - 数据的类型（整数、浮点数、Python 对象）
    - 数据的大小（例如整数用多少字节存储）
    - 数据的字节顺序（大端法、小端法）
    - 在结构化类型的情况下，字段的名称、每个字段的数据类型和每个字段所取的内存块的部分
    - 如果数据类型是子数组，它的形状和数据类型
- 字节顺序是通过对数据类型预先设定"<"或">"来决定的。"<"意味着小端法(最小值存储在最小的地址，即低位组放在最前面)。">"意味着大端法(最重要的字节存储在最小的地址，即高位组放在最前面)
- 可以使用 `numpy.dtype(object, align, copy)` 构造 dtype 对象
    - object - 要转换为的数据类型对象
    - align - 如果为 true，填充字段使其类似 C 的结构体。
    - copy - 复制 dtype 对象 ，如果为 false，则是对内置数据类型对象的引用
- 前面提供的 numpy 数据类型实际上是 np.dtype 类型的实例

**样例**

- 标量类型：`dt = np.dtype(np.int32)`
- int8, int16, int32, int64 四种数据类型可以使用字符串 'i1', 'i2', 'i4', 'i8' 代替，例如 `dt = np.dtype('i4')`
- 字节顺序标注：`dt = np.dtype('<i4')`
- 将 dtype 应用到 ndarray，其中每个元素是一个单变量元组，即 age
```py
dt = np.dtype([('age',np.int8)]) # 首先创建结构化数据类型
a = [(10,),(20,),(30,)] # 内置 list
arr = np.array(a, dtype = dt) # 将数据类型应用于 ndarray 对象
```
- 元素类型可以类似结构体那样，相当于每个元素是一个元组
```py
student = np.dtype([('name','S20'), ('age', 'i1'), ('marks', 'f4')]) 
a = np.array([('abc', 21, 50),('xyz', 18, 75)], dtype = student)
```
- 每个内置类型都有一个唯一的定义它的字符代码，例如 S 表示字符串，i 表示整型，f 表示浮点型

## 1.3 数据属性

- ndarray.ndim	秩，即轴的数量或维度的数量，结果是一个整数
- ndarray.shape	数组的维度，对于矩阵，n 行 m 列，结果是一个元组
- ndarray.size	数组元素的总个数，相当于 .shape 中 n*m 的值，结果是一个整数
- ndarray.dtype	ndarray 对象的元素类型，返回 numpy.dtype 类型实例
- ndarray.itemsize	ndarray 对象中每个元素的大小，以字节为单位，结果是一个整数
- ndarray.flags	ndarray 对象的内存信息
- ndarray.real	ndarray元素的实部，结果是一个 ndarray
- ndarray.imag	ndarray 元素的虚部，结果是一个 ndarray
- ndarray.data	包含实际数组元素的缓冲区，由于一般通过数组的索引获取元素，所以通常不需要使用这个属性

# 2. 各种创建方式

## 2.1 常用快速创建方式

- `numpy.empty(shape, dtype = float, order = 'C')` 创建一个未初始化的数组
    - shape	数组形状，接受 list 或 tuple 类型参数（可能由于内部只用了元素下标运算符 `[]`，但建议采用 list 形式的参数）
    - dtype	数据类型，可选，默认是 numpy 中的 float64 类型
    - order	有"C"和"F"两个选项,分别代表，行优先和列优先，在计算机内存中的存储元素的顺序
    - 样例： `x = np.empty([3,2], dtype = int) ` 或 `x = np.empty((3,2), dtype = int) `
- `numpy.zeros(shape, dtype = float, order = 'C')` 创建一个全为 0 的数组
    - 参数和前面保持一致，下面没有特殊说明，参数含义保持一致
    - 默认创建 float64 类型 `x = np.zeros(5) `
    - 指定为 int 型 `x = np.zeros((5,), dtype = np.int)`
    - 指定为自定义类型 `x = np.zeros((2,2), dtype = [('x', 'i4'), ('y', 'i4')])`
- `numpy.ones(shape, dtype = None, order = 'C')` 创建一个全 1 数组
    - 默认为浮点数 `x = np.ones(5)`
    - 设置为 int 型 `x = np.ones([2,2], dtype = int)`


## 2.2 从已有数组创建

- 使用内置 list 创建 ndarray : `numpy.array(object, dtype = None, copy = True, order = None, subok = False, ndmin = 0)`
    - object : 数组或嵌套的数列
    - dtype : 数组元素的数据类型，可选
    - copy : 对象是否需要复制，可选
    - order : 创建数组的样式，C 为行方向，F 为列方向，A 为任意方向（默认）
    - subok : 默认返回一个与基类类型一致的数组
    - ndmin : 指定生成数组的最小维度
- `numpy.asarray(a, dtype = None, order = None)`，作用类似 numpy.array，但 numpy.asarray 只有三个
    - a	任意形式的输入参数，可以是，列表, 列表的元组, 元组, 元组的元组, 元组的列表，多维数组
    - dtype	数据类型，可选
    - order	可选，有"C"和"F"两个选项,分别代表，行优先和列优先，在计算机内存中的存储元素的顺序
    - 从 list 创建 `x = np.asarray([1,2,3])`
    - 从 tuple 创建 `x = np.asarray((1,2,3))`
    - 不规则 list `x = np.asarray([(1,2,3),(4,5)]) `，每一个元素是一个 object 类型

- `numpy.frombuffer(buffer, dtype = float, count = -1, offset = 0)` 用于实现动态数组，其接受 buffer 输入参数，以流的形式读入转化成 ndarray 对象
    - buffer 可以是任意对象，会以流的形式读入
    - dtype 返回数组的数据类型，可选
    - count 读取的数据数量，默认为-1，读取所有数据。
    - offset 读取的起始位置，默认为0
    - 样例 `x = np.frombuffer(b'Hello World', dtype =  'S1')`
- `numpy.fromiter(iterable, dtype, count=-1)` 从迭代器中取出对象创建 ndarray，返回一位数组：
    - iterable 可迭代对象
    - dtype 返回数组的数据类型
    - count 读取的数据数量，默认为-1，读取所有数据

## 2.3 从数值范围创建数组

- `numpy.arange(start, stop, step, dtype)` 生成 [start, stop) 区间的数据，步长为 step
    - start 起始值，默认为 0
    - stop 终止值（不包含）
    - step 步长，默认为 1
    - dtype	返回 ndarray 的数据类型，如果没有提供，则会使用输入数据的类型
    - 样例 `x = np.arange(5)`，默认是 int32 型
    - 设置类型 `x = np.arange(5, dtype =  float)`
    - 设置步长 `x = np.arange(10,20,2)`
- `np.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None)` 生成区间 [start, stop] 的等差数列，公比根据数量 num 自动确定
    - start 序列的起始值
    - stop 序列的终止值，如果 endpoint 为 true，该值包含于数列中
    - num 要生成的等步长的样本数量，默认为 50
    - endpoint 该值为 ture 时，数列中中包含 stop 值，反之不包含，默认是 True
    - retstep	如果为 True 时，生成的数组中会显示间距，反之不显示。
    - dtype ndarray 的数据类型
    - 样例 `x = np.linspace(1,10,10)`
    - 不包含 stop `a = np.linspace(10, 20,  5, endpoint =  False)`
    - 设你想要的公比为 d，则若生成序列中包含 stop，则 num 应该设置为 $(stop - num) / d + 1$
- `np.logspace(start, stop, num=50, endpoint=True, base=10.0, dtype=None)` 用于创建一个于等比数列：
    - start 序列的起始值为：base ** start，** 表示次方
    - stop 序列的终止值为：base ** stop。如果 endpoint 为true，该值包含于数列中
    - num 要生成的等步长的样本数量，默认为50
    - endpoint 该值为 ture 时，数列中中包含stop值，反之不包含，默认是True。
    - base 对数 log 的底数。
    - dtype ndarray 的数据类型
    - 样例 `x = np.logspace(1,10,10, base=2)`
    - 注意前面三个参数生成等差数列，然后将它们应用于底数上，因此生成等比数列

# 3. 常用操作

## 3.1 基本操作

**调整形状**

- 使用 `np.reshape(a, newshape, order='C')` 方法调整
    - a 待调整的数组
    - newshape 新形状，是一个 list 或 tuple
    - order 可选，'C' -- 按行，'F' -- 按列，'A' -- 原顺序，'k' -- 元素在内存中的出现顺序
    - 该方法不改变原数组，而是返回调整后的数组
- 直接使用 `np.ndarray.reshape(shape, order='C')` 执行调整
    - 参数含义和前面一致
    - 该操作直接在原数组调整，是 O(1) 操作
- `numpy.ndarray.flat` 将数组展开为迭代器，可以用于遍历：
```py
for element in a.flat:
    print (element)
```
- `np.ndarray.flatten(order='C')` 返回一份数组拷贝，对拷贝所做的修改不影响原数据
    - order：'C' -- 按行，'F' -- 按列，'A' -- 原顺序，'K' -- 元素在内存中的出现顺序
    - 注意展开为一位数组后，仍然是 ndarray，当然，也可以直接用于遍历
    - 例如 `print(a.flatten())`
- `numpy.ravel(a, order='C')` 返回展平的数组元素，返回的是原数组的视图（类似 C++ 中的引用），修改会影响原有数组值：
    - order：'C' -- 按行，'F' -- 按列，'A' -- 原顺序，'K' -- 元素在内存中的出现顺序
    - `print(a.ravel())`
    - `a.ravel()[0] = 100` 会改变 a 中的值，而 flatten 不会

**转置**

- 使用 ndarray 对象的 .T 方法进行转置，只适用于二维数组，对于非正规向量返回自身
- 可以使用 `numpy.transpose(a, axes=None)` 进行高维数组转置，对于二维的情况，和 .T 效果一致
```py
x = np.arange(4).reshape((2,2))
np.transpose(x)
```
- 也可以直接使用 ndarray 自带的 tanspose() 方法
```py
np.arange(4).reshape((2,2))
x.transpose()
```


## 3.2 切片和索引

**切片**

- 可以使用内置的 slice 函数编写切片，其参数分别为 start, stop, step
```py
a = np.arange(10)
s = slice(2,7,2)   # 从索引 2 开始到索引 7 停止，间隔为2
```
- 也可以直接在下标中编写切片（推荐）
```py
a = np.arange(10)  
b = a[2:7:2]   # 从索引 2 开始到索引 7 停止，间隔为 2
```
- 冒号 : 的解释：
    - 如果只放置一个参数，没有冒号，如 `[2]`，则取出对应元素
    - 如果为 `[2:]`，表示从该索引开始以后的所有项都将被提取
    - 如果使用了两个参数，如 `[2:7]`，那么则提取两个索引(不包括停止索引)之间的项，即默认步长为 1
- 选择某行或某列的所有元素，可以使用 ... 或者 : 表示所有元素，例如下述代码
```py
a = np.array([[1,2,3],[3,4,5],[4,5,6]]) 
print (a[...,1])   # 第2列元素
print (a[:,1])   # 第2列元素
print (a[1,...])   # 第2行元素
print (a[1,:])  # 第2行元素
print (a[...,1:])  # 第2列及剩下的所有元素
print (a[:,1:])# 第2列及剩下的所有元素
```

**整数数组索引**

- 可以直接用一个整数取出，这个整数表示在数组中的第几个数
```py

```
- 可以利用 list 或 tuple 组成的额行列信息，分散地取出各个位置上的元素
```py
x = np.array([[1,  2],  [3,  4],  [5,  6]]) 
y = x[[0,1,2],  [0,1,0]] # list 写法，取出 (0, 0), (1, 1), (2, 0) 上个位置上的元素
y = x[(0,1,2),  (0,1,0)] # tuple 写法，和上一行效果一样
```
- 取出的分散元素，还可以按照想要的格式组合成新的数组
```py
x = np.array([[  0,  1,  2],[  3,  4,  5],[  6,  7,  8],[  9,  10,  11]])  
rows = np.array([[0,0],[3,3]]) # 要取出元素的行坐标
cols = np.array([[0,2],[0,2]]) # 要取出元素的列坐标
y = x[rows,cols] # 行列数组的结构就是你最终想要的数据结构，二者应该一致
```
- 可以使用 ... 和 : 索引数组组合

**布尔索引**

- 布尔索引即使用条件索引指定元素
```py
x = np.array([[  0,  1,  2],[  3,  4,  5],[  6,  7,  8],[  9,  10,  11]])
print (x[x >  5]) # 输出时，选取到的元素会展开为向量形式
```
- 也可以赋值或者直接拿到对应的 bool 数组
```py
x = np.array([[  0,  1,  2],[  3,  4,  5],[  6,  7,  8],[  9,  10,  11]])
print (x[x >  5]) # 输出时，选取到的元素会展开为向量形式
x[x>5] = -1 # 也可以利用布尔索引进行赋值
x > 5 # 结果是一个等规模的 ndarray，称之为 mask 数组
```
- 另外还可以利用 ~ 运算符取反，如下面例子
```py
a = np.array([np.nan, 1, 2, np.nan, 3, 4, 5])  
print (a[~np.isnan(a)]) # ~ 取反，取出不是 nan 的数
```

**花式索引**

- 花式索引根据索引数组的值作为目标数组的某个轴的下标来取值。对于使用一维整型数组作为索引，如果目标是一维数组，那么索引的结果就是对应位置的元素；如果目标是二维数组，那么就是对应下标的行
- 很像整数数组索引的化简
```py
x=np.arange(32).reshape((8,4))
print (x[[0,1,3]]) # 拿出 0, 1, 3 行
```
- 也可以使用负数表示倒序索引
```py
x=np.arange(32).reshape((8,4))
print (x[[-8, -7]]) # 其实就是第 0 行和第 1 行
```
- 传入多个索引数组（要使用np.ix_）
```py
x=np.arange(32).reshape((8,4))
print (x[np.ix_([1,5,7,2],[0,3,1,2])])
```


# 4. 常用运算


# 5. 高级特性

## 5.1 广播

- 当运算中的 2 个数组的形状不同且满足广播条件时，numpy 将自动触发广播机制，例如
```py
a = np.array([[ 0, 0, 0],
           [10,10,10],
           [20,20,20],
           [30,30,30]])
b = np.array([1,2,3])
print(a + b)
```
- 也可以利用 `np.tile` 进行广播
```py
a = np.array([[ 0, 0, 0],
           [10,10,10],
           [20,20,20],
           [30,30,30]])
b = np.array([1,2,3])
bb = np.tile(b, (4, 1)) # 广播，bb 相当于 b 复制了 4 行
print(a + bb)
```

## 5.2 迭代数组

- 利用 `np.nditer` 获取 ndarray 的逐元素迭代器（默认将按第一维迭代，例如二维矩阵按行迭代）
```py
for x in np.nditer(a):  # 以内存顺序迭代数组 a，a.T 效果也一样
    print (x, end=", " )
```
- 而且要注意，迭代的顺序即为在内存中存储的顺序，因此转置后不产生作用
- a 和 a.T 的遍历顺序是一样的，也就是他们在内存中的存储顺序也是一样的，但是 `a.T.copy(order = 'C')` 的遍历结果是不同的，那是因为它和前两种的存储方式是不一样的，默认是按行访问
- 如果要控制遍历顺序，则需要利用 nditer 的 order 属性，例如 `for x in np.nditer(a, order='F')`（Fortran 语言） 为列优先，`for x in np.nditer(a.T, order='C')` 为行优先（C语言）
- 迭代时，默认不可修改值，若需要修改，需要设置可选参数 op_flags 为 read-write 或者 write-only，例如：
```py
for x in np.nditer(a, op_flags=['readwrite']): # 迭代并修改数组元素
    x[...]=2*x 
print (a)
```
- np.nditer 构造器还有 flags 参数，其接受下述参数值：
    - c_index 可以跟踪 C 顺序的索引
    - f_index 可以跟踪 Fortran 顺序的索引
    - multi-index 每次迭代可以跟踪一种索引类型
    - external_loop 给出的值是具有多个值的一维数组，而不是零维数组
```py
for x in np.nditer(a, flags =  ['external_loop'], order =  'F'): 
    print (x, end=", " ) # 配合两个参数，这样就是按列遍历数组，每个元素是一列
```
- 如果两个数组是可广播的，nditer 组合对象能够同时迭代它们
```py
a = np.arange(0,60,5).reshape(3,4)
b = np.array([1,  2,  3,  4], dtype =  int)  
for x,y in np.nditer([a,b]):  
    print ("%d:%d"  %  (x,y), end="\n" )
```

> 分割线


---


# 3. 矩阵的加法、减法、数乘、数学运算、元素判断等

```py
# 3. 矩阵的加法、减法、数乘、数学运算、元素判断等
a = np.array([10, 20, 30, 40])
"""
[10 20 30 40]
"""
b = np.arange(4)  # [0, 1, 2, 3]
"""
[0 1 2 3]
"""

# 常见运算
print(a - b)  # 减法
"""
[10 19 28 37]
"""
print(a + b)  # 加法: [10 21 32 43]
"""
[10 21 32 43]
"""
print(b ** 2)  # 逐元素平方
"""
[0 1 4 9]
"""
print(10*np.sin(a))  # 数乘与常见数学运算
"""
[-5.44021111  9.12945251 -9.88031624  7.4511316 ]
"""

# 元素判断
print(b < 3)  # 小于3的位置为True，否则False，dtype=bool
"""
[ True  True  True False]
"""
```

# 4. 矩阵逐元素相乘、矩阵乘法

```py
# 4. 矩阵逐元素相乘、矩阵乘法
a = np.array([[1,1],
            [0, 1]])
"""
[[1 1]
 [0 1]]
"""
b = np.arange(4).reshape((2,2))
"""
[[0 1]
 [2 3]]
"""

print(a*b)  # 每个对应位置的元素相乘 [[0 1] \n [0 3]]
"""
[[0 1]
 [0 3]]
"""
print(np.dot(a, b))  # 矩阵乘法 [[2 4] \n [2 3]]
"""
[[2 4]
 [2 3]]
"""
print(a.dot(b))  # 矩阵乘法的另一种形式  [[2 4] \n [2 3]]
"""
[[2 4]
 [2 3]]
"""
```

# 5. 矩阵求和、求最大、求最小（可按行列或整个矩阵）

```py
# 5. 矩阵求和、求最大、求最小（可按行列或整个矩阵）

np.random.seed(1)  # 设置随机种子，保证结果的一致性
arr = np.random.random([2, 4])  # 随机生成区间 [0,1] 的指定形状的随机数
print(arr)
"""
[[  4.17022005e-01   7.20324493e-01   1.14374817e-04   3.02332573e-01]
 [  1.46755891e-01   9.23385948e-02   1.86260211e-01   3.45560727e-01]]
"""

col_sum = np.sum(arr, axis=1, keepdims=True)  # 求和，axis=1表示按行求和，注意结果会自动变为序列(2,)，需要使用keepdims=True保持列向量形状(2,1)
row_min = np.min(arr, axis=0, keepdims=True)  # 每列最小值，axis=0表示每列，使用keepdims=True保证为行向量，否则形状变为 (4,) 而不是 (1, 4)
col_max = np.max(arr, axis=1, keepdims=True)  # 每行最大值，axis=1表示行，使用keepdims=True保证为列向量
all_sum = np.sum(arr)  # 若不提供 axis 参数，则默认求整个矩阵的和，max和min类似

print(col_sum)
"""
[[ 1.43979345]
 [ 0.77091542]]
"""
print(row_min)
"""
[[  1.46755891e-01   9.23385948e-02   1.14374817e-04   3.02332573e-01]]
"""
print(col_max)
"""
[[ 0.72032449]
 [ 0.34556073]]
"""
print(all_sum)
"""
2.2107088696
"""
```

# 6. 最大、最小值索引（可按行、列、整个矩阵）

```py
# 6. 最大、最小值索引（可按行、列、整个矩阵）
arr = np.arange(2, 14).reshape((3, 4))
print(arr)
"""
[[ 2  3  4  5]
 [ 6  7  8  9]
 [10 11 12 13]]
"""

print(np.argmax(arr))  # 求整个矩阵最大值的索引，11
print(np.argmin(arr))  # 求整个矩阵最小值的索引，0
print(np.argmax(arr, axis=0))  # 求每列的最大值位置, [2 2 2 2]
print(np.argmin(arr, axis=1))  # 求每行的最小值位置,[0 0 0]
print(np.mean(arr))  # 整个矩阵的平均值 7.5
print(arr.mean())  # 另一种求平均值的方式 7.5
```

# 7. 平均值、中位数、累加和、逐个差、排序

```py
# 7. 平均值、中位数、累加和、逐个差、排序
print(np.average(arr)) # 另一种求平均值的方式 7.5
print(np.median(arr))  # 中位数 7.5
print(np.cumsum(arr))  # 前面i个数的累加和：[ 2  5  9 14 20 27 35 44 54 65 77 90]
print(np.diff(arr))  # 和后一个元素的差，按行计算
"""
[[1 1 1]
 [1 1 1]
 [1 1 1]]
"""

print(np.nonzero(arr)) # 输出非零的数的位置，返回两个规模相同的序列，分别表示横纵坐标
"""
(array([0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2], dtype=int64), 
array([0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3], dtype=int64))
"""
print(np.sort(arr)) # 按行排序
```

# 8. 矩阵转置、矩阵限定（限定最大值、最小值）

```py
# 8. 矩阵转置、矩阵限定（限定最大值、最小值）
print(np.transpose(arr))  # 矩阵转置
"""
[[ 2  6 10]
 [ 3  7 11]
 [ 4  8 12]
 [ 5  9 13]]
"""
print(arr.T)  # 矩阵转置写法2
print(np.clip(arr, 5, 9)) # 截取
"""
[[5 5 5 5]
 [6 7 8 9]
 [9 9 9 9]]
"""
# 注：多种操作都可以通过 axis 设置对行或列进行操作，并最好通过 keepdims 保持矩阵形状
print(np.mean(arr, axis=1, keepdims=True))  # 行求平均，结果保持为列向量
"""
[[  3.5]
 [  7.5]
 [ 11.5]]
"""
```

# 9. numpy 的索引、切片、迭代

```py
# 9. numpy 的索引、切片、迭代
arr = np.arange(3, 15) # [ 3  4  5  6  7  8  9 10 11 12 13 14]
print(arr[3])  # 6

arr = np.arange(3, 15).reshape((3,4))
"""
[[ 3  4  5  6]
 [ 7  8  9 10]
 [11 12 13 14]]
"""
print(arr[2])  # 第2行，[11 12 13 14]
print(arr[1, 1]) # 第1行第1列 -> 8
print(arr[1][1]) # 第1行第1列 -> 8
print(arr[0, :]) # 第0行，:表示所有列 -> [3 4 5 6]
print(arr[:, 1]) # 第1列，:表示所有航 -> [ 4  8 12]，注意变为行向量
print(arr[1, 1:3]) # 第1行，1-2列 -> [8 9]

# 迭代行
for row in arr:
    print(row)
    
# 迭代列：利用转置
for col in arr.T:
    print(col)
    
# 数组展开为行
print(arr.flatten())  # [ 3  4  5  6  7  8  9 10 11 12 13 14]
# 遍历项
for item in arr.flat: # arr.flat 是一个迭代器
    print(item)

```

# 10. np 矩阵合并

```py
# 10. np 矩阵合并
a = np.array([1,1,1])
b = np.array([2,2,2])

print(np.vstack((a, b)))  # 按列方向堆叠
"""
[[1 1 1]
 [2 2 2]]
"""
print(np.hstack((a, b))) # 按行方向堆叠
"""
[1 1 1 2 2 2]
"""

# 正常情况下，向量不是标准的行、列向量，这种向量的转置无效
# 一般需要将其转化为标准的行、列向量
print(a.shape)  # 非标准向量，(3,)
print(a[np.newaxis, :].shape)  # 转为行向量 (3,) -> (1, 3)
print(a[:, np.newaxis].shape)  # 转为列向量 (3,) -> (3, 1)
# 也可以使用reshape转化，且更方便
print(a.reshape(1, -1).shape)  # 转换为行向量  (3,) -> (1, 3)，-1所在的维度自动计算
print(a.reshape(-1, 1).shape)  # 转为列向量 (3,) -> (3, 1)
print(a.shape)  # 注意操作后要重新赋值，否则a仍然保持不变

a = a.reshape(-1, 1)  # 列向量
b = b.reshape(-1, 1)  # 列向量
print(np.hstack((a, b)))  # 水平堆叠
"""
[[1 2]
 [1 2]
 [1 2]]
"""
print(np.vstack((a, b)))  # 垂直堆叠
"""
[[1]
 [1]
 [1]
 [2]
 [2]
 [2]]
"""

# 另一种堆叠：np.concatenate((A,B), axis=...) 可以在连接时指定方向
print(np.concatenate((a,b,b,a), axis=1))  # 行方向
"""
[[1 2 2 1]
 [1 2 2 1]
 [1 2 2 1]]
"""
```

# 11. np 矩阵分割

```py
# 11. np 矩阵分割
arr = np.arange(12).reshape(3, 4)
"""
[[ 0  1  2  3]
 [ 4  5  6  7]
 [ 8  9 10 11]]
"""

print(np.split(arr, 2, axis=1))  # 行方向分割，必须要能均分，否则会报错
"""
[array([[0, 1],
       [4, 5],
       [8, 9]]), 
 array([[ 2,  3],
       [ 6,  7],
       [10, 11]])]
"""
print(np.split(arr, 3, axis=0))  # 纵向分割
"""
[array([[0, 1, 2, 3]]), array([[4, 5, 6, 7]]), array([[ 8,  9, 10, 11]])]
"""

# 不等量分割可以用 np.array_split，多出来的优先放置在前面的数组
print(np.array_split(arr, 3, axis=1)) # 横向分割
"""
[array([[0, 1],
       [4, 5],
       [8, 9]]), 
 array([[ 2],
       [ 6],
       [10]]), 
 array([[ 3],
       [ 7],
       [11]])]
"""

# 类似合并，也有 vsplit 和 hsplit
print(np.hsplit(arr, 2))
print(np.vsplit(arr, 3))

print(arr)

```

# 12. 拷贝与深拷贝

```py
# 12. 拷贝与深拷贝

a = np.arange(4)

b = a
c = a
d = b

print(b is a)  # True
print(d is a)  # True

# a 的修改会导致 b c d 的修改，因为他们指向同一个地址
a[0] = 10
print(b)  # b[0] 也修改为 10
# 可以利用切片修改
a[1:3] = [22, 33]
print(d)

# 深拷贝
a = np.arange(4)
b = a.copy()  # 深拷贝，a,b指向不同地址

b[[1, 3]] = [11, 33] # 修改 b 不会导致 a 发生变化
print(b is a)  # False
print(b)  # [ 0 11  2 33]
print(a)  # [0 1 2 3]

```