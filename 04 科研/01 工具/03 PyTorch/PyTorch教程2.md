
# PyTorch 和 numpy 的比较

- 本笔记来自于[Movan](https://github.com/MorvanZhou/PyTorch-Tutorial/tree/master/tutorial-contents)
- 可能用到的包：
```py
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable
import matplotlib.pyplot as plt
```
- PyTorch 和 numpy 中的许多操作十分类似，并且可以互相转换
- PyTorch 和 numpy 的互相转换

```py
np_data = np.arange(6).reshape((2, 3))  # 生成 numpy 数组
torch_data = torch.from_numpy(np_data)  # 转化为 Tensor
tensor2array = torch_data.numpy()  # Tensor 转化为 ndarray
print(
    '\nnumpy array:', np_data,          # [[0 1 2], [3 4 5]]
    '\ntorch tensor:', torch_data,      #  0  1  2 \n 3  4  5    [torch.LongTensor of size 2x3]
    '\ntensor to array:', tensor2array, # [[0 1 2], [3 4 5]]
)
```
- 常见数学运算
```py
# 绝对值：abs
data = [-1, -2, 1, 2]
tensor = torch.FloatTensor(data)  # 32-bit floating point
print(
    '\nabs',
    '\nnumpy: ', np.abs(data),          # [1 2 1 2]
    '\ntorch: ', torch.abs(tensor)      # [1 2 1 2]
)

# 正弦：sin
print(
    '\nsin',
    '\nnumpy: ', np.sin(data),      # [-0.84147098 -0.90929743  0.84147098  0.90929743]
    '\ntorch: ', torch.sin(tensor)  # [-0.8415 -0.9093  0.8415  0.9093]
)

# 平均：mean
print(
    '\nmean',
    '\nnumpy: ', np.mean(data),         # 0.0
    '\ntorch: ', torch.mean(tensor)     # 0.0
)
```
- 矩阵运算
```py
# 矩阵乘法
data = [[1,2], [3,4]]
tensor = torch.FloatTensor(data)  # 32-bit floating point
# correct method
print(
    '\nmatrix multiplication (matmul)',
    '\nnumpy: ', np.matmul(data, data),     # [[7, 10], [15, 22]]
    '\ntorch: ', torch.mm(tensor, tensor)   # [[7, 10], [15, 22]]
)
# incorrect method
data = np.array(data)
print(
    '\nmatrix multiplication (dot)',
    '\nnumpy: ', data.dot(data),        # [[7, 10], [15, 22]]，也是矩阵乘法
    '\ntorch: ', tensor.dot(tensor)     # this will convert tensor to [1,2,3,4], you'll get 30.0，新版的pytorch改为只支持向量
)
```

# 变量

- 新版 PyTorch 已将 Variable 整合到 Tensor 中，不再建议使用 Variable，但仍然提供样例代码：
```py
import torch
from torch.autograd import Variable

# 使用 Variable 构建动态计算图，注意新版的 PyTorch 已经可以直接使用 Tensor 执行计算图的构建

tensor = torch.FloatTensor([[1,2],[3,4]])            # build a tensor
variable = Variable(tensor, requires_grad=True)      # build a variable, usually for compute gradients

print(tensor)       # [torch.FloatTensor of size 2x2]
print(variable)     # [torch.FloatTensor of size 2x2]

# till now the tensor and variable seem the same.
# However, the variable is a part of the graph, it's a part of the auto-gradient.

t_out = torch.mean(tensor*tensor)       # x^2
v_out = torch.mean(variable*variable)   # x^2
print(t_out)
print(v_out)    # 7.5

v_out.backward()    # backpropagation from v_out
# v_out = 1/4 * sum(variable*variable)
# the gradients w.r.t the variable, d(v_out)/d(variable) = 1/4*2*variable = variable/2
print(variable.grad)
'''
 0.5000  1.0000
 1.5000  2.0000
'''

print(variable)     # this is data in variable format
"""
Variable containing:
 1  2
 3  4
[torch.FloatTensor of size 2x2]
"""

print(variable.data)    # this is data in tensor format
"""
 1  2
 3  4
[torch.FloatTensor of size 2x2]
"""

print(variable.data.numpy())    # numpy format
"""
[[ 1.  2.]
 [ 3.  4.]]
"""
```

# 激活函数

- 0.4 版本将常用的激活函数直接放到 torch 包下，更方便调用（原来在torch.nn.functional）
```py
# 构造假数据
x = torch.linspace(-5, 5, 200)  # 生成 Tensor， -5 到 5 之间均分 200 个点
x = Variable(x) # 构造变量，新版PyTorch可省略这一步
x_np = x.data.numpy()   # 转换成 np 数组用于绘图（plt不能直接绘制Tensor，必须转换为np数组）

# 下面是很常见的激活函数
y_relu = torch.relu(x).data.numpy()  # 若是Variable 要利用data属性取出对应的Tensor
y_sigmoid = torch.sigmoid(x).data.numpy()
y_tanh = torch.tanh(x).data.numpy()
y_softplus = F.softplus(x).data.numpy() # there's no softplus in torch
# y_softmax = torch.softmax(x, dim=0).data.numpy() softmax is a special kind of activation function, it is about probability

# 绘制结果
plt.figure(1, figsize=(8, 6))
plt.subplot(221)  # 2行2列第1幅图
plt.plot(x_np, y_relu, c='red', label='relu')  # 绘图
plt.ylim((-1, 5))  # 设置y轴区间
plt.legend(loc='best')

plt.subplot(222)  # 2行2列第2幅图
plt.plot(x_np, y_sigmoid, c='red', label='sigmoid')  # 绘图
plt.ylim((-0.2, 1.2))  # 设置y轴区间
plt.legend(loc='best')  # 设置曲线说明位置

plt.subplot(223)  # 2行2列第3幅图
plt.plot(x_np, y_tanh, c='red', label='tanh')  # 绘图
plt.ylim((-1.2, 1.2))  # 设置y轴区间
plt.legend(loc='best')  # 设置曲线说明位置

plt.subplot(224)  # 2行2列第4幅图
plt.plot(x_np, y_softplus, c='red', label='softplus')  # 绘图
plt.ylim((-0.2, 6))  # 设置y轴区间
plt.legend(loc='best')  # 设置曲线说明位置

plt.show()
```

# 回归问题

```py
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable
import matplotlib.pyplot as plt

x = torch.unsqueeze(torch.linspace(-1, 1, 100), dim=1)  # x data (tensor), shape=(100, 1)
y = x.pow(2) + 0.2*torch.rand(x.size())                 # noisy y data (tensor), shape=(100, 1)

# 旧版本中，torch只能训练Variable，故需要将Tensor转化为Variable
# 在 0.4 之后，Variable过时，Tensor直接支持autograd
# x, y = Variable(x), Variable(y)

# plt.scatter(x.data.numpy(), y.data.numpy())
# plt.show()


class Net(torch.nn.Module):  # 自定义Net类，继承 nn.Model
    def __init__(self, n_feature, n_hidden, n_output):
        super(Net, self).__init__()  # 调用父类构造函数
        self.hidden = torch.nn.Linear(n_feature, n_hidden)   # 单个隐藏层
        self.predict = torch.nn.Linear(n_hidden, n_output)   # 输出层

    def forward(self, x):
        """
        前向传播
        :param x: 输入数据 x
        :return:
        """

        x = torch.relu(self.hidden(x))  # 隐藏层后，执行激活函数 torch.relu 或 F.relu
        x = self.predict(x)             # 线性输出
        return x  # 返回输出


net = Net(n_feature=1, n_hidden=10, n_output=1)      # 定义网络
print(net)  # 打印网络结构

optimizer = torch.optim.SGD(net.parameters(), lr=0.2)  # 定义优化器 SGD
loss_func = torch.nn.MSELoss()  # 选择均方差损失

plt.ion()   # 打开交互模式

for t in range(200):  # 执行训练
    prediction = net(x)     # 输入x到网络net

    loss = loss_func(prediction, y)     # 执行损失计算，参数分别为：(1. nn output, 2. target)

    optimizer.zero_grad()   # 反向传播前要先清除原有梯度，否则会累加
    loss.backward()         # 反向传播
    optimizer.step()        # 梯度更新

    if t % 5 == 0:
        # plot and show learning process
        plt.cla()  # 清除上次的绘制
        plt.scatter(x.data.numpy(), y.data.numpy())  # 绘制散点图
        plt.plot(x.data.numpy(), prediction.data.numpy(), 'r-', lw=5)  # 绘制曲线
        plt.text(0.5, 0, 'Loss=%.4f' % loss.data.numpy(), fontdict={'size': 20, 'color':  'red'})  # 标注
        plt.pause(0.1)  # 每次绘图后暂停0.1秒

plt.ioff()  # 关闭交互模式
plt.show()  # 显示最终的图
```

# 分类问题

```py
import torch
import torch.nn.functional as F
import matplotlib.pyplot as plt

# torch.manual_seed(1)    # 随机种子，可复现

# 生成假数据
n_data = torch.ones(100, 2)  # (100, 2)的全一矩阵
x0 = torch.normal(2*n_data, 1)      # 类别0坐标数据,均值为2,标准差为1, shape=(100, 2)
y0 = torch.zeros(100)               # 类别0标签, shape=(100, 1)
x1 = torch.normal(-2*n_data, 1)     # 类别1坐标数据,均值为-2,标准差为1, shape=(100, 2)
y1 = torch.ones(100)                # 类别1标签, shape=(100, 1)
x = torch.cat((x0, x1), 0).type(torch.FloatTensor)  # 将数据堆叠起来，(200, 2) FloatTensor = 32-bit floating
y = torch.cat((y0, y1), ).type(torch.LongTensor)    # y也堆叠起来 (200,) LongTensor = 64-bit integer

# The code below is deprecated in Pytorch 0.4. Now, autograd directly supports tensors
# x, y = Variable(x), Variable(y)

# plt.scatter(x.data.numpy()[:, 0], x.data.numpy()[:, 1], c=y.data.numpy(), s=100, lw=0, cmap='RdYlGn')
# plt.show()


class Net(torch.nn.Module):
    def __init__(self, n_feature, n_hidden, n_output):
        super(Net, self).__init__()
        self.hidden = torch.nn.Linear(n_feature, n_hidden)   # hidden layer
        self.out = torch.nn.Linear(n_hidden, n_output)   # output layer

    def forward(self, x):
        x = F.relu(self.hidden(x))      # activation function for hidden layer
        x = self.out(x)
        return x


net = Net(n_feature=2, n_hidden=10, n_output=2)     # define the network
print(net)  # net architecture

optimizer = torch.optim.SGD(net.parameters(), lr=0.02)
loss_func = torch.nn.CrossEntropyLoss()  # 交叉熵损失

plt.ion()   # 打开绘图交互模式

for t in range(100):
    out = net(x)                 # input x and predict based on x
    loss = loss_func(out, y)     # must be (1. nn output, 2. target), the target label is NOT one-hotted

    optimizer.zero_grad()   # clear gradients for next train
    loss.backward()         # back propagation, compute gradients
    optimizer.step()        # apply gradients

    # 绘图
    if t % 2 == 0:
        # plot and show learning process
        plt.cla()
        prediction = torch.max(out, 1)[1]
        pred_y = prediction.data.numpy()
        target_y = y.data.numpy()
        plt.scatter(x.data.numpy()[:, 0], x.data.numpy()[:, 1], c=pred_y, s=100, lw=0, cmap='RdYlGn')
        accuracy = float((pred_y == target_y).astype(int).sum()) / float(target_y.size)
        plt.text(1.5, -4, 'Accuracy=%.2f' % accuracy, fontdict={'size': 20, 'color':  'red'})
        plt.pause(0.1)

plt.ioff()  # 关闭交互模式
plt.show()  # 打印
```

# 利用 Sequential 快速构建网络

```py
class Net(torch.nn.Module):  # 继承 nn.Model 构建自定义网络
    def __init__(self, n_feature, n_hidden, n_output):
        super(Net, self).__init__()
        self.hidden = torch.nn.Linear(n_feature, n_hidden)   # 隐藏层
        self.predict = torch.nn.Linear(n_hidden, n_output)   # 输出层

    def forward(self, x):
        x = F.relu(self.hidden(x))      # 隐藏层 -> relu
        x = self.predict(x)             # 线性回归
        return x

net1 = Net(1, 10, 1)

# 可以利用 Sequential 快速构建和上述 Net 等价的模型
net2 = torch.nn.Sequential(
    torch.nn.Linear(1, 10),  # 隐藏层
    torch.nn.ReLU(),  # ReLU 层，注意这是一个类
    torch.nn.Linear(10, 1)  # 线性回归层
)


print(net1)     # net1 architecture
"""
Net (
  (hidden): Linear (1 -> 10)
  (predict): Linear (10 -> 1)
)
"""

print(net2)     # net2 architecture
"""
Sequential (
  (0): Linear (1 -> 10)
  (1): ReLU ()
  (2): Linear (10 -> 1)
)
"""
```

# 保存和加载模型

```py
import torch
import matplotlib.pyplot as plt

# torch.manual_seed(1)    # reproducible

# 制造假数据
x = torch.unsqueeze(torch.linspace(-1, 1, 100), dim=1)  # [-1, 1]间的100个点, shape=(100, 1)
y = x.pow(2) + 0.2 * torch.rand(x.size())  # 0.2*torch.rand(x.size())是噪音, shape=(100, 1)


# The code below is deprecated in Pytorch 0.4. Now, autograd directly supports tensors
# x, y = Variable(x, requires_grad=False), Variable(y, requires_grad=False)


def save():
    """
    快速创建一个模型并保存
    :return:
    """
    # 快速创建模型
    net1 = torch.nn.Sequential(
        torch.nn.Linear(1, 10),
        torch.nn.ReLU(),
        torch.nn.Linear(10, 1)
    )
    # 优化器和损失函数
    optimizer = torch.optim.SGD(net1.parameters(), lr=0.5)
    loss_func = torch.nn.MSELoss()

    # 训练
    for t in range(100):
        prediction = net1(x)
        loss = loss_func(prediction, y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

    # 打印预测结果
    plt.figure(1, figsize=(10, 3))
    plt.subplot(131)
    plt.title('Net1')
    plt.scatter(x.data.numpy(), y.data.numpy())
    plt.plot(x.data.numpy(), prediction.data.numpy(), 'r-', lw=5)

    # 两种保存方式
    torch.save(net1, 'net.pkl')  # 保存整个模型
    torch.save(net1.state_dict(), 'net_params.pkl')  # 只保存模型参数，速度较快，可用于预测

    # 此外，optimizer 也有 state_dict，如果想继续训练，则需要保存 optimizer 的 state_dict
    # load model，若是要继续训练需要执行一下 model.train()
    # 若是要执行测试，要执行 model.eval()
    # 上述代码主要原因是：dropout 和 batch正则化 在执行训练和测试时的做法是不一致的，因此要告诉编译器


def restore_net():
    """
    读取整个模型
    :return:
    """
    # 读取整个模型
    net2 = torch.load('net.pkl')  # 官方推荐用 .pt 或 .pth 后缀
    net2.eval()  # 根据官方教程，执行预测之前似乎还要执行以下 model.eval()
    prediction = net2(x)  # 执行预测

    # 打印预测结果
    plt.subplot(132)
    plt.title('Net2')
    plt.scatter(x.data.numpy(), y.data.numpy())
    plt.plot(x.data.numpy(), prediction.data.numpy(), 'r-', lw=5)


def restore_params():
    # 读取参数前，要先构造一个完全一致的网络
    net3 = torch.nn.Sequential(
        torch.nn.Linear(1, 10),
        torch.nn.ReLU(),
        torch.nn.Linear(10, 1)
    )

    # 读取参数到新建的网络
    net3.load_state_dict(torch.load('net_params.pkl'))
    prediction = net3(x)  # 执行预测

    # 打印预测结果
    plt.subplot(133)
    plt.title('Net3')
    plt.scatter(x.data.numpy(), y.data.numpy())
    plt.plot(x.data.numpy(), prediction.data.numpy(), 'r-', lw=5)
    plt.show()


if __name__ == '__main__':
    # save net1
    save()
    # restore entire net (may slow)
    restore_net()
    # restore only the net parameters
    restore_params()
```

# Batch 训练

- 主要涉及 DataSet 和 DataLoader
- DataSet 用于提供所有数据
- DataLoader 是一个迭代器，将 DataSet 封装起来，每次提供一个 Batch
```py
import torch
import torch.utils.data as Data

torch.manual_seed(1)    # reproducible

BATCH_SIZE = 5
# BATCH_SIZE = 8

x = torch.linspace(1, 10, 10)       # this is x data (torch tensor)
y = torch.linspace(10, 1, 10)       # this is y data (torch tensor)

torch_dataset = Data.TensorDataset(x, y)  # 构造 DataSet
loader = Data.DataLoader(  # 为 DataSet 构造  DataLoader
    dataset=torch_dataset,      # torch TensorDataset format
    batch_size=BATCH_SIZE,      # mini batch size
    shuffle=True,               # 是否随机打乱数据，否的话每个epoch取出的数据顺序是一样的
    num_workers=0,              # win 下的多线程会报错，设置为 0
)


def show_batch():
    """
    打印每个 batch 的数据
    :return:
    """
    for epoch in range(3):   # train entire dataset 3 times
        for step, (batch_x, batch_y) in enumerate(loader):  # for each training step
            # loader 每次提供一个 batch （好像是一个迭代器）
            print('Epoch: ', epoch, '| Step: ', step, '| batch x: ',
                  batch_x.numpy(), '| batch y: ', batch_y.numpy())


if __name__ == '__main__':
    show_batch()
```

# 优化器

```py
import torch
import torch.utils.data as Data
import torch.nn.functional as F
import matplotlib.pyplot as plt

# torch.manual_seed(1)    # reproducible

LR = 0.01
BATCH_SIZE = 32
EPOCH = 12

# 生成假数据 [-1, 1] 的 1000 个点，unsqueeze 为解压缩，即增加一个维度（此处功能可以理解为 reshape）
x = torch.unsqueeze(torch.linspace(-1, 1, 1000), dim=1)
y = x.pow(2) + 0.1*torch.normal(torch.zeros(*x.size()))  # 生成对应的 y ，后半部分为噪音

# 绘制散点图
plt.scatter(x.numpy(), y.numpy())
plt.show()

# 将 Tensor 构造为 DataSet
torch_dataset = Data.TensorDataset(x, y)
# 使用 DataLoader 封装 DataSet，注意定义 batch_size、shuffle和num_works
loader = Data.DataLoader(dataset=torch_dataset, batch_size=BATCH_SIZE, shuffle=True, num_workers=0,)


# 定义网络
class Net(torch.nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.hidden = torch.nn.Linear(1, 20)   # hidden layer
        self.predict = torch.nn.Linear(20, 1)   # output layer

    def forward(self, x):
        x = F.relu(self.hidden(x))      # activation function for hidden layer
        x = self.predict(x)             # linear output
        return x


if __name__ == '__main__':
    # 同样的网络结构，创建多个网络
    net_SGD         = Net()
    net_Momentum    = Net()
    net_RMSprop     = Net()
    net_Adam        = Net()
    nets = [net_SGD, net_Momentum, net_RMSprop, net_Adam]

    # 为这些网络定义不同的优化器，同时设置超参数
    opt_SGD         = torch.optim.SGD(net_SGD.parameters(), lr=LR)
    opt_Momentum    = torch.optim.SGD(net_Momentum.parameters(), lr=LR, momentum=0.8)
    opt_RMSprop     = torch.optim.RMSprop(net_RMSprop.parameters(), lr=LR, alpha=0.9)
    opt_Adam        = torch.optim.Adam(net_Adam.parameters(), lr=LR, betas=(0.9, 0.99))
    optimizers = [opt_SGD, opt_Momentum, opt_RMSprop, opt_Adam]

    loss_func = torch.nn.MSELoss()
    losses_his = [[], [], [], []]   # 记录迭代过程中的 Loss

    # 训练
    for epoch in range(EPOCH):
        print('Epoch: ', epoch)
        for step, (b_x, b_y) in enumerate(loader):          # for each training step
            for net, opt, l_his in zip(nets, optimizers, losses_his):
                output = net(b_x)              # 对每个网络，执行预测
                loss = loss_func(output, b_y)  # 计算 loss
                opt.zero_grad()                # 清除梯度
                loss.backward()                # 反向传播
                opt.step()                     # 更新参数
                l_his.append(loss.data.numpy())     # loss值记录到列表

    labels = ['SGD', 'Momentum', 'RMSprop', 'Adam']
    for i, l_his in enumerate(losses_his):  # 分别绘制四条 loss 曲线
        plt.plot(l_his, label=labels[i])
    plt.legend(loc='best')  # 设置曲线说明位置
    plt.xlabel('Steps')  # x 轴说明
    plt.ylabel('Loss')  # y 轴说明
    plt.ylim((0, 0.2))  # y 轴区间
    plt.show()
```

# CNN

```py
import os

# third-party library
import torch
import torch.nn as nn
import torch.utils.data as Data
import torchvision
import matplotlib.pyplot as plt

# torch.manual_seed(1)    # reproducible

# 超参数
EPOCH = 1               # epoch数量
BATCH_SIZE = 50
LR = 0.001              # 学习速率
DOWNLOAD_MNIST = False  # 是否下载数据集


# 判断是否要下载
if not(os.path.exists('./mnist/')) or not os.listdir('./mnist/'):
    # not mnist dir or mnist is empyt dir
    DOWNLOAD_MNIST = True

# 利用 torchvision 提供的 DataSet 类读取数据集（若没有还可以自动下载）
train_data = torchvision.datasets.MNIST(
    root='./mnist/',
    train=True,                                     # 标志是训练集
    transform=torchvision.transforms.ToTensor(),    # 该Transform类会将图片转化为FloatTensor并调整通道到第一维：(C x H x W)，
                                                    # 然后标准化到 [0.0, 1.0]
    download=DOWNLOAD_MNIST,
)

# 绘制一个样例
print(train_data.train_data.size())                 # (60000, 28, 28)
print(train_data.train_labels.size())               # (60000)
plt.imshow(train_data.train_data[0].numpy(), cmap='gray')
plt.title('%i' % train_data.train_labels[0])
plt.show()

# 用 DataLoader 封装 (50, 1, 28, 28)
train_loader = Data.DataLoader(dataset=train_data, batch_size=BATCH_SIZE, shuffle=True)

# 利用 torchvision 提供的 DataSet 类读取MNIST数据集
test_data = torchvision.datasets.MNIST(root='./mnist/', train=False)
# 挑选出 2000 samples 用于训练过程中的测试
test_x = torch.unsqueeze(test_data.test_data, dim=1).type(torch.FloatTensor)[:2000]/255.   # shape from (2000, 28, 28) to (2000, 1, 28, 28), value in range(0,1)
test_y = test_data.test_labels[:2000]
# 若有需要，可测试集封装为 DataLoader，最后预测准确率时使用
# test_loader = Data.DataLoader(dataset=test_data, batch_size=BATCH_SIZE, shuffle=True)


# 定义 CNN 模型，继承 nn.Model
class CNN(nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        # 卷积、relu、池化
        self.conv1 = nn.Sequential(         # input shape (1, 28, 28)
            nn.Conv2d(
                in_channels=1,              # input height
                out_channels=16,            # n_filters
                kernel_size=5,              # filter size
                stride=1,                   # filter movement/step
                padding=2,                  # if want same width and length of this image after con2d, padding=(kernel_size-1)/2 if stride=1
            ),                              # output shape (16, 28, 28)
            nn.ReLU(),                      # activation
            nn.MaxPool2d(kernel_size=2),    # choose max value in 2x2 area, output shape (16, 14, 14)
        )
        # 卷积、relu、池化
        self.conv2 = nn.Sequential(         # input shape (16, 14, 14)
            nn.Conv2d(16, 32, 5, 1, 2),     # output shape (32, 14, 14)
            nn.ReLU(),                      # activation
            nn.MaxPool2d(2),                # output shape (32, 7, 7)
        )
        # 全连接
        self.out = nn.Linear(32 * 7 * 7, 10)   # fully connected layer, output 10 classes

    def forward(self, x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = x.view(x.size(0), -1)           # flatten the output of conv2 to (batch_size, 32 * 7 * 7)
        output = self.out(x)
        return output, x    # return x for visualization


cnn = CNN()
print(cnn)  # net architecture

optimizer = torch.optim.Adam(cnn.parameters(), lr=LR)   # optimize all cnn parameters
loss_func = nn.CrossEntropyLoss()                       # the target label is not one-hotted

# following function (plot_with_labels) is for visualization, can be ignored if not interested
from matplotlib import cm
try: from sklearn.manifold import TSNE; HAS_SK = True
except: HAS_SK = False; print('Please install sklearn for layer visualization')
def plot_with_labels(lowDWeights, labels):
    plt.cla()
    X, Y = lowDWeights[:, 0], lowDWeights[:, 1]
    for x, y, s in zip(X, Y, labels):
        c = cm.rainbow(int(255 * s / 9)); plt.text(x, y, s, backgroundcolor=c, fontsize=9)
    plt.xlim(X.min(), X.max()); plt.ylim(Y.min(), Y.max()); plt.title('Visualize last layer'); plt.show(); plt.pause(0.01)

plt.ion()
# training and testing
for epoch in range(EPOCH):
    for step, (b_x, b_y) in enumerate(train_loader):   # gives batch data, normalize x when iterate train_loader

        output = cnn(b_x)[0]            # 前向传播
        loss = loss_func(output, b_y)   # 计算交叉熵损失
        optimizer.zero_grad()           # 每次反向传播前要先清空梯度
        loss.backward()                 # 反向传播
        optimizer.step()                # 更新参数

        if step % 50 == 0:
            test_output, last_layer = cnn(test_x)  # 用前面提取的2000个测试样例执行当前网络的预测
            pred_y = torch.max(test_output, 1)[1].data.squeeze().numpy()  # 预测标签
            # 计算当前网络的准确率
            accuracy = float((pred_y == test_y.data.numpy()).astype(int).sum()) / float(test_y.size(0))
            # 打印准确率，还可以将准确率存储到list中用于后续打印
            print('Epoch: ', epoch, '| train loss: %.4f' % loss.data.numpy(), '| test accuracy: %.2f' % accuracy)
            # if HAS_SK:
            #     # Visualization of trained flatten layer (T-SNE)
            #     tsne = TSNE(perplexity=30, n_components=2, init='pca', n_iter=5000)
            #     plot_only = 500
            #     low_dim_embs = tsne.fit_transform(last_layer.data.numpy()[:plot_only, :])
            #     labels = test_y.numpy()[:plot_only]
            #     plot_with_labels(low_dim_embs, labels)
plt.ioff()

# print 10 predictions from test data
test_output, _ = cnn(test_x[:10])
pred_y = torch.max(test_output, 1)[1].data.numpy().squeeze()
print(pred_y, 'prediction number')
print(test_y[:10].numpy(), 'real number')
```

