# 1. 远程仓库

- `ssh-keygen -t rsa -C "Lyinghao@126.com"`，该命令会在当前用户目录下生成`.ssh`文件夹，文件内包含`id_rsa`和`id_rsa.pub`
- 把 id_rsa.pub 配置到 github 的 SSHKey 中，这样本地才能 push 到远程仓库

# 2. GitBash 相关

## 2.1 解决 GitBash 乱码

- 所有文件都基于 Git 安装目录进行操作
- 编辑 `etc\gitconfig` 文件，在文件末尾增加以下内容（没有文件则创建）

```bash
[gui]
    encoding = utf-8  # 代码库统一使用utf-8
[i18n]
    commitencoding = utf-8   # log 编码，windows 默认 gb2312，用 utf-8 可能乱码，声明后发到服务器才不会乱码
[svn]
    pathnameencoding = utf-8  # 支持中文路径
```

- 编辑 etc\git-completion.bash 文件,在文件末尾增加以下内容，文件没有手动创建

```bash
alias ls='ls --show-control-chars --color=auto'  #ls能够正常显示中文
```

- 编辑 etc\inputrc 文件，修改 output-meta 和 convert-meta 属性值：

```bash
set output-meta on  # bash 可以正常输入中文
set convert-meta off
```

- 编辑 profile 文件，在文件末尾添加如下内容：

```bash
export LESSHARESET=utf-8
```

- git status 乱码

```
git config --global core.quotepath false
```

- 2.15 版本，option -> utf8

## 2.2 IDEA 提交到 github 乱码

- 执行下述命令

```bash
git config --global i18n.commitencoding utf-8
git config --global gui.encoding utf-8
git config --global i18n.logoutputencoding utf-8
```

## 2.3 配置代理

```bash
export http_proxy=http://127.0.0.1:10809
export https_proxy=http://127.0.0.1:10809

git config --global http.proxy socks5://127.0.0.1:1080
git config --global https.proxy socks5://127.0.0.1:1080

git config --global http.proxy http://127.0.0.1:10809
git config --global https.proxy https://127.0.0.1:10809
```

# 3. .gitignore 配置

- 已经 add 的文件，再配置 .gitignore 后不会自动删除，需要先执行 `git rm -r --cached .`

## 3.1 前置斜线与后置斜线

- 后置斜线 : `/` 指代目录，因此 `static/` 和 `static` 是不一样的，前者只匹配目录 static，而后者则可以匹配同名的目录、文件名、符号链接等等
- 前置斜线 : `.gitignore` 默认以相对路径为基准，子目录下的 `.gitignore` 优先应用自己的规则然后再递归向上一直找到 git 的根（也就是 .git 存在的那个目录），因此不建议在路径模式前追加 `/`，因为 :
  1. 多数情况下我们只使用一个 `.gitignore`，即工作树根路径下的 `.gitignore`。此时相对于它自身，`/` 就代表着当前工作路径，没有必要加它；
  2. 如果我们添加了子目录下的 `.gitignore`，那我们的本意也是要去匹配其下的路径，若是加了前置的 `/` 反而让人摸不着头脑；
- 不过有一种情况下 / 是需要的，比如说你项目下有很多 `index.html` 文件，你只想忽略工作树根路径下的那一个，其他则不管；这样的话直接写 `index.html` 是不行的，因为 git 会把它当作一个 glob pattern 去匹配所有同名文件（哪怕不同级）。此时就需要追加一个前置斜线：`/index.html`，意思是：我只要屏蔽相对于 `/` 下的 `index.html`

## 3.2 配置样例

1. 忽略一个特定的文件：`/filename.extension`
2. 忽略所有同名的文件：`filename.extension`
3. 忽略一个特定的目录：`folder/` （这会连同其下所有子目录及文件都被忽略）
4. 在 3 的基础上，不忽略指定的文件：`!folder/some/important/filename.extension`
5. 忽略指定目录下所有子目录下的特定文件：`folder/**/filename.extension`
6. 同上，但是只匹配文件扩展名：`folder/**/*.extension`
7. 同上，但是只匹配特定的目录：`folder/**/tmp/`

## 3.3 样例

- gamming-server 样例

```conf
# 根目录下的文件夹，注意结尾要带 /
.idea/
build/

# 子项目下的文件夹，注意结尾要带 /
**/target/
**/.mvn/

# 子项目下的文件，结尾不带 /
**/mvnw
**/mvnw.cmd
**/HELP.MD
**/README.MD

# 统一排除的文件
rebel.xml
*.iml
```

# 4. 配置 github，gitee 环境共存

- 下述创建或者生成的文件都位于 `~/.ssh/` 目录下，涉及 config 以及两对 ssh 公钥私钥对
- 查看是否已经配置 `user.name` 和 `user.email` : `git config --global --list`
- 若已经配置需要先清除配置信息：

```bash
git config --global --unset user.name "你的名字"
git config --global --unset user.email "你的邮箱"
```

- 分别针对 github、gitee 生成 ssh 对，下述操作会生成 4 个文件，若是重装恢复直接拷贝即可：

```bash
ssh-keygen -t rsa -f ~/.ssh/github -C "Lyinghao@126.com"
ssh-keygen -t rsa -f ~/.ssh/gitee -C "Lyinghao@126.com"
```

- 最终得到 4 个相关文件：`gitee, gitee.pub, github, github.pub`，如果是手动拷贝过去的文件，则权限必须修改为 600
- 多环境 ssh 主要通过 config 文件，因此接下来重点配置 config
- 若无 config 文件，则需创建 config 文件，注意无其他后缀

```bash
touch ~/.ssh/config
```

- 配置 config 内容如下，主要是对应域名使用哪个私钥

```config
# gitee
Host gitee.com
HostName gitee.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/gitee

# github
Host github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/github
```

- 将公钥分别添加到 github、gitee 中的密钥管理处才能进行提交
- 测试是否配置成功：

```bash
ssh -T git@github.com
ssh -T git@gitee.com
```

# 9. 其他

## 9.1 github clone 很慢

- 利用[ipaddres](https://www.ipaddress.com/)查看域名对应的 ip 地址。
- 查找`github.global.ssl.fastly.net`对应的 ip 地址
- 查找`github.com`对应的 ip 地址
- 修改 host 文件，加入下述映射，注意地址改为当前查到的地址，因为 ip 地址可能发生变化：

```
151.101.13.194		github.global.ssl.fastly.net
192.30.253.112		github.com
```
