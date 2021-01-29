# flume自定义组件的 jar 包管理

[TOC]

1、方式一

将 jar 包直接放入 `lib/` 目录，简单但不易管理。


2、方式二

将 jar 包放入一个名为 `plugins.d` 的特殊目录，它会自动选取以特定格式打包的插件。

这允许更容易的管理插件打包问题，以及更简单的调试和排除一些问题，特别是库依赖冲突。

`plugins.d` 目录位于 `$FLUME_HOME/plugins.d`。在启动时，flume-ng 启动脚本会在 `plugins.d` 中查找符合下列格式的插件，并在启动 java 时将它们包含在正确的路径中。

每个 `plugins.d` 下的插件都有如下三个子目录：

- lib - the plugin’s jar(s)
- libext - the plugin’s dependency jar(s)
- native - any required native libraries, such as .so files

---------------------------------------------------------

（1）在 `$FLUME_HOME` 下新建目录 `plugins.d/`，及其三个子目录

```sh
[root@zgg flume-1.9.0]# mkdir plugins.d/
[root@zgg flume-1.9.0]# ls
bin        conf    DEVNOTES        docs          jobs  LICENSE  NOTICE     README.md      tools
CHANGELOG  cs.log  doap_Flume.rdf  file-channel  lib   logs     plugins.d  RELEASE-NOTES

[root@zgg plugins.d]# mkdir lib
[root@zgg plugins.d]# mkdir libext
[root@zgg plugins.d]# mkdir native
[root@zgg plugins.d]# ls
lib  libext  native
```

（2）将 jar 包放到相关目录下

使用自定义拦截器的例子。

这里打的 jar 包含了所需依赖，所以只将其放入到了 lib/ 目录下。

```sh
[root@zgg plugins.d]# cd lib
[root@zgg lib]# rz
rz waiting to receive.
Starting zmodem transfer.  Press Ctrl+C to cancel.
Transferring flumeproject-1.0-SNAPSHOT-jar-with-dependencies.jar...
  100%   42144 KB    5268 KB/sec    00:00:08       0 Errors   

[root@zgg lib]# ls
flumeproject-1.0-SNAPSHOT-jar-with-dependencies.jar
```

（3）执行flume任务

```sh
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-custom-Interceptor.conf --name a1 -Dflume.root.logger=INFO,console
.......
2021-01-25 13:11:31,200 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{num of bytes=12} body: 7A 68 61 6E 67 73 61 6E 20 72 65 64             zhangsan red }
2021-01-25 13:11:31,201 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{num of bytes=10} body: 6C 69 73 69 20 62 6C 61 63 6B                   lisi black }
```