# jstat命令

监控虚拟机的运行状态信息

```sh
[root@zgg ~]# jstat -help
Usage: jstat -help|-options
       jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]

Definitions:
  <option>      An option reported by the -options option
  <vmid>        Virtual Machine Identifier. A vmid takes the following form:
                     <lvmid>[@<hostname>[:<port>]]
                Where <lvmid> is the local vm identifier for the target
                Java virtual machine, typically a process id; 

                <hostname> is the name of the host running the target Java virtual machine;and 

                <port> is the port number for the rmiregistry on the
                target host. 

                See the jvmstat documentation for a more complete
                description of the Virtual Machine Identifier.

  <lines>       Number of samples between header lines.
  <interval>    Sampling interval. The following forms are allowed:
                    <n>["ms"|"s"] 
                Where <n> is an integer and the suffix specifies the units as 
                milliseconds("ms") or seconds("s"). The default units are "ms".
  <count>       Number of samples to take before terminating. 
  -J<flag>      Pass <flag> directly to the runtime system.
```

	option： 参数选项
	-t： 可以在打印的列加上Timestamp列，用于显示系统运行的时间
	-h： 在周期性数据数据的时候，可以在指定输出多少行以后输出一次表头
	vmid： Virtual Machine ID（ 本地：进程的 pid；远程：<lvmid>[@<hostname>[:<port>]]）
	interval： 执行每次的间隔时间，单位为毫秒
	count： 用于指定输出多少次记录，缺省则会一直打印

示例：

```sh
[root@zgg script]# jstat -gc -t -h 10 7505 4000
Timestamp        S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT   
         3933.5 1600.0 1600.0  0.0   563.4  13120.0   1092.3   32540.0    26693.6   32000.0 31470.3 3840.0 3648.6     29    0.247   1      0.022    0.268
         3937.5 1600.0 1600.0  0.0   563.4  13120.0   1092.3   32540.0    26693.6   32000.0 31470.3 3840.0 3648.6     29    0.247   1      0.022    0.268
         3941.5 1600.0 1600.0  0.0   563.4  13120.0   1124.6   32540.0    26693.6   32000.0 31470.3 3840.0 3648.6     29    0.247   1      0.022    0.268

```

会每4秒显示进程号为7505的java进成的GC情况，同时打印时间戳

---------------------------------------------------------------------


```sh
[root@zgg ~]# jstat -options
-class             # 显示载入类的相关信息；
-compiler          # 显示JIT编译的相关信息；
-gc                # 显示和gc堆相关的信息；
-gccapacity        # 显示各个代的容量以及使用情况；
-gccause           # 显示垃圾回收的相关信息(和 -gcutil 相同),显示最后一次或当前正在发生的垃圾回收的诱因；
-gcmetacapacity    # 显示元空间的大小；
-gcnew             # 显示新生代信息；
-gcnewcapacity     # 显示新生代大小和使用情况；
-gcold             # 显示老年代和元空间的信息；
-gcoldcapacity     # 显示老年代的大小；
-gcutil            # 显示垃圾收集信息；
-printcompilation  # 输出JIT编译的方法信息；
```

---------------------------------------------------------------------

- -class

显示加载class的数量，及所占空间等信息。 `jstat -class <pid>`

```sh
[root@zgg script]# jstat -class 7505
Loaded  Bytes  Unloaded  Bytes     Time   
  4784  9982.4        0     0.0       3.58
```

	Loaded : 已经装载的类的数量
	Bytes : 加载类所占用的字节数
	Unloaded：已经卸载类的数量
	Bytes：已经卸载类的字节数
	Time：装载和卸载类所花费的时间

---------------------------------------------------------------------

- -compiler

显示VM实时编译(JIT)的数量等信息。`jstat -compiler <pid>`

```sh
[root@zgg script]# jstat -compiler 7505
Compiled Failed Invalid   Time   FailedType FailedMethod
    2191      1       0     5.10          1 sun/misc/URLClassPath$JarLoader getResource
```

	Compiled：执行编译任务数量
	Failed：执行编译任务失败数量
	Invalid ：Number of compilation tasks that were invalidated.
	Time ：执行编译任务消耗时间
	FailedType：最后一个编译失败的编译类型
	FailedMethod：最后一个编译失败的类及方法

---------------------------------------------------------------------

- -gc 显示和gc堆相关的信息 `jstat –gc <pid>`

```sh
[root@zgg script]# jstat -gc 7505
 S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT   
1600.0 1600.0 436.1   0.0   13120.0   1672.4   32540.0    24585.5   30208.0 29653.8 3584.0 3473.7     26    0.233   1      0.022    0.254
```

	S0C: Current survivor space 0 capacity (kB).【幸存者区0】
	S1C: Current survivor space 1 capacity (kB).
	S0U: Survivor space 0 utilization (kB).【幸存者区0，已使用的空间】
	S1U: Survivor space 1 utilization (kB).
	EC: Current eden space capacity (kB). 【伊甸园】
	EU: Eden space utilization (kB).
	OC: Current old space capacity (kB). 【老年代】
	OU: Old space utilization (kB).
	MC: Metaspace capacity (kB). 【元空间】
	MU: Metacspace utilization (kB).
	CCSC: Compressed class space capacity (kB).【压缩后的类空间】
	CCSU: Compressed class space used (kB).
	YGC: Number of young generation garbage collection events.【新生代中gc次数】
	YGCT: Young generation garbage collection time. 【新生代中gc时间】
	FGC: Number of full GC events.【全部gc次数】
	FGCT: Full garbage collection time.
	GCT: Total garbage collection time.

---------------------------------------------------------------------

- -gccapacity 显示各个代的容量以及使用情况；

```sh
[root@zgg script]# jstat -gccapacity 7505
 NGCMN    NGCMX     NGC     S0C   S1C       EC      OGCMN      OGCMX       OGC         OC       MCMN     MCMX      MC     CCSMN    CCSMX     CCSC    YGC    FGC 
 10240.0 341312.0  16320.0 1600.0 1600.0  13120.0    20480.0   682688.0    32540.0    32540.0      0.0 1075200.0  30208.0      0.0 1048576.0   3584.0     26     1
```

	NGCMN: Minimum new generation capacity (kB). 【新生代】
	NGCMX: Maximum new generation capacity (kB).
	NGC: Current new generation capacity (kB).
	S0C: Current survivor space 0 capacity (kB).
	S1C: Current survivor space 1 capacity (kB).
	EC: Current eden space capacity (kB).
	OGCMN: Minimum old generation capacity (kB). 【老年代】
	OGCMX: Maximum old generation capacity (kB).
	OGC: Current old generation capacity (kB).
	OC: Current old space capacity (kB).
	MCMN: Minimum metaspace capacity (kB).  【元空间】
	MCMX: Maximum metaspace capacity (kB).
	MC: Metaspace capacity (kB).
	CCSMN: Compressed class space minimum capacity (kB). 【压缩后的类空间】
	CCSMX: Compressed class space maximum capacity (kB).
	CCSC: Compressed class space capacity (kB).
	YGC: Number of young generation GC events.  【新生代】
	FGC: Number of full GC events.

---------------------------------------------------------------------

- -gccause 显示垃圾回收的相关信息，输出内容和 -gcutil 相同，但是显示最后一次或当前正在发生的垃圾回收的诱因

```sh
[root@zgg script]# jstat -gccause 7505
  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC                 
 27.25   0.00  17.84  75.55  98.17  96.92     26    0.233     1    0.022    0.254 Allocation Failure   No GC
```

	LGCC: Cause of last garbage collection 
	GCC: Cause of current garbage collection

---------------------------------------------------------------------

- -gcmetacapacity 显示元空间的大小；

```sh
[root@zgg script]# jstat -gcmetacapacity 7505
   MCMN       MCMX        MC       CCSMN      CCSMX       CCSC     YGC   FGC    FGCT     GCT   
       0.0  1075200.0    30208.0        0.0  1048576.0     3584.0    26     1    0.022    0.254
```

	MCMN: Minimum metaspace capacity (kB).
	MCMX: Maximum metaspace capacity (kB).
	MC: Metaspace capacity (kB).
	CCSMN: Compressed class space minimum capacity (kB).  【压缩后的类空间】
	CCSMX: Compressed class space maximum capacity (kB).
	YGC: Number of young generation GC events. 【新生代】
	FGC: Number of full GC events.  【全部】
	FGCT: Full garbage collection time.
	GCT: Total garbage collection time.

---------------------------------------------------------------------

- -gcnew 显示新生代信息；

```sh
[root@zgg script]# jstat -gcnew 7505
 S0C    S1C    S0U    S1U   TT MTT  DSS      EC       EU     YGC     YGCT  
1600.0 1600.0  436.1    0.0 15  15  800.0  13120.0   2605.1     26    0.233
```

	S0C: Current survivor space 0 capacity (kB).
	S1C: Current survivor space 1 capacity (kB).
	S0U: Survivor space 0 utilization (kB).
	S1U: Survivor space 1 utilization (kB).
	TT: Tenuring threshold. 持有次数限制
	MTT: Maximum tenuring threshold. 最大持有次数限制
	DSS: Desired survivor size (kB).
	EC: Current eden space capacity (kB).
	EU: Eden space utilization (kB).
	YGC: Number of young generation GC events.
	YGCT: Young generation garbage collection time.

---------------------------------------------------------------------

- -gcnewcapacity 显示新生代大小和使用情况；

```sh
[root@zgg script]# jstat -gcnewcapacity 7505
  NGCMN      NGCMX       NGC      S0CMX     S0C     S1CMX     S1C       ECMX        EC      YGC   FGC 
   10240.0   341312.0    16320.0  34112.0   1600.0  34112.0   1600.0   273088.0    13120.0    26     1
```

	NGCMN: Minimum new generation capacity (kB).
	NGCMX: Maximum new generation capacity (kB).
	NGC: Current new generation capacity (kB).
	S0CMX: Maximum survivor space 0 capacity (kB).  【幸存者区0】
	S0C: Current survivor space 0 capacity (kB).
	S1CMX: Maximum survivor space 1 capacity (kB).
	S1C: Current survivor space 1 capacity (kB).
	ECMX: Maximum eden space capacity (kB).  【伊甸园】
	EC: Current eden space capacity (kB).
	YGC: Number of young generation GC events.
	FGC: Number of full GC events.

---------------------------------------------------------------------

- -gcold 显示老年代和元空间的信息；

```sh
[root@zgg script]# jstat -gcold 7505
   MC       MU      CCSC     CCSU       OC          OU       YGC    FGC    FGCT     GCT   
 30208.0  29653.8   3584.0   3473.7     32540.0     24585.5     26     1    0.022    0.254
```

	MC: Metaspace capacity (kB). 【元空间】
	MU: Metaspace utilization (kB).
	CCSC: Compressed class space capacity (kB).  【压缩后的类空间】
	CCSU: Compressed class space used (kB).
	OC: Current old space capacity (kB).   【老生代】
	OU: Old space utilization (kB).  
	YGC: Number of young generation GC events.   【新生代】
	FGC: Number of full GC events. 【全部】
	FGCT: Full garbage collection time.
	GCT: Total garbage collection time.

---------------------------------------------------------------------

- -gcoldcapacity 显示老年代的大小；

```sh
[root@zgg script]# jstat -gcoldcapacity 7505
   OGCMN       OGCMX        OGC         OC       YGC   FGC    FGCT     GCT   
    20480.0    682688.0     32540.0     32540.0    26     1    0.022    0.254
```

	OGCMN: Minimum old generation capacity (kB).  【老生代】
	OGCMX: Maximum old generation capacity (kB).
	OGC: Current old generation capacity (kB).
	OC: Current old space capacity (kB).
	YGC: Number of young generation GC events.  【新生代】
	FGC: Number of full GC events.  【全部】
	FGCT: Full garbage collection time.
	GCT: Total garbage collection time.

---------------------------------------------------------------------

- -gcutil 显示垃圾收集信息；

```sh
[root@zgg script]# jstat -gcutil 7505
  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT   
 27.25   0.00  22.96  75.55  98.17  96.92     26    0.233     1    0.022    0.254
```

	S0: Survivor space 0 utilization as a percentage of the space's current capacity.  幸存者区0的使用空间在当前容量的占比
	S1: Survivor space 1 utilization as a percentage of the space's current capacity.幸存者区1
	E: Eden space utilization as a percentage of the space's current capacity. 【伊甸园】
	O: Old space utilization as a percentage of the space's current capacity. 【老生代】
	M: Metaspace utilization as a percentage of the space's current capacity.【元空间】
	CCS: Compressed class space utilization as a percentage. 【元空间】
	YGC: Number of young generation GC events. 【新生代】
	YGCT: Young generation garbage collection time. 
	FGC: Number of full GC events.
	FGCT: Full garbage collection time.
	GCT: Total garbage collection time.

---------------------------------------------------------------------

- -printcompilation 输出JIT编译的方法信息；

```sh
[root@zgg script]# jstat -printcompilation  7505
Compiled  Size  Type Method
    2581   1702    1 org/apache/hadoop/ipc/Server$Responder processResponse
```

	Compiled: Number of compilation tasks performed by the most recently compiled method.

	Size: Number of bytes of byte code of the most recently compiled method.

	Type: Compilation type of the most recently compiled method.

	Method: Class name and method name identifying the most recently compiled method. Class name uses slash (/) instead of dot (.) as a name space separator. Method name is the method within the specified class. The format for these two fields is consistent with the HotSpot -XX:+PrintCompilation option.
	类名和方法名用来标识编译的方法。类名使用/做为一个命名空间分隔符。方法名是给定类中的方法。上述格式是由-XX:+PrintComplation选项进行设置的

[官网原文](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html#BEHHGFAE)

[参考](https://www.jianshu.com/p/213710fb9e40)