# tez环境搭建

[TOC]

搭建失败

## 1、下载、解压、重命名

下载：[http://tez.apache.org/releases/index.html](http://tez.apache.org/releases/index.html)

解压：`tar -zxvf apache-tez-0.9.1-bin.tar.gz`

重命名：`mv apache-tez-0.9.1-bin tez-0.9.1`

## 2、配置环境变量

```sh
[root@zgg opt]# vi /etc/profile
export TEZ_HOME=/opt/tez-0.9.1
export PATH=.:$TEZ_HOME/bin:$PATH

[root@zgg opt]# source /etc/profile
```

## 3、在hive中配置

配置 hive-env.sh 和 hive-site.sh

```sh
[root@zgg conf]# vi hive-env.sh
export TEZ_CONF_DIR=/opt/tez-0.9.1/conf
export TEZ_HOME=/opt/tez-0.9.1
export TEZ_JARS=/opt/tez-0.9.1

export HIVE_AUX_JARS_PATH=${TEZ_JARS}
```
```sh
[root@zgg conf]# vi hive-site.xml
<property>
    <name>hive.execution.engine</name>
    <value>tez</value>
</property>
```

## 4、配置tez

在 hive/conf 目录下添加 tez-site.xml 文件

```sh
[root@zgg conf]# vi tez-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>tez.lib.uris</name>
        <value>${fs.defaultFS}/tez/tez-0.9.1,${fs.defaultFS}/tez/tez-0.9.1/lib</value>
    </property>
    <property>
        <name>tez.lib.uris.classpath</name>
        <value>${fs.defaultFS}/tez/tez-0.9.1,${fs.defaultFS}/tez/tez-0.9.1/lib</value>
    </property>
    <property>
        <name>tez.use.cluster.hadoop-libs</name>
        <value>true</value>
    </property>
    <property>
        <name>tez.history.logging.service.class</name>
        <value>org.apache.tez.dag.history.logging.ats.ATSHistoryLoggingService</value>
    </property>
</configuration>
```

## 5、将tez上传到hdfs

```sh
[root@zgg script]# hadoop fs -mkdir /tez

[root@zgg script]# hadoop fs -ls /      
drwxr-xr-x   - root supergroup          0 2021-02-07 16:21 /tez

[root@zgg opt]# hadoop fs -put tez-0.9.1/ /tez

[root@zgg script]# hadoop fs -ls /tez
drwxr-xr-x   - root supergroup          0 2021-02-07 16:22 /tez/tez-0.9.1
```

执行 insert 语句，出现

	Diagnostics:	
	Application application_1612869903052_0002 failed 2 times due to AM Container for appattempt_1612869903052_0002_000002 exited with exitCode: 1
	Failing this attempt.Diagnostics: [2021-02-09 21:01:23.870]Exception from container-launch.
	Container id: container_1612869903052_0002_02_000001
	Exit code: 1
	[2021-02-09 21:01:23.876]Container exited with a non-zero exit code 1. Error file: prelaunch.err.
	Last 4096 bytes of prelaunch.err :
	Last 4096 bytes of stderr :
	[2021-02-09 21:01:23.879]Container exited with a non-zero exit code 1. Error file: prelaunch.err.
	Last 4096 bytes of prelaunch.err :
	Last 4096 bytes of stderr :
	For more detailed output, check the application tracking page: http://zgg:8088/cluster/app/application_1612869903052_0002 Then click on links to logs of each attempt.
	. Failing the application.