# Custom-Interceptor

1、编写代码

```java
import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.interceptor.Interceptor;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CustomInterceptor implements Interceptor {
    @Override
    public void initialize() {

    }

    @Override
    public Event intercept(Event event) {

        // 每个事件包含的字节数
        Map<String, String> headers = event.getHeaders();
        byte[] bodys = event.getBody();
        headers.put("num of bytes",String.valueOf(bodys.length));

        return event;
    }

    @Override
    public List<Event> intercept(List<Event> list) {
        ArrayList<Event> interceptors = new ArrayList<>();
        for (Event event : list) {
            Event intercept1 = intercept(event);
            if (intercept1 != null){
                interceptors.add(intercept1);
            }
        }
        return interceptors;
    }

    @Override
    public void close() {

    }
    public static class Builder implements Interceptor.Builder{
        @Override
        public Interceptor build() {
            return new CustomInterceptor();
        }

        @Override
        public void configure(Context context) {

        }
    }
}

```

2、打包，上传至 flume 的 lib/ 目录下。

3、编写配置文件

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-custom-Interceptor.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

a1.sources.r1.interceptors = i1
a1.sources.r1.interceptors.i1.type = CustomInterceptor$Builder

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 数据文件 test.txt
First Line
Second Line

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-custom-Interceptor.conf --name a1 -Dflume.root.logger=INFO,console
....
# 输出日志中输出了每个事件的字节数
2021-01-24 19:02:17,646 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{num of bytes=11} body: 46 69 72 73 74 20 4C 69 6E 65 20                First Line  }
2021-01-24 19:02:17,647 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{num of bytes=11} body: 53 65 63 6F 6E 64 20 4C 69 6E 65                Second Line }
```