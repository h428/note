# 逻辑回归

在 scikit-learn 中，与逻辑回归有关的主要是有 [LogisticRegression](https://scikit-learn.org.cn/view/378.html) 和 [LogisticRegressionCV](https://scikit-learn.org.cn/view/381.html)，它们的主要区别是 LogisticRegressionCV 使用了交叉验证来选择正则化系数 C，而 LogisticRegression 需要自己每次指定一个正则化系数。除了交叉验证，以及选择正则化系数 C 以外， LogisticRegression 和 LogisticRegressionCV 的使用方法基本相同。

## LogisticRegressionCV

LogisticRegressionCV 为带交叉验证的逻辑回归模型，全名为 sklearn.linear_model.LogisticRegressionCV，其是一个类，创建对象后即可调用方法进行逻辑回归的拟合与预测。

`fit(X, y[, sample_weight])` 方法根据给定的训练数据拟合逻辑回归模型，其入参如下：

- `X`：形状为 `(m, n)` 的矩阵，表示训练样本的输入，m 是样本数，n 是特征数，即每个样本是一个行向量，沿垂直方向堆叠
- `y`：形状为 `(m,)` 的向量，表示训练样本的标签，和 X 中样本一一对应的二分类标签
- `sample_weight`：形状为 `(m,)` 的向量，表示分配给各个样本的权重数组，如果未设置，则为每个样本的权重都为 1

`predict(X)` 方法对给定的测试数据进行预测，其入参返回值如下：

- `X`：形状为 `(m, n)` 的矩阵，表示训练样本的输入，m 是样本数，n 是特征数，即每个样本是一个行向量，沿垂直方向堆叠
- 返回值：返回一个形状为 `(m,)` 的向量，表示对各个测试数据的预测标签

```py
clf = sklearn.linear_model.LogisticRegressionCV();
clf.fit(X.T, Y[0, :].T);
```
