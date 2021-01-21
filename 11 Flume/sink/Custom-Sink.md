# Custom-Sink

1、编写代码

```java
import org.apache.flume.*;
import org.apache.flume.conf.Configurable;
import org.apache.flume.sink.AbstractSink;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/*
 * 自定义Sink的简单应用
 *
 * */
public class CustomSink extends AbstractSink implements Configurable {

    public static final Logger LOG = LoggerFactory.getLogger(AbstractSink.class);

    @Override
    public Status process() throws EventDeliveryException {
        Status status = null;
        Channel ch = getChannel();
        Transaction txn = ch.getTransaction();
        txn.begin();

        try {
            Event event = ch.take();
            //处理事件，即将其拆分成几部分，分别在日志上输出
            String eventstr = new String(event.getBody());
            String[] ss = eventstr.split(",");
            for(String s:ss){
                LOG.info(s);
            }
            txn.commit();
            status = Status.READY;
        } catch (Throwable t) {
            txn.rollback();

            status = Status.BACKOFF;

            if (t instanceof Error) {
                throw (Error)t;
            }
        }finally {
            txn.close();
        }
        return status;
    }

    @Override
    public void configure(Context context) {
    }
}

```

2、打包，上传至 flume 的 lib/ 目录下。

参考 Custom-Source 示例。

打包之后，只需要单独包，不需要将依赖的包上传。因为依赖包在 flume 的 lib 目录下面已经存在了。

```sh
[root@zgg lib]# rz
rz waiting to receive.
Starting zmodem transfer.  Press Ctrl+C to cancel.
Transferring flumeproject-1.0-SNAPSHOT.jar...
  100%       3 KB       3 KB/sec    00:00:01       0 Errors  
```

3、编写配置文件

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-custorm-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = CustomSink

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 输入数据
[root@zgg ~]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
zhangsan,lisi
OK

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-custorm-sink.conf --name a1 -Dflume.root.logger=INFO,console
....
2021-01-21 20:36:31,287 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - CustomSink.process(CustomSink.java:28)] zhangsan
2021-01-21 20:36:31,287 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - CustomSink.process(CustomSink.java:28)] lisi

````