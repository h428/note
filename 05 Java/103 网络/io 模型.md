# 前置概念

要了解 I/O 模型，需要提前掌握的相关概念包括：

- Socket
- Socket 缓冲区
- 用户空间、内核空间、系统调用
- 阻塞与非阻塞
- 同步与异步
- 文件描述符

# Linux I/O 模型

Linux 下包含 5 种 I/O 模型:

- 阻塞式 I/O
- 非阻塞式 I/O
- I/O 复用(select 和 poll)
- 信号驱动式 I/O(SIGIO)
- 异步 I/O(AIO)

# Java I/O 模型

# 参考链接

- [浅聊 Linux 的五种 IO 模型, by 码农 StayUp](https://segmentfault.com/a/1190000039898780)
- [IO 模型 - Unix IO 模型, by Java 全栈知识体系](https://pdai.tech/md/java/io/java-io-model.html)
- [详解 Java 中 4 种 IO 模型, by Java 技术栈](https://www.cnblogs.com/javastack/p/13222986.html)
- [Java NIO 浅析, by Java NIO 浅析](https://tech.meituan.com/2016/11/04/nio.html)
