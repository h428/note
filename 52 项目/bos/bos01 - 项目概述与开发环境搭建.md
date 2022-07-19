[toc]

# 项目概述

## 一、项目背景

- 物流公司的二期改造项目。物流公司存在一个一期项目（基于C/S架构），用C++开发的。
- BOS：Bussiness Operating System 业务操作系统

## 二、常见的软件类型

- BOS:业务操作系统
- OA:办公自动化系统
- CRM:客户关系管理系统
- ERP:综合的企业解决方案（平台）

## 三、软件开发流程（瀑布型）

1. 需求调研分析----需求规格说明书
2. 设计阶段（概要设计、详细设计）----页面原型、数据库设计、设计文档
3. 编码阶段
4. 测试阶段
5. 上线和运维

## 四、开发环境

- 操作系统：	win10/linux
- 开发工具：	eclipse/-
- 数据库:	MySQL 5.5/MySQL 5.1.6
- web容器:	Tomcat 7.0/Toncat 7.0
- 浏览器：	Chrome

## 五、技术选型

> 工具名称/版本/说明

- Struts2/2.3.24/表现层MVC框架
- Hibernate/5.0.7/数据层持久化框架
- Spring/4.2.4/业务管理IoC和AOP
- Junit/4.10/单元测试
- jQuery/1.8.3/js框架
- jQuery Easy UI/1.3.2/js前端UI框架
- zTree/3.5/js树形菜单插件
- POI/3.11/Office文档读写组件
- CXF/3.0.1/RMI远程调用
- Apache Shiro/1.2.2/权限管理框架
- Quartz/2.2.3/任务调度框架
- Highcharts/4.2.6/图形报表工具


# 开发环境搭建

## 一、搭建数据库环境

    //创建数据库
    create database bos character set utf8 collate utf8_general_ci;
    
    //创建用户名为bosuser 密码为 bospass的用户
    create user bosuser identified by 'bospass';
    
    //为新用户授权,将bos数据库下的所有对象都授权给bosuser
    grant all on bos.* to bosuser;

## 二、搭建Maven分模块项目（详细请参考：Maven构建分模块项目）

> 分别搭建bos-parent、bos-entity、bos-utils、bos-dao、bos-service、bos-web

1. 搭建bos-parent模块

    - 创建Maven Project，命名为bos-parent，packaging类型选择为pom
    - 复制porm.xml的内容，引入所需要的jar包

2. 搭建bos-entity模块

    - 在父工程上new Maven Module，命名为bos-entity，packaging类型选择为jar
    - 在该项目下创建实体层的包 com.hao.bos.entity

3. 搭建bos-utils模块

    - 在父工程上new Maven Module，命名为bos-utils，packaging类型选择为jar
    - 在该项目下创建工具类的包 com.hao.bos.utils

4. 搭建bos-dao模块

    - 在父工程上new Maven Module，命名为bos-dao，packaging类型选择为jar
    - 在该项目下创建工具类的包 com.hao.bos.dao
    - 在resources下创建log4j.properties，搭建log4j环境
    - 在resources下创建applicationContext-dao.xml，配置dao层的基本内容
    - 在resources下创建db.properties，配置数据库连接参数

5. 搭建bos-service模块

    - 在父工程上new Maven Module，命名为bos-service，packaging类型选择为jar
    - 在该项目下创建工具类的包 com.hao.bos.service
    - 在resources下创建applicationContext-service.xml，配置声明式事务

6. 搭建bos-web模块

- 在父工程上new Maven Module，命名为bos-web，packaging类型选择为war
- 在该项目下创建工具类的包 com.hao.bos.action
- 创建WEB-INF目录以及web.xml项目部署文件
- 在web.xml中配置Spring随web启动的监听器、扩展Hibernate Session作用域的过滤器和Struts2过滤器
- 复制项目资源文件，包括页面、css、js等
- 配置一个用于页面跳转的Action

7. 整合子模块之间的依赖

    - 对bos-parent执行install命令，讲所有模块都发布到本地仓库
    - 构建子模块之间的依赖，依赖顺序为web-->service-->dao-->utils-->entity

8. 启动项目，能打开主页即可