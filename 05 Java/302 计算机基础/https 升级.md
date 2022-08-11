
# 概述

- [参考地址](https://juejin.im/post/6844904143291678734)

## 为什么要升级？

- 安全性：相对于 HTTP 协议的明文传输，HTTPS 的传输是加密的，可防止数据在传输过程中被黑客恶意篡改和窃取，有效防止了中间人攻击
- 更高的 SEO 收录排名：HTTPS 可以对接入 HTTPS 协议的网站获取更高的收录排名
- 防止错误警告提示：新版的 Chrome 浏览器如果发现当前网站不支持 HTTPS 协议，会在右上角提示『不安全』三个字，提示『请勿在该网站输入任何敏感信息』，对用户的信赖感造成一定负面影响

## HTTP 与 HTTPS 的关系

- HTTPS 是由 SSL+HTTP 协议构建，https 在 http 通信协议的基础上，基于 ssl，增加了一个加密层
- 想要接入 HTTPS，必须申请创建一 SSL 证书，存放在服务器上，SSL 证书是由受信任的数字证书颁发机构 CA 颁发，注意，SSL 证书是有有效期的，一般为三个月到一年
- HTTP 协议默认走 80 端口，HTTPS 协议默认走 443 端口（记住这一点很重要！）

## 为什么要选取泛域名证书，而不是其他类型的的证书

- SSL 证书分为单域名证书、多域名证书和泛域名证书
- 单域名证书：
    - 一个单域名证书只能保护它自己，例如一个 msh.com 的证书，只能保护它自己，保护不了它下面的子域名，例如 b.msh.com，c.msh.com 是保护不了的
    - 缺点：如上所示，意味着我每增加一个子域名，就需要重新生成一次该子域名对应的的 SSL 证书
- 多域名证书：
    - 一个证书可以保护指定的多个域名，例如一个多域名证书既可以保护指定的 msh.com，也能保护指定的 b.msh.com 和 c.msh.com，或者同级的 nsh.com
    - 缺点：虽然可以指定多域名，但问题在于我也不知道将来我会增加什么子域名。这意味着我到时我可能还需要重新生成一次，个人感觉，多域名证书有点鸡肋
- 泛域名证书：
    - 一个对应为 *.msh.com 的泛域名证书，可以保护 msh.com 域名以及它下面所有的次一级的子域名例如 b.msh.com 和 c.msh.com
    - 优势：如上所示，也意味着我可以一劳永逸，泛域名证书生成后，可以适用于该域名证书下的所有次一级的子域名，所以说是泛域名证书是三种类型证书中最实用的证书
    - 注意：该证书是保护不了更下一级的 abc.test.msh.com 域名的，如果你想要保护 abc.test.msh.com，需要申请一个*.test.msh.com 的泛域名证书

## 选择付费型证书还是免费型证书？

- 付费型：通过赛门铁克或 GeoTrust 颁发，安全级别更高。此外，用他们的证书出安全事故的话，机构会提供几十万乃至上千万的美金赔付。当然了，代价是证书比较昂贵，一个单域名证书一年 5000 RMB,一个泛域名证书一年 40000 RMB，抵得上一年服务器租赁的成本了。所以穷逼们请绕过此条道
- 免费型：由 Let's Encrypt 等数字证书机构颁发，永久免费，免费的同时，又有着极高的浏览器兼容性和安全性，更重要的是，2018 年 1 月份开始，Let's Encrypt 开始正式泛域名证书了（穷逼们的天降福利）
- 结论：从适用范围来说，显然选择泛域名证书是最优解，而对于严格控制成本（qiong bi）的中小型互联网公司，基于 Let's Encrypt 生成自己的泛域名证书，是最最优解

## 为什么要通过 acme.sh 生成泛域名证书，而不是其它方式

- 通过 Letsencrypt 生成证书方式有三种：
- FreeSSL.org：可以访问 FreeSSL.org 的官网在线生成，缺点是那就是同一主域名下的证书数量是有限制的，一般是 20 个，数量远不能满足正常使用，而且到有效期需要手动更换证书，因此太过鸡肋
- Certbot：可以安装后再服务器上生成证书，但是自动化程度远远比不上 acme.sh
- acme.sh：他的优势简单两句话就可以说明白，安装很简单，一条命令搞定，自动化程度很高，支持自动 dns 校验，自动更新证书

# 基于 acme.sh 从 Letsencrypt 生成免费的泛域名证书

- 环境如下：
```
linux 服务器，操作系统为 centos7.2
nginx 1.10.1
acme.sh v2.8.0
```

## 安装 acme.sh

- 安装依赖环境：`yum -y install curl cron socat`
- 下载并安装 acme.sh：`curl  https://get.acme.sh | sh`
- 执行上述命令后，会在 /root 文件夹下建立一个 .acme.sh 的目录
- 安装完后执行 acme.sh，提示命令没找到，执行 `source ~/.bashrc` 即可
- 安装过程会访问 github 可能需要配置代理，若是云服务器无法访问可以自己查询出 ip 地址并配置到 /etc/hosts 则可以慢速访问

## 配置域名解析服务商的 token，完成 DNS 验证

- DNS 验证的意义在于证明域名的所有人是你，而不是别人
- acme.sh 是通过操作当前域名的 DNS 解析记录，来自动完成 DNS 校验的，这样省了我们很多力气，而且不容易出错
- 但是 acme.sh 不是随随便便就就能操作当前域名的 DNS 解析记录的，必须通过当前域名的域名注册服务商授权才可以，这就需要在域名服务商创建一个 API token 并授权给 acme
- 目前 acme.sh 支持的域名注册服务商有阿里云，亚马逊 AWS，微软 Azure，DNSPod 等，DNSPod 和腾讯云是一家
- 创建 token 后在服务器上导出，此处为腾讯云
```bash
export DP_Id="DP_Id"
export DP_Key="DP_Key"

# 替换成从阿里云后台获取的密钥
export Ali_Key="xxx" \
&& export Ali_Secret="xxx"
```

## 生成泛域名证书

- 注意，根据不同的域名商选择不同的 dns 商：如 dns_ali，dns_dp 等
- acme.sh 现在默认使用 ZeroSSL 生成证书，其需要在 ~/.acme.sh/account.conf 中添加邮箱
```conf
ACCOUNT_EMAIL='xxx@xxx.com'
```
- 也可以切换回原有的 Let's Encrypt：`acme.sh --set-default-ca --server letsencrypt`
- 执行命令生成证书：`acme.sh --issue --dns dns_ali -d h428.top -d *.h428.top`，此处基于域名 h428.top
- 正常情况下，该命令执行成功需要 120 秒
- 如果这个过程中报错，可以加上 debug 参数，重新执行一遍，查看更详尽的错误原因（90% 的问题都在于 token 不合法）
- `acme.sh --issue --dns dns_ali -d h428.top -d *.h428.top --debug 2`

## 复制证书到指定位置

- 疑惑：为什么要把 acme.sh 生成的证书位置从默认生成位置拷贝到其它地方？
- 解疑：因为 acme.sh 生成的文件夹结构可能会变，所以需要将证书复制到别的位置
- 疑惑：为什么不能手动通过 mv 或者 cp 命令来复制证书到指定位置？
- 解疑：SSL 证书是有有效期的，到期 acme.sh 会自动更新你的安全证书，并重启 nginx 服务器，让证书生效。所以你必须告诉 acme.sh 你指定的 SSL 证书存放位置，以及重启 nginx 服务器的命令，通过 --installcert 参数，指定的所有参数都会被自动记录下来, 并在将来证书自动更新以后, 被再次自动调用
- 例如我们指定的整数存放目录为 `/ssl`，重启 nginx 服务器的命令为 `/usr/local/nginx/sbin/nginx -s reload`
- 则完整的安装整数命令为：
```bash
mkdir /ssl
acme.sh --installcert -d h428.top --key-file /ssl/h428.top.key  --fullchain-file /ssl/h428.top.cer --reloadcmd "/usr/local/nginx/sbin/nginx -s reload"
```

# nginx 配置全站升级 HTTPS

## 为 nginx 安装 ssl 模块

- 想要 nginx 支持 https，必须安装 http_ssl_module 模块，该模块如果未安装或安装失败，在配置 nginx 的 https 时会报 unknown directive "ssl" 的错
- 可以在初始化 configure 时指定 --with-http_ssl_module 选项添加模块，这样首次安装就会安装该模块
- 如果首次安装没有安装该模块，则需要下列步骤：
```bash
# 下载你当前版本的nginx包，并且解压 进到目录
./configure --with-http_ssl_module
# 切记千万不要 make install 那样就覆盖安装了
make
# 将原来的 nginx 备份 备份之前先关闭当前正在执行的 nginx
/usr/local/nginx/sbin/nginx -s stop
cp /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak
# make 之后会在当前目录生成 objs 目录
cp objs/nginx /usr/local/nginx/sbin/nginx
# 然后重新启动 nginx
/usr/local/nginx/sbin/nginx
```

## 告诉 nginx 你的证书存放的位置

- 先明确，我们前面设置的整数存放位置为 /ssl
- 打开 nginx 安装目录的 nginx.conf 配置文件。因为是泛域名证书，所以当前域名以及当前域名下的所有次级子域名可以共用一个证书
- 例如下述配置：
```conf
# 第一个子域名
server {
	# https默认监听的是443 端口
	listen       443 ssl;
	server_name b.msh.com  ;
	# 指定证书位置
    ssl_certificate /mycertify/ssl/msh.com.cer;  
	ssl_certificate_key /mycertify/ssl/msh.com.key;
	
	# 下方的5个配置项是和https无关的，如果想让nginx能正常代理websocket，则必须加上
	# 防止nginx代理websocket时，每隔75秒自动中断
	proxy_connect_timeout 7d;
	proxy_send_timeout 7d;
	proxy_read_timeout 7d;
	# 防止nginx代理websocket 报错
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";


	location / {
		proxy_pass http://localhost:8585;
	}
}

# 其他的同级域名的证书配置，也可以照搬同上这样配置
```