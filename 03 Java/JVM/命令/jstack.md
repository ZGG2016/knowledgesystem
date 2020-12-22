# jstack命令

### 作用：

Prints Java thread stack traces for a Java process, core file, or remote debug server. This command is experimental and unsupported.

打印Java process, core file, or remote debug server的**线程的堆栈跟踪信息**。

### 语法：

- jstack [ options ] pid

- jstack [ options ] executable core

- jstack [ options ] [ server-id@ ] remote-hostname-or-IP

其中：

- options

		The command-line options. See Options.

- pid

		想要打印堆栈跟踪信息的进程ID。必须是java进程。

		The process ID for which the stack trace is printed. The process must be a Java process. To get a list of Java processes running on a machine, use the jps(1) command.

- executable

		产生core dump行为的Java可执行程序。

		The Java executable from which the core dump was produced.

[core dump](https://www.cnblogs.com/s-lisheng/p/11278193.html)：当程序运行的过程中异常终止或崩溃，操作系统会将程序当时的内存状态记录下来，保存在一个文件中，这种行为就叫做core dump

- core

		想要打印堆栈跟踪信息的core file

		The core file for which the stack trace is to be printed.

		core file：core dump产生的文件

- remote-hostname-or-IP

		远程服务器ip或主机名

		The remote debug server hostname or IP address. See jsadebugd(1).

- server-id

		服务器的唯一标识
		An optional unique ID to use when multiple debug servers are running on the same remote host.

### 选项Options

- -F

		当`jstack [-l] pid`打印失败时，强制打印

		Force a stack dump when jstack [-l] pid does not respond.

- -l

		打印关于锁的额外信息。

		Long listing. Prints additional information about locks such as a list of owned java.util.concurrent ownable synchronizers. See the AbstractOwnableSynchronizer class description at
		http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/AbstractOwnableSynchronizer.html

- -m

		同时打印 Java and native C/C++ frames 的堆栈跟踪
		Prints a mixed mode stack trace that has both Java and native C/C++ frames.

- -h

		Prints a help message.

- -help

		Prints a help message.

### 命令描述

对于每个java frame，会打印类名、方法名、字节码索引和行号。

如果进程运行在 64-bit JVM 中，需要指定参数 -J-d64，即`jstack -J-d64 -m pid`

*The jstack command prints Java stack traces of Java threads for a specified Java process, core file, or remote debug server. For each Java frame, the full class name, method name, byte code index (BCI), and line number, when available, are printed.*
*With the -m option, the jstack command prints both Java and native frames of all threads with the program counter (PC). For each native frame, the closest native symbol to PC, when available, is printed. C++ mangled names are not demangled. To demangle C++ names, the output of this command can be piped to c++filt. When the specified process is running on a 64-bit Java Virtual Machine, you might need to specify the -J-d64 option, for example:`jstack -J-d64 -m pid.`*

*Note: This utility is unsupported and might not be available in future release of the JDK. In Windows Systems where the dbgeng.dll file is not present, Debugging Tools For Windows must be installed so these tools work. The PATH environment variable needs to contain the location of the jvm.dll that is used by the target process, or the location from which the crash dump file was produced. For example:`set PATH=<jdk>\jre\bin\client;%PATH%*
`*

```sh
[root@zgg ~]# jstack -h
Usage:
    jstack [-l] <pid>
        (to connect to running process)
    jstack -F [-m] [-l] <pid>
        (to connect to a hung process)
    jstack [-m] [-l] <executable> <core>
        (to connect to a core file)
    jstack [-m] [-l] [server_id@]<remote server IP or hostname>
        (to connect to a remote debug server)

Options:
    -F  to force a thread dump. Use when jstack <pid> does not respond (process is hung)
    -m  to print both java and native frames (mixed mode)
    -l  long listing. Prints additional information about locks
    -h or -help to print this help message
```


[官网原文](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstack.html#BABGJDIF)

[jstack日志理解](https://blog.csdn.net/xingyuaini/article/details/84682398?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.channel_param)

[详细介绍](https://blog.csdn.net/lmb55/article/details/79349680?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param)