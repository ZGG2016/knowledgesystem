# Syslog-Sources

[TOC]

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-syslogTCP-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = syslogtcp
a1.sources.r1.host = zgg
a1.sources.r1.port = 44444
a1.sources.r1.eventSize = 100
a1.sources.r1.keepFields = all
a1.sources.r1.clientHostnameHeader = myhostname


# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-syslogTCP-source.conf --name a1 -Dflume.root.logger=INFO,console

2021-01-16 11:07:38,257 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{myhostname=desktop-0ahq4ft, Severity=0, Facility=0, flume.syslog.status=Invalid} body: 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 aaaaaaaaaaaaaaaa }
```

```java
// 发送数据代码
package flume;

import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;

public class SyslogTCPSource {

    public static void main(String[] args) throws IOException {
        String line="aaaaaaaaaaaaaaaaaaaaaa!";
        SyslogTCPSource sts = new SyslogTCPSource();
        sts.dataToFlume(line);
    }

    public void dataToFlume(String line) throws IOException {

        Socket s = new Socket("zgg", 44444);
        OutputStream out = s.getOutputStream();

        out.write((line + "\n").getBytes());
        out.flush();
        out.close();
        s.close();

    }
}

```