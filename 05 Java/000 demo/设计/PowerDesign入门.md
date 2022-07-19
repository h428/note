


# 1. 数据库设计

- 注意使用管理员运行程序
- 首先，要创建模型：File -> New Model，选择 Physical Data Model 里的 Physical Diagram，取名，然后可以进行数据库设计
- 主要是熟悉表设计、列添加以及外键的设计，其他具体可直接百度
- 设计时 name, code 都直接填写列名，其中 code 是真正的列名，name 是逻辑名，理论上要和 comment 保持一致，但设计时一般和列名相同，最后使用脚本统一替换
- 一定要编写 comment 注释

# 2. 物理模型反转

- 首先，必须先安装 MySQL 驱动，而且必须安装 32 版本，[下载地址](https://dev.mysql.com/downloads/connector/odbc/5.1.html)
- 安装后打开控制面板->系统和安全->管理工具->ODBC 数据源 32 位
- 点击添加，输入数据库连接信息
- 打开 PowerDesigner，选择 File -> Reverse Engineer -> Database，输入 pdm 文件名以及数据库版本，点确定
- 选择 Using a data source，并点击小图标，然后选择 ODBC machine data source，列表中应该有你前面添加的数据库（没有则说明前面配置不成功）
- 选择数据库 -> Connect -> 确定，会出现所有库下的数据表
- 先 Deselect All，然后选择对应 User 下的数据库，反转即可


# 3. 设置视图的显示

- PowerDesigner 默认显示的是 Name，没有 Comment，但有时为了更加清晰我们需要显示 Comment，则可通过如下间接操作来完成（16.5版本）
- 首先要为列编写注释 Comment
- 菜单：Tool -> Display Preferences -> Table，然后选右下角的 Advanced
- 新窗口中选择 Columns，点击 List Columns 那一栏右边的小图标，按顺序勾选 Code, Data Type, Name，其中 Code 移到顶端，这样会同时显示 code 和 name
- 然后输按快捷键 `ctrl+shirft+x`，输入下述 vbs 脚本，将 name 的内容替换为 comment 即可，若不想显示注释则按上述步骤关闭 Name 的显示即可
```vb
Option   Explicit   
    ValidationMode   =   True   
    InteractiveMode   =   im_Batch
    Dim blankStr
    blankStr   =   Space(1)
    Dim   mdl   '   the   current   model  
      
    '   get   the   current   active   model   
    Set   mdl   =   ActiveModel   
    If   (mdl   Is   Nothing)   Then   
          MsgBox   "There   is   no   current   Model "   
    ElseIf   Not   mdl.IsKindOf(PdPDM.cls_Model)   Then   
          MsgBox   "The   current   model   is   not   an   Physical   Data   model. "   
    Else   
          ProcessFolder   mdl   
    End   If  
      
    Private   sub   ProcessFolder(folder)   
    On Error Resume Next  
          Dim   Tab   'running     table   
          for   each   Tab   in   folder.tables   
                if   not   tab.isShortcut   then   
                      tab.name   =   tab.comment  
                      Dim   col   '   running   column   
                      for   each   col   in   tab.columns   
                      if col.comment = "" or replace(col.comment," ", "")="" Then
                            col.name = blankStr
                            blankStr = blankStr & Space(1)
                      else  
                            col.name = col.comment   
                      end if  
                      next   
                end   if   
          next  
      
          Dim   view   'running   view   
          for   each   view   in   folder.Views   
                if   not   view.isShortcut   then   
                      view.name   =   view.comment   
                end   if   
          next  
      
          '   go   into   the   sub-packages   
          Dim   f   '   running   folder   
          For   Each   f   In   folder.Packages   
                if   not   f.IsShortcut   then   
                      ProcessFolder   f   
                end   if   
          Next   
    end   sub
```
