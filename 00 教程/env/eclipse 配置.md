
#### eclipse.ini文件介绍

- openFile是打开文件时需要的内存大小参数：256偏小，可调成512
- org.eclipse.platform是Eclipse运行所需内存参数：256偏小，可调成512
- -Xms2048m 初始总堆内存，一般将它设置的和最大堆内存一样大，这样就不需要根据当前堆使用情况而调整堆的大小了
- -Xmx2048m 最大总堆内存，一般设置为物理内存的1/4
- -Xmn768m  年轻带堆内存，sun官方推荐为整个堆的3/8
- -XX:PermSize=256m   持久带堆的初始大小
- -XX:MaxPermSize=256m 持久带堆的最大大小，eclipse默认为256m。如果要编译jdk这种，一定要把这
- -XX:+UseParallelGC 使用并发内存回收，如果你有一个双核的CPU，可以尝试这个参数，让GC可以更快的执行
- -XX:+DisableExplicitGC 禁用System.gc()的显示内存回收
- 堆内存的组成：总堆内存 = 年轻带堆内存 + 年老带堆内存 + 持久带堆内存
    - 年轻带堆内存	对象刚创建出来时放在这里
    	 年老带堆内存	对象在被真正会回收之前会先放在这里
    	 持久带堆内存	class文件，元数据等放在这里个设的很大，因为它的类太多了 
---

#### 大内存参数配置参考


```
-clean //-clean不一定要加
-startup
plugins/org.eclipse.equinox.launcher_1.3.0.v20130327-1440.jar
--launcher.library
plugins/org.eclipse.equinox.launcher.win32.win32.x86_64_1.1.200.v20140116-2212
-product
org.eclipse.epp.package.jee.product
--launcher.defaultAction
openFile
--launcher.XXMaxPermSize
512M
-showsplash
org.eclipse.platform
--launcher.XXMaxPermSize
512m
--launcher.defaultAction
openFile
-vm
D:\All\jdk\jdk1.7.0_80\jre\bin\server\jvm.dll

-vmargs
-Dosgi.requiredJavaVersion=1.6
-Xms2048m
-Xmx2048m
-Xmn1024m
-XX:PermSize=1024M
-XX:MaxPermSize=1024M
-XX:+UseParallelGC
-XX:+DisableExplicitGC
-Xverify:none
```
---

#### eclipse其他优化设置（新工作空间要调整）


1. 关闭不必要的启动项
    - General/Startup and Shutdown
2. 关闭HTML、JS校验
    - Validation
3. 关闭拼写检查
    - General/Editors/Text Editors/Spelling
4. 关闭自动编译
    - 按需设置
5. 关闭自动更新
    - install/update -> automatic updates
6. 复制文件卡死：
    - Eclipse左侧的Project Explorer的右边一个按钮钮,鼠标移上去会提示”View Menu”点击
    - 选择Customize View勾选掉Java EE Navigator Content WEB最后重启下eclipse。
	- 一般将 Java EE Navigator Content WEB 勾掉，然后重启下eclipse：

---

#### 常用设置（新看、工作空间的调整）


1. 设置UTF-8编码
    - window -> preferences -> General -> workplace

2. 配置Maven环境
	- Windows - General - Maven
	- 调整installations和User Settings位置即可
	- D:\All\Server\apache-maven-3.3.9\conf 这个目录
4. 单元测试
    - 快捷键设置为ctrl+F12

5. HTML文件、JS文件两个空格

---


#### 安装插件（若需要）

###### 安装Jrebel并破解


- 破解
	
    1. 复制jrebel/jrebel.jar文件到[eclipse根目录]/plugins/org.zeroturnaround.eclipse.embedder6.4.3.RELEASE-201511061610/jrebel/目录，覆盖原jrebel.jar文件
    
    2. 复制 jrebel6/jrebel.jar文件到[eclipse根目录]/plugins/org.zeroturnaround.eclipse.embedder6.4.3.RELEASE-201511061610/jr6/jrebel/目录，覆盖原jrebel.jar文件
	
    3. 复制jrebel.lic文件到[USER_HOME]/.jrebel目录下
	
    4. 打开eclipse的Jrebel Configuration视图， Advanced - 选择Jrebel6 Agent，重启eclipse
		
	5. 重装后，若没有更改eclipse配置，则无需设置，但需要复制jrebel.lic到用户路径下

###### 安装Hibernate插件

- [参考此处](https://jingyan.baidu.com/article/295430f1d7ac830c7f00507d.html)
- 简便：复制hibernate_tool下的两个文件夹到eclipse根目录即可
- $\frac{1}{4}$
- 