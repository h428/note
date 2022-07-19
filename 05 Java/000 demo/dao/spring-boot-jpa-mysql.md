

# 概述


- 官方教程：[jpa](https://spring.io/guides/gs/accessing-data-jpa/), [mysql](https://spring.io/guides/gs/accessing-data-mysql/)




# 依赖

- 除了 web 中的基础依赖以外，jpa 工程需要额外配置下述依赖：
```xml
<!--mysql 驱动-->
<dependency>
  <groupId>mysql</groupId>
  <artifactId>mysql-connector-java</artifactId>
  <scope>runtime</scope>
</dependency>
<!--jpa 启动器-->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```

# 配置




# 代码