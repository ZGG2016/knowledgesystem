# mapreduce tutorial

v3.2.1

## 一、概述

**定义：** MapReduce 是一种软件框架，以可靠容错的方式并行计算大规模数据集（大于1TB），能够运行在由上千个商用机器组成的大型集群上。

**内部机制：** MapReduce Job 会把输入数据集划分成若干独立的数据块(chunk)，由 map 任务并行处理，排序后的 map 输出会作为 reduce 任务的输入。通常 Job 的输入和输出都会被存储在文件系统中。整个框架负责任务的调度和监控，以及重新执行已经失败的任务。

通常，**MapReduce 和 HDFS 是运行在一组相同的节点上的**，也就是说，计算节点和存储节点通常在一起。这种配置允许框架在那些已经存好数据的节点上高效地调度任务，这可以使整个集群的网络带宽被非常高效地利用。

MapReduce 框架由 **一个master ResourceManager、多个worker NodeManager 和应用程序的MRAppMaster** 组成。

**整体流程：** 在完成程序、配置完等参数(main函数里的configuration)之后，Hadoop job client **向ResourceManager提交job (jar/executable etc.) 和配置参数**，进行分发到worker节点，调度任务，并向客户端反馈状态和诊断信息。

## 二、Inputs Outputs

MapReduce 以 <key, value> 作为基本的操作单位，输入一组 <key, value>，会输出一组 <key, value>，**类型可以不同**。

key、value 类需要通过实现 **Writable接口** 来进行序列化。另外，为了方便框架执行排序操作，key 类必须实现 **WritableComparable接口**。

key, value变化过程：

    (input) <k1, v1> -> map -> <k2, v2> -> combine -> <k2, v2> -> reduce -> <k3, v3> (output)

## 三、实例: WordCount v1.0

## 四、MapReduce - User Interfaces

### 1、核心功能描述

#### (1)Mapper

Mapper 将输入键值对映射到一组中间格式的键值对集合。

**Map** 是一类将输入记录集转换为中间格式记录集的 **独立任务**。 这种中间格式记录集不需要与输入记录集的类型一致。一个给定的输入键值对可以映射成0个或多个输出键值对。

**MapReduce框架使用InputFormat将输入记录集划分成多个InputSplit，每一个InputSplit产生一个Map任务。**

概括地说，mapper类通过Job.setMapperClass(Class) 传给 Job，然后框架为这个任务的 InputSplit 中每个键值对调用 map(WritableComparable, Writable, Context) 方法处理。程序可以通过重写 cleanup(Context) 方法来执行清理工作。

输出键值对不需要与输入键值对的类型一致。一个给定的输入键值对可以映射成0个或多个输出键值对。通过调用 context.write(WritableComparable, Writable)可以收集输出的键值对。

应用程序使用 **Counters（计数器）** 汇报统计信息。

框架随后会把与一个特定 key 关联的所有中间过程的值（value）**分组** ，然后把它们传给 Reducer 以产出最终的结果。用户可以通过 Job.setGroupingComparatorClass(Class) 来指定具体负责分组的 Comparator。

Mapper的输出，**经过排序、分区** ，进入 Reducer。分区的总数目和一个作业的 reduce 任务的数目是一样的。用户可以通过实现自定义的 Partitioner来控制哪个 key 被分配给哪个 Reducer。

**combine过程可选** ，用户通过 Job.setCombinerClass(Class)指定一个 combiner，它负责对中间过程的输出进行本地的聚集，这会有助于降低从 Mapper 到 Reducer 数据传输量。

这些被排好序的中间输出结果保存的格式是(key-len, key, value-len, value)，应用程序可以通过配置 Configuration 控制对这些中间结果是否进行 **压缩** 以及怎么压缩，使用哪种 CompressionCodec。

##### 需要多少个Map

Map 的数目通常是由输入数据的大小决定的，一般就是所有输入文件的总块（block）数。

Map 正常的并行规模大致是每个节点（node）大约10到100个，对于CPU 消耗较小的 Map 任务可以设到300个左右。由于每个任务初始化需要一定的时间，因此，比较合理的情况是Map执行的时间至少超过1分钟。

这样，如果你输入10TB的数据，每个块（block）的大小是128MB，你将需要大约82,000个 Map 来完成任务，除非使用 Configuration.set(MRJobConfig.NUM_MAPS, int)将这个数值设置得更高。

#### (2)Reducer

Reducer 将与一个key关联的一组中间数值集归约（reduce）为一个更小的数值集。

用户可以通过 JobConf.setNumReduceTasks(int) 设定一个作业中 reduce 任务的数目。

概括地说，Reducer 类通过 Job.setReducerClass(Class) 传递给 Job, 框架为成组的输入数据中的每个<key, (list of values)>对调用一次 reduce(WritableComparable, Iterable<Writable>, Context) 方法。之后，应用程序可以通过重写cleanup(Context)来执行相应的清理工作。

Reducer 有3个主要阶段：shuffle、sort和reduce。

##### Shuffle

Reducer 的输入就是 Mapper 已经排好序的输出。在这个阶段，框架通过 HTTP 为每个 Reducer 获得所有 Mapper 输出中与之相关的分块。

##### Sort

这个阶段，框架将按照 key 的值对 Reducer 的输入进行分组 （因为不同 mapper 的输出中可能会有相同的 key）。

Shuffle和Sort两个阶段是同时进行的；**map的输出也是一边被取回一边被合并的（归并排序）。**

##### Secondary Sort

如果在reduce前，想要将中间的键的分组规则与键的分组等价规则不同，那么可以通过  Job.setSortComparatorClass(Class) 来指定一个Comparator，控制中间结果的key如何被分组，所以结合两者可以实现按**值的二次排序**。

##### Reduce

在这个阶段，框架为已分组的输入数据中的每个 <key, (list of values)>对调用一次 reduce(WritableComparable, Iterable<Writable>, Context) 方法。

Reduce任务的输出通常是通过调用 Context.write(WritableComparable, Writable) 写入文件系统的。

应用程序使用 **Counters（计数器）** 汇报统计信息。

**Reducer的输出是没有排序的。**

##### 需要多少个Reduce

Reduce 的数目建议是 **0.95或1.75乘以 (<no. of nodes> * <no. of maximum containers per node>)**。

用0.95，所有 Reduce 可以在 Map 完成时就立刻启动传输 Map 的输出结果。用1.75，速度快的节点可以在完成第一轮 Reduce 任务后，可以开始第二轮，这样可以得到比较好的负载均衡的效果。(???)

增加 Reduce 的数目会增加整个框架的开销，但可以改善负载均衡，降低由于执行失败带来的负面影响。

上述比例因子比整体数目稍小一些是为了给框架中的推测性任务（speculative-tasks） 或失败的任务预留一些 Reducer 的资源。

##### Reducer NONE

如果没有归约要进行，那么设置 Reducer 任务的数目为零是合法的。

这种情况下，Map 任务的输出会直接被写入由 FileOutputFormat.setOutputPath(Job, Path) 指定的输出路径。框架在把它们写入FileSystem之前 **没有对它们进行排序**。

#### (3)Partitioner

Partitioner 用于 **划分键值空间（key space）**。

Partitioner 负责控制 Map 输出结果 key 的分割。Key（或者一个key子集）通常使用 Hash 函数产生分区。分区的数目与一个作业的 Reducer 任务的数目是一样的。因此，它控制将中间过程的key（也就是这条记录）应该发送给m个reduce任务中的哪一个来进行reduce操作。

HashPartitioner是默认的 Partitioner。

#### (4)Counter

Counter 应用程序用来汇报统计信息的机制。

Mapper and Reducer 类可以使用 Counter 汇报统计信息。

### 2、Job Configuration

### 3、Task Execution & Environment

### 4、Job Submission and Monitoring

### 5、Job Input

InputFormat 为 MapReduce Job 描述输入的细节规范。

MapReduce框架根据 Job 的 InputFormat 做以下工作：

    - 检查 Job 输入的有效性。
    - 把输入文件切分成多个逻辑InputSplit实例，并分别分发每个InputSplit给一个 Mapper。
    - 提供RecordReader，RecordReader从逻辑InputSplit中获得输入记录，交由Mapper处理。

基于文件的InputFormat（通常是 FileInputFormat的子类）** 默认行为是按照输入文件的字节大小，把输入数据切分成逻辑InputSplit 。InputSplit的上限是文件系统的block的大小，下限通过 mapreduce.input.fileinputformat.split.minsize 设置。**

考虑到边界情况，对于很多应用程序来说，很明显 **按照输入文件大小进行逻辑分片是不能满足需求的。 在这种情况下，应用程序需要实现一个RecordReader** 来处理记录的边界并为每个任务提供一个逻辑分块的面向记录的视图。

**TextInputFormat 是默认的InputFormat。**

如果一个作业的Inputformat是TextInputFormat， 并且框架检测到输入文件的后缀是.gz，就会使用对应的CompressionCodec自动解压缩这些文件。 但是需要注意，上述 **带后缀的压缩文件不会被切分，并且整个压缩文件会分给一个mapper来处理** 。

#### (1)InputSplit

InputSplit 表示一个独立Mapper要处理的数据。

一般的 **InputSplit 是字节样式输入(byte-oriented)**，然后由 RecordReader 处理、转化成记录样式(record-oriented)。

FileSplit 是默认的 InputSplit。 设置 mapreduce.map.input.file 为输入文件的路径。

#### (2)RecordReader

RecordReader 从 InputSlit 读入 <key, value> 对。

一般的，RecordReader 把由 InputSplit 提供的字节样式的输入文件，转化成由Mapper处理的记录样式的文件。因此 RecordReader 负责处理记录的边界情况和presents the tasks with keys and values

### 6、Job Output

OutputFormat 描述 MapReduce Job的输出样式。

MapReduce 框架根据 Job 的 OutputFormat 做以下工作：

    - 检验作业的输出，例如检查输出路径是否已经存在。
    - 提供一个 RecordWriter 的实现，用来输出 Job 结果。输出文件保存在 FileSystem 上。

TextOutputFormat是默认的 OutputFormat。

#### (1)OutputCommitter

OutputCommitter 确保了 MapReduce Job 任务结果的提交。

MapReduce 框架根据 Job 的 OutputCommitter 做以下工作：

    - 初始化时设置 Job。例如，在 Job 初始化阶段，创建临时输出目录。当Job 处在准备阶段和初始化任务完成后，由一个单独的任务完成 Job 设置。一旦此任务完成，Job进入 RUNNING 阶段。
    - Job完成后，清理后续工作。例如，Job完成后，移除临时输出目录。在Job结束时，Job 的清理工作由一个单独的任务完成。此任务完成，Job 宣布 SUCCEDED/FAILED/KILLED。
    - 设置任务的临时输出。
    - 检查任务是否需要被提交。如果任务不需要提交，避免了任务重复提交。
    - 提交任务的结果。
    - 放弃提交任务。如果任务 FAILED/KILLED，输出将被清理。如果任务不能被清理，会启动一个单独的、具有相同attempt-id 的任务做这个清理工作。

FileOutputCommitter 是默认的 OutputCommitter. Job 的设置和清理任务会占用 map 或 reduce 的 containers，且具有最好的优先级。

#### (2)Task Side-Effect Files

在一些应用程序中，子任务需要产生一些附属文件(Side-Effect Files)，这些文件与 Job 实际输出结果的文件不同。

那么会存在这种问题：两个相同的 Mapper 实例或 两个相同的Reducer 实例（比如预防性任务）同时打开或者写入 FileSystem 上的同一文件(路径)。因此应用程序在写文件的时候需要为每次任务（不仅仅是每次任务，每个任务可以尝试执行很多次）尝试 **选取一个独一无二的文件名** (使用attemptid，例如task_200709221812_0001_m_000000_0)。

为了避免上述问题，当 OutputCommitter 是 FileOutputCommitter 时，MapReduce 框架 为每次尝试执行的任务 维护一个可用的子目录 ${mapreduce.output.fileoutputformat.outputdir}/_temporary/_${taskid}，这个目录位于本次尝试执行任务输出结果所在的FileSystem上，可以通过 ${mapreduce.task.output.dir} 来访问这个子目录。 对于成功完成的task-attempt，只有 ${mapreduce.output.fileoutputformat.outputdir}/_temporary/_${taskid} 下的文件会移动到 ${mapreduce.output.fileoutputformat.outputdir} 。当然，框架会丢弃那些失败的 task-attempts 的子目录。这种处理过程对于应用程序来说是完全透明的。

在任务执行期间，应用程序在写文件时可以利用这个特性，比如 通过 FileOutputFormat.getWorkOutputPath(Conext) 获得 ${mapreduce.task.output.dir}  目录， 并在其下创建任意任务执行时所需的side-file，框架在任务尝试成功时会马上移动这些文件，因此不需要在程序内为每次任务尝试选取一个独一无二的名字。

注意：在每次任务尝试执行期间，${mapreduce.task.output.dir} 的值实际上是 ${mapreduce.output.fileoutputformat.outputdir}/_temporary/_{$taskid}，这个值是 MapReduce 框架创建的。 所以使用这个特性的方法是，**在 FileOutputFormat.getWorkOutputPath(Conext) 返回的路径下创建side-file** 即可。

对于只使用map不使用reduce的作业，这个结论也成立。这种情况下，map的输出结果直接生成到HDFS上。

#### (3)RecordWriter

RecordWriter 生成<key, value> 对到输出文件。

RecordWriter 把 Job 的输出结果写到 FileSystem。

### 7、Other Useful Features

#### (1)Data Compression

Hadoop MapReduce 提供了压缩算法，可以对map的输出和job的输出进行压缩。它还
与 [zlib](http://www.zlib.net/) 压缩算法的 [CompressionCodec](https://hadoop.apache.org/docs/stable/api/org/apache/hadoop/io/compress/CompressionCodec.html) 
实现绑定在一起。同时也支持 [gzip](http://www.gzip.org/)，[bzip2](http://www.bzip.org/)，
[snappy](https://code.google.com/archive/p/snappy/) 和 [lz4](https://github.com/lz4/lz4) 文件格式。

考虑到 Java 库的性能和不可用性 Hadoop 提供了上述压缩算法的原生实现。
更多详细信息请见[此](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html)

##### Intermediate Outputs

通过 `Configuration.set(MRJobConfig.MAP_OUTPUT_COMPRESS, boolean)` 
和 `Configuration.set(MRJobConfig.MAP_OUTPUT_COMPRESS_CODEC, Class)`
可以控制map输出的压缩。

##### Job Outputs

通过 `FileOutputFormat.setCompressOutput(Job, boolean)` 
和 `FileOutputFormat.setOutputCompressorClass(Job, Class)`
可以控制 job 输出的压缩。


如果 job 输出需要是 `SequenceFileOutputFormat` 格式,那么可以设置
`SequenceFileOutputFormat.setOutputCompressionType(Job, SequenceFile.CompressionType)` 
(例如:RECORD / BLOCK - 默认是 RECORD)属性来实现.


### 8、Example: WordCount v2.0


