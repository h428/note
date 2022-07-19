


# 3. LaTex 基础

## 3.1 第一份文稿

```latex
\documentclass{ctexart}
\begin{document}
	Hello, world!
	你好，世界！
\end{document}
```

## 3.2 认识 LaTex

### 3.2.1 命令与环境

**命令**

- 举例： `\documentclass[a4paper]{ctexart}`
- 命令由反斜杠+名称+可选参数+必选参数组成，也可能不带参数，如 `\TeX`
- 如果有可选参数，使用方括号对指明，比如 `\documentclass[a4paper]{ctexart}`


**环境**

- 环境用于控制 `\begin{environment}` 和 `\end{environment}` 之间的内容
- 举例：
```latex
\begin{document}
    内容
\end{document}
```
- 若有可选参数，写在 `\begin[...]{name}` 的方括号中即可
- 不带花括号的命令后⾯如果想打印空格，请加上⼀对内部为空的花括号再键⼊空格，否则空格会被忽略，例如：`\LaTeX{} Studio.`

### 3.2.2 保留字符

- \# ：井号，自定义命令时，用于标明参数序号
- $ ：美元符号，数学环境
- % ：百分号，注释符
- ^ ：异或符号，数学环境中上标
- & ：与符号，表格环境中的列分隔
- _ ：下划线符号，数学环境中的下标
- {} ：花括号，用于标记命令的必选参数，或者标记某一部分命令称为一个整体
- \ ：反斜杠，用于开始各种 LaTex 命令
- 对于上述符号，可在前添加一个反斜杠进行转义，输出对应符号，如 \\# 输出 #
- 输出反斜杠的三种方式：`$\backslash$`, `\textbackslash`, `\texttt{\char92}` 
- \char[num] 或 \char\`+字符输出指定字符，但是要在 \texttt 或 \ttfamily 环境内
- 波浪线符号：
```latex
a $\sim$ b
a\~ b
a\~{} b
a\textasciitilde b
```

### 3.2.3 导言区

- 导言区一般声明一些通用的设置，可以简单地理解为模板定义
- 文档类 documentclass 默认有如下参数：
	- article ：科学期刊，演示文稿，短报告，邀请函
	- proc ：基于 article 的会议论文集
	- report ：多章节的长报告、博士论文、短篇书
	- book ：书籍
	- slides ：幻灯片
	- 此外还有 beamer 宏包定义的 beamer 文档类
	- ctex 宏包定义的各个类
- 上述类一般都包含有这些常见的选项：
	- 字体 ： 默认 10pt，可选 11pt 和 12pt
	- 页面方向 ： 默认竖向 portrait，可选横向 landscape
	- 分栏：默认 onecolumn，还有 twocolumn
	- 章节分页：有 openright/openany 选项，决定在奇数页开启或是任意页开启，注意 article 无 chaper 命令，即默认任意页
	- 公式对齐：默认居中，可改为左对齐 fleqn，默认编号居右，可改为左对齐 leqno
	- 草稿选项：默认 final，可改为 draft 使行溢出的部分显示为黑块
- 导言区最常见的工作是加载宏包，命令形如 `\usepackage{package}`，如显示文本代码的 listing 宏包
- 在命令行输入 `texdoc 宏包名` 查看文档，如 `texdoc xeCJK`

### 3.2.4 错误的排查

- 编译可能出现如下错误：
	- Errors ：严重的错误，编译通过该项一般是零
	- Warnings ： 一些不影响文档生成的瑕疵
	- Bad Boxes 坏箱：排版中出现长度问题，如长度超出等，后面的 Badness 表示错误的严重程度
- 对于大文件，要学会拆分文件，参见 3.13
- 可以使用宏包 syntonly，在导言区加入 \syntaxonly 命令，可以值排查语法错误而不生成任何文档，这样可以更快地编译，但似乎不太稳定，有时可能会报错

### 3.2.5 文件输出

- LaTex 的输出一般推荐为 pdf 格式
- 有时编译出错，可以删除除 tex 外的所有文件，重新编译

## 3.3 标点与强调

- 英文符号 `| < > + = ` 一般用于数学环境中，若在文本中使用，需要在两侧加上 $ 
- 文本中直接使用输入大于号、小于号不会被打印，应该使用 `\textgreater`, `\textless` 或 `$> <$`
- 科技文章中，中文句号一般用全角的 ．而不是英文的 . 和中文的 。，可以使用 。最后统一替换

### 3.3.1 引号 

- 引号不使用两个 ' 组合，左引号 \` , 右引号 '
- 嵌套引号借助 `\thinspace` 命令分割
- 也可以使用 `\,` 进行分割， `\,` 产生一个很小的间距
- 中文引号可以直接使用中文输入法

### 3.3.2 破折、省略号与短横

- 英文的短横包括三种：
	- 连字符：输入一个短横 `-`
	- 数字连字符：两个短横 `--`
	- 破折号：输入三个短横 `---`
- 中文破折号使用输入法直接输入，省略号同理
- 英文省略号使用命令 `\ldots`，注意不是三个点

### 3.3.3 强调

- `\emph{内容}` 进行强调，对于西文来说就是斜体，而对于斜体使用该命令就称为正文

### 3.3.4 下划线与删除线

- 原生提供的 `\underline` 命令可以用于加下划线，但效果不好
- 可以使用 `ulem` 宏包下的各个命令：
```latex
\uline{下划线}
\uuline{双下划线}
\dashuline{虚下划线}
\dotuline{点下划线}
\uwave{波浪线}
\sout{删除线}
\xout{斜删除线}
```
- 要注意的是 ulem 宏包重定义了 `\emph` 命令为下划线，两个 `\emph` 变为双下划线，可以通过设置宏包的 normalem 选项可以取消该更改： `\usepackage[normalem]{ulem}`

### 3.3.5 其他

- 角度符号或者温度符号需要借助数学模式输入
	- `$30\,^{\circ}$`，其中 `\,` 产生很小的间距
	- `$37\,^{\circ}\mathrm{C}$`
- 欧元符可能需要用到 textcomp 宏包下的 `\texteuro` 命令
- 千分位分隔符：`1\,000\,000` 或 `\mbox{1\,000\,000}`
- hologo 宏包还提供了 TeX 家族的标志，如 `\hologo{XeLaTeX}`


## 3.4 格式控制

- LaTeX 长度单位：pt, pc, in, bp, cm, mm, sp, em, ex
- `\textwidth` 页面上的文字宽度，即页宽减去两侧边距
- `\linewidth` 当前行允许的行宽
- 有时还会用可变长度，比如 `5pt plus 3pt minus 2pt`
- 支持直接使用倍数， `1.5\parindent`
- 经常还使用 `\hspace{len}` 和 `\vspace{len}` 产生空白，如 `\hspace{1.5\parindent}`

### 3.4.1 空格、换行与分段

- 多个空格被视为一个，多个换行也被视为一个
- 使用符号 `~` 禁止某个空格处的换行，如 `Fig.~8`
- 两个换行完成分段
- 可以利用 `\mbox{}` 配合换行产生空白段落
- 也可使用 `\par` 产生一个带缩紧的段落
- 也可以使用 `\\` 强制换行，但下一行的段首缩进会消失，当然可以使用 `\indent` 产生缩进长度的空白
- 正文中换行，请直接使用两个回车
- 段落之间的距离由 `\parskip` 控制，默认 0pt plus 1pt，可设置 `\setlength{\parskip}{0pt}`
- 宏包 lettrine 能产生首字下沉的效果

### 3.4.2 分页

- `\newpage` 开始新的一页
- `\clearpage` 清除浮动体队列并开始新的一页
- `\cleardoublepage` 清除浮动体队列，并在偶数页开始新的一页
- 以上命令都是基于 `\vfill` 的，若要连续新开两页，请在中间加上一个空箱子 `\mbox{}`，如 `\newpage\mbox{}\newpage`

### 3.4.3 缩进、对齐与行距

- 英文段首不需要缩进，中文段首缩进借助 indentfirst 宏包完成
- 可能还需设置距离：`\setlength\parindent{2em}`
- 使用 `\noindent` 强制取消段首的缩进
- LaTeX 默认使用两端对齐的方式，可以使用 flushleft, flushright, center 这三种环境来构造居左、居中、居右的效果
- `\centering` 常常用于环境内部或花括号内部实现居中效果
- 类似的可以使用 `\raggedleft`、`\raggedright` 实现居左和居右


## 3.5 字体与颜色

### 3.5.1 字体族、字系和字形

- 字体包含有字体族、字系和字形的概念
- 宋体、黑体这种属于字体族
- 加粗、斜体这种属于字系、字形
- 五号、四号这种属于字号
- 上述共同构成字体

### 3.5.2 中西文斜体

- 汉字无斜体，平时看到的斜体汉字，通常是几何变换后的效果，非常粗糙，并不严格满足排版要求，而真正的字形是需要精心设计的，类似的，汉字也基本无粗体
- 西文一般有加斜，指的的 Italic，而斜体，指的是 Slant，表示强调的是 Italic， Word 中的斜体也采用 Italic （Slant 体现为倾斜，而 Italic 更像是手写斜体）

### 3.5.3 原生字体命令

- LaTeX 提供下列常用字体命令：
	- `\rmfamily`  Roman 字体族
	- `\sffamily`  Sans Serif ⽆衬线字族
	- `\ttfamily`  Typewriter 等宽字族
	- `\bfseries`  粗体字系
	- `\mdseries`  中粗字系
	- `\upshape`  数值 Upright 字形
	- `\slshape`  斜体 Slant 字形
	- `\itshape`  强调体 Italic 字形
	- `\scshape`  小号大写字体 SCAP 字形
- 还有与之对应临时改变字体的 text 系列命令，`\textit{...}`, `\textbf{...}` 等
- 若在文中多次使用某字体，可以为其重定义命令，此时尽量采用 text 系列命令： `\newcommand{\concept}[1]{\textbf{#1}}` 和 `\newcommand{\concept}[1]{{\bfseries #1}}` 是等价的
- 行文有一个标准字号，LaTex 提供了一些命令用于设置字号，如 `\tiny`, `\huge`, `\small` 等
- 还可以使用 ctex 宏包提供的 `\zihao{}` 命令设置字号
- 日常使用的小四为 12pt, 五号为 10.5pt
- 若想设置特殊字号，使用：`\fontsize{font-size}{line-weight}{\selectfont <text>}`，font-size 填数字，单位为 pt，line-height 一般填 `\baselineskip`
- 默认全文使用 `\rmfamily` 族的字体，可以利用重定义的方式更改，是的 `\rmfamily`, `\textrm`命令都指向新的字体
```latex
\renewcommand{\rmdefault}{font-name}
% 默认字体改为 sf 字体族，也可以使用 \ttdefault
\renewcommand{\familydefault}{\sfdefault}
\renewcommand{\sfdefault}{font-name}
% 若排版 CJK 文档，还需要更改 CJK的默认字体
\renewcommand{\CJKfamilydefault}{\CJKsfdefault}
```

### 3.5.4 西文字体

- 预包含的字体名：cmr, lmr, pbk, ppl, lmss, phv, lmtt
- 使用样例：
```latex
\newcommand{\myfont}[2]{{\fontfamily{#1}\selectfont #2}}
\renewcommand{\rmdefault}{ptm} % 更改默认字体，同样可更改 sfdefault 等
```
- 基于 XeLaTeX 时，可以使用 fontspec 宏包来选择本地安装的字体，但可能会增加编译时间：
```latex
\usepackage{fontspec}
\newfontfamily{\lucida}{Lucida Calligraphy}
...
\lucida{Hello}
```
- 该宏包的 `\setmathrm/sf/tt` 与 `\setboldmathrm` 命令可用于更改数学环境中的字体
- 可以简单地加载 txtfont 宏包，设置西文字体为 Roman 体，同时设置好数学字体
- 其他简单字体宏包还有 cmbright, pxfonts 

### 3.5.5 中文支持

- ctex 宏包直接定义了新的中文文档类：ctexart, ctexrep, ctexbook 以及 ctexbeamer 幻灯片文档类
- 这些类继承了原生的类的参数，保留了原生文档类的特征
- ctex 文档类使用 \CTEX 开头的计数器命令替代原有的，除非使用 `schema=plain` 让 ctex 文档类进支持中文而不做任何文档细节修改
- ctex 预定义了下述字体：
	- `\songti`  宋体
	- `\heiti`  黑体
	- `\fangsong`  仿宋
	- `\kaishu`  楷书
	- `\yahei`  雅黑
	- `\lishu`  隶书（仅Win）
	- `\youyuan`  幼圆（仅Win）
- 在使用 XeLaTeX 时，若使用 ctex 文档类，其会在底层调用 xeCJK 宏包，所以无需显式加载它
- xeCJK 设置和使用查看文档
- 想要知道电脑上安装的中文字体，对于 Win，可以执行 `fc-list :lang=zh-cn > c:\list.txt`


### 3.5.6 颜色

- 使用 xcolor 宏包来方便地调用颜色
- 使用样例：
```latex
\usepackage{xcolor}  % 引入宏包
\definecolor{keywordcolor}{RGB}{34,34,250}  % 设置颜色
{\color{keywordcolor}{Nice to meet you.}}  % 使用颜色
```
- xcolor 预定了许多包括 black, darkgray 等常用颜色，详细可查阅文档
- 还可以通过调色做出新的效果：
```latex
{\color{red!70}{百分之70红色}}
{\color{blue!50!black!20!white}{50蓝20黑30白}}
{\color{-yellow}{黄色的互补色}}
```

## 3.6 引用与注释

### 3.6.1 标签和引用

- 使用 `\label` 插入标签，然后在其他地方用 `\ref` 或 `\pageref` 命令进行引用，分别引用标签的序号、标签所在页的页码
```latex
\label{sec:this}
\ref{sec:this}
\pageref{sec:this}
```
- amsmath 宏包提供了 `\eqref` 命令，默认效果如 (3.1) ，实质上是调用了原生的 `\ref` 命令
- 更常用的是 hyperref 宏包，由于其经常和其他宏包冲突，一般放在导言区最后
```latex
\usepackage[colorlinks, bookmarksopen=true, bookmarksnumbered=true]{hyperref}
```
- 宏包选项也可以另起一行，用 `\hypersetup` 设置，参数可查看文档
- 加载 hyperref 后，还可以使用其他超链接命令：
```latex
% 文档内跳转
\hyperref[label-name]{print-text}
\autoref{label-name} % 自动识别label上方的命令
% 链接网站
\href{URL}{print-text}
\url{URL} %彩色可点击
\nolinkurl{URL} % 黑色可点击
```
- 其中 `\autoref` 会检查 `\label` 引用的计数器，再检查其 autref 宏是否存在，比如对图表检查是否有 `\figureautorefname` 这个宏，若有则引用
- 正常的 `\ref` 命令只会引用 `\figurename`
- 可以重定义 `\figureautorefname` ，就能使用 图 3.1 替代 Figure 3.1 ：`\renewcommand\figureautorefname{图}`
- nameref 宏包提供了引⽤对象的标题内容的功能，`\nameref` 命令可以利⽤位于标题下⽅的标签来引⽤标题内容
- 关于⻚码引⽤，如果想要⽣成“第 × ⻚，共 × ⻚”的效果，可能需要借
助 lastpage 宏包，它提供的标签 LastPage 可以保证在输出⻚⾯的最后（如果你⾃⾏添加标签，可能还会有后续浮动体），因此可以 `This is page \thepage\ of \pageref{LastPage}`

### 3.6.2 脚注、边注与尾注

- `\footnote`
- `\footnotemark`
- `\footnotetext`
- footmisc 宏包
- `\marginpar`
- geometry 宏包
- endnotes 宏包

### 3.6.3 援引环境

- quote 环境
- quotation 环境
- verse 环境

### 3.6.4 摘要

- 在 `\maketitle` 后使用的 abstract 环境，单栏模式下相当于一个带标题的 quotation 环境
- 标题可以通过重定义 `\abstractname` 更改
- 双栏下相当于 `\section*` 命令定义的一节

### 3.6.5 参考文献

- 参考文献主要的命令时 `\cite`，与 `\label` 类似
- 可以通过 natbib 宏包定制文献标号在文中的格式
- 要将参考文献编号并添加到目录中，使用 tocbibind 宏包
- 重命名参考文献在目录中的标题，使用 `\tocbibname`
- tocbibind 可以将索引、目录本身、图表、参考文献等编入目录

### 3.7 正式排版：封面、大纲与目录

### 3.7.1 封面

- 封面的内容在导言区进行定义，一般写在所有宏包、自定义命令之后：
```latex
\title{标题}
\author{作者}
\date{2018年09月01日}
```
- 日期若省略参数，则以当前日期为准
- 标题页的脚注用 `\thanks` 命令完成

### 3.7.2 大纲与章节

- `\par` 部分，不会打断 chaper 编号
- `\chapter` 章， article 不含该级别
- `\section` 节
- `\subsection` 次节， report/book 不会对本级别以及以下的大纲进行编号，也不纳入目录
- `\subsubsection` 小节，article 不会对本级别以及以下的大纲进行编号，也不纳入目录
- 每个标签有自己对应的编号深度，并可以设置编号深和纳入目录
- book 文档类还提供了前言、正文、后记、附录等

### 3.7.3 目录

- 使用 `\tableofcontents` 插入目录
- 在加载了 hyperref 宏包后，可以实现点击跳转功能
- 可以重定义命令更改 `\contentsname` 即目录的标题名 `\renewcommand{\contensname}{目录}`
- 可以插入图表目录，和更改标题 `\listoffigures, \listoftables, \listfigurename, \listtablename`
- 设置目录显示的大纲深度 `\setcounter{tocdepth}{2} % 这是到subsection`
- 目录本身编入目录，使用 tocbibind 宏包
- 目录的高级自定义借助 titletoc 宏包

## 3.8 计数器与列表

### 3.8.1 计数器

- LaTeX 的自动编号都借助于内部的计数器来完成，包括 chaper, section, subsection 等
- 使用 `\the + 计数器名称` 可以直接调用对应的计数器编号
- 若想指定格式，可借助重定义命令实现，如:
```latex
\renewcommand{\thesection}{\chinese{section}}
\renewcommand{\thesubsection}{\Alph{section}-\arabic{subsection}}
```
- 常用更改形式包括：阿拉伯数字 `\arabic`, 大写字母 `\Alph`, 小写字母 `\alph`, 罗马数字 `\Roman`, 小写罗马数字 `\roman`
- 可以对章、节的编号在子环境中进行重定义，这样只更改该环境中的编号,比如列表中
- 计数器相关设置命令：
```latex
% 父级计数器变化，则子级计数器重新开始计数
\newcounter{counter-name}[parent counter-name]
\setcounter{counter-name}{number}
\addtocounter{counter-name}{number}
% 计数器步进1，并归零所有子级计数器
\stepcounter{counter-name}
```

### 3.8.2 列表

- LaTeX 预定义了三种列表：无序列表 itemize, 有序列表 enumerate, 描述列表 description

**itemize环境**

- 例子：
```latex
\begin{itemize}
	\item This is the 1st.
	\item[-] And this is the 2nd. 
\end{itemize}
```
- 使用 `\item` 定义列表项，方括号可选参数设置列表项符号
- 默认符号是圆点 `\textbullet`，自定义可参考 5.7

**enumerate环境**

- 例子：
```latex
\begin{enumerate}
	\item First
	\item[Foo] Second
	\item Thrid  % 输出编号变为 2
\end{enumerate}
```
- 方括号的使用会打断编号，之后会顺序后移
- 更多自定义内容参考 5.7 

**description环境**

- 例子：
```latex
\begin{description}
	\item[LaTeX] Typesetting System
	\item[wkl] a man
\end{description}
```
- 默认方括号内的内容会以加粗显示，更多的方法参考

## 3.9 浮动体与图表

### 3.9.1 浮动体

- 浮动体将图或表与其标题定义为整体，然后动态排版，以解决图表排版问题
- 图片的浮动体是 figure 环境，而表格的浮动体是 table 环境
```latex
\begin{table}{!htb}
	\centering
	\caption{table-cap}
	\label{tb:name}
	\begin{tabular}{...}
		content...
	\end{tabular}
\end{table}
```
- htp 表示浮动体位置，分别表示 here, top, bottom
- ! 表示忽略内部参数，比如内部参数对一页浮动体数量的限制
- 此外还有参数 p, 表示允许浮动体单独开一页
- `\caption` 给表格一个标题，注意 `\label` 要放在 `\caption` 下方，否则可能出现问题
- 浮动体的自调整属性可能导致它一直找不到合适的插入位置，然后多喝浮动体形成排队，因为靠前的浮动体插入后，靠后的才能插入
- 如果再生成的文档中发现浮动体丢失，请尝试更改浮动体参数、去掉部分浮动体，或者使用 `\clearpage` 来清空浮动体队列
- 如果希望浮动体不要跨过 section，使用 `\usepackage[section]{placeins}`
- 其实质是重定义了 `\section` 命令，在之前加上了 `\FloatBarrier`

### 3.9.2 图片

- 图片的插入使用 graphicx 宏包和 `\includegraphics` 命令
```latex
\begin{center}
	\includegraphics[width=\linewidth]{t.jpg}
\end{center}
```
- width 指定宽度，height 指定高度，scale 指定缩放系数
- angle 指定逆时针旋转角度，origin 指定图片旋转中心，可以取得值有 lrctbB，分别表示左右中顶底基线
- 图文混排可以利用 wrapfig 宏包
```latex
% \usepackage{wrapfig}
\begin{wrapfigure}[linenum]{place}[overhang]{picwidth}
\includegraphics...
\caption...
\end{wrapfigure}
```
- linenum 是可选参数，表示图片所占行数，一般不指定
- place 表示图片在文字段中的位置，RLIO分别代表右、左、近书脊、远书脊
- overhang 为可选参数，表示允许图片超出页面文本区的宽度，默认是 0pt，在该项可以使用 `\width` 代替图片的宽度，填入 `\width` 将允许图片全部放入页面边距
- picwidth 指定图片的宽度，默认情况下图片的高度会自动调整

### 3.9.3 表格

- LaTeX 原生的表格功能非常有限，甚至不支持单元格跨行和表格跨页，但是可以通过 longtable, supertabular, tabu 等宏包解决
- 跨行的问题只需要 multirow 宏包
- 下面是一个表格例子：
```latex
\begin{center}
	\begin{tabular}[c]{|l|c||p{3em}<{\centering}|r|} % 
		\hline \hline
		A & B & C & d \\
		D & E & F & g\\
		\cline{1-2} 
		\multicolumn{2}{|c|}{G} & H & i \\
		\hline
	\end{tabular}
\end{center}
```
- 可选参数 c 表示对齐方式，tbc 分别表示顶端、底端和中心对齐
- 必选参数设置列格式，竖线 | 表示表格的分割线，双竖线可表示双竖线分割线，最右边可不用竖线，而用 `@{-}` 表示一个横线
- 必选参数 l,c,r 分别表示左对齐，居中对齐和右对齐，p{3em} 则用于指定宽度
- `\cline{1-2}` 用于绘制部分的横线而不是一整行，`\hline` 为一整行横线
- `\multicolumn{2}{|c|}{G}` 实现类似合并单元格功能，可跨多列
- 基于 array 宏包，除了标准参数外，还支持 m{}, b{} ，此外还可以使用 `>{decl}`, `<{decl}` 分别用在参数前后，表示在该列的每个单元格都以 decl 开头或结尾，如：
```latex
\begin{tabular}{|>{\centering\ttfamily}p{5em}
|>{$}c<{$}|}
...
\end{tabular}
```
- 除 lcrpmb 外，还可以自定义列环境，如：`\newcolumntype{T}{>{$}c<{$}}`

**array, multirow**

- array 宏包例子：
```latex
\begin{tabular}{|>{\setlength\parindent{5mm}}m{1cm}|
		>{\large\bfseries}m{1.5cm}|
		>{$}c<{$}|}
	\hline A & 2 2 2 2 2 2 & C \\
	\hline 1 1 1 1 1 1 & 10 & \sin x \\ \hline
\end{tabular}
```
- 同时跨行跨列必须把 multirow 命令放在 multicolumn 内部
```latex
% 记得\usepackage{array}
\begin{tabular}{|>{\setlength
\parindent{5mm}}m{1cm}|
>{\large\bfseries}m{1.5cm}|
>{$}c<{$}|}
\hline A & 2 2 2 2 2 2 & C\\
\hline 1 1 1 1 1 1 & 10 &
\sin x \\ \hline
\end{tabular}
```
- 表格还可以嵌套，以方便地拆分单元格
```latex
\begin{tabular}{|c|l|c|}
	\hline
	a & bbb & c \\ \hline
	a & \multicolumn{1}{@{}l@{}|}{\begin{tabular}{c|c}
			a & b \\ \hline
			aa & bb \\
	\end{tabular}}
	& c \\ \hline
	a & b & c \\ \hline
\end{tabular}
```

**makecell宏包**

- makecell 宏包提供了一种方便在单元格内换行的方式，并可以配合参数 tblrc，带星表示有更大的竖直空距
- `\multirowcell` 由 multirow 宏包与该宏包共同支持，命令 `\thead` 则有更小的字号，通常用于表头
```latex
\begin{tabular}{|c|c|}
	\hline
	\thead{双行\\表头} & \thead{双行\\表头} \\ \hline
	\multirowcell{2}{简单\\粗暴} & \makecell[1]{ABCD\\EF} \\
	\cline{2-2} & 
	\makecell*{更大的竖直空距} \\ \hline
\end{tabular}
```
- 该宏包还提供了 `\Xhline` 和 `\Xcline` 命令，可以指定横线的线宽，例如模仿三线表

**diagbox宏包**

- 该宏包提供了分割表头的命令 `\diagbox`
```latex
\begin{tabular}{c|cc}
	\diagbox{左边}{中间}{右边} & A & B \\ \hline
	1 & A1 & B1 \\
	2 & A2 & B2
\end{tabular}
```

**其他**

- `\tancolsep` 或 `\arraycolsep` 控制列与列之间的间距，取决于你用 tabular 还是 array 环境，默认 6pt
- 列格式 @ 能取出列间的空距，比如 `@{}`，而 `\extracolsep{1pt}`放在 @ 参数这种，可以将右侧的列间隔都增加 1pt
- 表格内行距用 `\arraystretch` 控制，默认为 1
- `|*{7}{c|}r|` 相当于 7 个居中和一个居右
- tabularx 宏包提供的 `\begin{tabular*}{width}[pos][cols]`，可以把 width 取值为 `\0.8\linewidth`
- 单元格内换行，可以使用 makecell 宏包支持的 `\makecell` 命令
- 宏包 dcolumn 提供了新的列对齐方式 D，并调用 array 宏包
```latex
% 表示输入小数点、显示为小数点、保留2位
\newcolumntype{d}{D{.}{.}{2}}
```

### 3.9.4 非浮动体图表和并排图表

## 3.19 页面设置

### 3.10.1 纸张、方向和边距

- 主要借助 geometry 宏包

### 3.10.2 页眉和页脚

## 3.11 抄录与代码环境

- `\verb(*)` 或 `\verbatim(*)`，后者会将空格以特殊形式标注出来
- verbatim 宏包提供了更多的抄录支持，fancyvrb 宏包提供了 `\SaveVerb` 和 `\UseVerb` 命令
- 宏包 shortverb 支持以一对符号代替 `\verb` 命令

## 3.12 分栏

## 3.13 文档拆分

- 文档拆分只要把多个 tex 文件放在一起，然后在主文件中用 `\input{filename.tex}` 或者 `\include{filename}` 命令，区别在于 `\include` 会插入 `\clearpage` 再读取文件
- 可以把导言区做成一个文件，然后在不同的 LaTeX 文件中反复使用

## 3.14 西文排版及其他

# 5. LaTeX 进阶

## 5.1 自定义命令与环境

- 自定义命令 `\newcommand{cmd}[args][default]{def}`
- 举例：
```latex
\newcommand{\concept}[1]{\textbf{#1}} % 自定义命令，一个参数
\newcommand{\cop}[2][defaut value]{\textbf{#1}, \textit{#2}} % 自定义命令，两个参数，第一个参数支持默认值

\concept{abcdef}
\cop[abc]{abcd}
\cop{abcd}
```
- 如果想定义⼀个⽤于数学环境的命令，借助 `\ensuremath` 命令，它保证其参数会在数学模式下运转，且即使已位于数学模式中也不会报错 `\renewcommand\qedsymbol{\ensuremath{\Box}}`
- 自定义环境使用 `\newenvironment` 命令，可以定义多个参数，注意后段参数中不能使用参数，但可以在前段定义，后段使用：
```latex
\newenvironment{QuoteEnv}[2][]
{\newcommand\Qauthor{#1}\newcommand\Qref{#2}}  % 前半部分定义命令
{\medskip\begin{flushright}\small ——~\Qauthor\\  % 后半部分使用命令
\emph{\Qref}\end{flushright}}
```

## 5.2 箱子：排版的基础

- LaTeX 排版的基础单位就是 box，例如整个页面就是一个矩形 box，侧边栏、主正文区、页眉页脚也都是 box


### 5.2.1 无框箱子

- 命令 `\mbox` 产⽣⼀个⽆框的箱⼦，宽度⾃适应。有时⽤它来强制“结合”⼀系列命令，使之不在中间断⾏
- 比如，TeX 的定义：`\mbox{T\hspace{-0.1667em}\raisebox{-0.5ex}{E}\hspace{-0.125em}X}`
- 也可以使用 `\makebox[width][pos]{text}`，但宽度由 width 参数指定，pos 参数的取值可以是 l, s, r 即居左、两端对⻬、居右，还有竖直⽅向的 t, b 两个参数
- ⽆框小⻚的使⽤⽅法是 minipage 环境，参数类似 `\parbox` : `\begin{minipage}[pos]{width}`

### 5.2.2 加框箱子

- 命令 `\fbox` 产⽣加框的箱⼦，宽度⾃动调整，但不能跨⾏
- 命令 `\framebox` 类似上⾯介绍的 `\makebox`
- 如果是想在数学环境下完成加框，使⽤ `\boxed` 命令
- width 参数中，可以⽤ `\width`, `\height`, `\depth`, `\totalheight`分别表⽰箱⼦的⾃然宽度、⾃然⾼度、⾃然深度和⾃然⾼深度之和
```
\fbox{This is a frame box} \\
\framebox[2\width]{double-width}\\
\begin{equation}\boxed{x^2=4}
\end{equation}
```
- 加宽盒⼦的宽度、以及内容到盒⼦的距离可以⾃⾏定义，默认定义是：`\setlength{\fboxrule}{0.4pt} \setlength{\fboxsep}{3pt}`
- 加框小⻚使⽤boxedminipage环境 (需要 boxedminipage 宏包)

### 5.2.3 竖直升降的箱子

- 命令 `\raisebox` 可以把⽂字提升或降低，它有两个参数：`A\raisebox{-0.5ex}{n} example.`

### 5.2.4 段落箱子

- 段落箱⼦的强⼤之处在于它提供⾃动换⾏的功能，当然你需要指定宽度，`\parbox[pos]{width}{text}`
```latex
This is \parbox[t]{3.5em}{an long
example to show} how \parbox[b]
{4em}{parbox' works perfectly.
```

### 5.2.5 缩放箱⼦

- 宏包 graphicx 提供了⼀种可缩放的箱⼦`\scalebox{h-sc}[v-sc]{pbj}`，注意其中⽔平缩放因⼦是必要参数。缩放内容可以是⽂字也可以是图⽚，例⼦
```latex
\LaTeX---\scalebox{-1}[1]{\LaTeX}\\
\LaTeX---\scalebox{1}[-1]{\LaTeX}\\
\LaTeX---\scalebox{-1}{\LaTeX}\\
\LaTeX---\scalebox{2}[1]{\LaTeX}
```
- 此外还有 `\resizebox{width}{heigh}{text}` 命令

### 5.2.6 标尺箱⼦



