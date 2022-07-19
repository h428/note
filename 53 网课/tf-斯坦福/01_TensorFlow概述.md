
# TensorFlow 概述

**为什么使用TensorFlow？**

- 开源软件工具包，通过数据流图进行数值计算
- 拥有许多开源的机器学习库
- 可扩展性和灵活性，由谷歌开发，适合做研究和应用于生产
- 社区活跃（使用者多）

**课程目的**

- 理解 TensorFlow 的计算图
- 学习 TensorFlow 内置类型和相关内建函数
- 学习如何以最合适的方法构建一些深度学习模型

# 计算图和 Session

- TensorFlow 将计算的定义和运行分离开来
- 构建 TensorFlow 程序步骤：
    - 组装一个计算图
    - 在一个 Session 中执行计算图中的运算

**什么是 Tensor**

- 是一个 n 维数组
- 0-d tensor: scalar (number) 
- 1-d tensor: vector
- 2-d tensor: matrix
- and so on

**数据流图（计算图）**

- TensorFlow 会自动为节点命名若计算图中的某节点没被你显示命名
- 比如：`a = tf.add(3, 5)`，会自动为 3 和 5 添加名称
- 计算图由 nodes 和 edges 组成，其中，nodes 包括 operators, variables, 和 constants，edges 包括 tensors
- Tensors 是数据，TensorFlow = tensor + flow = data + flow 
- 对于计算图中的类型，使用 print 直接打印会输出所属的类型，例如 `a = tf.add(3, 5)`，直接打印显示为 `Tensor("Add_1:0", shape=(), dtype=int32)` ，是一个 operator 类型，并不会打印其值
- 要计算节点的值，需要开启 Session，并在 Session 中计算值，因为 TensorFlow 存储的是计算的定义，计算要在 Session 中计算
- 定义完计算图后，除了占位符之类的类型，其他节点一般有一个初始值，但是在执行运行时可以替换某个节点的值，如下述代码所示：
```py
x = tf.constant(3)
y = tf.constant(5)
a = tf.add(x, y)
with tf.Session() as sess:
    b = sess.run(a, feed_dict={x: 11}) # 替换计算图中的节点 x
    print(b) # 结果是 16 而不是 8
```
- 计算图由点和边构成，注意 tf.add 、 tf.multiply 这些运算也是节点类型
- `tf.Session.run(fetches, feed_dict=None, options=None, run_metadata=None)`，该函数用于计算一个或子图，fetches 是一个 list，那样返回值也是 list，feed_dict 可以用于替换子图中的节点值和填充占位符
- 在这种模型的架构下，允许你利用多个 CPU、GPU 并行计算多个子图，最后再计算出总结果，例如 AlexNet
- 下面代码是一个例子，其调用某个具体的 GPU 计算一个子图：
```py
To put part of a graph on a specific CPU or GPU:
# Creates a graph.
with tf.device('/gpu:2'):
  a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], name='a')
  b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], name='b')
  c = tf.multiply(a, b)

# Creates a session with log_device_placement set to True.
sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))

# Runs the op.
print(sess.run(c))
```

# 多个计算图

- 一般不需要多个计算图，session 会计算默认的计算图
- 且多个计算图需要多个会话，且每个会话默认情况下会自动尝试使用所有可用资源
- 若不通过 python/numpy，无法在它们之间传递数据，但 python/numpy 在分布式协议中是不起作用的
- 因此，好的做法是在默认计算图中开出多个分开的子图，而不是定义多个计算图
- 若确实需要，则使用 `tf.Graph()` 定义新的计算图
- 为了往自定义计算图中添加操作，需要先将其设置为默认图，然后用该图开启一个Session，最后在 Session 中计算结果：
```py
g = tf.Graph() # 新建图 g
with g.as_default(): # 将图 g 设置为默认图
    x = tf.add(3, 5) # 添加操作
with tf.Session(graph=g) as sess: # 开启图 g 的 Session
    print(sess.run(x)) # 计算子图
```
- 若要获取原有默认计算图，可以执行 `g = tf.get_default_graph()`，但注意要在 `g.as_default()` 的代码块外部，若在其内部，默认计算图已经更改为自定义的计算图
- 不建议自定义计算图，默认计算图已经够用了，但若真的定义了，一定要区分清楚默认计算图和自定义计算图：
```py
g1 = tf.get_default_graph() # 获取默认计算图
g2 = tf.Graph() # 自定义一个计算图
# 将操作添加到默认计算图
with g1.as_default():
    a = tf.Constant(3) 
# 将操作添加到自定义的计算图
with g2.as_default():
    # 注意在该代码块内部，默认计算图变为 g2
    b = tf.Constant(5)
```

# 为什么使用计算图

- 节省计算：只有当运行子图时，才会计算所需子图，且不会进行多余计算
- 将计算切分到更小的计算，促进自动分区 (auto-differentiation)
- 可将不同的子图分派到不同的 CPU、GPU 进行并行计算，增加计算速度
- 许多机器学习的模型就是直接以计算图的展示的
