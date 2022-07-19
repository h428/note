


# Git 安装和初始配置


## 安装与初始化配置

- 根据自己的操作系统安装Git，windows安装[Git](https://git-scm.com/downloads)
- 安装完，进入某目录，右键可看到**Git Bash Here**，则可进入git命令行界面

- 使用 git 之前，要先配置用户名和邮箱，其中 `--global` 选项表示全局配置
```bash
git config --global user.name "用户名"
git config --global user.email "邮箱地址"
```
- 配置完成后可以用下述命令查看配置结果：
```bash
git config --global user.name
git config --global user.email
```
- git 默认采用 vim 作为编辑器，若想修改默认编辑器，例如使用 sublime，可以使用 `git config --global core.editor sbul` 配置，其中编辑器必须位于 Path 上下文中
- 可以使用 `git config --list` 查看所有配置信息，使用 `git config user.name` 查看某一项信息

**操作代码**
```bash
git config --global user.name "hao" # 配置用户名
git config --global user.email "Lyinghao@126.com" # 配置邮箱
git config --global user.name # 查看已配置的用户名
git config --global user.email # 查看已配置的邮箱
```

# Git 基础

## 仓库操作

### 创建本地仓库

- `git init`：将当前所在目录变为 Git 可以管理的仓库，其会在当前目录生成 **.git** 目录，这个目录是 Git 来跟踪管理版本库的
- 图片、视频这些二进制文件，虽然也能由版本控制系统管理，但没法跟踪文件的变化，只能把二进制文件每次改动串起来，也就是只知道图片从 100KB 改成了 120KB，但到底改了啥，版本控制系统不知道，也没法知道，因此，如果要真正使用版本控制系统，就要以纯文本方式编写文件
- 因为文本是有编码的，如果没有历史遗留问题，强烈建议使用标准的 UTF-8 编码，所有语言使用同一种编码，既没有冲突，又被所有平台所支持
- 通用初始化操作代码：
```bash
pwd # 查看当前目录路径，确保位置正确
git init # 将当前目录作为 Git 仓库，会在当前目录下生成 .git 文件夹
git add *.c
git add LICENSE
git commit -m 'initial project version'
```

### 克隆现有仓库

- 可以使用 `git clone` 命令克隆指定仓库，例如例如 `git clone https://github.com/libgit2/libgit2` 会在当前目录下创建一个名为 “libgit2” 的目录，并在这个目录下初始化一个 .git 文件夹，从远程仓库拉取下所有数据放入 .git 文件夹，然后从中读取最新版本的文件的拷贝
- 若想在克隆远程仓库时自定义本地仓库有名称，可以使用 `git clone https://github.com/libgit2/libgit2 mylibgit`，这样本地仓库的名称为 mylibgit

## 文件跟踪

- 对于 Git 来说，工作目录下的每一个文件都不外乎这两种状态：已跟踪或未跟踪
- 已跟踪的文件是指那些被纳入了版本控制的文件，在上一次快照中有它们的记录，在工作一段时间后，它们的状态可能处于未修改，已修改或已放入暂存区
- 工作目录中除已跟踪文件以外的所有其它文件都属于未跟踪文件，它们既不存在于上次快照的记录中，也没有放入暂存区
- 初次克隆某个仓库的时候，工作目录中的所有文件都属于已跟踪文件，并处于未修改状态
- 编辑过某些文件之后，由于自上次提交后你对它们做了修改，Git 将它们标记为已修改文件
- 我们逐步将这些修改过的文件放入暂存区，然后提交所有暂存了的修改，如此反复
- 被 Git 纳入管理的文件的生命周期如下图所示：
![生命周期](https://raw.githubusercontent.com/h428/img/master/note/00000209.jpg)

## 文件状态查看 git status

- 可以使用 `git status` 查看文件状态：
    - `nothing to commit, working directory clean`：表示工作目录相当干净，自上次提交后本地未修改
    - `Untracked files: ...`：表示存在未跟踪的文件，git 不会对这些文件做版本控制；注意新建的文件，git 不会自动将其纳入版本管理，除非使用 `git add` 明确告诉 git 需要对该文件进行版本管理
    - `Changes to be committed: ...`：表示文件处于已暂存状态，若此时提交，单么该文件此刻的版本就被留存在历史记录中
    - `Changes not staged for commit: ...`：表示已跟踪文件的内容发生了变化，但还没有添加到暂存区，需要使用 `git add` 将本次修改添加到暂存区
- 可以使用 `git status -s` 或 `git status --short` 查看紧凑的格式输出，其输出格式如下：
```bash
$ git status -s
 M README
MM Rakefile
A  lib/git.rb
M  lib/simplegit.rb
?? LICENSE.txt
```
- 新添加的为暂存的文件前面有 `??` 标记
- 新添加到暂存区的文件前面有 `A` 标记
- 修改过的文件前面有 `M` 标记，出现在右边的 `M` 表示该文件被修改了但是还没放入暂存区，出现在靠左边的 `M` 表示该文件被修改了并放入了暂存区
- 例如，上面的状态报告显示： 
    - README 文件在工作区被修改了但是还没有将修改后的文件放入暂存区
    - lib/simplegit.rb 文件被修改了并将修改后的文件放入了暂存区
    - Rakefile 在工作区被修改并提交到暂存区后又在工作区中被修改了，所以在暂存区和工作区都有该文件被修改了的记录
- 若 `git status` 显示中文乱码，则输入`git config --global core.quotepath false`即可


## 添加和提交文件 git add

- `git add 文件名或目录名`：将一个新文件或一个目录添加到仓库。
- `git commit -m "更新信息"`：将添加的文件提交到仓库，`-m` 后面输入的是本次提交的说明，可以输入任意内容，当然最好是有意义的，这样你就能从历史记录里方便地找到改动记录。
- 为什么 Git 添加文件需要 add, commit 一共两步：因为 commit 可以一次提交很多文件，所以你可以多次 add 不同的文件，最红统一 commit，比如下述操作：
```bash
git add file1.txt
git add file2.txt file3.txt
git commit -m "add 3 files."
```
- 测试操作代码
```bash
touch a.txt # 创建文件 a.txt
git add a.txt # 将文件添加到仓库
git commit -m "新建 a.txt 文件" # 将文件提交到仓库
```


## 忽略文件 .gitignore

- 一般我们总会有些文件无需纳入 Git 的管理，也不希望它们总出现在未跟踪文件列表，通常都是些自动生成的文件，比如日志文件，或者编译过程中创建的临时文件等
- 我们可以创建一个名为 .gitignore 的文件，列出要忽略的文件模式，其格式规范如下：
    - 所有空行或者以 `#` 开头的行都会被 Git 忽略。
    - 可以使用标准的 glob 模式匹配
    - 匹配模式可以以 `/` 开头防止递归（不以 `/` 开头默认会做递归处理，忽略当前目录以及子目录下的指定文件夹）
    - 匹配模式可以以 `/` 结尾指定目录
    - 要忽略指定模式以外的文件或目录，可以在模式前加上惊叹号 `!` 取反
- glob 模式（shell 所使用的简化了的正则表达式）：
    - `*`：匹配零个或多个任意字符
    - `[abc]`：匹配任何一个列在方括号中的字符（这个例子要么匹配一个 a，要么匹配一个 b，要么匹配一个 c）
    - `?`：问号只匹配一个任意字符
    - 如果在方括号中使用短划线分隔两个字符，表示所有在这两个字符范围内的都可以匹配（比如 `[0-9]` 表示匹配所有 0 到 9 的数字）
    - `**`：两个星号表示匹配任意中间目录，比如 `a/**/z` 可以匹配 `a/z`, `a/b/z` 或 `a/b/c/z` 等
- 注意，.gitignore 默认支持递归模式，例如 `target/` 将会忽略当前目录以及所有子目录下的 `target/` 目录，`bb.txt` 则会忽略当前目录以及所有子目录下名称为 `bb.txt` 的文件

## 文件变化查看 git diff

- 可以使用 `git diff` 命令查看文件具体发生了什么变化
- 注意，`git diff` 本身只显示尚未暂存的改动，而不是自上次提交以来所做的所有改动，因此执行 `git add` 添加到暂存区后，运行 `git diff` 后却什么也没有，就是这个原因
- 如果要查看已暂存的文件的变更内容，可以使用 `--cached/--staged` 参数，例如 `git diff --staged`（Git 1.6.1 及更高版本还允许使用 `git diff --staged`，效果是相同的，但更好记些）
- 测试操作代码：
```bash
vim a.txt # 修改 a.txt 的内容后保存
git status # 查看仓库变化的状态，有哪些文件发生了变化（包括修改、新增和删除）
git diff a.txt # 详细查看 a.txt 发生了什么变化
git add a.txt #将修改后的 a.txt 添加到仓库
git commit -m "修改 a.txt 文件" # 将修改后的 a.txt 提交到仓库
git status # 提交后再次查看哪些文件发生了变化
```

# 版本控制

## 版本回退

- `git log`：可以查看版本变更的历史记录。
- 如果嫌输出信息太多，看得眼花缭乱的，可以试试加上`--pretty=oneline`参数。
- `git log --pretty=oneline`：以较为简洁的形式按时间顺序显示历史版本，包括版本号和提交信息描述。
- Git的版本号为SHA1计算出来的一个非常大的数字，用十六进制表示。
- 每提交一个新版本，实际上Git就会把它们自动串成一条时间线
- 在Git中， **HEAD** 表示当前版本，上一个版本就是 **HEAD^**，上上一个版本就是 **HEAD^^**，往上100个版本就是 **HEAD~100**
- `git reset --hard 版本标识`：进行版本跳转，其中版本号没必要写全，可以只写前几位，Git会自动去找
- `git reset --hard HEAD^`：回退到当前版本的前一个版本
- `git reflog`：查看版本变更记录，可以在回退版本后，重新退回最新的版本

**操作代码**

```bash
git log # 查看提交的历史记录
vim a.txt # 再次修改a.txt文件
git add a.txt # 将修改添加到仓库
git commit -m "再次往a.txt添加内容" # 将修改提交到仓库
git log --pretty=oneline # 以较简洁的形式查看提交历史记录
git reset --hard HEAD^ # 回退到上个版本，相当于将HEAD指针移动到上个版本
git log --pretty=oneline # 查看提交历史记录，和前面的历史记录做对比
git reflog # 查看版本变更历史记录
git reset 2d38757 #撤销上述版本回退，退回原最新版本
git log --pretty=oneline # 查看提交历史记录，检查是否退回最新版本
```

## 工作区和暂存区

- 工作区：就是你在你的电脑里能看到的目录或当前正在进行版本控制的目录。
- 版本库：工作区内部有一个.git隐藏目录，这个不算工作区，而是git的版本库。
- Git的版本库里存了很多东西，其中最重要的就是称为stage（或者叫index）的暂存区，还有Git为我们自动创建的第一个分支master，以及指向master的一个指针叫HEAD。
- 我们把文件往Git版本库里添加的时候，是分两步执行的：
    - 第一步是用git add把文件添加进去，实际上就是把文件修改添加到暂存区。
    - 第二步是用git commit提交更改，实际上就是把暂存区的所有内容提交到当前分支。
- git add命令实际上就是把要提交的所有修改放到暂存区（Stage），然后，执行git commit就可以一次性把暂存区的所有修改提交到分支。


## 管理修改

- Git跟踪并管理的是修改，而非文件。
- 新增了一行，这就是一个修改，删除了一行，也是一个修改，更改了某些字符，也是一个修改，删了一些又加了一些，也是一个修改，甚至创建一个新文件，也算一个修改。
- git commit只负责把暂存区的修改进行提交
- 提交修改还是使用`git add`和`git commit`命令完成的
- `git diff HEAD -- 本地文件`：查看最新版本库中的内容和本地工作区文件内容的区别

**操作代码**
```bash
vim a.txt # 修改a.txt并保存
git diff HEAD -- a.txt # 查看本地和最新版本的内容区别
git add a.txt # 添加到暂存区
git commit -m "添加new" # 提交到本地仓库
```

## 撤销修改

**还未add到暂存区的撤销**

- `git checkout -- 文件名`：如果文件修改还未add到暂存区，可以使用该命令丢弃工作区的修改。
- 注意这里的撤销修改分为两种情况：
    - 一种是文件还没add到暂存区，则直接退回到版本库HEAD的状态
    - 若是add到暂存区，还未commit，又修改了文件，则退回到add到暂存区的那个状态
- 注意，`git checkout -- file`中的`--`很重要，如果没有，就变成了切换到另一个分支的命令，我们在后面的分支管理中会再次遇到`git checkout`命令。
- 注意上述撤回命令要在还未add到暂存区时才有效

**已经add但还未commit的撤销**

- `git reset HEAD <file>`：撤销add到暂存区的文件，退回和HEAD保持一致，该操作不影响工作区的文件。
- 之后，可以进一步采用`git checkout -- 文件名`撤销工作区的修改。

**操作代码**

```bash

# 还未add到暂存区的撤销
git status # 查看文件变化情况，确保nothing to commit
vim a.txt # 修改文件内容
git status # 查看文件变化情况，可以看到a.txt modified
git checkout -- a.txt # 撤销工作区的修改，退回到上次提交版本版本
vim a.txt # 修改本件内容
git add a.txt # add到暂存区
git status # 查看文件变化情况，会显示modified，绿色（由于已经add）
vim a.txt # 再次修改a.txt
git status # 查看文件变化情况，会显示modified，红色（因为还未add到暂存区）
git checkout -- a.txt # 撤销后一次的修改，退回到暂存区中的a.txt版本
cat a.txt # 验证文件内容是否为暂存区中的那个版本

# 已经add但还未commit的撤销
vim a.txt #修改a.txt的内容
git add a.txt # 添加到暂存区
git status # 查看文件变化情况，会显示modified，绿色（由于已经add）
git reset HEAD a.txt # 撤销add到暂存区的操作
git status # 此时查看文件变化情况，也会显示modified，红色（因为还未add）
git checkout -- a.txt # 撤销工作区的修改
```

## 删除文件

- 删除也是一个修改操作，在你删除文件后，Git知道你删除了文件，因此，工作区和版本库就不一致了，git status命令会立刻告诉你哪些文件被删除了。
- 当文件删除后，有下面两种情况：
    - 若是确实需要删除文件，则利用`git rm`（也可以用`git add`），将本次修改（删除文件）添加到暂存区，之后就可以用`git commit`提交到本地仓库，这样就删除了文件。
    - 另一种情况是删错了，因为版本库里还有呢，所以可以使用`git checkout`命令很轻松地把误删的文件恢复到最新版本（可能来自暂存区或者仓库）。
- `git checkout`其实是用版本库或暂存区里的版本替换工作区的版本，无论工作区是修改还是删除，都可以“一键还原”。

```bash

# 删除文件
vim b.txt # 新建文件b.txt
git add b.txt # 添加到暂存区
git commit -m "新建b.txt"
rm b.txt # 删除本地的b.txt
git status # 查看文件变化情况，显示deleted（红色）
git rm b.txt # 添加删除操作到暂存区，也可以用 git add b.txt
git status # 查看文件变化情况，显示deleted（绿色）
git commit -m "删除b.txt" # 确认删除b.txt，提交删除操作到仓库

# 误删除后从仓库恢复文件
vim b.txt # 新建文件b.txt
git add b.txt # 添加到暂存区
git commit -m "新建b.txt" # 提交到仓库
rm b.txt # 模拟误删除本地的 b.txt
git status # 查看文件变化情况
git checkout -- b.txt # 从仓库恢复误删除 b.txt

# 误删除后从暂存区恢复文件
vim b.txt # 修改b.txt的内容
git add b.txt # 添加到暂存区
rm b.txt # 模拟误删除本地的 b.txt
git status # 查看文件变化情况，显示deleted（红色）
git checkout -- b.txt # 由于还未commit，故从暂存区恢复最新的文件
cat b.txt # 打印文件内容，验证其确实为暂存区版本而不是仓库版本
```

# 远程仓库

> [github](https://github.com/)  [码云](https://gitee.com/)

## 配置远程仓库基础

- `ssh-keygen -t rsa -C "Lyinghao@126.com"`，该命令会在当前用户目录下生成`.ssh`文件夹，文件内包含`id_rsa`和`id_rsa.pub`
- 把id_rsa.pub配置到github的SSHKey中，这样本地才能push到远程仓库

## 添加远程仓库

- 进入工作区，执行下述命令，即可将本地已有仓库与远程仓库关联（若是从0开始的项目，应该优先创建远程仓库，然后再clone到本地）：
  - github：`git remote add origin git@github.com:hao77428/Test.git`
  - 码云：`git remote add origin git@gitee.com:hao77428/Test.git`
- 在上述命令中，远程库的名字就是`origin`，这是Git默认的叫法，也可以改成别的，但是origin这个名字一看就知道是远程库。
- `git push -u origin master`：首次push本地的master分支到远程库，添加`-u`参数后Git会将本地的master分支和远程仓库的master分支关联起来，之后push就可以简化命令
- `git push`：把本地库的内容推送到远程，实际上是把当前分支`master`推送到远程。
- 以后提交，只需执行`git push origin master` 甚至 `git push`

**首次合并冲突解决**

一个在本地已经编写了很久的项目，打算托管到云端，但是在云端创建项目时，不小心创建了README.md文件，此时无法直接push，需要先pull下来，并且由于本地的提交记录和云端不同步，直接pull会导致问题，需要为此次pull添加参数，设置允许忽略历史记录不一致问题：
- `git pull origin master --allow-unrelated-histories`
- 之后弹出界面要求天界Merge原因，可填写：首次同步本地仓库到远程仓库而导致的Merge

也可以采用更简便的方式，直接删除云端不小心创建的README.md文件，然后直接关联、push即可，若有需要README.md，可在本地创建并push。

## 从远程库克隆

- 假设我们从零开发，那么最好的方式是先创建远程库，然后，从远程库克隆。
- 首先，登陆GitHub或码云，创建一个新的仓库，名字叫CloneTest
- 进入本地目录（该目录用于存放项目CloneTest），执行`git clone git@gitee.com:hao77428/CloneTest.git`，即可从远程仓库复制到本地（注意用ssh协议而非https协议，否则前面的配置就没有意义）。
- 要克隆一个仓库，首先必须知道仓库的地址，然后使用`git clone`命令克隆
- Git支持多种协议，包括https，但通过ssh支持的原生git协议速度最快。
- 从远程仓库克隆时，实际上Git自动把本地的master分支和远程的master分支对应起来了，并且，远程仓库的默认名称是origin。
- `git remote`：查看远程仓库的名称信息。
- `git remote -v`：查看远程仓库的详细信息。(如果没有推送权限，就看不到push的地址。)

# 分支管理

分支在实际中有什么用呢？假设你准备开发一个新功能，但是需要两周才能完成，第一周你写了50%的代码，如果立刻提交，由于代码还没写完，不完整的代码库会导致别人不能干活了。如果等代码全部写完再一次提交，又存在丢失每天进度的巨大风险。

现在有了分支，就不用怕了。你创建了一个属于你自己的分支，别人看不到，还继续在原来的分支上正常工作，而你在自己的分支上干活，想提交就提交，直到开发完毕后，再一次性合并到原来的分支上，这样，既安全，又不影响别人工作。

## 创建合并分支

- 在版本回退里，你已经知道，每次提交，Git都把它们串成一条时间线，这条时间线就是一个分支。
- 截止到目前，只有一条时间线，在Git里，这个分支叫主分支，即 `master` 分支。
- `HEAD` 严格来说不是指向提交，而是指向 `master`， `master` 才是指向提交的，所以， `HEAD`指向的就是当前分支。若创建一个新分支 `dev` 并切换到该分支，此时 `HEAD` 指向 `dev` 分支。
- Git利用指针管理分支，提交后，指针往前移动一格，要理解这种模型。
- `git checkout -b dev`：创建dev分支并切换到dev分支，相当于以下两条命令：
    - `git branch dev`
    - `git checkout dev`
- `git branch`：查看分支，其会列出所有分支，当前分支前面会标一个*号。
- `git merge`：合并指定分支到当前分支
- `git branch -d dev`：删除dev分支
- clone 时默认只生成 master 分支，可以使用 `git checkout -b dev origin origin/dev` 来根据远程的分支生成本地对应分支

```Bash
git branch # 查看分支，只有master分支，并在当前分支前显示 * 号
git checkout -b dev # 创建并切换到dev分支
git branch # 再次查看分支，此时应有master、dev分支，并且dev分支前显示 * 号
vim c.txt # dev分支下新建文件，保存，表示dev分支已开发完毕
git checkout master # 切换到master分支
git branch # master前显示 * 号
git merge dev # 将dev分支合并到当前分支
git branch # 查看分支，仍然有两个分支
git log --graph --pretty=oneline --abbrev-commit # 查看分支合并情况，ff模式
git branch -d dev # 删除dev分支
git branch # 再次查看分支，只剩下master
git status # 查看工作区状态
git push origin master # 提交到远程仓库
```

## 解决冲突

- 冲突主要有下述两种情况：
    - 一是，工作在不同的分支，且都对某一文件执行了不同的修改，则合并分支时会发生冲突，因为Git不知道该使用哪个分支的版本，此时需要手动解决冲突，**本节讲解这种情况**。
    - 还有一种情况是，多人协作，没有开分支，工作在相同的分支，两人都对某文件做了修改，此时A先提交，提交成功，B要提交时发生冲突，因为远程仓库的版本已经更新了，此时需要先pull下来，在本地合并，解决冲突后，重新push即可。
- `git merge xxx`：将目标分支合并到当前分支，合并时可能发生冲突。
- 发生冲突后，可使用`git status`查看冲突的文件。
- 询问共同编辑该文件的小伙伴，重新编辑冲突文件，解决冲突。
- 重新`git add`和`git commit`新文件，冲突解决。
- `git log --graph --pretty=oneline --abbrev-commit`：查看分支合并的情况。
- 合并分支后，可删除无用分支`git branch -d feature1`

**操作代码**

```bash
git checkout -b dev # 新建并切换到dev分支
vim a.txt # 在dev分支修改a.txt
git add a.txt # 添加到暂存区
git commit -m "在dev分支提交a.txt"
git checkout master # 切换到master分支
vim a.txt # 在master分支修改a.txt
git add a.txt # 添加到暂存区
git commit -m "在master分支提交a.txt"

# 合并分支，由于master和dev都对a.txt做了修改，合并会发生冲突
git merge dev # 将dev分支合并到当前分支，发生冲突
git status # 查看冲突文件，显示a.txt发生冲突
vim a.txt # 编辑a.txt，解决冲突
git add a.txt # 添加到暂存区
git commit -m "解决冲突后提交a.txt" # 解决冲突后提交到仓库
git log --graph --pretty=oneline --abbrev-commit # 查看分支合并情况
git branch -d dev # 删除dev分支
```

## 分支管理策略

- 通常，合并分支时，如果可能，Git会使用`Fast forward`模式，但这种模式下，删除分支后，会丢掉分支信息。
- `git merge --no-ff -m "以no-ff方式合并分支" dev`：以禁用`Fast forward`模式方式合并dev分支到当前分支，则本次合并会当做一次commit，合并后的历史有分支，可以看出曾经做过合并。

**操作代码**

```bash
git checkout -b dev # 新建并切换到dev分支
vim a.txt # 修改a.txt文件
git add a.txt # 添加到暂存区
git commit -m "修改a.txt" # 提交到dev分支
git checkout master # 切换到master分支
git merge --no-ff -m "合并dev分支到master分支" dev # 合并dev分支
git log --graph --pretty=oneline --abbrev-commit # 查看提交历史，可以看出合并操作
```

**分支策略**

- `master` 分支应该是非常稳定的，也就是仅用来发布新版本，平时不能在上面干活。
- 干活都在`dev`分支上，也就是说，`dev`分支是不稳定的，到某个时候，比如1.0版本发布时，再把`dev`分支合并到`master`上，在`master`分支发布1.0版本。
- 你和你的小伙伴们每个人都在`dev`分支上干活，每个人都有自己的分支，时不时地往`dev`分支上合并就可以了。

## Bug分支

软件开发中，bug就像家常便饭一样。有了bug就需要修复，在Git中，由于分支是如此的强大，所以，每个bug都可以通过一个新的临时分支来修复，修复后，合并分支，然后将临时分支删除。

当你接到一个修复一个代号101的bug的任务时，很自然地，你想创建一个分支issue-101来修复它，但是，等等，当前正在dev上进行的工作还没有提交，且只工作到一半，你此时还不想提交，此时可以用`git stash`命令将现场储存起来，修复完bug后恢复现场即可。

注意，经测试，需要将文件add到暂存区后，`git stash`才有效，其相当于备份已经add但还不想commit的代码。 而为add到暂存区的文件，切换分支后再切换回来，其仍然存在，`git status`会显示其已经发生变化。

- `git stash`：可以把当前工作现场“储藏”起来，等以后恢复现场后继续工作。
- `git stash list`：查看有哪些stash备份。
- `git stash pop`：恢复的同时删除stash备份。
- `git stash apply stash@{0}`：恢复但不删除stash备份，需要手动删除。
- `git stash drop stash@{0}`：删除指定的stash

```bash
vim a.txt # 正在dev分支工作，接到要修复bug-101的通知
git add a.txt # 添加到暂存区
git stash # 储存当前工作现场，修复bug后恢复
git checkout master # 切换到master分支
git checkout -b bug-101 # 新建并切换到bug-101分支
vim a.txt # 模拟修复bug操作
git add a.txt # 提交到暂存区
git commit -m "修复bug-101" # 提交到修复bug-101分支
git checkout master # 切换到master分支
git merge --no-ff -m "修复bug-101后，合并分支" bug-101 # 合并bug-101分支
git log --graph --pretty=oneline --abbrev-commit # 查看提交记录
git checkout dev # 切换到dev分支
git status # 查看状态，发现为空
git stash list # 查看有哪些工作现场
git stash pop # 恢复工作现场的同时删除备份中的现场
```

## Feature分支

添加一个新功能时，你肯定不希望因为一些实验性质的代码，把主分支搞乱了，所以，每添加一个新功能，最好新建一个feature分支，在上面开发，完成后，合并，最后，删除该feature分支。

- `git branch -D feature`：强行删除还未merge的feature分支。

**操作代码**

```Bash
# 你接到了一个新任务：开发代号为new的新功能
git checkout -b new # 新建并切换到new分支
vim n.txt # 模拟功能开发
git add n.txt # 提交到暂存区
git commit -m "新功能开发" # 提交到new分支
git checkout master # 切换到master分支
git merge --no-ff -m "合并new分支" new # 合并new分支到master
git log --graph --pretty=oneline --abbrev-commit
```

## 多人协作

多人协作往往涉及到远程仓库，可使用`git remote -v`查看远程仓库详细信息。

**推送分支**

- 推送分支，就是把该分支上的所有本地提交推送到远程库。推送时，要指定本地分支，这样，Git就会把该分支推送到远程库对应的远程分支上：`git push origin master`。
- 如果要推送其他分支，比如dev，就改成：`git push origin dev`。
- 并不是一定要把本地分支往远程推送，那么，哪些分支需要推送，哪些不需要呢?
  - master分支是主分支，因此要时刻与远程同步；
  - dev分支是开发分支，团队所有成员都需要在上面工作，所以也需要与远程同步；
  - bug分支只用于在本地修复bug，就没必要推到远程了，除非老板要看看你每周到底修复了几个bug；
  - feature分支是否推到远程，取决于你是否和你的小伙伴合作在上面开发。

**抓取分支**

- 从远程仓库clone下来时，默认只能看到本地的master分支。
- `git checkout -b dev origin/dev`：从远程仓库获取dev分支到本地。
- `git branch --set-upstream-to=origin/dev dev`：将本地分支和远程分支关联起来，方便push和pull。
- 若不想关联本地分支和远程分支，则执行push和pull时加上具体的参数也可以：
  - `git push origin dev`
  - `git pull origin dev`

```Bash
git clone git@gitee.com:hao77428/Test # 重新找个目录，假设为hao2，克隆到本地，用于模拟多人协作
git branch # 查看分支信息，发现只有master分支
git checkout -b dev origin/dev # 从远程仓库复制dev分支到本地，并切换到dev分支
vim dev.txt # dev分支已经包含dev.txt，修改该文件
git add dev.txt # 添加到暂存区
git commit -m "修改dev.txt - hao2" # 提交到dev分支
git push origin dev # 推送到远程仓库，成功

# 此时回到原来的目录
vim dev.txt # 同样修改 dev.txt
git add dev.txt
git commit -m "修改dev.txt - hao1" # 提交到dev分支
git push origin dev # 推送到远程仓库，发生冲突，因为远程仓库的dev.txt已经发生变化
git branch --set-upstream-to=origin/dev dev # 将远程仓库的dev和本地仓库的dev关联起来
git pull # 已经关联，直接从远程仓库pull下来
vim dev.txt # 修改dev.txt，解决冲突
git add dev.txt # 添加到暂存区
git commit -m "解决冲突"
git push # 重新推送
```

## Rebase

多人在同一个分支上协作时，很容易出现冲突。即使没有冲突，后push的童鞋不得不先pull，在本地合并，然后才能push成功。每次合并再push后，分支多出了分叉，总之看上去很乱。

- `git rebase`：把分叉的提交历史“整理”成一条直线，看上去更直观。缺点是本地的分叉提交已经被修改过了。

# 标签管理

发布一个版本时，我们通常先在版本库中打一个标签（tag），这样，就唯一确定了打标签时刻的版本。将来无论什么时候，取某个标签的版本，就是把那个打标签的时刻的历史版本取出来。所以，标签也是版本库的一个快照。

Git的标签虽然是版本库的快照，但其实它就是指向某个commit的指针（跟分支很像，但是分支可以移动，标签不能移动），所以，创建和删除标签都是瞬间完成的。

## 创建标签

- 在Git中打标签非常简单，首先，切换到需要打标签的分支上，然后，敲命令 `git tag <name>`就可以打一个新标签，如：`git tag v1.0`。
- `git tag`：查看所有标签。
- `git tag v0.9 <commit id>`：为指定版本添加标签。
- 注意，标签不是按时间顺序列出，而是按字母排序的。
- `git show <tagname>` ：查看标签信息。
- 注意：标签总是和某个commit挂钩。如果这个commit既出现在master分支，又出现在dev分支，那么在这两个分支上都可以看到这个标签。
- `git tag -a <tagname> -m "blablabla..."`：指定带有标签信息的标签。

## 操作标签

- `git tag -d v0.1`：删除指定标签。
- `git push origin v1.0`：推送某个标签到远程仓库。
- `git push origin --tags`：推送所有标签到远程仓库.
- 若标签已经推送到远程仓库，要删除远程标签就麻烦一点：
    - `git tag -d v0.9`：先在本地仓库删除。
    - `git push origin :refs/tags/v0.9`：同步删除云端标签。

# 远程仓库

## github

我们可以使用[GitHub](https://github.com/)作为免费的远程仓库，对于github上的开源库，可以Fork到自己仓库，然后就可以clone到本地了。注意一定要从自己的账号下clone仓库，这样你才能推送修改。

修改完开源库的bug后，如果想要某官方库能接受你的修改，你就可以在GitHub上发起一个pull request。当然，对方是否接受你的pull request就不一定了。

在GitHub上，可以任意Fork开源仓库；自己拥有Fork后的仓库的读写权限；可以推送pull request给官方仓库来贡献代码。

## 码云

使用GitHub时，国内的用户经常遇到的问题是访问速度太慢，有时候还会出现无法连接的情况。如果我们希望体验Git飞一般的速度，可以使用国内的Git托管服务——[码云](https://gitee.com/)。

- 在本地仓库使用`git remote add origin git@gitee.com:hao77428/Test.git`将本地仓库和远程仓库关联。
- 可以添加多个远程仓库


# 其他

- 修改 .gitignore 无效问题，需要先清空缓存
```bash
git rm -r --cached .
```


- 提交脚本
```bash
#!/bin/bash

if [ $# != 1 ] ; then 
   echo "wrong params, string contains blank should begin and end with quote"
   exit 1;  
fi

msg=$1

echo "commit and push master to remote with message : $msg"
git add .
git commit -m "$msg"

git push origin master
git push pri master
```



# 参考文献

- [廖雪峰Git教程](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
- [Pro Git 中文版（第二版）](https://www.progit.cn/)