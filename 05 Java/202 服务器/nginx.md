

# 安装

## 初始化安装

- 访问[官网](http://nginx.org/en/download.html)，下载源码包，此处选择 1.18.0：`wget http://nginx.org/download/nginx-1.18.0.tar.gz`
- 观察官方的默认命令
```bash
./configure
    --sbin-path=/usr/local/nginx/nginx
    --conf-path=/usr/local/nginx/nginx.conf
    --pid-path=/usr/local/nginx/nginx.pid
    --with-http_ssl_module
    --with-pcre=../pcre-8.44
    --with-zlib=../zlib-1.2.11
```
- 我们可以看到其依赖 pcre-8.44 和 zlib-1.2.11，同时 --with-http_ssl_module 需要 openssl 依赖
- 下载 openssl、pcre 和 zlib 并解压，注意和 nginx 在同一级目录
```
wget https://www.openssl.org/source/openssl-1.0.2s.tar.gz
wget https://ftp.exim.org/pub/pcre/pcre-8.44.tar.gz
wget https://zlib.net/fossils/zlib-1.2.11.tar.gz
ls *.tar.gz | xargs -n1 tar xzvf
```
- 执行 configure 校验依赖，会生成 Makefile 文件
```bash
./configure \
    --with-openssl=../openssl-1.0.2s \
    --with-pcre=../pcre-8.44 \
    --with-zlib=../zlib-1.2.11 \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module
```
- 可以看到下列输出说明依赖没问题，同时会在当前目录生成 Makefile：
```bash
Configuration summary
  + using PCRE library: ../pcre-8.44
  + using OpenSSL library: ../openssl-1.0.2s
  + using zlib library: ../zlib-1.2.11

  nginx path prefix: "/usr/local/nginx"
  nginx binary file: "/usr/local/nginx/sbin/nginx"
  nginx modules path: "/usr/local/nginx/modules"
  nginx configuration prefix: "/usr/local/nginx/conf"
  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
  nginx error log file: "/usr/local/nginx/logs/error.log"
  nginx http access log file: "/usr/local/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"
```
- 确保安装了编译器 `yum install -y gcc gcc-c++`
- 执行 `make` 编译，`make install` 安装

## 添加模块

- nginx 首次安装完成后，发现需要 `--with-http_gzip_static_module` 模块，则需要动态添加模块
- 我们在之前安装命令的基础上，添加 `--with-http_gzip_static_module` 并重新 configure
```bash
./configure \
    --with-openssl=../openssl-1.0.2s \
    --with-pcre=../pcre-8.44 \
    --with-zlib=../zlib-1.2.11 \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module
```
- 之后，执行 `make` 操作进行编译，注意千万不要执行 `make install` 这会导致覆盖
- 我们先停止原来的 nginx：`/usr/local/nginx/sbin/nginx -s stop`
- 我们备份原来的 nginx：`mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak`
- 编译后会在 objs 下生成 nginx 文件，将新生成的 nginx 拷贝到原来的目录：`cp objs/nginx /usr/local/nginx/sbin/nginx`
- 添加 gzip_static on; 配置后重新启动：`/usr/local/nginx/sbin/nginx`

## 开启自启动

- 我们编辑 `vim /etc/systemd/system/nginx.service`
```conf
[Unit]
Description=nginx
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PrivateTmp=true
 
[Install]  
WantedBy=multi-user.target
```
- 刷新配置并启动
```sh
systemctl daemon-reload \
&& systemctl enable nginx.service \
&& systemctl start nginx.service \
&& systemctl status nginx.service
```

# 配置

- nginx.conf 配置文件采用 # 作为注释，全局文件结构如下：
```conf
...              # 全局块
events {         # events块
   ...
}
http      # http块
{
    ...   # http全局块
    server        # server 块
    { 
        ...       # server 全局块
        location [PATTERN]   # location 块
        {
            ...
        }
        location [PATTERN] 
        {
            ...
        }
    }
    server
    {
      ...
    }
    ...     # http 全局块
}
```

## 全局块

- 一般在全局块配置影响 nginx 服务器整体运行的配置指令，一般有：
    - 运行 nginx 服务器的用户组
    - nginx 进程 pid 存放路径
    - 日志存放路径
    - 配置文件引入
    - 允许生成 worker processor 数等
- 比如 `worker_processes auto` 这一行表示 nginx 进程数，worker_processes 值越大，nginx 可支持的并发数就越多，当然，这受服务器硬件条件限制，一般按 cpu 数目来指定，如 2 个四核的 cpu 计为 8

## events 块

- events 块的配置主要影响 nginx 服务器或与用户的网络连接
- 例如 worker_connections 表示每个进程允许的最大连接数，理论上每台nginx 服务器的最大连接数 worker_processes*worker_connections
- 此外还包括：
- 选取哪种事件驱动模型处理连接请求
- 是否允许同时接受多个网路连接
- 开启多个网络连接序列化等

## http 块

- http 块内部可以嵌套多个 server，我们可以通过 http 块和 server 块配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置
- 如文件引入，MIME-TYPE 定义，日志自定义，是否使用 sendfile 传输文件，连接超时时间，单连接请求数等

## server 块

- http 块中的 server 块则相当于一个虚拟主机，一个 http 块可以拥有多个 server 块，我们配置代理主要就是在 server 块配置
- 直观的理解就是，一个 server 块会根据 `listen` 的配置监听指定端口（一般是 80），并通过 `server_name` 配置识别不同的来源参数（例如分别以通过 api.hao.com、sys.hao.com、指定 ip 同样访问 80 端口），我们通过 location 的正则匹配路径部分，并将其代理到指定的目录或者进程端口
- 一般一个 server 对应一个本地端口或者一个本地目录
- 配置含义如下
```conf
http {
    server {
        listen       80; # 配置监听端口
        server_name  www.h428.top; # 配置识别来源，若通过 www.h428.top 访问当前端口

        location / { # 路径部分（冒号后面的）正则匹配，简单配置为
            root /lab/web/index;
            index  index.html;
            try_files $uri $uri/ /index.html;
        }
    }
    
    server {
        listen       80; # 配置监听端口
        server_name  api.h428.top; # 配置识别来源，若通过 api.h428.top 访问当前端口
        access_log logs/api.h428.log;
        error_log logs/api.h428.error;
        
        location / { # 通过正则匹配路径，此处表示匹配所有
            proxy_set_header Host $host; # 转发 host 头部
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass   http://localhost:20000; # 代理至本地 20000 端口
        }
    }
}
```

## location 块

- location 块：配置请求的路由，以及各种页面的处理情况