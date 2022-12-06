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
y = x ** 2
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

### 2.2.1 figure.add_axes 和 plt.axes

通过调用 `figure.add_axes(rect)` 方法能够将 axes 对象添加到 figure 中，该方法用来生成一个 axes 对象，对象的位置与大小由参数 rect 决定，其是由 4 个浮点数组成，形如 `[left, bottom, width, height]` 的 list，描述了 axes 绘图区域的矩形信息，前两个值表示 axes 的左下角坐标`(x, y)`，后两个值表示 axes 的宽度和高度。例如 `ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])` 即可创建一个 axes 并添加到 figure。注意每个元素的值是 figure 宽度和高度的百分比，例如 `[0.1, 0.1, 0.8, 0.8]` 代表该 axes 从 figure 左下角 10% 的位置开始绘制，axes 的宽高是 figure 的 80%。

还可以直接使用 `plt.axes(rect)` 创建 axes 对象，并自动添加到最新新建的 figure 对象，若没有则会先创建一个 figure，其相当于是 `figure.add_axes(rect)` 的快捷方法。

```py
ax2 = plt.axes([0.1, 0.05, 0.8, 0.4])
l1 = ax2.plot(x1, y, "ys-")  # 黄色/正方形标记/实线
ax3 = plt.axes([0.1, 0.55, 0.8, 0.4])
l2 = ax3.plot(x2, y, "go--")  # 绿色/圆点/虚线
ax3.figure.show()
```

### 2.2.2 axes.plot 和 plt.plot

`axes.plot(x, y, desc)` 方法是 axes 类的基本方法，它将一个数组的值与另一个数组的值绘制成线或标记，第三个参数 `desc` 表示可选格式的字符串参数，用来指定线型、标记颜色、样式以及大小。使用 plot 绘制的图表特点为：如果数据点比较分散化，会体现为折线图，如果数据点很密集，也可以离散化模拟曲线，例如常见的正弦、余弦等等。

也可以直接调用 `plt.plot(...)` 进行绘制，其本质上还是基于 `axes.plot(...)`，其会在前面代码最新一次创建的 axes 对象上进行绘制，如果前面没有创建过 axes 对象，会创建一个（如果没有 figure 还会级联创建 figure）。

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

经测试，也可以直接使用 `plt.legend(...)` 添加说明标记，其本质上应该还是调用 `axes.legend(...)`，其会在前面代码最新一次创建的 axes 对象上进行绘制，前面代码理论上已经必然创建过 axes 并绘制图案了，否则调用 legend 也没有什么意义。

## 2.3 多子图绘制

需要知道的是，matplotlib 使用 figure 抽象整块画布，使用 axes 抽象可绘制区域，之后将 figure 划分为若干个 axes 子区域（允许重叠），并在 axes 上绘制图形。如果只有一张子图，则 figure 只包含一个 axes 对象，如果包含多个子图则一个 figure 包含多个 axes 对象。

子图在本质上就是提前规划好的，对 figure 进行均分的 axes。我们后续要介绍的各种创建子图方法，本质上都是以一定的形式提前规划好 rect 并返回 axes 对象，只不过使用这些函数创建子图更加简便，不用我们自己再计算和划分 rect 了。

### 2.3.1 plt.subplot

matplotlib.pyplot 模块提供 `plt.subplot(nrows, ncols, index, ...)` 函数，它可以均等地划分 figure，其中 nrows 与 ncols 表示要划分几行几列的子图，（nrows\*nclos 表示子图数量），index 用来选定具体的某个子图，初始值为 1 表示第一个子图，其返回值就是当前子图对应的 axes 对象。

```py
x = np.arange(1, 5, 0.05)  # x 轴坐标
y1 = x ** 2
y2 = np.sqrt(x)

ax1 = plt.subplot(211)  # 创建 (2, 1) 划分下的 1 号 axes
ax1.plot(x, y1)  # 在该 axes 上绘制
plt.subplot(212, facecolor='y')  # 创建 (2, 1) 划分下的 2 号 axes，设置背景为黄色
plt.plot(x, y2)  # 在新建的 axes 上绘制，本质上是 axes.plot(...)
plt.show()
```

在新建 subplot 时，如果提供的划分 `(nrows, ncols)` 和已有的划分冲突，将会清空整个 figure（包括以绘制的 axes） 并重新划分。如果新建 subplot 提供的划分 `(nrows, ncols)` 和已有的划分一致，但子图编号和已有的子图重叠，那么将会覆盖重叠子图。如果想保留已有的 subplot，则需要使用 add_subplot 创建子图并进行绘制，或者直接使用原始的 add_axes 函数。

此外，使用 subplot 创建 axes 时，依赖一个 figure，如果已经创建过 figure 则会使用对应 figure，如果没创建过 figure 会自动创建一个，可使用下列代码测试：

```py
x = np.arange(0.1, 5, 0.05)  # 准备 log(x) 和 exp(x) 数据
y1 = np.log(x)
y2 = np.exp(x)

fi = plt.figure()  # 创建 figure
ax1 = plt.subplot(121)  # 创建第一个 axes 并绘制 log(x)
ax1.plot(x, y1)

ax2 = plt.subplot(122)  # 创建第二个 axes 并绘制 exp(x)
ax2.plot(x, y2)

print(ax1.figure is ax2.figure)  # 验证 fi, ax1.figure, ax2.figure 三者指向同一个地方
print(ax1.figure is fi)
print(ax1.figure is fi)

plt.show()
```

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

### 2.3.4 plt.subplot2grid

plt 提供了 `axes = plt.subplot2grid(shape, location, rowspan, colspan)`，该函数能够在画布的特定位置创建 axes 对象（即绘图区域）并返回。不仅如此，它还可以使用不同数量的行、列来创建跨度不同的绘图区域（类似单元格合并）。与 `subplot()` 和 `subplots()` 函数不同，`subplot2gird()` 函数允许通过单元格合并非等分的形式对画布进行切分，并按照绘图区域的大小来展示最终绘图结果，其入参含义如下表所示：

|       参数       |                           含义                            |
| :--------------: | :-------------------------------------------------------: |
|      shape       |           把该参数值规定的网格区域作为绘图区域            |
|     location     | 在给定的位置绘制图形，初始位置 `(0,0)` 表示第 1 行第 1 列 |
| rowsapan/colspan |           这两个参数用来设置让子区跨越几行几列            |

示例代码如下：

```py
x = np.arange(1, 10, 0.05)  # x 轴坐标
y1 = x ** 2
y2 = np.sqrt(x)
y3 = np.exp(x)
y4 = np.log10(x)

ax1 = plt.subplot2grid((3, 3), (0, 0), colspan=2)  # 从 (0, 0) 开始，占据两列
ax2 = plt.subplot2grid((3, 3), (0, 2), rowspan=3)  # 从 (0, 2) 开始，占据三行
ax3 = plt.subplot2grid((3, 3), (1, 0), rowspan=2, colspan=2)  # 从 (1, 0) 开始，占据两行两列

ax1.plot(x, np.exp(x))
ax1.set_title('exp')
ax2.plot(x, x * x)
ax2.set_title('square')
ax3.plot(x, np.log(x))
ax3.set_title('log')

plt.tight_layout()
plt.show()
```

## 2.4 其他辅助信息设置

### 2.4.1 设置网格

axes 对象提供的 `axes.grid(color='b', ls = '-.', lw = 0.25)` 方法可以开启或者关闭画布中的网格（即是否显示网格）以及网格的主/次刻度。除此之外，`grid(...)` 函数还可以设置网格的颜色、线型以及线宽等属性。示例代码如下：

```py
x = np.arange(1, 10, 0.05)  # x 轴坐标
y1 = x ** 2
y2 = np.sqrt(x)
y3 = np.exp(x)

fig, axes = plt.subplots(1, 3, figsize=(12, 4))  # fig画布, axes 子图区域
axes[0].plot(x, y1, 'g', lw=2)
axes[0].grid(True)  # 开启网格
axes[0].set_title('default grid')  # 设置 title

axes[1].plot(x, y2, 'r')  # 设置网格的颜色，线型，线宽
axes[1].grid(color='b', ls='-.', lw=0.25)
axes[1].set_title('custom grid')  # 设置 title

axes[2].plot(x, y3)
axes[2].set_title('no grid')
fig.tight_layout()
plt.show()
```

### 2.4.2 设置坐标轴精度

在一个函数图像中，有时自变量 x 与因变量 y 是指数对应关系，这时需要将坐标轴刻度设置为对数刻度，这样就可以使得指数函数呈现为直线。Matplotlib 通过设置 axes 对象的 xscale 或 yscale 属性来实现对坐标轴的刻度单位精度，例如下列示例代码：

```py
x = np.arange(1, 10, 0.05)  # x 轴坐标
y3 = np.exp(x)

fi = plt.figure()
axes = fi.add_subplot(111)
axes.plot(x, y3)  # 指数函数会体现为一条直线
axes.set_yscale("log")  # 纵坐标设置为对数关系
fi.show()
```

### 2.4.3 设置轴是否显示

在 plt 中，每个 axes 有 4 条轴，通用的描述是上下左右四条轴，但一般的 x, y 坐标轴是指的底部和左侧两条轴说的，可以使用 axes.spines 对象的 bottom, left, right, top 获取指定轴，这样就可以进一步设置相关属性和样式，例如下述代码：

```py
x = np.arange(1, 10, 0.05)  # x 轴坐标
y1 = x ** 2
y2 = np.sqrt(x)

fi = plt.figure()
axes = fi.add_subplot(111)
axes.plot(x, y1)  # 指数函数会体现为一条直线
axes.spines['bottom'].set_color('blue')  # 设置底部轴为蓝色
axes.spines['left'].set_color('red')  # 设置左侧轴为红色
axes.spines['left'].set_linewidth(2)  # 设置左侧轴的宽度为 2
axes.spines['right'].set_color(None)  # 将侧轴、顶部轴设置为 None，即隐藏
axes.spines['top'].set_color(None)
fi.show()
```

### 2.4.4 设置坐标轴数值范围

Matplotlib 可以根据自变量与因变量的取值范围，自动设置 x 轴与 y 轴的数值大小。当然，您也可以用自定义的方式，通过 `set_xlim(start, stop)` 和 `set_ylim(start, stop)` 对 x、y 轴的数值范围进行设置，例如下述示例代码：

```py
x = np.arange(1, 10, 0.05)  # x 轴坐标
y3 = np.exp(x)

fi = plt.figure()
axes = fi.add_subplot(111)
axes.plot(x, y3)  # 指数函数会体现为一条直线
axes.set_ylim(0, 30000)  # 设置 y 轴的数值范围
fi.show()
```

### 2.4.5 设置坐标轴刻度和刻度标签

刻度指的是轴上数据点的标记，Matplotlib 能够自动的在 x 、y 轴上绘制出刻度，这一功能的实现得益于 Matplotlib 内置的刻度定位器和格式化器（两个内建类）。在大多数情况下，这两个内建类完全能够满足我们的绘图需求，但是在某些情况下，刻度标签或刻度也需要满足特定的要求，比如将刻度设置为“英文数字形式”或者“大写阿拉伯数字”，此时就需要对它们重新设置。

`xticks()` 和 `yticks()` 函数接受一个列表对象作为参数，列表中的元素表示对应数轴上要显示的刻度，例如下列示例代码：

```py
x = np.arange(0, np.pi * 2, 0.05)
y = np.sin(x)
fi = plt.figure()
axes = fi.add_subplot(111)
axes.plot(x, y)  # 指数函数会体现为一条直线
axes.set_xticks([0, 2, 4, 6])  # 设置 x 轴要展示的刻度
axes.set_xticklabels(['zero', 'two', 'four', 'six'])  # 设置刻度对应的文本，注意要和上一个数组一一对应
fi.show()
```

### 2.4.6 中文乱码解决

临时解决方案，在导包处添加下列代码：

```py
plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 正常显示负号
```

例如下列示例：

```py
plt.rcParams["font.sans-serif"] = ['sans-serif', 'SimHei']  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 正常显示负号

year = [2017, 2018, 2019, 2020]
people = [20, 40, 60, 70]
plt.plot(year, people)  # 生成图表
plt.xlabel('年份')
plt.ylabel('人口')
plt.title('人口增长')

plt.yticks([0, 20, 40, 60, 80])  # 设置纵坐标刻度
plt.fill_between(year, people, 20, color='green')  # 设置填充选项：参数分别对应横坐标，纵坐标，纵坐标填充起始值，填充颜色
plt.show()
```

# 3 各类图形

## 3.1 散点图

散点图用于在水平轴和垂直轴上绘制数据点，它表示了因变量随自变量变化的趋势。通俗地讲，它反映的是一个变量受另一个变量的影响程度。散点图将序列显示为一组点，其中每个散点值都由该点在图表中的坐标位置表示。对于不同类别的点，则由图表中不同形状或颜色的标记符表示。同时，您也可以设置标记符的颜色或大小。

使用 `plt.scatter(x, y)` 绘制散点图，x 和 y 为必备入参，分别表示坐标的横纵坐标，此外还有其他可选入参，下表列了一部分，更详细的可以参考官方文档 [matplotlib.pyplot.scatter](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.scatter.html)。

| 入参 |           含义           |
| :--: | :----------------------: |
|  c   | 颜色列表，可以有多种形式 |
| cmap |         colormap         |

下面示例，绘制了学生考试成绩的散点图，其中蓝色代表男孩成绩，红色表示女孩的成绩。

```py
x = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]  # x 轴
y_girls = [89, 90, 70, 89, 100, 80, 90, 100, 80, 34]  # girls 散点图的 y 轴
y_boys = [30, 29, 49, 48, 100, 48, 38, 45, 20, 30]  # boys 散点图的 y 轴
fig = plt.figure()
ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])  # 添加绘图区域
ax.scatter(x, y_girls, color='r', label="girls")
ax.scatter(x, y_boys, color='b', label="boys")
ax.set_xlabel('Grades Range')
ax.set_ylabel('Grades Scored')
ax.set_title('scatter plot')
ax.legend()  # 添加说明图例
fig.show()
```

## 3.2 等高线

等高线图（也称“水平图”）是一种在二维平面上显示 3D 图像的方法。等高线有时也被称为 “Z 切片”，如果您想要查看因变量 Z 与自变量 X、Y 之间的函数图像变化（即 `Z = f(X,Y)`），那么采用等高线图最为直观。

自变量 X 和 Y 需要被限制在矩形网格内，您可以将 x、y 数组作为参数传递给 `numpy.meshgrid(x, y)` 函数来构建一个网格点矩阵。

Matplotlib API 提供了绘制等高线（contour）与填充等高线（contourf）的函数。这两个函数都至少需要三个参数，分别是 X、Y 与 Z。其中 X 是网格点横坐标组成的矩阵，Y 是网格点纵坐标组成的矩阵，Z 则是网格点的值。示例代码如下：

```py
x = np.linspace(-3.0, 3.0, 100)  # 创建 x, y 数组
y = np.linspace(-3.0, 3.0, 100)
xx, yy = np.meshgrid(x, y)  # 将上述数据变成网格数据形式
z = np.sqrt(xx ** 2 + yy ** 2)  # 使用圆公式定义 z 与 x, y 之间的关系：z = x^2 + y^2
fig, ax = plt.subplots(1, 1)  # 创建 figure 和 axes
cp = ax.contourf(x, y, z)  # 填充等高线颜色
fig.colorbar(cp)  # 给图像添加颜色柱
ax.contour(x, y, z)  # 绘制等高线
ax.set_title('Filled Contours Plot')  # 设置 title
ax.set_xlabel('x (cm)')  # 设置 x 轴描述
ax.set_ylabel('y (cm)')  # 设置 y 轴描述
plt.show()
```

除了必备参数外，绘制等高线还可提供下列参可选数：

- alpha：设置透明度，介于 0（透明）和 1（不透明）之间。
- cmap：一个 Colormap 示例或者预定义的 colormap 名称，Colormap 是从浮点高度值到 RGB 颜色值的一个映射，例如 `cmap=plt.cm.hot` 为常用的热力图映射方案，其是 plt 定义好的一套热力图等高线颜色方案，可用方案可参考链接 [Choosing Colormaps in Matplotlib](https://matplotlib.org/stable/tutorials/colors/colormaps.html)。
