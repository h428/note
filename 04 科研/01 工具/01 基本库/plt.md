# 1 介绍

Matplotlib 是 Python 中最受欢迎的数据可视化软件包之一，支持跨平台运行，它是 Python 常用的 2D 绘图库，同时它也提供了一部分 3D 绘图接口。

Matplotlib 通常与 NumPy、Pandas 一起使用，是数据分析中不可或缺的重要工具之一，它能够根据 NumPy ndarray 数组来绘制 2D 图像，它使用简单、代码清晰易懂，深受广大技术爱好者喜爱。

安装命令：`conda install matplotlib -y`，安装完后可以使用下列代码进行测试

```py
import matplotlib
matplotlib.__version__
```

## 1.1 pyplot

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

## 1.2 pylab

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

# 2 绘图组件

通过前面的学习，我们知道 matplotlib.pyplot 模块能够快速地生成图像，但如果使用面向对象的编程思想，我们就可以更好地控制和自定义图像。在 matplotlib 中，涉及到的对象主要包括 figure, axes, axis 和 artist，它们的作用如下所示：

- Figure：指整个图形，您可以把它理解成一张画布，它包括了所有的元素，比如标题、轴线等。
- Axes：绘制 2D 图像的实际区域，也称为轴域区，或者绘图区，一个 figure 可以包含多个 axes，即一张图形含有多张子图
- Axis：指坐标系中的垂直轴与水平轴，包含轴的长度大小（图中轴长为 7）、轴标签（指 x 轴，y 轴）和刻度标签，每个 axes 中一般只会有一个坐标轴，但可能保留不同的标尺信息
- Artist：您在画布上看到的所有元素都属于 Artist 对象，比如文本对象（title、xlabel、ylabel）、Line2D 对象（用于绘制 2D 图像）等。

![plt 组件](https://raw.githubusercontent.com/h428/img/master/note/00000232.jpg)

> 注意：下述内容全凭猜测，只是为了个人辅助理解，猜测挂靠在 plt 下函数的相关行为。

类似 GUI 编程，在使用 plt 进行绘制，也是基于面向对象思想，按照上述包含关系，需要逐一创建 figure, axes，然后再在 axes 内部绘制绘制内容，但这样标准的面向对象编程流程很繁琐，因此 plt 为我们简化了工作。经过测试，其整体的思想为：当调用 plt.xxx 某一函数时，若依赖有 figure 或 axes 对象，plt 会就近选择最新创建的对应对象（合理猜测 plt 内部应该是做了全局缓存），如果最近没有创建过对应对象，plt 会为我们自动级联创建需要的对象。

例如，我们前面的示例代码并没有创建 figure, axes 等，直接调用 `plt.plot(...)` 就进行了绘制，而 plot 实际上是 axes 对象的函数，其依赖一个 axes 对象，而由于我们在前面的代码没有创建过 axes 对象，故 plt 会为我们创建一个 axes 对象，而创建 axes 对象又需要一个 figure 对象，plt 又会为我们级联创建 figure 对象，最后才调用 axes 对象的 plot 方法完成 axis 和 line2D 对象的绘制。

使用基于面向对象思想进行绘图能使得我们的代码具备更好的可读性，因此建议采用下述绘图流程：

- 首先，使用 `plt.figure` 创建 figure 对象（除了首次创建 figure 对象意外，不要再直接使用 plt 下的任何其他函数）
- 根据需要，使用 figure 对象创建所需数量的 axes
- 在 axes 上绘制对象，建议采用 axes.plot 而不要直接使用 plt.plot
- 调用 figure.show 显示对象

## 2.1 figure 对象

使用 `plt.figure()` 创建图形对象，该方法入参如下表所示：

|   参数    |                          说明                           |
| :-------: | :-----------------------------------------------------: |
|  figsize  |        指定画布的大小，(宽度,高度)，单位为英寸。        |
|    dpi    | 指定绘图对象的分辨率，即每英寸多少个像素，默认值为 80。 |
| facecolor |                       背景颜色。                        |
| dgecolor  |                       边框颜色。                        |
|  frameon  |                     是否显示边框。                      |

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

> 注意上述代码，在创建 axes 时指定了 rect 为 `[0, 0, 1, 1]`，其表示该 axes 绘制区域占满整个 figure，这使得 title, label 之类的信息在 PyCharm 中这类的 IDE 无法展示，但在 jupyter 中可以正常展示。

## 2.2 axes 对象

Matplotlib 定义了一个 axes 类（轴域类），该类的对象被称为 axes 对象（即轴域对象），它指定了一个有数值范围限制的绘图区域。在一个给定的 figure 中可以包含多个 axes 对象，但是同一个 axes 对象只能在一个 figure 中使用，例如 `plt.subplot(...)` 方法返回的实际上就是 axes 对象。

> 2D 绘图区域（axes）包含两个轴（axis）对象；如果是 3D 绘图区域，则包含三个。

### 2.2.1 figure.add_axes 和 np.axes

通过调用 `figure.add_axes(rect)` 方法能够将 axes 对象添加到 figure 中，该方法用来生成一个 axes 对象，对象的位置大小由参数 rect 决定，其是由 4 个浮点数组成，形如 `[left, bottom, width, height]` 的 list，描述了 axes 矩形的信息，前两个值表示 axes 的左下角坐标`(x, y)`，后两个值表示 axes 的宽度和高度。例如 `ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])` 即可创建一个 axes 并添加到 figure。注意每个元素的值是 figure 宽度和高度的百分比，例如 `[0.1, 0.1, 0.8, 0.8]` 代表该 axes 从 figure 左下角 10% 的位置开始绘制，axes 的宽高是 figure 的 80%。

还可以直接使用 `np.axes(rect)` 创建 axes 对象，并添加到上一次访问的 figure 对象，若没有则会先创建一个 figure，其相当于是 `figure.add_axes(rect)` 的快捷方法。

```py
ax2 = plt.axes([0.1, 0.05, 0.8, 0.4])
l1 = ax2.plot(x1, y, "ys-")  # 黄色/正方形标记/实线
ax3 = plt.axes([0.1, 0.55, 0.8, 0.4])
l2 = ax3.plot(x2, y, "go--")  # 绿色/圆点/虚线
ax3.figure.show()
```

### 2.2.2 axes.plot 和 plt.plot

`axes.plot(x, y, desc)` 方法是 axes 类的基本方法，它将一个数组的值与另一个数组的值绘制成线或标记，第三个参数 `desc` 表示可选格式的字符串参数，用来指定线型、标记颜色、样式以及大小。使用 plot 绘制的图表特点为：如果数据点比较分散化，会体现为折线图，如果数据点很密集，也可以离散化模拟曲线，例如常见的正弦、余弦等等。

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

> 在直接调用 `np.plot(...)` 时，会在基于前面代码最新一次创建或访问的 axes 对象进行绘制，如果前面没有创建过 axes 对象，会创建一个（可能会级联创建 figure）。

### 2.2.3 axes.legend

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

## 2.3 多子图绘制

需要知道的是，matplotlib 使用 figure 抽象整块画布，使用 axes 抽象可绘制区域，之后将 figure 划分为若干个 axes 子区域（允许重叠），并在 axes 上绘制图形。如果只有一张子图，则 figure 只包含一个 axes 对象，如果包含多个子图则一个 figure 包含多个 axes 对象。

子图在本质上就是提前规划好的，对 figure 进行均分的 axes。我们后续要介绍的各种创建子图方法，本质上都是以一定的形式提前规划好 rect 并返回 axes 对象，只不过使用这些函数创建子图更加简便，不用我们自己再计算和划分 rect 了。

### 2.3.1 plt.subplot

matplotlib.pyplot 模块提供 `plt.subplot(nrows, ncols, index, ...)` 函数，它可以均等地划分 figure，其中 nrows 与 ncols 表示要划分几行几列的子图，（nrows\*nclos 表示子图数量），index 用来选定具体的某个子图，初始值为 1 表示第一个子图，其返回值就是当前子图对应的 axes 对象。

```py
ax1 = plt.subplot(211)  # 创建 (2, 1) 划分下的 1 号 axes
ax1.plot(range(12))  # 在该 axes 上绘制，本质上是 axes.plot(...)
plt.subplot(212, facecolor='y')  # 创建 (2, 1) 划分下的 2 号 axes，设置背景为黄色
plt.plot(range(12))  # 在该 axes 上绘制，本质上是 axes.plot(...)
plt.show()
```

在新建 subplot 时，如果提供的划分 `(nrows, ncols)` 和已有的划分冲突，将会清空整个 figure（包括以绘制的 axes） 并重新划分。如果新建 subplot 提供的划分 `(nrows, ncols)` 和已有的划分一致，但子图编号和已有的子图重叠，那么将会覆盖重叠子图。如果想保留已有的 subplot，则需要使用 add_subplot 创建子图并进行绘制，或者直接使用原始的 add_axes 函数。

### 2.3.2 figure.add_subplot

使用 `add_subplot(nrows, ncols, index, ...)` 同样可以创建子图，且当多个子图的划分冲突时允许在 Z 轴方向重叠（类似 CSS 中的 z-index），其中后添加的子图优先级更高，会覆盖前面的重叠部分的子图。

下列示例代码，可以看成由两个 figure 重叠而成，其中 ax1 的规划为 `(1, 1, 1)` 占满整个 figure，而 ax2 的规划为 `(2, 2, 1-4)`，两个划分互相冲突，使用 add_subplot 可以共存，后绘制的 4 个子图会重叠在 ax1 之上，但我们人看可以在缝隙看到部分 ax1 的内容；如果我们把 ax1 的代码放到底部，则其会完全覆盖 ax2

```py
fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.plot([1,2,3])
ax2 = fig.add_subplot(221, facecolor='y')
ax2.plot([1,2,3])
ax2 = fig.add_subplot(222, facecolor='y')
ax2.plot([3,2,1])
ax2 = fig.add_subplot(223, facecolor='y')
ax2.plot([3,2,1])
ax2 = fig.add_subplot(224, facecolor='y')
ax2.plot([1,2,3])
```

类似地，直接使用 axes 也可以完成重叠式绘制，且其比 add_subplot 更加灵活（但 add_subplot 的平均划分机制使得编写代码更加便捷），只需定义好 rect 参数即可，例如下列示例代码在主图绘制 sin(x) 函数，然后再右上角补充 cos(x) 函数：

```py
x = np.arange(0, np.pi * 2, 0.05)
sin = np.sin(x)
cos = np.cos(x)
fig = plt.figure()

axes1 = fig.add_axes([0.1, 0.1, 0.8, 0.8])  # 主图为 sin 函数
axes1.plot(x, sin, 'b')
axes1.set_title('sine')

axes2 = fig.add_axes([0.55, 0.55, 0.3, 0.3])  # 有伤角区域为 cos 函数
axes2.plot(x, cos, 'r')
axes2.set_title("cosine")
plt.show()
```

### 2.3.3 plt.subplots

plt 提供了 `fig, ax = plt.subplots(nrows, ncols)` 函数，它的使用方法和 `plt.subplot(...)` 函数类似。其不同之处在于，`plt.subplots(nrows, ncols)` 会同时返回 figure 和 axes 数组对象（一维或二维数组），而 `plt.subplot()` 只会返回单个 axes 对象（当然其内部包含了创建 figure 的代码，可以使用 `ax.figure` 查看）

```py
x = np.arange(1, 5, 0.05)  # x 轴坐标
fig, a = plt.subplots(2, 2)  # 创建 (2, 2) 子图
a[0][0].plot(x, x * x)  # 绘制平方函数
a[0][0].set_title('square')
a[0][1].plot(x, np.sqrt(x))  # 绘制平方根图像
a[0][1].set_title('square root')
a[1][0].plot(x, np.exp(x))  # 绘制指数函数
a[1][0].set_title('exp')
a[1][1].plot(x, np.log10(x))  # 绘制对数函数
a[1][1].set_title('log')
fig.show()
```

## 2.4 plt.subplot2grid
