

# 概述

- [参考地址](https://www.runoob.com/linux/linux-shell.html)
- Shell 是用户和 Linux 交互的桥梁，即我们常说的命令行，Shell 既是一种命令语言，又是一种程序设计语言
- Ken Thompson 的 sh 是第一种 Unix Shell，Windows Explorer 是一个典型的图形界面 Shell
- Shell 脚本（Shell Script），是一种为 Shell 编写的脚本程序，业界所说的 Shell 通常都是指 Shell 脚本，但读者朋友要知道，Shell 和 Shell Script 是两个不同的概念，后文出现的 "shell编程" 都是指 Shell 脚本编程，不是指开发 Shell 自身
- Linux 的 Shell 种类众多，常见的有：
    - Bourne Shell（/usr/bin/sh或/bin/sh）
    - Bourne Again Shell（/bin/bash）
    - C Shell（/usr/bin/csh）
    - K Shell（/usr/bin/ksh）
    - Shell for Root（/sbin/sh）
- 本教程关注的是 Bash，也就是 Bourne Again Shell，由于易用和免费，Bash 在日常工作中被广泛使用，同时，Bash 也是大多数Linux 系统默认的 Shell
- 在一般情况下，人们并不区分 Bourne Shell 和 Bourne Again Shell，所以，像 #!/bin/sh，它同样也可以改为 #!/bin/bash
- #! 告诉系统其后路径所指定的程序即是解释此脚本文件的 Shell 程序
- 第一个 Shell 脚本，保存为 run.sh：
```sh
#!/bin/bash
echo "Hello World !"
```
- 运行 Shell 脚本有两种方式，一种是作为可执行程序运行，另一种是作为 Shell 解释器参数执行：
```sh
# 作为可执行文件执行需要具有执行权限 x
chmod +x ./run.sh
./run.sh

# 也可以作为 shell 解释器参数执行
/bin/sh ./run.sh
```

# 变量

## 变量基础

- 变量名和 C 语言的变量命名要求保持一致，不能使用关键字
- 可以显式地定义变量并给变量赋值，例如：`name="lyh"`
- 需要特别注意，Shell 脚本不支持添加空格，因此写成 `name = "lyh"` 会报错，因为 Shell 解析器会把 name 当做一个可执行命令，从而导致指令找不到错误，因此西关编程语言中加空格的写法，在这里要特别注意一下
- 可以使用语句给变量赋值，例如下述例子：
```sh
#!/bin/bash
for file in $(ls /etc) # 或者 for file in `ls /etc`
do
    echo $file
done
```
- 变量的使用可以是 $name 或者 ${name}，花括号是可选的，但有时需要字符串定位变量边界时，可能必须加上花括号，例如 `echo "I am good at ${skill}Script"`
- 注意第二次赋值的时候不能写 $name="alibaba"，使用变量的时候才加美元符
- 使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变：
```sh
name="lyh"
readonly name
name="hao" # 将会报错，line 4: name: readonly variable
```
- 使用 unset 命令可以删除变量，例如 `unset name` 后，后续将无法再使用 name：
```sh
name="lyh"
echo "name = $name"
unset name
echo "name = $name" # 不会报错，但输出空串
```
- 运行 Shell 中，涉及的变量大致有三种（种类而非类型）：
    - 局部变量：即在脚本或命令中定义的变量，仅在当前 shell 实例有效，其他 shell 启动时不能访问该类变量
    - 环境变量：系统定义的环境变量，所有的程序都能访问环境变量，shell 也不例外，例如最经典的 PATH 环境变量；必要时我们还可以在 shell 脚本中定义环境变量
    - shell 变量：shell 变量是由 shell 程序临时设置的特殊变量，shell 变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了 shell 的正常执行

## 变量类型

- 数据类型无非就是字符串、数字、数组

### 字符串

- 字符串是最常用的数据类型，在 shell 中，字符串可以使用单引号、双引号、不使用引号，例如：
```sh
k1='v1'
k2="v2"
k3=v3

echo $k1
echo $k2
echo $k3
```
- 对于普通的字符串，这三种形式无任何区别，但不同的字符串类型有不同的限制
- 单引号：
    - 单引号中的任何字符都会原样输出，其内部的任何变量无效：例如 `k4='$k1'`，最终 k4 的值为 $k1 而不是 v1
    - 单引号内部不能单独出现一个单引号，即使转移也不行，但可以成对出现，作为字符串使用
- 双引号：
    - 双引号中可以有变量：例如 `k4="$k1"`，最终 k4 的值为 v1
    - 双引号可以有转义字符：例如 `k4="\"$k1\""`，最终 k4 的值为 "v1"
- 无引号：
    - 允许将其他变量赋值给当前变量：例如 `k4=k1`，则 k4 的值为 v1
    - 若是纯字符串，不允许带有空格，空格后面的会被当成指令执行
- 字符串拼接：通过在字符串内部嵌入成对的单引号、双引号、变量表达式 ${name} 等进行字符串拼接
```sh
name="lyh"
# 使用双引号拼接
g1="hello, "$name" !"
# 双引号内部省略双引号，使用变量表达式拼接
g2="hello, ${name} !"
# 使用单引号拼接
g3='hello, '$name' !'
# 注意，单引号内部不能省略单引号直接使用变亮表达式拼接
g4='hello, ${name} !' # 该拼接无效
# 个人更习惯使用双引号+变量表达式的方式进行拼接
echo "g1 = ${g1}"
echo "g2 = ${g2}"
echo "g3 = ${g3}"
echo "g4 = ${g4}"
```
- 获取字符串长度：
```sh
name="lyh"
echo ${#name} # 输出 3
len=${#name} # 计算长度并存储为变量
echo "len = ${len}"
```
- 提取子字符串：
```sh
data="my name is lyh"
echo ${data:11:3} # 从 index = 12 处开始截取 3 个字符，得到 lyh，注意 index 不支持负数，
```



# 参数传递

# 数组

# 运算符