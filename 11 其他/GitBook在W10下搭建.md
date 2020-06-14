# GitBook在W10下搭建

### 1 安装NodeJs

（1）下载安装：https://nodejs.org/en/

（2）`node -v` 查看是否安装成功

![1](https://s1.ax1x.com/2020/05/31/t1Enne.png)

### 2 安装GitBook

（1）cmd控制台输入安装：npm install gitbook-cli -g

![2](https://s1.ax1x.com/2020/05/31/t1VAEj.png)

（2）查看gitbook是否安装成功：gitbook -V

![3](https://s1.ax1x.com/2020/05/31/t1VFbQ.png)

### 3 编写GitBook

（1）在硬盘上新建了一个叫 mybook 的文件

（2）在 mybook 文件夹下使用 gitbook init 初始化gitbook。
执行完后，你会看到多了两个文件 —— README.md 和 SUMMARY.md，它们的作用如下：

    README.md —— 书籍的介绍写在这个文件里
    SUMMARY.md —— 书籍的目录结构在这里配置

![4](https://s1.ax1x.com/2020/05/31/t1Vm80.png)

（3）编辑器Atom下编写文件内容

    # Summary

    * [前言](README.md)
    * [第一章](Chapter1/README.md)
        * [第1节：衣](Chapter1/衣.md)
        * [第2节：食](Chapter1/食.md)
        * [第3节：住](Chapter1/住.md)
        * [第4节：行](Chapter1/行.md)
    * [第二章](Chapter2/README.md)
    * [第三章](Chapter3/README.md)

（4）回到命令行，在 mybook 文件夹中再次执行 gitbook init 命令。GitBook 会查找SUMMARY.md 文件中描述的目录和文件，如果没有则会将其创建。

![5](https://s1.ax1x.com/2020/05/31/t1VV5n.png)

（5）执行 gitbook serve 来预览这本书籍，执行命令后会对 Markdown 格式的文档进行转换，默认转换为 html 格式，最后提示 “Serving book on http://localhost:4000”。

![6](https://s1.ax1x.com/2020/05/31/t1VeCq.png)

（6）当你写得差不多，你可以执行gitbook build命令构建书籍，默认将生成的静态网站输出到_book目录。实际上，这一步也包含在gitbook serve里面，因为它们是 HTML，所以 GitBook 通过 Node.js 给你提供服务了。

### 4 卸载GitBook

（1）删除C:\Users\{User}\.gitbook 文件夹

（2）删除后执行命令

    # npm uninstall -g gitbook
    # npm uninstall -g gitbook-cli
    --- 清除npm缓存
    # npm cache clean --force

======================================

参考：

[GitBook + Typora + Git 编写电子文档](https://cloud.tencent.com/developer/article/1441130)

[GitBook的安装、卸载、常见问题](https://www.jianshu.com/p/1f78d8018ea7)
