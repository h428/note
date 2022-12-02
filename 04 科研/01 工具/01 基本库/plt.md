# 介绍

Matplotlib 是 Python 中最受欢迎的数据可视化软件包之一，支持跨平台运行，它是 Python 常用的 2D 绘图库，同时它也提供了一部分 3D 绘图接口。

Matplotlib 通常与 NumPy、Pandas 一起使用，是数据分析中不可或缺的重要工具之一，它能够根据 NumPy ndarray 数组来绘制 2D 图像，它使用简单、代码清晰易懂，深受广大技术爱好者喜爱。

安装命令：`conda install matplotlib -y`，安装完后可以使用下列代码进行测试

```py
import matplotlib
matplotlib.__version__
```

## pyplot

Matplotlib 中的 pyplot 模块是一个类似命令风格的函数集合，这使得 Matplotlib 的工作模式和 MATLAB 相似。我们在实际编写程序中一般都是基于 pyplot 进行绘制，故一般有下列引入代码：

```py
import matplotlib.pyplot as plt
```

pyplot 模块提供了可以用来绘图的各种函数，比如创建一个画布，在画布中创建一个绘图区域，或是在绘图区域添加一些线、标签等，整体上可以将这些绘图函数分为四类，分别是：

- 绘图函数：主要绘制各类统计图和标记，包括条形图、直方图、饼状图、散点图等
- Image 函数：主要读取和展示图片
- Axis 函数：主要绘制坐标轴、标题等描述信息
- Figure 函数：画布的创建和保存

基于 pyplot 的 Hello, World 代码如下

```py
x = np.arange(0, np.pi * 2, 0.05)  # 构造 [0, 2pi] 的 x，没 0.05 间隔一个点
y = np.sin(x)  # 求 sin
plt.plot(x, y)  # 绘制正弦图形，注意计算机中的图形都是离散化的，都是通过构造大量断间距的 (x, y) 坐标点来进行绘制的
plt.xlabel("angle")  # 添加 x 轴描述，不建议采用中文，可能出错
plt.ylabel("sine")  # 添加 y 轴描述，不建议采用中文，可能出错
plt.title('sine wave')  # 添加图片标题，不建议采用中文，可能出错
plt.show()  # 如果是在 PyCharm 内部执行一般还要加上这一行才可以显示图片
```

## pylab

pylab 将许多常用的 module 集中到统一的 namespace，目的是提供一个类似 matlab 的工作环境，省去很多包名，更加侧重在类似 IPython 这样的交互环境中使用，平时编码还是建议使用 pyplot。如果是在交互式环境中，一般直接使用命令 `from pylab import *` 进行全量式导包，然后就可以直接使用相关绘制函数。

例如，下列是绘制 y = x \*\* 2 的样例：

```py
from numpy import *
from pylab import *
x = linspace(-3, 3, 30)
y = x**2
plot(x, y)
show()
```

# 标准绘图流程

## figure 对象

通过前面的学习，我们知道 matplotlib.pyplot 模块能够快速地生成图像，但如果使用面向对象的编程思想，我们就可以更好地控制和自定义图像。在 Matplotlib 中，面向对象编程的核心思想是创建图形对象（figure object），通过图形对象来 figure 调用其它的方法和属性，这样有助于我们更好地处理多个画布，在这个过程中，pyplot 负责生成图形对象，并通过该对象来添加一个或多个 axes 对象（即绘图区域）。

使用 `plt.figure()` 创建图形对象，该方法入参如下表所示：

|   参数    |                          说明                           |
| :-------: | :-----------------------------------------------------: |
|  figsize  |        指定画布的大小，(宽度,高度)，单位为英寸。        |
|    dpi    | 指定绘图对象的分辨率，即每英寸多少个像素，默认值为 80。 |
| facecolor |                       背景颜色。                        |
| dgecolor  |                       边框颜色。                        |
|  frameon  |                     是否显示边框。                      |

经测试使用 `figure.add_axes` 返回的 axes 对象在 jupyter 中能正常显示，但在 PyCharm 中只能显示图像，但 title 和 label 信息无法正常展示，若改为使用 `plt.subplot` 返回的 axes 对象则可以正常显示。基于 figure 的示例代码如下：

```py
x = np.arange(0, 2 * np.pi, 0.05)
y = np.sin(x)
figure = plt.figure()  # 准备 figure 对象
ax = figure.add_axes([0, 0, 1, 1])  # 使用 add_axes 将 axes 轴域添加到画布中
ax.plot(x, y)
plt.title("sine wave")
ax.set_xlabel("angle")
ax.set_ylabel("sine")
plt.show()
```

## axes 类

Matplotlib 定义了一个 axes 类（轴域类），该类的对象被称为 axes 对象（即轴域对象），它指定了一个有数值范围限制的绘图区域。在一个给定的 figure 中可以包含多个 axes 对象，但是同一个 axes 对象只能在一个 figure 中使用。`plt.subplot()` 方法返回的实际上也是 axes 对象。

> 2D 绘图区域（axes）包含两个轴（axis）对象；如果是 3D 绘图区域，则包含三个。

通过调用 `figure.add_axes(rect)` 方法能够将 axes 对象添加到 figure 中，该方法用来生成一个 axes 对象，对象的位置大小由参数 rect 决定，其是由 4 个浮点数组成，形如 `[left, bottom, width, height]` 的 list，描述了 axes 矩形的信息，前两个值表示 axes 的左下角坐标`(x, y)`，后两个值表示 axes 的宽度和高度。例如 `ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])` 即可创建一个 axes 并添加到 figure。注意每个元素的值是 figure 宽度和高度的百分比，例如 `[0.1, 0.1, 0.8, 0.8]` 代表该 axes 从 figure 左下角 10% 的位置开始绘制，axes 的宽高是 figure 的 80%。

### axes.plot

axes 类的基本方法，它将一个数组的值与另一个数组的值绘制成线或标记，plot() 方法具有可选格式的字符串参数，用来指定线型、标记颜色、样式以及大小。如果数据点比较分散化，会体现为折线图，如果数据点很密集，也可以离散化模拟曲线，例如常见的正弦、余弦等等。

颜色代码如下表：

| 标记 | 颜色 |
| :--: | :--: |
| 'b'  | 蓝色 |
| 'g'  | 绿色 |
| 'r'  | 红色 |
| 'c'  | 青色 |
| 'm'  | 品红 |
| 'y'  | 黄色 |
| 'k'  | 黑色 |
| 'w'  | 白色 |

标记符号如下表：

| 标记符号 |    描述    |
| :------: | :--------: |
|   '.'    |   点标记   |
|   'o'    |  圆圈标记  |
|   'x'    |  'X'标记   |
|   'D'    |  钻石标记  |
|   'H'    |  六角标记  |
|   's'    | 正方形标记 |
|   '+'    |  加号标记  |

线型表示字符，如下表：

| 字符 |   描述   |
| :--: | :------: |
| '-'  |   实线   |
| '--' |   虚线   |
| '-.' |  点划线  |
| ':'  |   虚线   |
| 'H'  | 六角标记 |

简单的绘制例子如下：

```py
y = [1, 4, 9, 16, 25, 36, 49, 64]
x1 = [1, 16, 30, 42, 55, 68, 77, 88]
x2 = [1, 6, 12, 18, 28, 40, 52, 65]

fi = plt.figure()
ax = fi.add_axes([0.1, 0.1, 0.8, 0.8])  # 宽高 80%，从左下角 10% 处开始绘制
l1 = ax.plot(x1, y, "ys-")  # 黄色/正方形标记/实线
l2 = ax.plot(x2, y, "go--")  # 绿色/圆点/虚线
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title("simple line")
ax.legend(labels=("x1", "x2"), loc="lower right")  # 按绘制顺序标记曲线
plt.show()
```

### axes.legend

我们如果绘制了多条曲线，有时候会希望为这几条曲线分别添加说明，这时候可以使用 `ax.legend(handles, labels, loc)` 方法按序为 plot 绘制的图形添加说明图例以便于区分不同曲线（添加一个小矩形，描述那条曲线是什么样式的以及对应的含义），它需要三个参数，如下所示：

|  参数   |                          描述                          |
| :-----: | :----------------------------------------------------: |
| handles |      参数，它也是一个序列，它包含了所有线型的实例      |
| labels  |          是一个字符串序列，用来指定标签的名称          |
|   loc   | 是指定图例位置的参数，其参数值可以用字符串或整数来表示 |

其中 loc 参数用于指定图形的位置，其可以有字符串和数字两种取值，主要有下列取值：

|   位置   |  字符串表示  | 整数数字表示 |
| :------: | :----------: | :----------: |
|  自适应  |     Best     |      0       |
|  右上方  | upper right  |      1       |
|  左上方  |  upper left  |      2       |
|   左下   |  lower left  |      3       |
|   右下   | lower right  |      4       |
|   右侧   |    right     |      5       |
| 居中靠左 | center left  |      6       |
| 居中靠右 | center right |      7       |
| 底部居中 | lower center |      8       |
| 上部居中 | upper center |      9       |
|   中部   |    center    |      10      |

## subplot()

在使用 Matplotlib 绘图时，我们大多数情况下，需要将一张 figure 划分为若干个子区域，之后，我们就可以在这些区域上绘制不用的图形。在本节，我们将学习如何在同一画布上绘制多个子图。

matplotlib.pyplot 模块提供了一个 subplot() 函数，它可以均等地划分画布，该函数的参数格式为 `plt.subplot(nrows, ncols, index)`，其中 nrows 与 ncols 表示要划分几行几列的子图，（nrows\*nclos 表示子图数量），index 用来选定具体的某个子图，初始值为 1 表示第一个子图。

```py
# 现在创建一个子图，它表示一个有 2 行 1 列的网格的顶部图。
# 因为这个子图将与第一个重叠，所以之前创建的图将被删除
plt.subplot(211)
plt.plot(range(12))
# 创建带有黄色背景的第二个子图
plt.subplot(212, facecolor='y')
plt.plot(range(12))
plt.show()
```

## add_subplot()
