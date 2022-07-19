
[toc]

# 记录代码

```
public class Log4JTest {
    @Test
    public void testLog(){
        //获得一个日志记录器
        Logger logger = Logger.getLogger(Log4JTest.class);
        logger.fatal("致命错误");
        logger.error("普通错误");
        logger.warn("警告信息");
        logger.info("普通信息");
        logger.debug("调试信息");
        logger.trace("堆栈信息");
    }
}
```


# log4j.properties样例

```
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Target=System.out
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{ABSOLUTE} %5p %c{1}:%L - %m%n

log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.File=D:\\temp\\mylog.log
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d{ABSOLUTE} %5p %c{1}:%L - %m%n

### fatal error warn info debug debug trace
log4j.rootLogger=debug, file
#log4j.logger.org.hibernate=INFO
#log4j.logger.org.hibernate.type=INFO
```