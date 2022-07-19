
# 0. 说明

- 本教程来自莫烦Python
- 涉及的工具包：
```py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
```

# 1. Pandas 基本介绍

## 1.1 DataFrame 创建

```py
# 1. Pandas 基本介绍

## 1.1 DataFrame 创建

# 创建列序列
s = pd.Series([1,3,6,np.nan,44,1])  
print(s)  # 打印序列结果
# 创建索引
dates = pd.date_range('20160101', periods=6)  # DatetimeIndex类型，用作索引
print(dates)

# DataFrame 类似一个矩阵，数据就是np的数据，但行列索引可以自定义（类似一张二维表）

# 1. 使用np数组创建DataFrame，行索引index为dates，列索引columns为['a','b','c','d']
df = pd.DataFrame(np.random.randn(6, 4), index=dates, columns=['a','b','c','d'])
print(df)  # 打印表结构和值

# 2.创建时不定义索引，index和columns都默认使用从0开始的数字索引
df1 = pd.DataFrame(np.arange(12).reshape((3,4))) 
print(df1)   # 打印表结构和值

# 3.使用 map 定义 DataFrame，key为列索引，值为列的值
df2 = pd.DataFrame({'A':1.,
                   'B':pd.Timestamp('20130102'),
                   'C':pd.Series(1, index=list(range(4)), dtype='float32'),
                   'D':np.array([3]*4, dtype='int32'),
                   'E':pd.Categorical(['test','train','test','train']),
                   'F':'foo'})
print(df2)   # 打印表结构和值
```

## 1.2 查看 DataFrame 信息

```py
## 1.2 查看 DataFrame 信息
print(df2.dtypes)  # 各个列的类型
print(df2.index)  # 行的索引
print(df2.columns)  # 列的索引
print(df2.values)  # 数据
print(df2.describe())  # 统计数值列的性质：count、mean、std、min、25%、50%、75%、max
```

## 1.3. 常见运算

```py
## 1.3. 常见运算
# 一般来说对于全为数值型的 DataFrame，转置才有意义，否则可能导致每列类型不一样
print(df.T)  # 转置
# 排序索引
df2.sort_index(axis=1, ascending=False)  # 对索引列排序，ascending=False表示降序
# 排序值
df2.sort_values(by='E')  # 根据 E 列排序
```

# 2. 选择数据

## 2.1 根据索引选择 loc

```py
# 2. 选择数据
dates = pd.date_range("20130101", periods=6)  # 日期索引
# 创建 df，行索引为日期索引，列索引为['A','B','C','D']
df = pd.DataFrame(np.arange(24).reshape((6, 4)), index=dates, columns=['A','B','C','D'])
print(df)
"""
             A   B   C   D
2013-01-01   0   1   2   3
2013-01-02   4   5   6   7
2013-01-03   8   9  10  11
2013-01-04  12  13  14  15
2013-01-05  16  17  18  19
2013-01-06  20  21  22  23
"""

## 2.1 根据索引选择 loc

# 选择某一列
print(df['A'])
print(df.A)
"""
2013-01-01     0
2013-01-02     4
2013-01-03     8
2013-01-04    12
2013-01-05    16
2013-01-06    20
Freq: D, Name: A, dtype: int32
"""

# 选出行
print(df[0:3])  # 0-2 行
"""
            A  B   C   D
2013-01-01  0  1   2   3
2013-01-02  4  5   6   7
2013-01-03  8  9  10  11
"""
print(df["20130102":"20130104"]) # 1-3行
"""
             A   B   C   D
2013-01-02   4   5   6   7
2013-01-03   8   9  10  11
2013-01-04  12  13  14  15
"""
# 根据标签选择某行（会以列的形式打印）
print(df.loc['20130102'])
"""
A    4
B    5
C    6
D    7
"""
# 也可以选择纵向标签
print(df.loc[:, ['A', 'B']])
"""
             A   B
2013-01-01   0   1
2013-01-02   4   5
2013-01-03   8   9
2013-01-04  12  13
2013-01-05  16  17
2013-01-06  20  21
"""
# 同时选择横纵标签
print(df.loc["20130102", ['A', 'B']])
"""
A    4
B    5
"""
```

## 2.2 根据元素所处位置选择 iloc

```py
## 2.2 根据元素所处位置选择 iloc

print(df.iloc[3,1])  # 13
print(df.iloc[3:5,1:3]) # 切片
"""
             B   C
2013-01-04  13  14
2013-01-05  17  18
"""
print(df.iloc[[1,3,5],1:3])  # 逐个筛选
"""
             B   C
2013-01-02   5   6
2013-01-04  13  14
2013-01-06  21  22
"""
```

## 2.3 综合标签和位置进行选择（过时）

```py
## 2.3 综合标签和位置进行选择（过时）
# print(df.ix[:3,['A','C']])  # 行以数字筛选，列以标签筛选（过时）
"""
            A   C
2013-01-01  0   2
2013-01-02  4   6
2013-01-03  8  10
"""
```

## 2.4 Boolean 筛选，也可叫 Mask 筛选

```py
## 2.4 Boolean 筛选，也可叫 Mask 筛选
print(df[df.A>8])
"""
             A   B   C   D
2013-01-04  12  13  14  15
2013-01-05  16  17  18  19
2013-01-06  20  21  22  23
"""
```

# 3. 设置值

```py
# 3. 设置值

dates = pd.date_range("20130101", periods=6)  # 日期索引
# 创建 df，行索引为日期索引，列索引为['A','B','C','D']
df = pd.DataFrame(np.arange(24).reshape((6, 4)), index=dates, columns=['A','B','C','D'])
print(df)
"""
             A   B   C   D
2013-01-01   0   1   2   3
2013-01-02   4   5   6   7
2013-01-03   8   9  10  11
2013-01-04  12  13  14  15
2013-01-05  16  17  18  19
2013-01-06  20  21  22  23
"""

# 设置操作基本和选择操作一致 iloc,loc,mask
df.iloc[2,2] = 1111
df.loc["20130101", "B"] = 2222
df[df.A > 8] = 0  # A列大于8的行全部设置为0
df.A[df.A > 8] = 0 #  A列大于8的行，把A设置为0
df.B[df.A > 8] = 0 #  A列大于8的行，把B设置为0

# 增加列
df['E'] = pd.Series([1,2,3,4,5,6], index=pd.date_range("20130101", periods=6))  # 增加序列
df['F'] = np.nan  # 加列F，初始化为NaN

print(df)

```

# 4. 处理丢失数据

```py
# 4. 处理丢失数据

dates = pd.date_range("20130101", periods=6)  # 日期索引
# 创建 df，行索引为日期索引，列索引为['A','B','C','D']
df = pd.DataFrame(np.arange(24).reshape((6, 4)), index=dates, columns=['A','B','C','D'])
df.iloc[0,1] = np.nan  # 丢失数据
df.iloc[1,2] = np.nan  # 丢失数据
print(df)
"""
             A     B     C   D
2013-01-01   0   NaN   2.0   3
2013-01-02   4   5.0   NaN   7
2013-01-03   8   9.0  10.0  11
2013-01-04  12  13.0  14.0  15
2013-01-05  16  17.0  18.0  19
2013-01-06  20  21.0  22.0  23
"""

# axis指明了操作方向，axis=0 表示从上往下操作（按行方向），axis=1 表示从左往右操作（按列方向）
# 比如，对于求和 np.sum，axis=0，从上往下，按行方向求和，那就是对每一列求和
# 对于 df.dropna(axis=0) ，从上往下 drop，那就是扔掉包含 NaN 的行

# 丢弃存在 NaN 的行，丢弃列的话设置 axis=1,how={"any", "all"}
print(df.dropna(axis=0, how="any"))  # 这也是默认情况
"""
             A     B     C   D
2013-01-03   8   9.0  10.0  11
2013-01-04  12  13.0  14.0  15
2013-01-05  16  17.0  18.0  19
2013-01-06  20  21.0  22.0  23
"""

# 将 NaN 使用指定的值进行填充
print(df.fillna(value=0))

# 判断各个位置是否 NaN
print(df.isnull())
# 是否至少存在一个 NaN
print((np.any(df.isnull())) == True)
```

# 5. 导入导出数据

```py
# 5. 导入导出数据

# 读取 CSV 文件，会自动加上index索引
data = pd.read_csv("./student.csv")  
print(data)

# 存储：pandas支持多种格式
data.to_pickle("student.pickle")
```

# 6. 合并 - concat:将两个DataFrame中的列综合起来，组成新的表结构

```py
# 6. 合并 - concat:将两个DataFrame中的列综合起来，组成新的表结构

df1 = pd.DataFrame(np.ones((3,4))*0, columns=['a','b','c','d'])  # 全为0
df2 = pd.DataFrame(np.ones((3,4))*1, columns=['a','b','c','d'])  # 全为1
df3 = pd.DataFrame(np.ones((3,4))*2, columns=['a','b','c','d'])  # 全为2

# 纵向合并,ignore_index=True用于忽略index，否则index会重复
res = pd.concat([df1, df2, df3], axis=0, ignore_index=True)  
print(res)

# join 功能：合并两个表的列
df1 = pd.DataFrame(np.ones((3,4))*0, columns=['a','b','c','d'], index=[1,2,3])  # 全为0
df2 = pd.DataFrame(np.ones((3,4))*1, columns=['b','c','d','e'], index=[2,3,4])  # 全为1

# outer有点类似外连接，保留两个表的所有列（但重复的列只保留一列），没有的另一个表中的列用NaN表示
res = pd.concat([df1, df2], join="outer", ignore_index=True)  
# inner有点类似内连接，只保留两个表中都存在的列
res = pd.concat([df1, df2], join="inner", ignore_index=True)  
# 两个表中重复的列，分别保留，行以第一个表的数据为准，有点类似左外连接
res = pd.concat([df1, df2], axis=1, join_axes=[df1.index])

# DataFrame
df1 = pd.DataFrame(np.ones((3,4))*0, columns=['a','b','c','d'])  # 全为0
df2 = pd.DataFrame(np.ones((3,4))*1, columns=['a','b','c','d'])  # 全为1
df3 = pd.DataFrame(np.ones((3,4))*1, columns=['a','b','c','d'])  # 全为1

# 追加 DataFrame
res = df1.append(df2, ignore_index=True)  # df2的数据追加到df1结尾
res = df1.append([df2, df3], ignore_index=True)  # 可同时追加多个

# 追加序列
s1 = pd.Series([1,2,3,4], index=['a','b','c','d'])
res = df1.append(s1, ignore_index=True)
```

# 7. 合并 - Merge

```py
# 7. 合并 - Merge

left = pd.DataFrame({'key': ['K0', 'K1', 'K2', 'K3'],
                                  'A': ['A0', 'A1', 'A2', 'A3'],
                                  'B': ['B0', 'B1', 'B2', 'B3']})
"""
    A   B key
0  A0  B0  K0
1  A1  B1  K1
2  A2  B2  K2
3  A3  B3  K3
"""
right = pd.DataFrame({'key': ['K0', 'K1', 'K2', 'K3'],
                                    'C': ['C0', 'C1', 'C2', 'C3'],
                                    'D': ['D0', 'D1', 'D2', 'D3']})
"""
    C   D key
0  C0  D0  K0
1  C1  D1  K1
2  C2  D2  K2
3  C3  D3  K3
"""

# 根据 key 列执行连接，默认为内连接
res = pd.merge(left, right, on='key')  

# 考虑两个 key 的情况
left = pd.DataFrame({'key1': ['K0', 'K0', 'K1', 'K2'],
                             'key2': ['K0', 'K1', 'K0', 'K1'],
                             'A': ['A0', 'A1', 'A2', 'A3'],
                             'B': ['B0', 'B1', 'B2', 'B3']})
"""
    A   B key1 key2
0  A0  B0   K0   K0
1  A1  B1   K0   K1
2  A2  B2   K1   K0
3  A3  B3   K2   K1
"""
right = pd.DataFrame({'key1': ['K0', 'K1', 'K1', 'K2'],
                              'key2': ['K0', 'K0', 'K0', 'K0'],
                              'C': ['C0', 'C1', 'C2', 'C3'],
                              'D': ['D0', 'D1', 'D2', 'D3']})
"""
    C   D key1 key2
0  C0  D0   K0   K0
1  C1  D1   K1   K0
2  C2  D2   K1   K0
3  C3  D3   K2   K0
"""

# 根据 (key1, key2) 执行连接，默认为内连接：二者都相同的行才连接
res = pd.merge(left, right, on=['key1', 'key2'], how='inner')  # default for how='inner'

# 连接模式类似数据库：how = ['left', 'right', 'outer', 'inner']
res = pd.merge(left, right, on=['key1', 'key2'], how='left')  # 左外连接


# indicator 显示出本行所采用的的连接策略
df1 = pd.DataFrame({'col1':[0,1], 'col_left':['a','b']})
df2 = pd.DataFrame({'col1':[1,2,2],'col_right':[2,2,2]})
# 有一个多余的列，描述该行所使用的连接策略
res = pd.merge(df1, df2, on='col1', how='inner', indicator=True)
# 可以为该列命名
res = pd.merge(df1, df2, on='col1', how='outer', indicator='indicator_column')

# 还可以直接根据index进行merge
left = pd.DataFrame({'A': ['A0', 'A1', 'A2'],
                                  'B': ['B0', 'B1', 'B2']},
                                  index=['K0', 'K1', 'K2'])
right = pd.DataFrame({'C': ['C0', 'C2', 'C3'],
                                     'D': ['D0', 'D2', 'D3']},
                                      index=['K0', 'K2', 'K3'])
# left_index and right_index
res = pd.merge(left, right, left_index=True, right_index=True, how='outer')
res = pd.merge(left, right, left_index=True, right_index=True, how='inner')


# 处理连接时同名的列
boys = pd.DataFrame({'k': ['K0', 'K1', 'K2'], 'age': [1, 2, 3]})
girls = pd.DataFrame({'k': ['K0', 'K0', 'K3'], 'age': [4, 5, 6]})
res = pd.merge(boys, girls, on='k', suffixes=['_boy', '_girl'], how='inner')


```

# 8. 绘制数据

```py
# 8. 绘制数据

# 随机生成序列数据
data = pd.Series(np.random.randn(1000), index=np.arange(1000))
data = data.cumsum()  # 序列数据的累加
data.plot()  # 直接绘制

# 100行4列DataFrame
data = pd.DataFrame(np.random.randn(1000, 4), index=np.arange(1000), columns=list("ABCD"))
data = data.cumsum()
# plot methods:
# 'bar', 'hist', 'box', 'kde', 'area', scatter', hexbin', 'pie'
ax = data.plot.scatter(x='A', y='B', color='DarkBlue', label="Class 1")  # 绘制点
data.plot.scatter(x='A', y='C', color='LightGreen', label='Class 2', ax=ax)  # 绘制点到同一幅图

plt.show()

```
