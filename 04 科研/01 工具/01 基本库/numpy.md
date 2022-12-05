# 1 概述

NumPy 是 Python 中科学计算的基础包。它是一个 Python 库，提供多维数组对象，各种派生对象（如掩码数组和矩阵），以及用于数组快速操作的各种 API，有包括数学、逻辑、形状操作、排序、选择、输入输出、离散傅立叶变换、基本线性代数，基本统计运算和随机模拟等等。

NumPy 包的核心是 ndarray 对象。它封装了 python 原生的同数据类型的 n 维数组，为了保证其性能优良，其中有许多操作都是代码在本地进行编译后执行的。

## 1.1 NumPy 为什么这么快

NumPy 通过 ndarray 进行了矢量化，且在底层是通过预编译的 C 代码完成的，而在编写的代码中不需要编写循环、下标等处理代码。使用矢量化代码有许多优点，其中包括：

- 矢量化代码更简洁，更易于阅读
- 更少的代码行通常意味着更少的错误
- 代码更接近于标准的数学符号（通常，更容易正确编码数学结构）
- 矢量化导致产生更多 “Pythonic” 代码。如果没有矢量化，我们的代码就会被低效且难以阅读的 for 循环所困扰。

除了向量化，NumPy 还具备广播机制，也对矩阵运算的加速起到一定作用。广播是用于描述操作的隐式逐元素行为的术语，一般来说，在 NumPy 中，所有操作，不仅仅是算术运算，而是逻辑、位、功能等，都以这种隐式的逐元素方式表现，即它们进行广播。基于广播机制，参与运算的两个参数可以是相同形状的多维数组，或者标量和数组，或者甚至是具有不同形状的两个数组，条件是较小的数组可以“扩展”到更大的形状。有关广播的详细“规则”，请参阅 [numpy.doc.broadcasting](https://www.numpy.org.cn/user/basics/broadcasting.html#module-numpy.doc.broadcasting)。

## 1.2 环境安装

建议基于 Anaconda 安装 Python 环境，详细参考相关笔记，此处不再赘述。

```bash
conda/source activate xxx
conda install numpy
```

《Python 数据分析基础教程（第 2 版）》涉及到的库主要有，numpy、matplotlib 和 SciPy，我们使用 anaconda 安装即可。同时其使用 IPython 作为编辑器，我们使用 Py Charm 作为替代，并建议基于 SSH 进行开发。

- 使用先前导入 numpy 模块：`import numpy as np`
- 对于许多操作，axis 表示其操作方向，不能死记为对行或对列的操作，而是要理解
- axis 指明了操作方向，axis=0 表示从上往下操作（按行方向），axis=1 表示从左往右操作（按列方向）
- 比如，对于求和 np.sum，axis=0，从上往下，按行方向求和，那就是对每一列求和
- 比如，对于 df.dropna(axis=0) ，从上往下 drop，那就是扔掉包含 NaN 的行
- 同样是 axis=0，np.sum 体现为对列求和，df.dropna 体现为扔掉行，因此不能死记硬背

# 2 NumPy 基础

## 2.1 ndarray 对象

NumPy 的核心是一个称作 ndarray 的多维数组，其是一个 N 维数组对象，它是一系列同类型数据的集合，每个元素在内存中占据相同的存储大小，下标从 0 开始索引，每个维度可也称为轴。

ndarray 也被别名所知 array，但 numpy.array 这与标准 Python 库数组类 array.array 不同，后者只处理一维数组并提供较少的功能，它们有如下区别：

- NumPy 数组在创建时具有固定的大小，与 Python 的原生数组对象（可以动态增长）不同，更改 ndarray 的大小将创建一个新数组并删除原来的数组。
- NumPy 数组中的元素都需要具有相同的数据类型，因此在内存中的大小相同。例外情况：Python 的原生数组里包含了 NumPy 的对象的时候，这种情况下就允许不同大小元素的数组。
- NumPy 数组有助于对大量数据进行高级数学和其他类型的操作。通常，这些操作的执行效率更高，比使用 Python 原生数组的代码更少。
- 越来越多的基于 Python 的科学和数学软件包使用 NumPy 数组; 虽然这些工具通常都支持 Python 的原生数组作为参数，但它们在处理之前会还是会将输入的数组转换为 NumPy 的数组，而且也通常输出为 NumPy 数组。换句话说，为了高效地使用当今科学/数学基于 Python 的工具（大部分的科学计算工具），你只知道如何使用 Python 的原生数组类型是不够的，还需要知道如何使用 NumPy 数组。

## 2.2 ndarray 属性

ndarray 对象具备下列几个重要属性：

- ndarray.ndim：秩，即轴的数量或维度的数量，结果是一个整数。
- ndarray.shape：数组的维度，对于 m 行 n 列的矩阵返回 (m, n)，结果是一个元组，shape 元组的长度就是 rank 或维度的个数 ndim。
- ndarray.size：数组元素的总个数，相当于 .shape 中 n\*m 的值，结果是一个整数。
- ndarray.dtype：ndarray 对象的元素类型，返回 numpy.dtype 类型实例，可以使用标准的 Python 类型创建或指定 dtype，另外 NumPy 提供它自己的类型，例如 numpy.int32、numpy.int16 和 numpy.float64。
- ndarray.itemsize：ndarray 对象中每个元素占用的字节数，结果是一个整数，例如，元素为 float64 类型的数组的 itemsize 为 8（=64/8），而 complex32 类型的数组的 itemsize 为 4（=32/8），它等于 ndarray.dtype.itemsize
- ndarray.flags：ndarray 对象的内存信息
- ndarray.real：ndarray 元素的实部，结果是一个 ndarray
- ndarray.imag：ndarray 元素的虚部，结果是一个 ndarray
- ndarray.data：包含实际数组元素的缓冲区，由于一般通过数组的索引获取元素，所以通常不需要使用这个属性

我们可以使用下列测试代码测试上述基本属性：

```py
import numpy as np


def print_prop(prop_name, value):
    print(prop_name + ": " + str(value))


if __name__ == '__main__':
    arr = np.arange(15).reshape(3, 5)
    print(arr)
    print_prop("data", arr.data)
    print_prop("shape", arr.shape)
    print_prop("ndim", arr.ndim)
    print_prop("type", type(arr))
    print_prop("d_type", arr.dtype.name)
    print_prop("item_size", arr.itemsize)
    print_prop("size", arr.size)
```

## 2.3 元素类型

NumPy 支持的数据类型比 Python 内置的类型要多很多，基本上可以和 C 语言的数据类型对应上，但由于 C 中类型长度和平台定义有关，在 32/64 位系统上会有不同长度，因此 NumPy 还额外定义了固定大小的别名，比如 np.int32, np.int64 等，详细可查看 [NumPy 数据类型](http://www.runoob.com/numpy/numpy-dtype.html)。

在 NumPy 中，定义了很多 dtype 实例的别名，在使用这些别名时，在 ndarray 内部会转化为的真正类型一般是带数据长度的类型，主要包括下述类型：

|  NumPy 类型   |       描述        |                   别名                   |
| :-----------: | :---------------: | :--------------------------------------: |
|   np.bool\_   |     bool 类型     |                 np.bool                  |
|    np.int8    |    单字节整数     |                 np.byte                  |
|   np.int16    |    双字节整数     |                 np.short                 |
|   np.int32    |    4 字节整数     |            np.intc, np.int\_             |
|   np.int64    |    8 字节整数     |           np.longlong, np.intp           |
|   np.uint8    | 无符号单字节整数  |                 np.ubyte                 |
|   np.uint16   | 无符号双字节整数  |                np.ushort                 |
|   np.uint32   | 无符号 4 字节整数 |              np.uintc, uint              |
|   np.uint64   | 无符号 8 字节整数 |          np.ulonglong, np.uintp          |
|  np.float16   |   半精度浮点数    |                 np.half                  |
|  np.float32   |   单精度浮点数    |            np.single, float\_            |
|  np.float64   |   双精度浮点数    |         np.double, np.longdouble         |
| np.complex64  |    单精度复数     |                np.csingle                |
| np.complex128 |    双精度复数     | np.cdouble, np.clongdouble, np.complex\_ |

> 注意：上表中的别名列是在 64 位机器上得到的统计结果，由于 numpy 中的原始类型与 C 中的原始类型紧密相关，因此很多别名都和平台定义有关，最后再转化到指定字节长度的类型，如果在 32 位机器上使用别名可能会得到不同的对应结果，但带长度的类型是一致的。

Python 内置的 bool, int, float 和 complex 类型也可直接作为 dtype，NumPy 会自动将其转化为对应的 np.bool\_, np.int\_, np.float\_ 和 np.complex\_，同时这些映射后的类型除了 np.bool\_ 外也只是别名，真正的对应类型会映射到对应的带长度的 NumPy 类型。

### 2.3.1 类型描述类 np.dtype

NumPy 的数值类型实际上是 np.dtype 对象的实例，并对应唯一的字符，包括前面列举的 np.bool\_，np.int32，np.float32 等等，且前面已经介绍过，对一个 np.ndarray 数组，可以使用 ndarray.dtype 属性查看其类型描述实例。

数据类型对象 dtype 用于描述 ndarray 对应的内存区域如何使用，其主要包括下述几个方面：

- 数据的类型（整数、浮点数、Python 对象）
- 数据的大小（例如整数用多少字节存储）
- 数据的字节顺序（大端法、小端法）：字节顺序是通过对数据类型预先设定"<"或">"来决定的。"<"意味着小端法(最小值存储在最小的地址，即低位组放在最前面)。">"意味着大端法(最重要的字节存储在最小的地址，即高位组放在最前面)
- 在结构化类型的情况下，字段的名称、每个字段的数据类型和每个字段所取的内存块的部分
- 如果数据类型是子数组，它的形状和数据类型

如果要转换 ndarray 的 dtype，则可以使用 `ndarray.astype(np.dtype)` 方法，其不更改原数组，会拷贝一份内容并转化到对应类型后返回，例如 `np.empty((2, 3)).astype(np.int32)` 会得到一个整数矩阵。

### 2.3.2 自定义类型

我们前面提供的 numpy 数据类型实际上是官方给我们预先初始化好的 np.dtype 类型的实例，我们也可以使用 `numpy.dtype(object, align, copy)` 构造 dtype 对象实例，其需要提供下面的三个参数：

- object：要转换为的数据类型对象
- align：如果为 true，填充字段使其类似 C 的结构体。
- copy：复制 dtype 对象，如果为 false，则是对内置数据类型对象的引用

- 标量类型：`dt = np.dtype(np.int32)`
- int8, int16, int32, int64 四种数据类型可以使用字符串 'i1', 'i2', 'i4', 'i8' 代替，例如 `dt = np.dtype('i4')`
- 字节大小端顺序标注：`dt = np.dtype('<i4')`
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

# 3 数组创建

NumPy 提供了多种方式来创建 ndarray 对象，主要包括：

- 给定数组形状快速创建 ndarray
- 从已有数组或对象创建 ndarray
- 给定数值范围快速创建 ndarray

## 3.1 给定数组形状快速创建

官方教程列举的场景创建方法主要包括下列函数，更详细的内容可直接参考 API 文档。

```
array, zeros, zeros_like, ones, ones_like, empty, empty_like, arange, linspace, numpy.random.mtrand.RandomState.rand, numpy.random.mtrand.RandomState.randn, fromfunction, fromfile
```

### 3.1.1 np.empty

使用 `np.empty(shape, dtype = float64, order = 'C')` 可以创建一个未初始化的数组，其入参具体含义如下所示：

- shape 数组形状，接受 tuple 或 list 类型参数（可能由于内部只用了元素下标运算符 `[]` 来取出各个维度的长度，但建议采用 tuple 形式的入参）
- dtype 数据类型，可选，默认是 numpy 中的 float64 类型
- order 有"C"和"F"两个选项,分别代表，行优先和列优先，在计算机内存中的存储元素的顺序
- 参考样例： `x = np.empty((3,2), dtype = int) ` 或 `x = np.empty([3,2], dtype = int) ` 或

> 注：1.20.0+ 版本引入了 like 入参，但是向前兼容的，不影响使用 `numpy.zeros(shape, dtype=float, order='C', *, like=None)`

### 3.1.2 np.zeros

使用 `np.zeros(shape, dtype = float64, order = 'C')` 创建一个全为 0 的数组，其入参具体含义和 no.empty 一致。

关于 np.zeros，有如下说明内容：

- 默认创建 float64 类型 `x = np.zeros(5) `
- 指定为 int 型 `x = np.zeros((5,), dtype = np.int)`
- 指定为自定义类型 `x = np.zeros((2,2), dtype = [('x', 'i4'), ('y', 'i4')])`

### 3.1.3 np.ones

使用 `numpy.ones(shape, dtype = np.float64, order = 'C')` 创建一个全 1 数组

- 默认为浮点数 `x = np.ones(5)`
- 设置为 int 型 `x = np.ones([2,2], dtype = int)`

### 3.1.4 np.fromfunction

使用 `np.fromfunction(func, shape, dtype)` 创建一个根据下标进行值初始化的 ndarray，其入参具体含义如下：

- func：是一个带有 ndim 个入参，带有返回值的计算函数，入参的含义即为 ndarray 的下标， np.fromfunction 会调用函数，传入下标并根据下标计算值得到返回值填入 ndarray 对应位置
- shape：ndarray 形状
- dtype：元素类型

```py
def f(x, y):
    return 10 * x + y

b = np.fromfunction(f, (5, 4), dtype=int)

b 结果为：
array([[ 0,  1,  2,  3],
       [10, 11, 12, 13],
       [20, 21, 22, 23],
       [30, 31, 32, 33],
       [40, 41, 42, 43]])
```

## 3.2 从已有数组创建

### 3.2.1 使用 np.array 方法

如果已经拥有一个 list 类型的常量或者变量，可以使用 `numpy.array(object, dtype = None, copy = True, order = None, subok = False, ndmin = 0)` 将 list 转化为 ndarray，其各个参数的具体含义如下：

- object : 数组或嵌套的数列
- dtype : 数组元素的数据类型，可选
- copy : 对象是否需要复制，可选
- order : 创建数组的样式，C 为行方向，F 为列方向，A 为任意方向（默认）
- subok : 默认返回一个与基类类型一致的数组
- ndmin : 指定生成数组的最小维度

例如，使用 `np.array([(1.5,2,3), (4,5,6)])`，其会得到如下的 ndarray：

```py
array([[1.5, 2. , 3. ],
       [4. , 5. , 6. ]])
```

### 3.2.2 使用 np.asarray 方法

除了 np.array 方法，使用 `numpy.asarray(object, dtype = None, order = None)` 也可以完成一个普通对象（包括 list）到 ndarray 的转换，其作用类似 numpy.array，但 numpy.asarray 只有三个入参：

- object 任意形式的输入参数，可以是，列表, 列表的元组, 元组, 元组的元组, 元组的列表，多维数组
- dtype 数据类型，可选
- order 可选，有 "C" 和 "F" 两个选项，分别代表，行优先和列优先，在计算机内存中的存储元素的顺序

通过使用 np.asarray，我们可以从各种不同的已有线性类型创建 ndarray 对象，比如：

- 使用 `np.asarray([1,2,3])` 从 list 创建 ndarray
- 使用 `np.asarray((1,2,3))` 从 tuple 创建 ndarray
- 使用 `np.asarray([(1,2,3),(4,5)], object)` 从不规则的 list 创建 ndarray，对于不规则 list 创建出来的 ndarray，其 dtype 的本质是一个 object 类型

### 3.2.3 使用 numpy.frombuffer

使用 `numpy.frombuffer(buffer, dtype = float, count = -1, offset = 0)` 可以实现几个 ndarray 管理的动态数组，其接受 buffer 输入参数，以流的形式读入转化成 ndarray 对象，参数列表含义如下：

- buffer 可以是任意对象，会以流的形式读入
- dtype 返回数组的数据类型，可选
- count 读取的数据数量，默认为-1，读取所有数据。
- offset 读取的起始位置，默认为 0
- 样例 `x = np.frombuffer(b'Hello World', dtype = 'S1')`

### 3.2.4 使用 numpy.fromiter

使用 `numpy.fromiter(iterable, dtype, count=-1)` 可以从迭代器中取出对象创建 ndarray，返回一维数组，其入参含义如下：

- iterable 可迭代对象
- dtype 返回数组的数据类型
- count 读取的数据数量，默认为-1，读取所有数据

## 3.3 从数值范围创建数组

> 特别注意：从数值范围创建的数组得到的结果是一个向量，且一般是一个非标准的向量，其 shape 往往为 `(n,)`，在进行深度学习的矢量化运算时，一般需要 reshape 为标准列向量 `(n, 1)` 或标准行向量 `(1, n)`。

### 3.3.1 np.arange

使用 `numpy.arange(start, stop, step, dtype)` 可以生成 [start, stop) 区间的数据，步长为 step，其各个入参的具体含义如下：

- start 起始值，默认为 0
- stop 终止值（不包含）
- step 步长，默认为 1
- dtype 返回 ndarray 的数据类型，如果没有设置，则会使用输入数据的类型，例如 `np.arange(5)`返回的 ndarray，其 dtype 是 int32 类型

```py
np.arange(5, dtype = float) # 创建 [0, 5) 步长为 1 的 float 数组
```

### 3.3.2 np.linspace

当 np.arange 与浮点参数一起使用时，由于有限的浮点精度，通常不可能预测所获得的元素的步长，比如想在 $[0, 2\pi]$ 间生成 100 个等差数列时，出于这个原因，最好使用 linspace 函数来接收我们想要的元素数量的函数，设置数列个数，而不是步长。

使用 `np.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None)` 生成区间 `[start, stop]` 的等差数列，公差根据数量 num 自动确定，其各个入参含义如下：

- start：序列的起始值
- stop：序列的终止值，如果 endpoint 为 true，该值包含于数列中
- num：要生成的等步长的样本数量，默认为 50，会根据 start, stop 和 num 计算公差
- endpoint：该值为 ture 时，数列中中包含 stop 值，反之不包含，默认是 True
- retstep：如果为 True 时，生成的数组中会显示间距，反之不显示。
- dtype：ndarray 的数据类型，默认为 float64

```py
np.linspace(1, 10, 10) # 生成 [1, 10] 公差为 1 的 float64 等差数列
np.linspace(10, 20, 5, endpoint = False) # 生成 [10, 18] 公差为 2 的 float64 等差数列
```

### 3.3.3 np.logspace

使用 `np.logspace(start, stop, num=50, endpoint=True, base=10.0, dtype=None)` 创建一个等比数列：

- start：序列的起始值为 base 的 start 次方
- stop：序列的终止值为：base 的 stop 次方，如果 endpoint 为 true，该值包含于数列中
- num：要生成的等步长的样本数量，默认为 50，基于 start, stop 和 num 计算公差 d，然后 base 的 d 次方即为公比
- endpoint：该值为 ture 时，数列中中包含 stop 值，反之不包含，默认是 True。
- base：对数 log 的底数。
- dtype：ndarray 的数据类型，默认为 np.float64

以下列代码为例，前面三个参数生成等差数列，公差 d = 1，然后将它们应用于底数 2 上，因此生成等比数列公比为 2 的 1 次方，即 q = 2。

```py
np.logspace(1, 10, 10, base=2) # 1, 2, 4 ...
```

# 4 数组操作

## 4.1 基本操作

### 4.1.1 算数运算符

在 ndarray 上的算术运算符都会应用到元素级别，并返回一个同结构的 ndarray 结果，这类运算包括加减乘除、平方运算 `** 2`、大于小于判断等，示例代码如下：

```py
a = np.array([20,30,40,50]) # [20,30,40,50]
b = np.arange(4) # [0, 1, 2, 3]
c = a - b # [20, 29, 38, 47]
d = b ** 2 # [0, 1, 4, 9]
e = 10 * np.sin(a) # [9.12945251, -9.88031624,  7.4511316 , -2.62374854]
e = a < 35 # [True, True, False, False]
```

与许多矩阵语言不同，乘积运算符 `*` 在 NumPy 数组中表示按元素进行乘法运算，不表示矩阵乘法，若要进行矩阵乘法要使用 ndarray.dot 或 np.dot 方法，在 python> = 3.5 中可以使用 `@` 运算符进行矩阵乘法，示例代码如下：

```py
a = np.array([[1, 1],
              [0, 1]])
b = np.array([[2, 0],
              [3, 4]])
c = a * b
"""
[[2 0]
[0 4]]
"""
d = a @ b
e = a.dot(b)
g = np.dot(a, b)
"""
d, e 结果都为：
[[5 4]
[3 4]]
"""
```

其他一些不记录示例代码，但需要记住的基本操作语法点

- 某些操作（例如 `+=` 和 `*=`）会更直接更改被操作的矩阵数组而不会创建新矩阵数组。
- 当使用不同类型的数组进行操作时，结果数组的类型对应于更一般或更精确的数组（称为向上转换的行为），例如对一个 np.int32 的数据和一个 np.float64 的数组进行加法运算得到的结果为 np.float64 的数组。

### 4.1.2 聚合函数

聚合函数可以简单理解为，对于一个 ndarray，将元素沿某个方向或整体进行聚合，得到一个更小的 ndarray 或者向量或者标量。NumPy 提供了许多聚合函数，这些聚合函数一般是挂靠是 numpy 库下，同时往往会在 ndarray 上提供别名，例如 `np.sum()`, `np.min()`, `np.max()`, `np.mean()` 等。默认情况下，这些方法对数组的所有元素进行聚合并返回一个标量，但可以通过指定 axis 参数，来指定聚合操作的应用轴方向，比如传入 `axis=0` 表示按列聚合，示例代码如下：

```py
a = np.random.random((2,3))
"""
array([[ 0.18626021,  0.34556073,  0.39676747],
       [ 0.53881673,  0.41919451,  0.6852195 ]])
"""

a.sum() # 2.5718191614547998
a.min() # 0.1862602113776709
a.max() # 0.6852195003967595

b = np.arange(12).reshape(3,4)
"""
array([[ 0,  1,  2,  3],
       [ 4,  5,  6,  7],
       [ 8,  9, 10, 11]])
"""
b.sum(axis=0) # [12, 15, 18, 21]
b.min(axis=1) # [0, 4, 8]
b.cumsum(axis=1)
"""
array([[ 0,  1,  3,  6],
       [ 4,  9, 15, 22],
       [ 8, 17, 27, 38]])
"""
```

### 4.1.3 通函数

NumPy 提供熟悉的数学函数，例如 sin，cos 和 exp。在 NumPy 中，这些被称为“通函数”（universal functions, ufunc），这些函数同样在数组上按元素进行运算，产生一个数组、向量或标量作为输出，因此聚合函数可以看成通函数的一部分。这些函数一般都直接挂靠在 numpy 库下，一般可以使用 `np.xxx()` 进行调用，例如 `np.exp(arr)`, `np.sum(arr)` 等，官方教程列举的通函数如下：

```js
all, any, apply_along_axis, argmax, argmin, argsort, average, bincount, ceil, clip, conj, corrcoef, cov, cross, cumprod, cumsum, diff, dot, floor, inner, invert, lexsort, max, maximum, mean, median, min, minimum, nonzero, outer, prod, re, round, sort, std, sum, trace, transpose, var, vdot, vectorize, where
```

> 注意：对于部分常用函数，在 ndarray 中也为它们起了别名，包括 `sum`, `max` 等，他们的本质还是调用 numpy 下的函数，因此不同的人可能使用不同的写法，在遇到时需要知道它们是同一个东西。

一些常见通函数介绍：

- `np.exp(a)`：指数函数
- `np.sqrt(a)`：求平方根
- `np.add(a, b)`：加法运算，等价于 ndarray 的 `a + b`
- `np.all(ndarray, axis)`：所有元素且运算，指定维度则对指定维度做且运算
- `np.any(ndarray, axis)`：所有元素或运算，指定维度则对指定维度做或运算
- `np.argmax(ndarray, axis)`：根据 axis 方向求最大值的下标，这在深度学习中很常用；注意若不指定 axis 则求整个 ndarray 的最大值，返回的序号为迭代器下标
- `np.argmin(ndarray, axis)`：根据 axis 方向求最小值的下标，这在深度学习中很常用
- `np.mean(ndarray)`：平均值
- `np.median(ndarray)`：中位数
- `np.diff(ndarray)`：计算每个元素和前一个元素的差值，默认逐行取出行向量，在一行内进行计算
- `np.cumsum(ndarray)`：逐元素累加

## 4.2 索引、切片和迭代

ndarray 可以进行索引、切片和迭代操作的，就像列表和其他 Python 序列类型一样。

### 4.2.1 索引

普通索引很常规，就和使用数组一样，不再详细介绍。

#### 4.2.1.1 数组索引

可以利用 list 或 tuple 组成的额行列信息，分散地取出各个位置上的元素

```py
x = np.array([[1,  2],  [3,  4],  [5,  6]])
y = x[[0,1,2], [0,1,0]] # list 写法，取出 (0, 0), (1, 1), (2, 0) 这三处位置的元素
y = x[(0,1,2), (0,1,0)] # tuple 写法，和上一行效果一样
```

取出的分散元素，还可以按照想要的格式组合成新的数组，只要将行列信息提供成相同格式的数组，其会自动取出对应的值并返回

```py
x = np.array([[0, 1, 2], [3, 4, 5], [6, 7, 8], [9, 10, 11]])
rows = np.array([[0,0], [3,3]]) # 要取出元素的行坐标
cols = np.array([[0,2], [0,2]]) # 要取出元素的列坐标
y = x[rows,cols] # 行列数组的结构就是你最终想要的数据结构，二者应该一致
```

#### 4.2.1.2 布尔索引

布尔索引即使用条件索引指定元素，其原理是：首先通过 bool 表达式确定一个和原有 ndarray 等 shape 的 bool ndarray，我们将其称作 mask 数组，然后通过这个 bool ndarray 取出元素，NumPy 会取出值为 True 的对应位置元素。

```py
x = np.array([[0, 1, 2], [3, 4, 5], [6, 7, 8], [9, 10, 11]])
print (x[x >  5]) # 输出时，选取到的元素会展开为向量形式
x[x > 5] = -1 # 也可以利用布尔索引进行赋值
x > 5 # 结果是一个等规模的 ndarray，称之为 mask 数组
```

对于多个 mask 数组，由于其全为 bool 类型，可以使用位运算表示逻辑运算，而对于单个 mask 数组，可以使用 ~ 运算符取反，如下面例子：

```py
a = np.array([np.nan, 1, 2, np.nan, 3, 4, 5])
print (a[~np.isnan(a)]) # ~ 取反，取出不是 nan 的数
```

#### 4.2.1.3 花式索引

花式索引指的是，根据整个数组作为一个索引，从目标数组的某个轴进行取值。对于使用一维整型数组作为索引，如果目标是一维数组，那么索引的结果就是多个对应位置的元素；如果目标是二维数组，那么就是多个对应下标的行。从语法上很像整数数组索引的化简。例如下述示例：

```py
x = np.arange(32).reshape((8,4))
print (x[[0, 1, 3]]) # 拿出 0, 1, 3 行
```

也可以使用负数表示倒序索引

```py
x = np.arange(32).reshape((8,4))
print (x[[-8, -7]]) # 其实就是第 0 行和第 1 行
```

如果需要传入多个索引数组，则要使用 `np.ix_`，同时还允许自由组合列顺序，允许先访问后面的行或列，在访问前面的，例如下列代码

```py
x = np.arange(32).reshape((8,4))
print(x[np.ix_([1,5,7,2], [0,3,1,2])])
```

### 4.2.2 切片

对于切片，可以使用内置的 slice 函数编写切片，其参数分别为 start, stop, step，也可以直接在下标中编写切片（推荐）。

```py
a = np.arange(10)
b = slice(2, 7, 2)   # 取区间 [2. 7) 的数字，间隔为 2
c = a[2:7:2]   # 取区间 [2, 7) 的数字，间隔为 2
```

对于切片语法中的冒号 `:`，主要有下述内容需要注意：

- 对于每一个维度，切片语法包括 `起始下标:结束下标:步长`，多个维度使用 , 连接成一个 tuple
- 若省略步长，则表示步长为 1，会逐个往后取元素，即提取两个索引区间 `[start, stop)` 之间的项，例如对于一个向量，切片 `[2:7]` 提取下标 2 ~ 6 的元素
- 若省略结束下标，则取结束下标为当前维度长度，会取到后续所有值，例如对于一个向量，如果切片为 `[2:]`，表示从该索引开始以后的所有项都将被提取
- 若想要选择某行或某列的所有元素，可以使用 `:` 表示某行或某列所有元素，此时相当于三者都省略，故选出整个向量或子数组
- 三个点 `...` 表示产生完整索引元组所需的冒号，其可能表示一个或多个 `:`，例如，如果 x 是 rank 为 5 的数组（即，它具有 5 个轴），则：
  - `x[1,2,...]` 相当于 `x[1,2,:,:,:]`
  - `x[...,3]` 等效于 `x[:,:,:,:,3]`
  - `x[4,...,5,:]` 等效于 `x[4,:,:,5,:]`
- 当提供的索引数量少于轴的数量时，缺失维度的索引被认为是完整的切片 `:`，这意味着 `:` 或者 `...` 可以被省略，但为了更好地语义化编码，不建议省略
- 根据上一条特性，如果只放置一个参数，没有冒号，如 `[2]`，则可看成取出对应子数组，对于 n 维数组则是 n - 1 的子数组
- 可以使用 `step = -1` 来对当前维度指定反序读取元素，例如 `a[ : : -1]`

```py
a = np.array([[1,2,3],[3,4,5],[4,5,6]])
print (a[...,1])   # 第 2 列元素
print (a[:,1])   # 第 2 列元素
print (a[1,...])   # 第 2 行元素
print (a[1,:])  # 第 2 行元素
print (a[...,1:])  # 第 2 列及剩下的所有元素
print (a[:,1:])# 第 2 列及剩下的所有元素
```

### 4.2.3 迭代

对多维数组进行迭代（Iterating）是相对于第一个轴完成的，但是，如果想要对数组中的每个元素执行操作，，示例代码如下：

```py
for row in b:
    print(row)

for element in b.flat:
    print(element)
```

如果想要对 ndarray 展开为一个向量后再进行迭代（即单元素迭代），主要有下列方法：

- `np.nditer(ndarray)`：numpy 上的方法，获取 ndarray 示例的迭代器
- `np.ndarray.flat` 属性：该属性是 ndarray 的所有元素的迭代器视图，对应类型为 numpy.flatiter，对迭代器的修改会更新到 ndarray 实例中
- `np.ndarray.ravel()` 方法：该方法的返回值 ndarray 所有元素的迭代器视图，对迭代器的修改会更新到 ndarray 实例中
- `np.ndarray.flatten(order='C')` 方法：该方法返回 ndarray 数据的迭代器拷贝，对拷贝所做的修改不影响原数据，

```py
for element in a.flat:
    print (element)
```

## 4.3 形状操纵

### 4.3.1 改变形状

#### 4.3.1.1 reshape

使用 `np.reshape(ndarray, newshape, order='C')` 方法调整数组形状

- ndarray：待调整的 ndarray 实例
- newshape：新形状，是一个 list 或 tuple
- order 可选，'C' -- 按行，'F' -- 按列，'A' -- 原顺序，'k' -- 元素在内存中的出现顺序
- 该方法不改变原数组，而是返回调整后的数组，但两个数组互为视图，它们的 base 指向的是同一个地方，对其中一个数组的修改会反映到另一个数组上

此外还可以直接使用 `np.ndarray.reshape(shape, order='C')` 调整数组形状，其本质上是 `np.reshape` 的别名，为了方便形状操纵而添加到 ndarray 上，但对应的操作是直接在 ndarray 实例上调整的（是 O(1) 操作）。

#### 4.3.1.2 resize

使用 `np.resize(ndarray, newshape)` 方法调整数组形状

- ndarray：待调整的 ndarray 实例
- newshape：新形状，是一个 list 或 tuple
- 该方法返回的是一个拷贝，对新数组的修改不影响原数组

还可以使用 `np.ndarray.resize(newshape)` 直接调整数组形状，该修改会直接对调用的 ndarray 实例进行修改。

### 4.3.2 转置

使用 ndarray 对象的 `.T` 属性获取转置视图，只适用于二维数组，对于非正规向量返回自身，由于其返回的是视图，对视图的修改会同步到原 ndarray 中。

也可以使用 `np.transpose(a, axis=None)` 进行高维数组转置，其返回的同样是视图，对于二维的 ndarray 情况，和 `.T` 属性效果一致。

```py
x = np.arange(4).reshape((2,2))
np.transpose(x)
```

对于 tanspose，也可以直接使用 ndarray 自带的 `tanspose()` 方法，其本质上是 `np.transpose()` 的别名

```py
np.arange(4).reshape((2,2))
x.transpose()
```

### 4.3.3 堆叠

数组可以沿不同的轴堆叠在一起，但最常见的形式还是矩阵的堆叠，堆叠涉及的方法主要包括：

- `np.vstack(ndarrays)`：对向量或矩阵沿垂直方向堆叠，相当于 `axis=0`
- `np.hstack(ndarrays)`：对向量或矩阵沿水平方向堆叠，相当于 `axis=1`
- `np.concatenate(ndarrays, axis)`：指定堆叠的轴对通用 ndarray 进行堆叠
- `np.r_[...]`：沿垂直方向堆叠，相当于 `np.vstack`
- `np.c_[...]`：沿水平方向堆叠，相当于 `np.hstack`

```py
def test_stack(a, b):
    print("a.shape:", a.shape, ", data: \n", a)
    print("b.shape:", b.shape, ", data: \n", b)
    print("vstack : \n", np.vstack((a, b))) # a, b 沿垂直方向堆叠
    print("hstack : \n", np.hstack((a, b))) # a, b 沿水平方向堆叠
    print("concatenate(axis=0): \n", np.concatenate((a, b), axis=0)) # 0 沿垂直方向堆叠，1 沿水平方向堆叠
    if a.ndim != 1 and b.ndim != 1:
        print("concatenate(axis=1): \n", np.concatenate((a, b), axis=1)) # 0 沿垂直方向堆叠，1 沿水平方向堆叠
    print("np.r_ : \n", np.r_[a, b]) # 沿垂直方向堆叠
    print("np.c_ : \n", np.c_[a, b]) # 沿按水平方向堆叠


a = np.arange(0, 4)
b = np.arange(4, 8)
test_stack(a, b)

a = np.arange(0, 4).reshape(1, -1)
b = np.arange(4, 8).reshape(1, -1)
test_stack(a, b)

a = np.arange(0, 4).reshape(-1, 1)
b = np.arange(4, 8).reshape(-1, 1)
test_stack(a, b)

a = np.array([[8, 8], [0, 0]])
b = np.array([[1, 8], [0, 4]])
test_stack(a, b)
```

对于标准向量，这些堆叠函数的行为是一致的，堆叠方式就按照前面的描述方式进行堆叠，但对于非标准向量（即 shape 为 `(m,)` 这类的向量）的堆叠方式，在行为上有所差别，其中 `np.r_` 和 `np.c_` 的行为较为特殊：

- `np.concatenate(ndarrays, axis)` 对于非标准向量将其看做行向量沿水平方向堆叠，即使设置 `axis=0` 也不会和矩阵一样沿垂直方向堆叠
- `np.vstack(ndarrays)` 和 `np.hstack(ndarrays)` 将非标准向量看做行向量，然后分别沿垂直、水平方向堆叠
- `np.r_[...]` 直接将元素堆叠成一个非标准的行向量
- `np.c_[...]` 将非标准向量看做一个列向量，然后沿水平方向堆叠

### 4.3.4 拆分

拆分和堆叠类似，主要有三个方法：

- `np.hsplit(ndarray, indices_or_sections)`：沿水平方向拆分，一般针对矩阵或向量
- `np.vsplit(ndarray, indices_or_sections)`：沿垂直方向拆分，一般针对矩阵或向量
- `np.split(ndarray, indices_or_sections, axis=1)`：沿指定轴方向拆分，注意对于第二个参数 indices_or_sections，其可以是一个整数或者是一个元组，如果是一个整数，则表示需要拆分的份数，NumPy 会自动均分成 indices 列，如果无法均分会报错；如果传入的是一个元组（注意单个元素的元组需要加上结尾的逗号，否则会被解释为数字），则将元素的列元素看做拆分行或拆分列，在指定的行或列进行拆分然后返回结果。
- `np.array_split(ndarray, indices_or_sections, axis)`：沿指定轴方向拆分，indices_or_sections 含义和 np.split 一致，但不能均分时会将多出来的优先放置在前面的子数组。

## 4.4 拷贝和视图

### 4.4.1 视图

不同的数组对象可以共享相同的数据，这种情况称作视图，视图的真正数据指向同一块引用，对其中一块的修改会反映到所有视图上，使用 `ndarray.view` 方法创建一个查看相同数据的视图。可以使用 `a.base is b.base` 判断两个 ndarray 是否引用同一块数据区域，即互为视图。

我们前述的很的常用操作返回的都是视图，包括切片、转置等，部分操作则分别提供了返回视图的方法和返回拷贝的方法。

### 4.4.2 拷贝

copy 方法生成数组及其数据的完整副本。有时，如果在对 ndarray 进行切片后不再需要原始数组，则可以在切片后对切片调用 copy，这样就可以 del 掉原数组。例如下述代码，假设 a 是一个巨大的中间结果，最终结果 b 只包含 a 的一小部分，那么在用切片构造 b 时应该做一个深拷贝：

```py
a = np.arange(int(1e8))
b = a[:100].copy()
del a  # the memory of ``a`` can be released.
```

# 5 高级特性

## 5.1 广播

广播使得 NumPy 中的两个 shape 不完全一致的 ndarray 可以进行运算，广播规则主要包括：

- 让所有输入数组都向其中形状最长的数组看齐，形状中不足的部分都通过在前面加 1 补齐。
- 输出数组的形状是输入数组形状的各个维度上的最大值。
- 如果输入数组的某个维度和输出数组的对应维度的长度相同或者其长度为 1 时，这个数组能够用来计算，否则出错。
- 当输入数组的某个维度的长度为 1 时，沿着此维度运算时都用此维度上的第一组值。

需要注意，对于广播机制，小的数组可以省略前导 1，因此一个非标准向量在广播时默认被看做行向量，如果想当做列向量进行水平广播必须手动 reshape。广播的示例代码如下：

```py
a = np.arange(24).reshape(2, 3, 4) # 准备一个三位数组测试广播
a + np.arange(4) # 按行广播，相当于省略两个前导 1，shape(1, 1, 4)
a + np.arange(3).reshape(3, 1) # 按列广播，后置的 1 必须写，即必须改为列向量，省略一个前导 1，shape(1, 3, 1)
a + np.arange(2).reshape(2, 1, 1) # 必须补全后置 1 才可广播，shape(2, 1, 1)
```

此外，也可以利用 `np.tile` 进行广播

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
- 如果要控制遍历顺序，则需要利用 nditer 的 order 属性，例如 `for x in np.nditer(a, order='F')`（Fortran 语言） 为列优先，`for x in np.nditer(a.T, order='C')` 为行优先（C 语言）
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

# 6 补充内容

## np.meshgrid

`xx, yy = np.meshgrid(x, y)` 用于给定两个向量，基于这两个向量交叉生成生成网格点坐标矩阵，其会返回两个 $n_x * n_y$ 的矩阵，第一个矩阵表示坐标矩阵横坐标，第二个矩阵表示坐标矩阵纵坐标。例如对于入参 `[1, 2]` 和 `[3, 4]` 会返回矩阵 `[1, 2], [1, 2]` 和 `[3, 3], [4, 4]`，表示 `(1, 3), (1, 4), (2, 3), (2, 4)` 四个坐标点。

该函数一般用于绘制等高线或者绘制决策边界时用于生成 x, y 轴的数值点。

## 6.1 卷积时添加 padding 保持形状

`np.pad()` 函数用于往多维数组添加 padding，使得多层卷积层不会减少图像的宽高

```py
np.pad(x2, ((1,2), (3,4)), "constant", constant_values = 0)
np.pad(x, ((0,0), (1,1), (1,1)), "constant", constant_values = 0)
```

- 参数 x：被扩充的数组
- 参数 2：tuple，长度要和 x 的维度一样，其每个元素用于描述各个维度的 padding，(0,0)表示当前维度不扩充，例如上述代码中，x2 表示二维数组，第一维的(1,2)表示在数组上下分别增加一行、两行指定内容，而(3,4)表示在数组的左右两侧分别增加三列、四列内容。而((0,0), (1,1), (1,1))则表示第一维不 padding，第二维首位 padding 为(1,1)，第三位首位 padding 也为(1,1)
- 参数 3：估计是设置填充类型，"constant"表示用常数填充
- constant_values：表示用 0 填充

# 7 参考链接

- [《Python 数据分析基础教程（第 2 版）》](https://book.douban.com/subject/25798462/)
- [【莫烦 Python】Numpy & Pandas (数据处理教程)](https://www.bilibili.com/video/BV1Ex411L7oT)
