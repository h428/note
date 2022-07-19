
# 通用 submit 提交脚本

- submit.sh 脚本
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
```


# wn 版本切换脚本

```bash
#!/bin/bash

if [ $# != 1 ] ; then 
    echo "必须输入分支名称，比如 release-qybx-3.8.1"
    exit 1;  
fi

branch_name=$1

## 检查指定分支是否存在
if [ `git rev-parse --verify $branch_name` ]
then
    echo "本地分支 $branch_name 已存在，即将切换到分支 $branch_name"
    git checkout $branch_name
else
    echo "本地分支 $branch_name 不存在，即将从远程分支 origin/$branch_name 拉取内容并创建对应的本地分支"
    git fetch
    git checkout -b $branch_name origin/$branch_name
fi
```