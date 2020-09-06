# Github 删除问题

1、在本地修改了文件名，git push后，远程出现原文件名和现文件名。如，本地文件夹为'10 大数据面试题整理'，在本地修改为'大数据面试题整理'，push后，远程既有 '10 大数据面试题整理' 文件夹，也有'大数据面试题整理' 文件夹。

解决： git status 查看状态。出现：

    zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/knowledgesystem (master)
    $ git status                                                                                                            On branch master
    Your branch is up to date with 'origin/master'.

    Changes not staged for commit:
      (use "git add/rm <file>..." to update what will be committed)
      (use "git restore <file>..." to discard changes in working directory)
            deleted:    "10 \345\244\247\346\225\260\346\215\256\351\235\242\350\257\225\351\242\230\346\225\264\347\220\206/\347\275\221\347\273\234\346\224\266\351\233\206/1-Java.md"
            ......

然后删除: git rm -r --cache 10\ 大数据面试题整理/  

    zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/knowledgesystem (master)
    $ git rm -r --cache 10\ 大数据面试题整理/
    rm '10 大数据面试题整理/网络收集/1-Java.md'
    rm '10 大数据面试题整理/网络收集/1-Java2.md'
    rm '10 大数据面试题整理/网络收集/1-Spark.md'
    rm '10 大数据面试题整理/网络收集/1-hadoop.md'

最后提交、push:  git commit -m "delete"  ;   git push origin master
