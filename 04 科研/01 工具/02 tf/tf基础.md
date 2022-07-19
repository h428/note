

# 概述

> [官方教程](http://www.tensorfly.cn/tfdoc/get_started/basic_usage.html)

## 自我总结

常见的Tensor包括常量常量（tf.constant）、占位符（tf.placeholder），操作间传递的数据都是 tensor。

此外，还有变量类型（tf.Vatiable），变量维护图执行过程中的状态信息（个人认为也可以当做一个Tensor）。

一个经典的计算图由上述成分组成，并计算出最终结果结果。

# tf类型基础

> TensorFlow 使用 tensor 表示数据. 通过 变量 (Variable) 维护状态. （引用自官方文档）

个人认为，Variable也可算是Tensor，因而Tensor主要包括：常量(tf.constant)、占位符(tf.placeholder)和变量(tf.Variable).

**常量**

使用`tf.constant()`构造常量，其构造的常量可直接计算，但要打印函数值必须利用`sess.run()`：
```py
a = tf.constant([2,3])      # tf常量
b = tf.constant([10,4])     # tf常量
c = tf.multiply(a,b)        # 执行计算

with tf.Session() as sess:
    print(sess.run(c))      # 要打印必须利用sess.run()
```

**占位符**

使用`tf.placeholder`定义占位符，占位符可以运行时在提供数据，在`sess.run()`中以参数的形式提供。

```py
x = tf.placeholder(tf.int64, name = 'x')

with tf.Session() as sess:
    print(sess.run(2 * x, feed_dict = {x: 3}))
```

**Vatiable类型**

tf.Variable()为图变量，可定义相关计算式子进行计算，注意计算之前必须先初始化：
```py
y_hat = tf.constant(36, name='y_hat')            # tf常量 y_hat
y = tf.constant(39, name='y')                    # tf常量 y

loss = tf.Variable((y - y_hat)**2, name='loss')  # tf图变量：loss

init = tf.global_variables_initializer()         # 初始化所有图变量

with tf.Session() as session:                    # 创建一个session
    session.run(init)                            # 真正执行初始化
    print(session.run(loss))                     # 计算函数值并打印
```
