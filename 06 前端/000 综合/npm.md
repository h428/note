

# 1. npm

## 1.1 概述

- npm 默认随 NodeJS 一起安装
- 查看版本 : `npm -v`

**nrm 安装与使用**

- npm 默认的仓库地址是在国外，速度较慢，因此我们需要将其切换到淘宝镜像，推荐使用 nrm 进行镜像源切换
- 全局安装 nrm : `npm install nrm -g`，其中 -g 表示全局安装
- 查看 npm 仓库列表 : `nrm ls`
- 选择指定镜像源 : `nrm use taobao`
- 测试速度 : `nrm test npm`

**手动设置镜像（不推荐）**

- 手动设置 : `npm config set registry https://registry.npmmirror.com`
- 现在，taobao 镜像从原有地址 `https://registry.npm.taobao.org` 切换为 `https://registry.npmmirror.com/`

## 1.2 npm 用法

- 初始化项目 : `npm init -y`
- 安装模块语法 : `npm install 模块名`
- npm 安装模块分为本地安装（local）、全局安装（global）两种，带参数 `-g` 表示全局安装，其他完全一致
- 例如 : `npm install vue` 和 `npm install vue -g`
- 如果出现错误 `npm err! Error: connect ECONNREFUSED 127.0.0.1:8087 ` 可以尝试输入 `npm config set proxy null` 解决
- 本地安装：将木块安装在 ./node_modules 下，如果没有该目录会创建
- 全局安装 : 安装在 /usr/local 或者 nodejs 的安装目录，可以直接在命令行里使用相关命令，例如前面的 nrm
- 安装项目所有依赖 : `npm install`
- 卸载模块 : `npm uninstall vue`
- 查看本项目模块 : `npm ls`
- 更新模块 : `npm update vue`
- 搜索模块 : `npm search express`
- 查看全局安装模块 : `npm list -g`
- 查询某个模块的版本号 : `npm list vue`
- 查询某个模块的信息 : `npm info vue`
- 运行项目中的 script : `npm run xxx`


# 2. yarn

- 设置淘宝镜像 : `yarn config set registry https://registry.npm.taobao.org`
- 初始化项目 : `yarn init -y`
- 安装项目所有声明依赖 : `yarn`
- 安装指定模块 : `yarn add vue`
- 全局安装 : `yarn global add webpack`
- 删除旧依赖 : `yarn remove webpack`, `yarn global remove webpack`
- 运行项目中的 script : `yarn run xxx`
- 查询某个模块的信息 : `yarn info vue`


# 3. package.json

- package.json 一般位于当前项目的目录下，用于定义依赖的属性，类似 maven 中的 pom.xml 文件，主要描述当前项目的基本信息
- 常见属性说明 :
    - name : 项目名称/包名，一般和目录名一致
    - version : 版本号
    - main : 指定了程序的主入口文件，require('moduleName') 就会加载这个文件，该字段的默认值就是根目录下的 index.js
    - keywords : 关键字
    - dependencies : 依赖包列表，如果依赖包没有安装，npm 会自动将依赖包安装在 node_module 目录下