
# 概述


## 简介

- 和 maven 相比，优势有：更加简介，构建速度更快
- 劣势：每一个版本相比上一个版本有较大的改动，没有向上兼容；学习成本高；构建采用 groovy 脚本语言，需要额外了解学习
- maven 配置较为繁琐，但优势是更加稳定
- 新版 Spring 就是采用 gradle 构建的

## 安装

- 访问 [gradle 官网](https://gradle.org/releases/) 并下载最新发型版
- 解压后，配置 GRADLE_HOME，同时配置 GRADLE_HOME/bin 到 PATH
- 执行 `gradle -v`，若能看到版本信息，表示安装成功
- 但在实际工作中，往往不需要安装 gradle，而是采用 gradle wrapper 的方式进行使用，且通过该种方式达到 gradle 版本的统一


## 配置全局 maven 地址

- 通过 init.gradle 文件来配置全局 maven 地址
- 首先，除了参数外，gradle 加载 init.gradle 的默认顺序为：
    - 加载 USER_HOME/.gradle/init.gradle 文件，USER_HOME 即配置的 GRADLE_USER_HOME，默认为当前用户目录
    - 加载 USER_HOME/.gradle/init.d/ 目录下的以 .gradle 结尾的文件
    - 加载 GRADLE_HOME/init.d/ 目录下的以 .gradle 结尾的文件，GRADLE_HOME 
    - [参考地址](https://www.shuzhiduo.com/A/WpdKvYxM5V/)
- 在 GRADLE_USER_HOME 的 .gradle 目录下创建 init.gradle 文件，并填入下述内容：
```js
allProjects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/public/' }
        maven { url 'https://maven.aliyun.com/repository/spring/'}
        mavenLocal()
        mavenCentral()
    }
}

settingsEvaluated { settings ->
    settings.pluginManagement {
        repositories {
            maven { url "https://maven.aliyun.com/repository/gradle-plugin" }
            mavenLocal()
            mavenCentral()
            gradlePluginPortal()
        }
    }
}
```
- [参考地址2](https://bbs.huaweicloud.com/blogs/detail/257878)


# Gradle 基础

## 基本概念

- Gradle 中有两大对象，Project 和 Task
- 一个构建脚本就是一个 project（对应 maven 中 pom 模块的概念），任何一个 gradle 构建都是由一个或者多个 project 构成，每一个 project 都是一个 groovy 脚本文件
- task 即任务，是 gradle 中的最小执行单元，类似于一个 method 或 function 函数（对应 maven 中生命周期的概念），如编译、打包、生成 javadoc 等，一个 project 中会有多个 task

## Hello World

- 首先，创建一个目录作为项目根目录，在根目录下创建 build.gradle 配置文件，该文件名称必须固定，其内容本质是一个 groovy 脚本文件
- 编写 build.gradle 文件，定义一个名称为 say 的任务，该任务简单地打印一行 hello world 到控制台
```groovy
task say {
    println "Hello, world"
}
```
- 对根目录执行 `gradle -q say` 查看是否打印 hello world


# wrapper

- 可以使用 `./gradlew wrapper --gradle-version 版本` 设置 wrapper 的版本，可以在工程目录的 `gradle/wrapper/gradle-wrapper.properties` 中查看到使用的具体版本
- 同时可以使用 `./gradlew wrapper --gradle-version 版本 --distribution-type all` 设置是使用 bin 版本的 wrapper 还是 all 版本的 wrapper




# build.gradle 文件参考


## restful-web spring boot

```js
plugins {
    id 'org.springframework.boot' version '2.5.2'
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
    id 'java'
}

group 'com.hao.learn.spring'
version '1.0-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
    maven { url 'https://maven.aliyun.com/repository/public/' }
    mavenLocal()
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation('org.springframework.boot:spring-boot-starter-test')
}

test {
    useJUnitPlatform()
}
```