# 介绍

# Hello, World

基于 Netty 的简单代码如下，下述代码测试了“启动服务器 - 启动客户端 - 发送 hello, world 字符串 - 服务器接受”这样一个流程，具体运行流程在 Server 和 Client 中都有标明序号。

服务端代码如下：

```java
// 服务端代码
public class NettyServer {
    public static void main(String[] args) {
        // 1. 创建服务端的启动类 ServerBootstrap
        new ServerBootstrap()
            // 2. 添加事件循环组 EventLoop
            .group(new NioEventLoopGroup())
            // 3. 设置服务器通道为 NioServerSocketChannel，注意使用 netty 封装服务器通道类
            .channel(NioServerSocketChannel.class)
            // 4. 添加子处理器，对于子处理器中添加的处理器都是给 NioSocketChannel 用的
            .childHandler(
                // 5. Channel 代表和客户端进行数据读写的通道，Initializer 为初始化，故该类为通道初始化类
                new ChannelInitializer<NioSocketChannel>() {
                    // 12. 客户端连接后，NioEventLoop 会处理 accept 事件并最终调用下述代码进行通道初始化
                    @Override
                    protected void initChannel(NioSocketChannel ch) throws Exception {
                        // 17. NioEventLoop 会处理 read 事件，接受到 ByteBuf
                        // Netty 会将 ByteBuf 经过一系列对当前通道设置好的职责链，执行到各个 handler 的具体方法
                        ch.pipeline()
                            // 添加解码器，用于接收数据时从 byte 解码为 String，是个 ChannelInboundHandler
                            // 18. ByteBuf 经由 StringDecoder 处理器，变为 String
                            .addLast(new StringDecoder())
                            // 自定义入站处理器，也是一个 ChannelInboundHandler
                            // 19. String 经由自定义的 ChannelInboundHandler，进行打印，自此 hello, world 处理结束
                            .addLast(new ChannelInboundHandlerAdapter() {
                                @Override
                                public void channelRead(ChannelHandlerContext ctx, Object msg)
                                    throws Exception {
                                    // 打印上一步转化后的字符串
                                    System.out.println(msg);
                                }
                            });
                    }
                })
            // 6. 绑定监听端口
            .bind(8080);
    }
}
```

对于 Server 端代码，需要重点关注的地方为：

- 序号 2 处，对于创建 NioEventLoopGroup，可以简单理解为线程池 + Selector，类似我们前面自行编写的多路复用多线程版本，但 Netty 封装得更好，后面会详细展开
- 序号 3 处，使用 channel 方法设置当前终端要选择的 Socket 实现类，其中 NioServerSocketChannel 表示基于 NIO 的服务器端实现
- 序号 4 处，对于添加子处理器的方法 childHandler，是接下来添加的处理器都是给 SocketChannel 用的，而不是给 ServerSocketChannel。ChannelInitializer 处理器（仅执行一次），它的作用是待客户端 SocketChannel 建立连接后，执行 initChannel 以便添加更多的处理器
- 序号 6 处，使用 ServerSocketChannel.bind 绑定的监听端口
- 序号 18 处，SocketChannel 的处理器，解码 ByteBuf => String
- 序号 19 处，SocketChannel 的业务处理器，使用上一个处理器的处理结果，故输入类型为 String

客户端代码如下：

```java
public class NettyClient {
    public static void main(String[] args) throws InterruptedException {
        // 7. 创建客户端启动类
        new Bootstrap()
            // 8. 为客户端添加 EventLoop
            .group(new NioEventLoopGroup())
            // 9. 设置客户端的 Channel，即为 NioSocketChannel，注意选择 netty 封装的实现
            .channel(NioSocketChannel.class)
            // 10. 添加处理器，客户端只有应用到 SocketChannel 的处理器，使用 handler 添加
            .handler(new ChannelInitializer<NioSocketChannel>() {
                // 12. 同样的，在连接建立后，客户端也会执行下列方法进行通道初始化
                @Override
                protected void initChannel(NioSocketChannel ch) throws Exception {
                    // 16. 消息经过编码器，是一个 ChannelOutboundHandler
                    ch.pipeline().addLast(new StringEncoder());
                }
            })
            // 11. 连接到服务器
            .connect(new InetSocketAddress(8080))
            // 13. 阻塞方法，直到连接建立成功才会返回
            .sync()
            // 获取连接对应的 channel 对象
            .channel()
            // 14. 利用 channel 对象像服务器发送字符串 hello, world
            .writeAndFlush("hello, world");
    }
}
```

对于 Client 端代码，需要重点关注的地方为：

- 序号 8 处，创建 NioEventLoopGroup，同 Server
- 序号 9 处，选择客户 Socket 实现类，NioSocketChannel 表示基于 NIO 的客户端实现
- 序号 10 处，添加 SocketChannel 的处理器，ChannelInitializer 处理器（仅执行一次），它的作用是待客户端 SocketChannel 建立连接后，执行 initChannel 以便添加更多的处理器
- 序号 11 处，指定要连接的服务器和端口
- 序号 13 处，Netty 中很多方法都是异步的，如 connect，这时需要使用 sync 方法等待 connect 建立连接完毕
- 序号 14 处，获取 channel 对象，它即为通道抽象，可以进行数据读写操作
- 序号 15 处，写入消息并清空缓冲区
- 序号 16 处，消息会经过通道 handler 处理，这里是将 String => ByteBuf 发出
- 数据经过网络传输，到达服务器端，服务器端 17 和 18 处的 handler 先后被触发，走完一个流程
