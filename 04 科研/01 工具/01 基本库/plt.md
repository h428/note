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

# axes 类
