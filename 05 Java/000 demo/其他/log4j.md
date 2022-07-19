

# 1. 概述

- Log4j 是一个用于记录日志的组件，是项目中必不可少的部分，使用下述步骤快速构建一个入门 log4j 实例
- 首先，基于 maven 构建普通的项目（当然 web 也可以），并引入 log4j 的依赖包
```xml
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
</dependency>
```
- 然后在 resources 下提供 log4j.properties 配置文件，配置内容的含义请参考下文
```properties
### log4j 根配置：设置全局日志级别为 debug，并声明三个 appender : stdout, debugOut, errorOut ###
log4j.rootLogger = debug,stdout,debugOut,errorOut

### 定义 appender: stdout，输出信息到控制抬 ###
log4j.appender.stdout = org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Target = System.out
log4j.appender.stdout.layout = org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern = [%-5p] %d{yyyy-MM-dd HH:mm:ss} [%l] : %m%n

### 输出DEBUG 级别以上的日志到=E:/debug.log ###
log4j.appender.debugOut = org.apache.log4j.DailyRollingFileAppender
log4j.appender.debugOut.File = E:/debug.log
log4j.appender.debugOut.Append = false
log4j.appender.debugOut.Threshold = DEBUG
log4j.appender.debugOut.layout = org.apache.log4j.PatternLayout
log4j.appender.debugOut.layout.ConversionPattern = [%-5p] %d{yyyy-MM-dd HH:mm:ss, SSS} [%c %t, %r] [%l] : %m%n

### 输出ERROR 级别以上的日志到=E:/error.log ###
log4j.appender.errorOut = org.apache.log4j.DailyRollingFileAppender
log4j.appender.errorOut.File =E:/error.log
log4j.appender.errorOut.Append = false
log4j.appender.errorOut.Threshold = ERROR
log4j.appender.errorOut.layout = org.apache.log4j.PatternLayout
log4j.appender.errorOut.layout.ConversionPattern = [%-5p] %d{yyyy-MM-dd HH:mm:ss, SSS} [%c %t, %r] [%l] : %m%n
```
- 最后，编写测试类，写入日志信息
```java
public class LogTest {
    private static final Logger logger = Logger.getLogger(LogTest.class);
    
    public static void main(String[] args) {
        // 一般，常用的日志级别为 debug, info, warn, error 四个

        // 记录 debug 级别的信息
        logger.debug("This is debug message.");
        // 记录 info 级别的信息
        logger.info("This is info message.");
        // 记录 warn 级别的信息
        logger.warn("This is warn message.");
        // 记录 error 级别的信息
        logger.error("This is error message.");
    }
}
```
- 之后，我们查看并对比、控制台、E:/debug.log、E:/error.log 三个地方的输出


# 2. 配置介绍

- 通过前面例子，我们可以看出，log4j 的主要配置都在 log4j.properties 这个配置文件中，下面我们来详细学习相关配置
- log4j 对日志定义了各个级别（8+1），但一般建议只采用 4 个日志级别，它们从低到高分别是：debug, warn, info, debug
- log4j 的配置主要包含三部分：
    - 全局日志的优先级：通过 rootLogger 配置，设置了该级别后，代码中所有低于该级别的日志将不会被记录
    - 日志的输出目的地：通过 rootLogger 声明要输出到哪些目的地，使用 appender 进行定义不同的目的地，目的地可以是控制台、各个不同的文件等，可以将不同级别的日志输出到不同的 appender
    - 每个 appender 的日志内容和格式：使用 layout 进行配置，可以控制各个日志的输出格式

**rootLogger 配置**

- 首先，要配置的就是 rootLogger，其指定了全局日志的级别以及要记录到哪些输出目的地
- 配置语法格式如下
```properties
# log4j 根配置：设置全局日志级别为 debug，并定义 stdout, debugOut, errorOut 三个输出目的地
log4j.rootLogger = debug,stdout,debugOut,errorOut
```
- 按照上述代码，log4j 只会记录代码中 debug 级别以上的日志
- 配置不同的文件时，如果要利用编写相对路径，可以利用 catalina.home 这个变量，其表示 Tomcat 目录，比如可以这样设置路径 `log4j.appender.D.File = ${catalina.home}/logs/info.log`
- 如果只想记录 info 级别以上，可将其设置为 info，这样将会导致代码中所有的 `logger.debug(...)` 记录的内容全都不记录日志
- 此外，上述配置我们还定义了三个输出目的地，接下来就是具体定义这三个 appender

**appender 配置**

- 首先，要确定 appender 的名称，比如前面的 stdout, debugOut, errorOut 等，然后名称指向一个 log4j 预定义的日志记录类，表示该 appender 要输出的地方（控制台，文件等）
- log4j 提供了下述几个预定义日志类，可以按自己需要使用
    - org.apache.log4j.ConsoleAppender（控制台），
    - org.apache.log4j.FileAppender（文件），
    - org.apache.log4j.DailyRollingFileAppender（每天产生一个日志文件），
    - org.apache.log4j.RollingFileAppender（文件大小到达指定尺寸的时候产生一个新的文件），
    - org.apache.log4j.WriterAppender（将日志信息以流格式发送到任意指定的地方）
- 使用了不同的日之类后，就要配置这些类各自的参数了，比如控制台的 Target，文件的 File, Append, Threshold 等
- 其中， Threshold 表示该文件只保存这个级别以上的日志信息，其他设置的含义很容易通过名称看出，不再赘述
- 之后，就是要配置日志的 layout，即日志格式了

**layout 配置**

- log4j 提供下述的 layout 布局，其中常用的是 PatternLayout
    - org.apache.log4j.HTMLLayout（以HTML表格形式布局），
    - org.apache.log4j.PatternLayout（可以灵活地指定布局模式），
    - org.apache.log4j.SimpleLayout（包含日志信息的级别和信息字符串），
    - org.apache.log4j.TTCCLayout（包含日志产生的时间、线程、类别等等信息）
- log4j 采用类似 C 语言中 printf 函数的格式化进行日志的打印，其各个格式化串含义如下：
    - %m 代码中指定的消息
    - %p 日志级别，即 DEBUG, INFO, WARN, ERROR, FATAL 等
    - %r 从应用启动到输出该 log 信息耗费的毫秒数
    - %c 所属的类，就是所在类的全名
    - %t 该日志事件的线程名
    - %n 输出一个换行
    - %d 时间，默认格式为 ISO8601，可以自行指定格式，例如 %d{yyy MMM dd HH:mm:ss,SSS}
    - %l 日志发生位置，包括类名、方法名、以及代码中的行数，例如 com.hao.test.LogTest.main(LogTest.java:13)
- 个人比较习惯的控制台格式是 `[%-5p] %d{yyyy-MM-dd HH:mm:ss} [%l] : %m%n`，比较简洁，然后输出到文件可以额外多一点信息，比较详细 `[%-5p] %d{yyyy-MM-dd HH:mm:ss, SSS} [%c %t, %r] [%l] : %m%n`

# 3. 和 Spring 整合

- 按要求提供文件即可，暂时没整合也能直接正常记录，不知什么原因

# 4. 日志门面 slf4j

- slf4j只是定义了一组日志接口，但并未提供任何实现
- 既然如此，那为何还需要 slf4j 呢，因为日志框架不只有一个，可能有的人喜欢log4j，有的喜欢其他日志框架，如 logback 或 jdk 自带的日志框架
- 这种情况下，我们的项目如果依赖了多个开源框架，而这些开源框架使用了不同的日志框架，那我们的项目岂不是同时依赖多个日志框架，基于这个原因，slf4j 应运而生
- 我们在进行日志记录时，代码使用 slf4j 的接口，具体实现使用喜欢用的 log4j（还需要一个转换包），而其他人使用他自己的日志框架（也需要一个转环包），则所有的代码部分只需要 slf4j 接口而不需要依赖具体的日志框架包，这是一种典型的门面模式应用
- 如果你的代码使用slf4j的接口，具体日志实现框架你喜欢用log4j，其他人的代码也用slf4j的接口，具体实现未知，那你依赖其他人jar包时，整个工程就只会用到log4j日志框架，这是一种典型的门面模式应用，与jvm思想相同，我们面向slf4j写日志代码，slf4j处理具体日志实现框架之间的差异，正如我们面向jvm写java代码，jvm处理操作系统之间的差异，结果就是，一处编写，到处运行。况且，现在越来越多的开源工具都在用slf4j了
