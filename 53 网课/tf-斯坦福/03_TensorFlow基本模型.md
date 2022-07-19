
# 1. 复习

- TensorFlow 将计算的定义和计算分离开来，一个 TensorFlow 程序大致包含下述步骤：
    - 定义计算图
    - 在一个 Session 中计算一个计算图或计算子图
- 可以在 TensorBoard 中可视化计算图，要可视化计算图，需要在构造计算图后，使用`tf.summary.FileWriter`输出计算图，并在 TensorBoard 中打开
- tf.constant 存储在计算图的定义中，当常量很庞大时将导致计算图的导入非常耗时
- tf.Variable 实在 Session 中进行内存的分配和值得存储，因此在使用变量前需要先在 Session 中初始化变量
- 在构建计算图时，我们可能有部分数据是还没有的，是在计算时才能获取到的，比如训练数据，此时需要使用一个 palceholder 暂时表示这些数据，在执行 run 时通过 feed_dict 提供真正的数据
- 最后，记得避免使用懒加载，需要经运算的定义和计算分离开，并使用 Python 属性确定函数只加载一次在函数调用前

# 2. 线性回归

- 数据集： X - 出生率，Y - 存货期望
- 目的：找到 X、Y 之间的关系，给出 X，能够预测 Y
- 模型： y = w * X + b ， 最小化 E( (y-y_predict)^2)

## 2.1 组装计算图

**1. 读取数据**

下载的代码已经包含了读取数据的函数

**2. 为输入和标签创建占位符**

- `tf.placeholder(dtype, shape=None, name=None)` 

**4. 创建参数**

- 权重参数由于需要更新，一般采用变量存储
- `tf.get_variable(name, shape=None, dtype=None,initializer=None,…)`
- 若是使用 constant initializer 创建，则不必填写 shape

**4. 推断（前向传播）**

- `y+predict = w * X + b`

**5. 计算损失函数**

- `loss = tf.square(Y - Y_predicted, name='loss')`

**6. 创建优化器**

- 给定超参数创建优化器，并给优化器设置优化目标
```py
opt = tf.train.GradientDescentOptimizer(learning_rate=0.001)
optimizer = opt.minimize(loss)
```

到此，计算图组装完毕

## 2.2 训练模型（即计算计算图）

**绘制计算图**

- 在执行计算之前，一般会前绘制计算图
- 绘制计算图：`writer = tf.summary.FileWriter('./graphs/linear_reg', sess.graph)`
- 执行代码：`python3 03_linreg_starter.py`
- 在 TensorBoard 打开：`tensorboard --logdir='./graphs'`

**初始化变量**

- 初始化所有变量：`sess.run(tf.global_variables_initialzer())`

**运行优化器**

- 代码没有采用向量化，内循环执行完一次代表一代训练，要将损失值累加起来
```py
for i in range(50): # train the model 100 epochs
    total_loss = 0
    for x, y in data:
    _, loss_ = sess.run([optimizer, loss], feed_dict={X: x, Y:y})
            total_loss += loss_
```
- 

**使用 Matplotlib 绘制结果**

- 下属代码的 plt.plot() 函数，前三个参数，按顺序分别为：X 轴数据、Y 轴数据、绘制类型
```py
plt.plot(data[:,0], data[:,1], 'bo', label='Real data')
plt.plot(data[:,0], data[:,0] * w_out + b_out, 'r', label='Predicted data')
plt.legend()
plt.show()
```

**其他技巧**

- 若想采用 Huber loss 代价函数，可以采用下述实现：
```py
def huber_loss(labels, predictions, delta=14.0):
    residual = tf.abs(labels - predictions)
    def f1(): return 0.5 * tf.square(residual)
    def f2(): return delta * residual - 0.5 * tf.square(delta)
    return tf.cond(residual < delta, f1, f2)
```

# 3. 控制数据流

- TF Control Flow

| Name | op |
|:---: |:---:|
| Control Flow Ops | tf.group, tf.count_up_to, tf.cond, tf.case, tf.while_loop, ...|
| Comparison Ops | tf.equal, tf.not_equal, tf.less, tf.greater, tf.where, ...|
| Logical Ops | tf.logical_and, tf.logical_not, tf.logical_or, tf.logical_xor |
|Debugging Ops | tf.is_finite, tf.is_inf, tf.is_nan, tf.Assert, tf.Print, ... |

# 4. tf.data

**placeholder**

- 优点：将数据处理放在TensorFlow之外，使得在Python中很容易
- 缺点：用户经常最终在单个线程中处理他们的数据并创建数据瓶颈，从而减慢执行速度

## 4.1 tf.data

- tf.data 是一种新的读取数据的方式，常用的包括 tf.data.Dataset 和 tf.data.Iterator

**tf.data.Dataset**

- `tf.data.Dataset.from_tensor_slices((features, labels))` 最常用的创建 DataSet 的方式
- `tf.data.Dataset.from_generator(gen, output_types, output_shapes)`
```py
dataset = tf.data.Dataset.from_tensor_slices((data[:,0], data[:,1])) # 特征 和 label
print(dataset.output_types)		# >> (tf.float32, tf.float32)
print(dataset.output_shapes)		# >> (TensorShape([]), TensorShape([]))
```
**从文件创建 DataSet**

- `tf.data.TextLineDataset(filenames)`：这个函数的输入是一个文件的列表，输出是一个dataset。dataset中的每一个元素就对应了文件中的一行。可以使用这个函数来读入CSV文件
- `tf.data.FixedLengthRecordDataset(filenames)`：这个函数的输入是一个文件的列表和一个record_bytes，之后dataset的每一个元素就是文件中固定字节数record_bytes的内容。通常用来读取以二进制形式保存的文件，如CIFAR10数据集就是这种形式
- `tf.data.TFRecordDataset(filenames)`：顾名思义，这个函数是用来读TFRecord文件的，dataset中的每一个元素就是一个TFExample

**tf.data.Iterator**

- 迭代器用于遍历数据集中的样本
- `iterator = dataset.make_one_shot_iterator()`：从头到尾只能读一次的迭代器，但无需初始化
- `iterator = dataset.make_initializable_iterator()`：可以多次迭代数据，但需要初始化
- one_shot_iterator 迭代器样例代码：
```py
# 用特征向量和分类标签构造训练集
dataset = tf.data.Dataset.from_tensor_slices((data[:, 0], data[:, 1]))
# 创建迭代器
iterator = dataset.make_one_shot_iterator()
X, Y = iterator.get_next() # 迭代各个数据

with tf.Session() as sess:
    try:
        i = 0
        while True:
            # 拿到各个数据
            x, y = sess.run([X, Y])
            print((i, x, y)) # 打印下标和数据
            i += 1
    except tf.errors.OutOfRangeError:
        print("读取完毕")
```
- initializable_iterator 迭代器样例代码：
```py
iterator = dataset.make_initializable_iterator()
...
for i in range(100): 
    sess.run(iterator.initializer)
    total_loss = 0
    try:
        while True:
            sess.run([optimizer])
    except tf.errors.OutOfRangeError:
        pass
```

## 4.2 在 TensorFlow 中处理数据

- `dataset = dataset.shuffle(1000)`：打乱dataset中的元素，它有一个参数buffersize，表示打乱时使用的buffer的大小
- `dataset = dataset.repeat(100)`：epeat的功能就是将整个序列重复多次，主要用来处理机器学习中的epoch，假设原先的数据是一个epoch，使用repeat(5)就可以将之变成5个epoch
- `dataset = dataset.batch(128)`：batch就是将多个元素组合成batch，参数即为 batch size，可以将原来的单个数据重组为各个batch，这样迭代器拿到的就是一个batch
- `dataset = dataset.map(lambda x: tf.one_hot(x, 10)) `：将元素转换为 one_hot 向量
- map 接收一个函数，Dataset中的每个元素都会被当作这个函数的输入，并将函数返回值作为新的Dataset，如我们可以对dataset中每个元素的值加1 `dataset = dataset.map(lambda x: x + 1)`

## 使用 placeholder 还是 tf.data ？

- tf.data 的速度比 placeholder 更快
- 对原型设计来说，使用 feed_dict 更加容易、快速编写
- 当有多个复杂的要处理的数据源时，tf.data 很难处理
- NLP 数据通常只是一个整数序列。 在这种情况下，将数据传输到GPU非常快，因此 tf.data 的加速并不是那么大


# 5. 梯度下降与优化器

- TensorFlow 如何知道要更新哪些参数？ ---> 通过优化器
- `optimizer = tf.train.GradientDescentOptimizer(learning_rate=0.01).minimize(loss)`：定义一个优化器，并设置优化目标为最小化 loss
- `_, l = sess.run([optimizer, loss], feed_dict={X: x, Y:y})`：每执行一次优化器，则相当于做了一次优化器对应的运算，并会更新包括 loss 在内的相应变量
- 运行优化器后，会话会查看 loss 所依赖的所有可训练变量并更新他们
- 创建 Variable 时，默认都是可训练的，即 trainable=True
- TensorFlow 中大致包含这些优化器优化器：
    - tf.train.GradientDescentOptimizer
    - tf.train.AdagradOptimizer
    - tf.train.MomentumOptimizer
    - tf.train.AdamOptimizer
    - tf.train.FtrlOptimizer
    - tf.train.RMSPropOptimizer
    - ...

# 6. MNIST 上的逻辑回归

- MNIST 数据集，每张图片是一个灰度图片，大小为 28 * 28 的数组，展开后为 784 维向量
- X ：输入图片， Y ： 图片类别
- 模型：
    - 推断: Y_predicted = softmax(X * w + b)
    - 交叉熵损失: -log(Y_predicted)
- 新的处理训练集和测试集数据的方法，详细可参考代码：
```py
train_data = tf.data.Dataset.from_tensor_slices(train)
train_data = train_data.shuffle(10000) # optional
test_data = tf.data.Dataset.from_tensor_slices(test)

# 按给定的结构和形状创建新的迭代器，这样这个迭代器可以同时用于训练集和测试集
iterator = tf.data.Iterator.from_structure(train_data.output_types, train_data.output_shapes)
img, label = iterator.get_next()

# 提供不同的数据集创建不同的初始化器
train_init = iterator.make_initializer(train_data)
test_init = iterator.make_initializer(test_data)

with tf.Session() as sess:
    # 执行训练
    for i in range(1): # 模拟训练的 epoch
        sess.run(train_init)# 训练时使用训练初始化器
        try:
            idx = 0
            while True:
                # _, l = sess.run([optimizer, loss])
                l = sess.run(label) # 简单读取，模拟 训练
                idx += 1
        except tf.errors.OutOfRangeError:
            print("读取完毕，共 %d 条训练数据" %(idx))
    # 执行测试
    sess.run(test_init)	# 测试时时使用测试初始化器
    try:
        idx = 0
        while True:
            sess.run(label) # 简单读取，模拟测试过程
            idx += 1
    except tf.errors.OutOfRangeError:
        print("读取完毕，共 %d 条测试数据" % (idx))
```

## 6.1 组装计算图

**1. 读取数据**

课程提供的 utils 工具包已经实现

**2. 创建数据集和迭代器**

```py
train_data = tf.data.Dataset.from_tensor_slices(train)train_data = train_data.shuffle(10000) # optionaltrain_data = train_data.batch(batch_size)
test_data = tf.data.Dataset.from_tensor_slices(test)test_data = test_data.batch(batch_size)

iterator = tf.data.Iterator.from_structure(train_data.output_types, train_data.output_shapes)
img, label = iterator.get_next()
train_init = iterator.make_initializer(train_data)
test_init = iterator.make_initializer(test_data)	
```

**3. 创建权重和偏置**

- 使用tf.get_variable()

**4. 创建模型来预测 Y**

- `logits = tf.matmul(img, w) + b`
- 在这儿我们不进行 softmax ,而是在 cross_entropy 中一并计算

**5. 定义损失函数**

```py
entropy = tf.nn.softmax_cross_entropy_with_logits(labels=label, logits=logits)
loss = tf.reduce_mean(entropy)
```

**6. 创建优化器**

- `tf.train.AdamOptimizer(learning_rate=0.01).minimize(loss)`

## 6.2 训练模型

- 可以使用 TensorBoard 查看计算图
- 初始化所有变量
- 运行优化目标
- 完整代码如下：
```py

```

