# 1 Anaconda 安装与配置

## 1.1 安装

- 去官网下载相关的安装文件，win 下为 exe，直接安装即可
- linux 下是 sh 文件，执行 `bash Anaconda3-xxx.sh` ，按提示进行安装（包括选择安装路径，默认安装到 `~/anaconda3/` 下），可执行 `which conda` 查看

## 1.2 配置下载镜像

通过修改用户目录下的 .condarc 文件来使用 TUNA 镜像源。Windows 用户无法直接创建名为 .condarc 的文件，可先执行 conda config --set show_channel_urls yes 生成该文件之后再修改。

.condarc 的默认值为：

```yml
channels:
  - defaults
show_channel_urls: true
```

我们将其修改为清华大学提供的内容

```yml
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

运行 conda clean -i 清除索引缓存，保证用的是镜像站提供的索引。

运行 conda create -n myenv numpy 测试一下吧。

在 Win10 下，默认会发生下列异常：

```js
Exception: HTTPSConnectionPool(host='mirrors.tuna.tsinghua.edu.cn', port=443): Max retries exceeded with url: /anaconda/pkgs/main/win-64/current_repodata.json (Caused by SSLError("Can't connect to HTTPS URL because the SSL module is not available."))
```

异常原因 Windows SSL 包丢失，解决方案：将路径 miniconda3/Library/bin 下面的两个文件：libcrypto-1_1-x64.dll ；libssl-1_1-x64.dll，复制到路径 miniconda3/DLLs 下。

若使用 pip 命令，可利用`-i`参数临时设置镜像，本次有效

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
```

# 2 Anaconda 环境管理相关命令

**基础命令**

```bash
conda create –n dl python=3.6 # 创建名为dl的环境
activate dl # 进入 dl 环境(win)
source activate dl 或 conda activate dl # 进入 dl 环境(Linux)
deactivate # 退出当前环境(win)
source deactivate 或 conda deactivate # 退出当前环境(Linux)
conda env list # 列出所有环境
conda env remove -n dl # 删除dl环境
conda create -n dl --clone base
```

**共享环境**

```bash
conda env export > env.yaml
conda env create -f env.yaml
```

# 3 Anaconda 包管理相关命令

```bash
conda install numpy scipy pandas # 同时安装多个包
conda install numpy=1.10 # 指定版本
conda remove numpy # 移除包
conda update numpy # 更新包
conda list # 列出所有包
conda list numpy # 列出指定包
conda list | findstr numpy # 利用管道查找内容
```

# 4 远程 SSH 开发

新建一个 Py Charm 工程，在选择 Interpreter 时，选择远程的 py 编译器，并配置好目录映射

或者在一个已有的工程，选择 `Tools/Deployment/Configuration` 配置映射和自动上传，然后在 `File/Settings/Project xxx` 里配置编译器为远程编译器，如果没有远程编译器则需要基于 SSH 新建。

# 5 具体环境

## 5.1 Ng DL 课程环境

**查看常用的库版本**

```py
import numpy as np
import tensorflow as tf
import h5py
import matplotlib
import sys
import keras
import scipy
import PIL
import pandas
import pydot
import sklearn
import cv2

# 6 查看常用库版本
print("python="+sys.version)
print("scipy="+scipy.__version__)
print("scikit-learn="+sklearn.__version__)
print("pillow="+PIL.__version__)
print("pandas="+pandas.__version__)
print("numpy=" + np.__version__)
print("h5py=" + h5py.__version__)
print("matplotlib=" + matplotlib.__version__)
print("pydot="+pydot.__version__)
print("opencv-python:"+cv2.__version__)
print("tensorflow:" + tf.__version__)
print("keras:"+keras.__version__)
```

下面是 Coursera 官网利用上述代码得到的版本输出：

```html
python=3.6.0 |Anaconda custom (64-bit)| (default, Dec 23 2016, 12:22:00) [GCC
4.4.7 20120313 (Red Hat 4.4.7-1)] scipy=0.18.1 scikit-learn=0.18.1 pillow=4.0.0
pandas=0.19.2 numpy=1.11.3 h5py=2.6.0 matplotlib=2.0.0 pydot=1.2.3
opencv-python:3.3.0 tensorflow:1.2.1 keras:2.0.7
```

使用如下命令构建环境

```bash
conda create –n dl python=3.6.0
activate dl
conda install scipy=0.18.1 pillow=4.0.0 pandas=0.19.2 numpy=1.11.3 h5py=2.6.0 matplotlib=2.0.0 pydot=1.2.3 scikit-learn=0.18.1
conda install bleach=1.5.0 html5lib=0.9999999
pip install opencv-python # 这个指定版本一样会导致无法导入，不指定版本就无问题，不知何解
pip install tensorflow==1.2.1 # cpu版本
pip install keras==2.0.7
```

## 6.1 paper 环境

```bash
conda create –n paper python=3.5.4
activate paper
pip install tensorflow==1.6.0
conda install tqdm scipy
```

## 6.2 GPU 环境(win6.2 )

- 显卡型号：1050ti
- cuda 9.0.176, cudnn 7.0.5 for cuda 9.0
- python 3.5.4
- tensorflow-gpu==1.6

```bash
conda create –n paper python=3.5.4
activate paper
pip install tensorflow-gpu==1.6.0
conda install tqdm scipy
```

# 7 其他

## 7.1 win10 重装后快速配置 Anaconda 环境（D 盘未清除）

- 直接配置目录 Scripts 到 path ，以便能使用 conda 命令
- 检查环境对应工具
- 如果丢失 Jupyter 链接，则卸载重新安装即可

**配置 Jupyter 起始位置**

- 首先，执行 `jupyter notebook --generate-config`，将在当前用户目录下生成位置文件

- 进入当前用户的目录`~\.jupyter`，如我的为`C:\Users\hao\.jupyter`，编辑`jupyter_notebook_config.py`文件，找到其中的`c.NotebookApp.notebook_dir`，取消其前面的注释`#`，并配置为你想要配置的起始位置，如`c.NotebookApp.notebook_dir = 'E:\\Code\\Jupyter'`
- 此时，如果是在 Anaconda 中 Lauch，应该就是你设置的目录了，若是使用快捷方式启动，还要注意快捷方式里的目标是否设置了目录，若是设置了，该设置会覆盖上述公共设置，如默认设置了目录`%USERPROFILE%`，此时可以直接删除该内容，就会使用公共配置了。

以后每次新安装 Jupyter 时，删除设置的目录即可。
