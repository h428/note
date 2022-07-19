
# 1. 概述

## 1.1 介绍

- Vue 是一套用于构建用户界面的渐进式框架，与其它大型框架不同的是，Vue 被设计为可以自底向上逐层应用
- Vue 的核心库只关注视图层，不仅易于上手，还便于与第三方库或既有项目整合
- 当与现代化的工具链以及各种支持类库结合使用时，Vue 也完全能够为复杂的单页应用提供驱动

# 1.2 安装


**安装 npm**

- 首先安装 nodejs，并验证 `node -v`, `npm -v`
- npm 默认的仓库在国外速度较慢，一般需要设置到淘宝镜像，推荐使用切换镜像的工具 nrm
    - 全局安装 nrm : `npm install nrm -g` 
    - 查看当前仓库列表 : `nrm ls` （带 * 的就是选中的）
    - 切换淘宝库 : `nrm use taobao`
    - 测试速度 : `nrm test npm`
- 注意：有的教程推荐大家使用 `cpnpm` 命令，但该命令有时会 bug，不推荐
- 安装完成请一定要重启电脑

**基于 cnd 安装 vue**

- 可以直接使用 cdn : 
```html
<!-- 开发环境版本，包含了用帮助的命令行警告 -->
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
```
- 或者：
```html
<!-- 生产环境版本，优化了尺寸和速度 -->
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
```

**基于 npm 安装 vue**

- 进入工程目录，执行 `npm init -y` 进行初始化工程
- 安装 vue : `npm install vue --save`
- 在当前工程的 `node_modules/vue` 下即存放 vue 的相关文件
- node_modules 是通过 npm 安装的所有模块的默认位置

## 1.3 样例

- 文件模板见文件尾部

**声明式渲染**



# 2. 基础

# 3. 组件

# 4. 路由


# 9. 其他

- 文件模板：
```html

```