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

# 4 常用操作

## 4.1 基本操作

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

## 4.2 切片和索引

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

- 传入多个索引数组（要使用 np.ix\_）

```py
x=np.arange(32).reshape((8,4))
print (x[np.ix_([1,5,7,2],[0,3,1,2])])
```

# 5 常用运算

# 6 高级特性

## 6.1 广播

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

## 6.2 迭代数组

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

> 分割线

---

# 7 矩阵的加法、减法、数乘、数学运算、元素判断等

```py
# 8 矩阵的加法、减法、数乘、数学运算、元素判断等
a = np.array([10, 20, 30, 40])
"""
[10 20 30 40]
"""
b = np.arange(4)  # [0, 1, 2, 3]
"""
[0 1 2 3]
"""

# 9 常见运算
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

# 10 元素判断
print(b < 3)  # 小于3的位置为True，否则False，dtype=bool
"""
[ True  True  True False]
"""
```

# 11 矩阵逐元素相乘、矩阵乘法

```py
# 12 矩阵逐元素相乘、矩阵乘法
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

# 13 矩阵求和、求最大、求最小（可按行列或整个矩阵）

```py
# 14 矩阵求和、求最大、求最小（可按行列或整个矩阵）

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

# 15 最大、最小值索引（可按行、列、整个矩阵）

```py
# 16 最大、最小值索引（可按行、列、整个矩阵）
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

# 17 平均值、中位数、累加和、逐个差、排序

```py
# 18 平均值、中位数、累加和、逐个差、排序
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

# 19 矩阵转置、矩阵限定（限定最大值、最小值）

```py
# 20 矩阵转置、矩阵限定（限定最大值、最小值）
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
# 21 注：多种操作都可以通过 axis 设置对行或列进行操作，并最好通过 keepdims 保持矩阵形状
print(np.mean(arr, axis=1, keepdims=True))  # 行求平均，结果保持为列向量
"""
[[  3.5]
 [  7.5]
 [ 11.5]]
"""
```

# 22 numpy 的索引、切片、迭代

```py
# 23 numpy 的索引、切片、迭代
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

# 24 迭代行
for row in arr:
    print(row)

# 25 迭代列：利用转置
for col in arr.T:
    print(col)

# 26 数组展开为行
print(arr.flatten())  # [ 3  4  5  6  7  8  9 10 11 12 13 14]
# 27 遍历项
for item in arr.flat: # arr.flat 是一个迭代器
    print(item)

```

# 28 np 矩阵合并

```py
# 29 np 矩阵合并
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

# 30 正常情况下，向量不是标准的行、列向量，这种向量的转置无效
# 31 一般需要将其转化为标准的行、列向量
print(a.shape)  # 非标准向量，(3,)
print(a[np.newaxis, :].shape)  # 转为行向量 (3,) -> (1, 3)
print(a[:, np.newaxis].shape)  # 转为列向量 (3,) -> (3, 1)
# 32 也可以使用reshape转化，且更方便
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

# 33 另一种堆叠：np.concatenate((A,B), axis=...) 可以在连接时指定方向
print(np.concatenate((a,b,b,a), axis=1))  # 行方向
"""
[[1 2 2 1]
 [1 2 2 1]
 [1 2 2 1]]
"""
```

# 34 np 矩阵分割

```py
# 35 np 矩阵分割
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

# 36 不等量分割可以用 np.array_split，多出来的优先放置在前面的数组
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

# 37 类似合并，也有 vsplit 和 hsplit
print(np.hsplit(arr, 2))
print(np.vsplit(arr, 3))

print(arr)

```

# 38 拷贝与深拷贝

```py
# 39 拷贝与深拷贝

a = np.arange(4)

b = a
c = a
d = b

print(b is a)  # True
print(d is a)  # True

# 40 a 的修改会导致 b c d 的修改，因为他们指向同一个地址
a[0] = 10
print(b)  # b[0] 也修改为 10
# 41 可以利用切片修改
a[1:3] = [22, 33]
print(d)

# 42 深拷贝
a = np.arange(4)
b = a.copy()  # 深拷贝，a,b指向不同地址

b[[1, 3]] = [11, 33] # 修改 b 不会导致 a 发生变化
print(b is a)  # False
print(b)  # [ 0 11  2 33]
print(a)  # [0 1 2 3]

```

# 43 补充内容（待整理）

np.pad()函数用于往多维数组添加 padding，使得多层卷积层不会减少图像的宽高

```py
np.pad(x2, ((1,2), (3,4)), "constant", constant_values = 0)
np.pad(x, ((0,0), (1,1), (1,1)), "constant", constant_values = 0)
```

- 参数 x：被扩充的数组
- 参数 2：tuple，长度要和 x 的维度一样，其每个元素用于描述各个维度的 padding，(0,0)表示当前维度不扩充，例如上述代码中，x2 表示二维数组，第一维的(1,2)表示在数组上下分别增加一行、两行指定内容，而(3,4)表示在数组的左右两侧分别增加三列、四列内容。而((0,0), (1,1), (1,1))则表示第一维不 padding，第二维首位 padding 为(1,1)，第三位首位 padding 也为(1,1)
- 参数 3：估计是设置填充类型，"constant"表示用常数填充
- constant_values：表示用 0 填充

# 44 参考链接

- [《Python 数据分析基础教程（第 2 版）》](https://book.douban.com/subject/25798462/)
- [【莫烦 Python】Numpy & Pandas (数据处理教程)](https://www.bilibili.com/video/BV1Ex411L7oT)
