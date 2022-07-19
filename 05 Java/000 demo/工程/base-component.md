

# 1. 项目概述

## 1.1 项目介绍

- com.demo.base:base-component 是所有 demo 项目通用组件的集合
- 包前缀即为 groupId : com.demo.base
- 项目名 : base-component
- 该项目包含的子包有 : entity, dto, exception, mapper, mapper2, service, util，主要供其他项目使用

## 1.2 子包介绍

- 包前缀和 groupId 保持一致 : com.demo.base，包含下列子包
- entity : maven 数据库对应的实体
- dto : 相关 dto
- exception : 目前只有 Web 全局异常，用于统一处理状态码的
- mapper : 逆向工程生成的 tk common mapper
- mapper2 : 自己需要额外编写 sql 而创建的 mapper，和自动生成的 mapper 区分开，所以采用 mapper2
- service : 存放通用 Service，各个 Service 的父类
- util : 各个项目都可能用到的通用工具类

## 1.3 pom 相关

- 使用的依赖版本和 spring boot 2.1.9.RELEASE 中管理的各个依赖版本保持一致，如果是 spring boot 中未定义的依赖则使用自定义版本（例如 mybatis, swagger-ui 等）
- 本项目中除了一些很通用的基础工具类例如 commons-lang3 等，其他依赖都设置为 provided，这表示如果你在其他项目中要使用该工具类，需要先引入对应的包
- 例如，要使用 common mapper，必须在项目中引入 tk mybatis 相关依赖，如果你使用了相关的类而没有引入对应依赖，在运行时会抛出类找不到的异常
