# 使用eclipse搭建hadoop开发环境

1、下载对应版本的hadoop插件：hadoop-eclipse-plugin-2.7.3.jar。并将其放在eclipse的dropins目录下。重启eclipse。重新打开后会在windows/preferences下看到Hadoop Map/Reduce。

![1](https://s1.ax1x.com/2020/05/31/t3ucOP.png)

2、在windows/preferences目录下，设置hadoop在windows下的目录。是hadoop-2.7.3.tar.gz文件的解压目录，不是hadoop-2.7.3-src.tar.gz文件。

![2](https://s1.ax1x.com/2020/05/31/t3uyQI.png)

点击Apply and Close

3、点击Window--Show View--Other--MapReduce Tool--Map/Reduce Locations--open

![3](https://s1.ax1x.com/2020/05/31/t3usSA.png)

之后会出现如下图：

![4](https://s1.ax1x.com/2020/05/31/t3u0Fe.png)

4、点击小象，会出现

![5](https://s1.ax1x.com/2020/05/31/t3uBJH.png)

    Location name: 可以填写虚拟机的主机名
    Host:虚拟机的IP地址
    Port:9001/9000（Host和Port配置成与core-site.xml的一致）
    User Name:设置访问集群的用户名，默认为本机的用户名。

![6](https://s1.ax1x.com/2020/05/31/t3uDWd.png)

5、点击中的小象，在Project Explorer栏出现DFS Location

![7](https://s1.ax1x.com/2020/05/31/t3u6yt.png)

连接成功。

6、创建工程File--New--Other--Maven--Maven Project

![8](https://s1.ax1x.com/2020/05/31/t3u2ef.png)

![9](https://s1.ax1x.com/2020/05/31/t3uWTS.png)

![10](https://s1.ax1x.com/2020/05/31/t3uRw8.png)

点击finish。完成。

注意，在运行中出现：

![11](https://s1.ax1x.com/2020/05/31/t3u4YQ.png)

    因为log4j这个日志信息打印模块的配置信息没有给出造成的。
    解决:
    在你的项目的src目录中创建一个名为log4j.properties的文本文件，记住是文本文件，不是文件夹

然后在你的文本文件中加入如下的内容：

    # Configure logging for testing: optionally with log file  

    #log4j.rootLogger=debug,appender  
    log4j.rootLogger=info,appender  
    #log4j.rootLogger=error,appender  

    #\u8F93\u51FA\u5230\u63A7\u5236\u53F0  
    log4j.appender.appender=org.apache.log4j.ConsoleAppender  
    #\u6837\u5F0F\u4E3ATTCCLayout  
    log4j.appender.appender.layout=org.apache.log4j.TTCCLayout

然后将下面的方法插入到main函数中：

    BasicConfigurator.configure();

![12](https://s1.ax1x.com/2020/05/31/t3uhFg.png)

    注：Maven安装
    https://jingyan.baidu.com/article/295430f136e8e00c7e0050b9.html
    1、下载、解压、配置环境变量、mvn -v测试安装成功
    2、配置成功后开始在Eclipse中配置Maven，点击eclipse菜单栏Help->Eclipse Marketplace搜索关键字maven到插件Maven Integration for Eclipse 并点击安装即可
    3、重启后，为了使得Eclipse中安装的Maven插件，同windows中安装的那个相同，需要让eclipse中的maven重新定位一下，点击Window -> Preference -> Maven -> Installation -> Add进行设置
