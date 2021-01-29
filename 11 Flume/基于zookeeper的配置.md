# 基于zookeeper的配置

【存在问题待解决】

1、配置文件

	# Name the components on this agent
	a1.sources = r1
	a1.sinks = k1
	a1.channels = c1

	# Describe/configure the source
	a1.sources.r1.type = exec
	a1.sources.r1.command = tail -F /root/data/test.txt

	# Describe the sink
	a1.sinks.k1.type = logger

	# Use a channel which buffers events in memory
	a1.channels.c1.type = memory
	a1.channels.c1.capacity = 1000
	a1.channels.c1.transactionCapacity = 100

	# Bind the source and sink to the channel
	a1.sources.r1.channels = c1
	a1.sinks.k1.channel = c1

数据文件 test.txt

	zhangsan red
	lisi black

2、上传配置文件到zookeeper

（1）在zookeeper目录中创建一个节点

```sh
[root@zgg zookeeper-3.4.14]# bin/zkCli.sh -server zgg create /flume-1.9.0 "flume-1.9.0"
Connecting to zgg
2021-01-25 12:12:57,964 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
2021-01-25 12:12:57,967 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=zgg
2021-01-25 12:12:57,967 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_271
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/opt/jdk1.8.0_271/jre
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/classes:/opt/zookeeper-3.4.14/bin/../build/classes:/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/lib/*.jar:/opt/zookeeper-3.4.14/bin/../build/lib/*.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-log4j12-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-api-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/netty-3.10.6.Final.jar:/opt/zookeeper-3.4.14/bin/../lib/log4j-1.2.17.jar:/opt/zookeeper-3.4.14/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.4.14/bin/../lib/audience-annotations-0.5.0.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-3.4.14.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-server/src/main/resources/lib/*.jar:/opt/zookeeper-3.4.14/bin/../conf:.:/opt/jdk1.8.0_271/lib:/opt/jdk1.8.0_271/jre/lib:/opt/hadoop-3.2.1/lib:
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=3.10.0-957.el7.x86_64
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2021-01-25 12:12:57,970 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/opt/zookeeper-3.4.14
2021-01-25 12:12:57,971 [myid:] - INFO  [main:ZooKeeper@442] - Initiating client connection, connectString=zgg sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@446cdf90
2021-01-25 12:12:57,994 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1025] - Opening socket connection to server zgg/192.168.1.6:2181. Will not attempt to authenticate using SASL (unknown error)
2021-01-25 12:12:57,999 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@879] - Socket connection established to zgg/192.168.1.6:2181, initiating session
2021-01-25 12:12:58,006 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server zgg/192.168.1.6:2181, sessionid = 0x100001d94bd000c, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
Created /flume-1.9.0
```

（2）将flume配置导入到zookeeper

由于根节点已经创建，我将创建第一个配置节点，并将 Flume 配置文件的内容放入其中。

```sh
[root@zgg zookeeper-3.4.14]# bin/zkCli.sh -server zgg create /flume-1.9.0/flume-zk-test.conf "`cat /opt/flume-1.9.0/jobs/flume-zk-test.conf`"
Connecting to zgg
2021-01-25 12:19:40,445 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
2021-01-25 12:19:40,448 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=zgg
2021-01-25 12:19:40,448 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_271
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/opt/jdk1.8.0_271/jre
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/classes:/opt/zookeeper-3.4.14/bin/../build/classes:/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/lib/*.jar:/opt/zookeeper-3.4.14/bin/../build/lib/*.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-log4j12-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-api-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/netty-3.10.6.Final.jar:/opt/zookeeper-3.4.14/bin/../lib/log4j-1.2.17.jar:/opt/zookeeper-3.4.14/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.4.14/bin/../lib/audience-annotations-0.5.0.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-3.4.14.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-server/src/main/resources/lib/*.jar:/opt/zookeeper-3.4.14/bin/../conf:.:/opt/jdk1.8.0_271/lib:/opt/jdk1.8.0_271/jre/lib:/opt/hadoop-3.2.1/lib:
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=3.10.0-957.el7.x86_64
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2021-01-25 12:19:40,450 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/opt/zookeeper-3.4.14
2021-01-25 12:19:40,451 [myid:] - INFO  [main:ZooKeeper@442] - Initiating client connection, connectString=zgg sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@446cdf90
2021-01-25 12:19:40,470 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1025] - Opening socket connection to server zgg/192.168.1.6:2181. Will not attempt to authenticate using SASL (unknown error)
2021-01-25 12:19:40,478 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@879] - Socket connection established to zgg/192.168.1.6:2181, initiating session
2021-01-25 12:19:40,485 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server zgg/192.168.1.6:2181, sessionid = 0x100001d94bd0010, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
Created /flume-1.9.0/flume-zk-test.conf
```

（3）检查 /flume-1.9.0 和 /flume-1.9.0/flume-zk-test.conf 节点下的内容

```sh
[root@zgg zookeeper-3.4.14]# bin/zkCli.sh -server zgg ls /flume-1.9.0
Connecting to zgg
2021-01-25 12:20:43,881 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
2021-01-25 12:20:43,883 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=zgg
2021-01-25 12:20:43,883 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_271
2021-01-25 12:20:43,885 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2021-01-25 12:20:43,885 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/opt/jdk1.8.0_271/jre
2021-01-25 12:20:43,885 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/classes:/opt/zookeeper-3.4.14/bin/../build/classes:/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/lib/*.jar:/opt/zookeeper-3.4.14/bin/../build/lib/*.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-log4j12-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-api-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/netty-3.10.6.Final.jar:/opt/zookeeper-3.4.14/bin/../lib/log4j-1.2.17.jar:/opt/zookeeper-3.4.14/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.4.14/bin/../lib/audience-annotations-0.5.0.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-3.4.14.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-server/src/main/resources/lib/*.jar:/opt/zookeeper-3.4.14/bin/../conf:.:/opt/jdk1.8.0_271/lib:/opt/jdk1.8.0_271/jre/lib:/opt/hadoop-3.2.1/lib:
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=3.10.0-957.el7.x86_64
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2021-01-25 12:20:43,886 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/opt/zookeeper-3.4.14
2021-01-25 12:20:43,887 [myid:] - INFO  [main:ZooKeeper@442] - Initiating client connection, connectString=zgg sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@446cdf90
2021-01-25 12:20:43,909 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1025] - Opening socket connection to server zgg/192.168.1.6:2181. Will not attempt to authenticate using SASL (unknown error)
2021-01-25 12:20:43,914 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@879] - Socket connection established to zgg/192.168.1.6:2181, initiating session
2021-01-25 12:20:43,920 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server zgg/192.168.1.6:2181, sessionid = 0x100001d94bd0012, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[flume-zk-test.conf]
```

```sh
[root@zgg zookeeper-3.4.14]# bin/zkCli.sh -server zgg get /flume-1.9.0/flume-zk-test.conf                                           Connecting to zgg
2021-01-25 12:51:07,886 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
2021-01-25 12:51:07,889 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=zgg
2021-01-25 12:51:07,889 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_271
2021-01-25 12:51:07,891 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/opt/jdk1.8.0_271/jre
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/classes:/opt/zookeeper-3.4.14/bin/../build/classes:/opt/zookeeper-3.4.14/bin/../zookeeper-server/target/lib/*.jar:/opt/zookeeper-3.4.14/bin/../build/lib/*.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-log4j12-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/slf4j-api-1.7.25.jar:/opt/zookeeper-3.4.14/bin/../lib/netty-3.10.6.Final.jar:/opt/zookeeper-3.4.14/bin/../lib/log4j-1.2.17.jar:/opt/zookeeper-3.4.14/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.4.14/bin/../lib/audience-annotations-0.5.0.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-3.4.14.jar:/opt/zookeeper-3.4.14/bin/../zookeeper-server/src/main/resources/lib/*.jar:/opt/zookeeper-3.4.14/bin/../conf:.:/opt/jdk1.8.0_271/lib:/opt/jdk1.8.0_271/jre/lib:/opt/hadoop-3.2.1/lib:
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=3.10.0-957.el7.x86_64
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2021-01-25 12:51:07,892 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/opt/zookeeper-3.4.14
2021-01-25 12:51:07,893 [myid:] - INFO  [main:ZooKeeper@442] - Initiating client connection, connectString=zgg sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@446cdf90
2021-01-25 12:51:07,930 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1025] - Opening socket connection to server zgg/192.168.1.6:2181. Will not attempt to authenticate using SASL (unknown error)
2021-01-25 12:51:07,936 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@879] - Socket connection established to zgg/192.168.1.6:2181, initiating session
2021-01-25 12:51:07,946 [myid:] - INFO  [main-SendThread(zgg:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server zgg/192.168.1.6:2181, sessionid = 0x100001d94bd001b, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

# Describe the sink
a1.sinks.k1.type = file_roll
a1.sinks.k1.sink.directory = /root/data/file_roll
a1.sinks.k1.sink.rollInterval = 10

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
cZxid = 0x58a
ctime = Mon Jan 25 12:42:53 CST 2021
mZxid = 0x58a
mtime = Mon Jan 25 12:42:53 CST 2021
pZxid = 0x58a
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 573
numChildren = 0
```

3、启动flume任务

```sh
bin/flume-ng agent --conf conf --zkConnString zgg:2181 --zkBasePath /flume-1.9.0/flume-zk-test.conf --name a1 -Dflume.root.logger=INFO,console
。。。。
2021-01-25 12:43:04,636 (lifecycleSupervisor-1-0-EventThread) [INFO - org.apache.curator.framework.state.ConnectionStateManager.postState(ConnectionStateManager.java:237)] State change: CONNECTED
【一直卡在这里，目标目录下也没有输出？？？？】
```


4、出现的问题

（1）`Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/zookeeper/admin/ZooKeeperAdmin`

flume lib/ 目录下的 curator 与 zookeeper 的版本不一致。zookeeper 3.4.x 版本匹配 curator 4.0 版本

（2）`com.google.common.util.concurrent.MoreExecutors.sameThreadExecutor()Lcom/goo`

flume lib/ 目录下缺少 guava，或它的版本和 curator 不一致。。

参考：[https://ergemp.gitbook.io/data-blog/blog/using-zookeeper-for-your-flume-configurations](https://ergemp.gitbook.io/data-blog/blog/using-zookeeper-for-your-flume-configurations)