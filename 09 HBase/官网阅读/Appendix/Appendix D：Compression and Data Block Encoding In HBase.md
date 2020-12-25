# Appendix D: Compression and Data Block Encoding In HBase

[TOC]

> Codecs mentioned in this section are for encoding and decoding data blocks or row keys. For information about replication codecs, see [cluster.replication.preserving.tags](https://hbase.apache.org/2.2/book.html#cluster.replication.preserving.tags).

**本节中提到的编解码器用于编码和解码数据块或行键**。有关复制编解码器的信息，请参见`cluster.replication.preserving.tags`。

> Some of the information in this section is pulled from a [discussion](http://search-hadoop.com/m/lL12B1PFVhp1/v=threaded) on the HBase Development mailing list.

> HBase supports several different compression algorithms which can be enabled on a ColumnFamily. Data block encoding attempts to limit duplication of information in keys, taking advantage of some of the fundamental designs and patterns of HBase, such as sorted row keys and the schema of a given table. Compressors reduce the size of large, opaque byte arrays in cells, and can significantly reduce the storage space needed to store uncompressed data.

HBase 支持几种不同的压缩算法，可以在一个列族上启用。

**数据块编码试图限制键中信息的重复**，利用 HBase 的一些基本设计和模式，例如有序的行键和给定表的模式。压缩器可以减少单元格中大型不透明的字节数组的大小，并可以显著减少存储未压缩数据所需的存储空间。

> Compressors and data block encoding can be used together on the same ColumnFamily.

压缩器和数据块编码可以在同一个列族上一起使用。

#### Changes Take Effect Upon Compaction

> If you change compression or encoding for a ColumnFamily, the changes take effect during compaction.

**如果更改列族的压缩或编码，这些更改将在 compaction 期间生效**。

> Some codecs take advantage of capabilities built into Java, such as GZip compression. Others rely on native libraries. Native libraries may be available as part of Hadoop, such as LZ4. In this case, HBase only needs access to the appropriate shared library.

一些编解码器利用了内置在 Java 中的功能，比如 GZip 压缩。

还有一些依赖于本地库。本地库可以作为 Hadoop 的一部分，比如 LZ4。在这种情况下，HBase 只需要访问适当的共享库。

> Other codecs, such as Google Snappy, need to be installed first. Some codecs are licensed in ways that conflict with HBase’s license and cannot be shipped as part of HBase.

其他编解码器，如谷歌 Snappy，需要先安装。

有些编解码器的许可方式与 HBase 的许可冲突，不能作为 HBase 的一部分发布。

> This section discusses common codecs that are used and tested with HBase. No matter what codec you use, be sure to test that it is installed correctly and is available on all nodes in your cluster. Extra operational steps may be necessary to be sure that codecs are available on newly-deployed nodes. You can use the [compression.test](https://hbase.apache.org/2.2/book.html#compression.test) utility to check that a given codec is correctly installed.

本节讨论 HBase 使用和测试的常用编解码器。

无论使用哪种编解码器，请确保测试它是否正确安装，并且在集群中的所有节点上都可用。

为了确保编解码器在新部署的节点上可用，可能需要额外的操作步骤。您可以使用 `compression.test` 实用程序，以检查给定的编解码器是否正确安装。

> To configure HBase to use a compressor, see [compressor.install](https://hbase.apache.org/2.2/book.html#compressor.install). To enable a compressor for a ColumnFamily, see [changing.compression](https://hbase.apache.org/2.2/book.html#changing.compression). To enable data block encoding for a ColumnFamily, see [data.block.encoding.enable](https://hbase.apache.org/2.2/book.html#data.block.encoding.enable).

**如何配置 HBase 使用压缩器，请参见 `compressor.install`**。

**若要为列族启用压缩器，请参见 `changing.compression`**。

**若要为列族启用数据块编码，请参见 `data.block.encoding.enable`**。

#### Block Compressors

- none

- Snappy

- LZO

- LZ4

- GZ

#### Data Block Encoding Types

##### Prefix

> Often, keys are very similar. Specifically, keys often share a common prefix and only differ near the end. For instance, one key might be RowKey:Family:Qualifier0 and the next key might be RowKey:Family:Qualifier1.

**通常，keys 的非常相似的。具体地说，keys 通常共享一个共同的前缀，并且只有在接近结尾时才有差异**。例如，一个 key 可能是 `RowKey:Family:Qualifier0`，下一个 key 可能是 `RowKey:Family:Qualifier1`。

> In Prefix encoding, an extra column is added which holds the length of the prefix shared between the current key and the previous key. Assuming the first key here is totally different from the key before, its prefix length is 0.

**在前缀编码中，添加一个额外的列，该列保存当前 key 和前一个 key 间共享的前缀的长度**。假设这里的第一个 key 与之前的 key 完全不同，那么它的前缀长度为0。

> The second key’s prefix length is 23, since they have the first 23 characters in common.

第二个 key 的前缀长度是23，因为它们有共同的前 23 个字符。

> Obviously if the keys tend to have nothing in common, Prefix will not provide much benefit.

显然，**如果 keys 没有任何共同之处，前缀将不会提供太多好处**。

> The following image shows a hypothetical ColumnFamily with no data block encoding.

下图显示了一个没有数据块编码的假设的列族。

![hbase08](../image/hbase08.png)

> Here is the same data with prefix data encoding.

下面是带有前缀数据编码的相同数据。

![hbase09](../image/hbase09.png)

##### Diff

> Diff encoding expands upon Prefix encoding. Instead of considering the key sequentially as a monolithic series of bytes, each key field is split so that each part of the key can be compressed more efficiently.

Diff 编码扩展了前缀编码。**不是按顺序将 key 作为为一个统一的字节系列，而是将每个 key 字段拆分，以便更有效地压缩 key 的每个部分**。

> Two new fields are added: timestamp and type.

添加了两个新字段:时间戳和类型。

> If the ColumnFamily is the same as the previous row, it is omitted from the current row.

**如果列族与前一行相同，则从当前行省略它**。

> If the key length, value length or type are the same as the previous row, the field is omitted.

**如果 key 长度、值长度或类型与前一行相同，则省略对应的该字段**。

> In addition, for increased compression, the timestamp is stored as a Diff from the previous row’s timestamp, rather than being stored in full. Given the two row keys in the Prefix example, and given an exact match on timestamp and the same type, neither the value length, or type needs to be stored for the second row, and the timestamp value for the second row is just 0, rather than a full timestamp.

此外，为了增加压缩，**时间戳将与前一行的时间戳比较，存储不同的部分，而不是全部存储**。

给定两个行键，并且给定精确匹配的时间戳和相同的类型，则不需要为第二行存储值长度或类型，并且第二行的时间戳值仅为0，而不是完整的时间戳。

> Diff encoding is disabled by default because writing and scanning are slower but more data is cached.

Diff 编码在**默认情况下是禁用的**，因为写入和扫描会变慢，但会缓存更多的数据。

> This image shows the same ColumnFamily from the previous images, with Diff encoding

此图像显示了与前面图像相同的列族，使用了 Diff 编码。

![hbase10](../image/hbase10.png)

##### Fast Diff

> Fast Diff works similar to Diff, but uses a faster implementation. It also adds another field which stores a single bit to track whether the data itself is the same as the previous row. If it is, the data is not stored again.

Fast Diff 的工作原理与 Diff 相似，但使用了更快的实现。

它还**添加了另一个字段，该字段存储一个位，来跟踪数据本身是否与前一行相同。如果是，则不再存储数据**。

> Fast Diff is the recommended codec to use if you have long keys or many columns.

**如果有长 keys 或多列，建议使用 Fast Diff 编解码器**。

> The data format is nearly identical to Diff encoding, so there is not an image to illustrate it.

数据格式与 Diff 编码几乎相同，因此没有图像来说明它。

##### Prefix Tree

> Prefix tree encoding was introduced as an experimental feature in HBase 0.96. It provides similar memory savings to the Prefix, Diff, and Fast Diff encoder, but provides faster random access at a cost of slower encoding speed. It was removed in hbase-2.0.0. It was a good idea but little uptake. If interested in reviving this effort, write the hbase dev list.

前缀树编码作为 HBase 0.96 的一个实验特性被引入。

它提供了与 Prefix、Diff 和 Fast Diff 编码器类似的内存节省，但以较慢的编码速度为代价，提供了更快的随机访问。

它在 hbase-2.0.0 中被删除。这是个好主意，但很少有人接受。

## D.1. Which Compressor or Data Block Encoder To Use

> The compression or codec type to use depends on the characteristics of your data. Choosing the wrong type could cause your data to take more space rather than less, and can have performance implications.

要使用哪种类型的压缩器或编解码器取决于数据的特征。选择错误的类型可能会导致数据占用更多而不是更少的空间，并可能影响性能。

> In general, you need to weigh your options between smaller size and faster compression/decompression. Following are some general guidelines, expanded from a discussion at [Documenting Guidance on compression and codecs](http://search-hadoop.com/m/lL12B1PFVhp1).

通常，**需要权衡在占用更小的空间和更快的压缩/解压缩速度**。

以下是一些通用的指导方针，是在关于压缩和编解码器的文档指南的讨论中扩展而来的。

> If you have long keys (compared to the values) or many columns, use a prefix encoder. FAST_DIFF is recommended.

- 如果 keys 很长(相比于值)或列很多，请使用前缀编码器。推荐 FAST_DIFF。

> If the values are large (and not precompressed, such as images), use a data block compressor.

- 如果值很大(并且没有预压缩，比如图像)，则使用数据块压缩器。

> Use GZIP for cold data, which is accessed infrequently. GZIP compression uses more CPU resources than Snappy or LZO, but provides a higher compression ratio.

- 对于不经常访问的冷数据，使用 GZIP。 GZIP 压缩比 Snappy 或 LZO 使用更多的 CPU 资源，但提供更高的压缩比。

> Use Snappy or LZO for hot data, which is accessed frequently. Snappy and LZO use fewer CPU resources than GZIP, but do not provide as high of a compression ratio.

- 对于访问频繁的热数据，请使用 Snappy 或 LZO 。 Snappy 和 LZO 比 GZIP 使用更少的 CPU 资源，但不能提供更高的压缩比。

> In most cases, enabling Snappy or LZO by default is a good choice, because they have a low performance overhead and provide space savings.

- 在大多数情况下，默认情况下启用 Snappy 或 LZO 是一个不错的选择，因为它们的性能开销较低，而且节省了空间。

> Before Snappy became available by Google in 2011, LZO was the default. Snappy has similar qualities as LZO but has been shown to perform better.

- 在 2011 年 Snappy 被谷歌使用之前，LZO 是默认版本。Snappy 与 LZO 有着相似的性质，但表现得更好。

## D.2. Making use of Hadoop Native Libraries in HBase

> The Hadoop shared library has a bunch of facility including compression libraries and fast crc’ing — hardware crc’ing if your chipset supports it. To make this facility available to HBase, do the following. HBase/Hadoop will fall back to use alternatives if it cannot find the native library versions — or fail outright if you asking for an explicit compressor and there is no alternative available.

Hadoop 共享库有很多工具，包括压缩库和快速 crc'ing(如果你的芯片组支持硬件 crc'ing)。要使这个功能对 HBase 可用，请执行以下操作。如果 HBase/Hadoop 找不到本地库版本，它会回退到使用替代方案--或者如果你要求显式指定压缩器，而又没有可用的替代方案，它会直接失败。

> First make sure of your Hadoop. Fix this message if you are seeing it starting Hadoop processes:

首先确保你的 Hadoop。如果在启动 Hadoop 进程时，看到它，修复这个消息，:

	16/02/09 22:40:24 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable

> It means is not properly pointing at its native libraries or the native libs were compiled for another platform. Fix this first.

这意味着没有正确地指向它的本地库，或者本地库为另一个平台编译。先解决这个问题。

> Then if you see the following in your HBase logs, you know that HBase was unable to locate the Hadoop native libraries:

然后，如果你在你的 HBase 日志中看到以下情况，你就知道 HBase 无法定位到 Hadoop 本地库:

	2014-08-07 09:26:20,139 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable

> If the libraries loaded successfully, the WARN message does not show. Usually this means you are good to go but read on.

如果库成功加载，则不会显示 WARN 消息。通常这意味着你可以继续读下去了。

> Let’s presume your Hadoop shipped with a native library that suits the platform you are running HBase on. To check if the Hadoop native library is available to HBase, run the following tool (available in Hadoop 2.1 and greater):

让我们假设 Hadoop 附带了一个本地库，这个库适合运行 HBase 的平台。**检查 Hadoop 本地库是否对 HBase 可用**，使用以下工具(在Hadoop 2.1及以上版本中可用):

	$ ./bin/hbase --config ~/conf_hbase org.apache.hadoop.util.NativeLibraryChecker
	2014-08-26 13:15:38,717 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
	Native library checking:
	hadoop: false
	zlib:   false
	snappy: false
	lz4:    false
	bzip2:  false
	2014-08-26 13:15:38,863 INFO  [main] util.ExitUtil: Exiting with status 1

> Above shows that the native hadoop library is not available in HBase context.

以上说明了本地 hadoop 库在 HBase 上下文中是不可用的。

> The above NativeLibraryChecker tool may come back saying all is hunky-dory — i.e. all libs show 'true', that they are available — but follow the below presecription anyways to ensure the native libs are available in HBase context, when it goes to use them.

上面的 NativeLibraryChecker 工具可能会回来说一切都很好--例如，所有的库都显示'true'，表示它们是可用的--但无论如何都要遵循以下的处方，以确保本地库在 HBase 的上下文中是可用的，当它去使用它们时。

> To fix the above, either copy the Hadoop native libraries local or symlink to them if the Hadoop and HBase stalls are adjacent in the filesystem. You could also point at their location by setting the LD_LIBRARY_PATH environment variable in your hbase-env.sh.

**要解决上述问题，如果 Hadoop 和 HBase 的位置在文件系统中相邻，要么将本地的 Hadoop 本地库复制到它们，要么将 symlink 复制到它们**。

**还可以通过在 `hbase-env.sh` 中设置 `LD_LIBRARY_PATH` 环境变量来指向它们的位置**。

> Where the JVM looks to find native libraries is "system dependent" (See java.lang.System#loadLibrary(name)). On linux, by default, is going to look in lib/native/PLATFORM where PLATFORM is the label for the platform your HBase is installed on. On a local linux machine, it seems to be the concatenation of the java properties os.name and os.arch followed by whether 32 or 64 bit. HBase on startup prints out all of the java system properties so find the os.name and os.arch in the log. For example:

JVM 查找本地库的地方是“依赖于系统的”。

**在 linux 上，默认情况下，将在 `lib/native/PLATFORM` 中查找**，PLATFORM 是安装 HBase 的平台标签。

**在本地 linux 机器上，它似乎是 java 属性 `os.name` 和 `os.arch` 的连接，`os.arch`后面是 32 位或 64 位**。

在启动时，HBase 打印出所有的 java 系统属性，因此可以在日志中找到 `os.name` 和 `os.arch`。例如:

	...
	2014-08-06 15:27:22,853 INFO  [main] zookeeper.ZooKeeper: Client environment:os.name=Linux
	2014-08-06 15:27:22,853 INFO  [main] zookeeper.ZooKeeper: Client environment:os.arch=amd64
	...

> So in this case, the PLATFORM string is Linux-amd64-64. Copying the Hadoop native libraries or symlinking at lib/native/Linux-amd64-64 will ensure they are found. Rolling restart after you have made this change.

所以在这个例子中，PLATFORM 字符串是 `Linux-amd64-64`。复制 `lib/native/Linux-amd64-64` 下的 Hadoop 本地库或 symlink 以确保它们被找到。在进行此更改后，滚动重新启动。

> Here is an example of how you would set up the symlinks. Let the hadoop and hbase installs be in your home directory. Assume your hadoop native libs are at `~/hadoop/lib/native`. Assume you are on a Linux-amd64-64 platform. In this case, you would do the following to link the hadoop native lib so hbase could find them.

下面是如何设置 symlinks 的示例。

**让 hadoop 和 hbase 安装在你的主目录中**。假设你的 hadoop 本地库位于 `~/hadoop/lib/native`。假设使用的是 `Linux-amd64-64`平台。

在本例中，你将执行以下操作来链接 hadoop 本地库，以便 hbase 能够找到它们。

	...
	$ mkdir -p ~/hbaseLinux-amd64-64 -> /home/stack/hadoop/lib/native/lib/native/
	$ cd ~/hbase/lib/native/
	$ ln -s ~/hadoop/lib/native Linux-amd64-64
	$ ls -la
	# Linux-amd64-64 -> /home/USER/hadoop/lib/native
	...

> If you see PureJavaCrc32C in a stack track or if you see something like the below in a perf trace, then native is not working; you are using the java CRC functions rather than native:

如果在堆栈跟踪中看到 PureJavaCrc32C，或者在 perf 跟踪中看到如下内容，那么本地不起作用；你使用的是 java 的 CRC 函数而不是本地的:

	5.02%  perf-53601.map      [.] Lorg/apache/hadoop/util/PureJavaCrc32C;.update

> See [HBASE-11927 Use Native Hadoop Library for HFile checksum (And flip default from CRC32 to CRC32C)](https://issues.apache.org/jira/browse/HBASE-11927), for more on native checksumming support. See in particular the release note for how to check if your hardware to see if your processor has support for hardware CRCs. Or checkout the Apache Checksums in HBase blog post.

请参阅 HBASE-11927 使用本地 Hadoop 库进行 HFile 校验和(并将默认值从 CRC32 翻转到 CRC32C)，了解原生校验和支持的更多信息。具体请参阅发布说明，了解如何检查您的硬件，以确定您的处理器是否支持硬件crc。或者在HBase博客文章中检查Apache校验和。

> Here is example of how to point at the Hadoop libs with LD_LIBRARY_PATH environment variable:

下面是如何用 `LD_LIBRARY_PATH` 环境变量指向 Hadoop 库的示例:

```sh
$ LD_LIBRARY_PATH=~/hadoop-2.5.0-SNAPSHOT/lib/native ./bin/hbase --config ~/conf_hbase org.apache.hadoop.util.NativeLibraryChecker
2014-08-26 13:42:49,332 INFO  [main] bzip2.Bzip2Factory: Successfully loaded & initialized native-bzip2 library system-native
2014-08-26 13:42:49,337 INFO  [main] zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
Native library checking:
hadoop: true /home/stack/hadoop-2.5.0-SNAPSHOT/lib/native/libhadoop.so.1.0.0
zlib:   true /lib64/libz.so.1
snappy: true /usr/lib64/libsnappy.so.1
lz4:    true revision:99
bzip2:  true /lib64/libbz2.so.1
```

> Set in hbase-env.sh the LD_LIBRARY_PATH environment variable when starting your HBase.

启动 HBase 时，在 `hbase-env.sh` 中设置 LD_LIBRARY_PATH 环境变量。

## D.3. Compressor Configuration, Installation, and Use

### D.3.1. Configure HBase For Compressors

> Before HBase can use a given compressor, its libraries need to be available. Due to licensing issues, only GZ compression is available to HBase (via native Java libraries) in a default installation. Other compression libraries are available via the shared library bundled with your hadoop. The hadoop native library needs to be findable when HBase starts. See

在 HBase 使用给定的压缩器之前，它的库必须是可用的。由于许可问题，在默认的安装中只有 GZip 压缩对 HBase 可用(通过本地Java库)。

其他压缩库可以通过与 hadoop 绑定的共享库获得。hadoop 本地库需要在 HBase 启动时被找到。

#### Compressor Support On the Master

> A new configuration setting was introduced in HBase 0.95, to check the Master to determine which data block encoders are installed and configured on it, and assume that the entire cluster is configured the same. This option, hbase.master.check.compression, defaults to true. This prevents the situation described in [HBASE-6370](https://issues.apache.org/jira/browse/HBASE-6370), where a table is created or modified to support a codec that a region server does not support, leading to failures that take a long time to occur and are difficult to debug.

HBase 0.95 中引入了一个新的配置设置，**检查 Master 以确定在它上安装和配置了哪些数据块编码器**，并假设整个集群的配置相同。

这个选项 **`hbase.master.check.compression` 默认为 true**。这就避免了 HBASE-6370 中描述的情况，即创建或修改一个表，来支持一个区域服务器不支持的编解码器【？？？】，从而导致花费很长时间发生的故障，并且很难调试。

> If hbase.master.check.compression is enabled, libraries for all desired compressors need to be installed and configured on the Master, even if the Master does not run a region server.

如果启用了 `hbase.master.check.compression`，所有需要的压缩器的库都需要安装、配置在 Master 上，即使 Master 没有运行 region server。

#### Install GZ Support Via Native Libraries

> HBase uses Java’s built-in GZip support unless the native Hadoop libraries are available on the CLASSPATH. The recommended way to add libraries to the CLASSPATH is to set the environment variable HBASE_LIBRARY_PATH for the user running HBase. If native libraries are not available and Java’s GZIP is used, Got brand-new compressor reports will be present in the logs. See [brand.new.compressor](https://hbase.apache.org/2.2/book.html#brand.new.compressor)).

除非类路径上有可用的本地 Hadoop 库，否则**HBase 使用 Java 内置的 GZip 支持**。

在类路径中添加库的建议方法是，为运行 HBase 的用户设置环境变量 `HBASE_LIBRARY_PATH`，。如果本地库不可用，并且使用了 Java 的 GZIP，则日志中将显示获得的全新压缩器报告。

#### Install LZO Support

> HBase cannot ship with LZO because of incompatibility between HBase, which uses an Apache Software License (ASL) and LZO, which uses a GPL license. See the [Hadoop-LZO](https://github.com/twitter/hadoop-lzo/blob/master/README.md) at Twitter for information on configuring LZO support for HBase.

**由于使用 ASL 的 HBase 和使用 GPL 许可的 LZO 不兼容，HBase 不能和 LZO 一起使用。关于配置对 HBase 的 LZO 支持的信息，请参阅 Twitter 上的 Hadoop-LZO**。

> If you depend upon LZO compression, consider configuring your RegionServers to fail to start if LZO is not available. See [hbase.regionserver.codecs](https://hbase.apache.org/2.2/book.html#hbase.regionserver.codecs).

如果你依赖于 LZO 压缩，且 LZO 不可用，请考虑将你的 regionserver 配置为启动失败。

#### Configure LZ4 Support

> LZ4 support is bundled with Hadoop. Make sure the hadoop shared library (libhadoop.so) is accessible when you start HBase. After configuring your platform (see [hadoop.native.lib](https://hbase.apache.org/2.2/book.html#hadoop.native.lib)), you can make a symbolic link from HBase to the native Hadoop libraries. This assumes the two software installs are colocated. For example, if my 'platform' is Linux-amd64-64:

**LZ4 支持与 Hadoop 捆绑在一起的。启动 HBase 时，请确保 hadoop 共享库(libhadoop.so)是可访问的**。

在配置好平台之后，你可以创建一个从 HBase 到本地 Hadoop 库的符号链接。

这假设两个软件安装是并行的。例如，如果我的“平台”是 Linux-amd64-64:

	$ cd $HBASE_HOME
	$ mkdir lib/native
	$ ln -s $HADOOP_HOME/lib/native lib/native/Linux-amd64-64

> Use the compression tool to check that LZ4 is installed on all nodes. Start up (or restart) HBase. Afterward, you can create and alter tables to enable LZ4 as a compression codec.:

使用压缩工具检查 LZ4 是否安装在所有节点上。

启动(或重启)HBase。之后，你可以创建和修改表，来启用 LZ4 作为压缩编解码器。

	hbase(main):003:0> alter 'TestTable', {NAME => 'info', COMPRESSION => 'LZ4'}

#### Install Snappy Support

> HBase does not ship with Snappy support because of licensing issues. You can install Snappy binaries (for instance, by using yum install snappy on CentOS) or build Snappy from source. After installing Snappy, search for the shared library, which will be called libsnappy.so.X where X is a number. If you built from source, copy the shared library to a known location on your system, such as /opt/snappy/lib/.

由于许可问题，**HBase 不支持 Snappy。你可以安装 Snappy 的二进制文件(例如，在 CentOS 上使用 yum install Snappy)或者从源代码构建 Snappy**。

安装完 Snappy 之后，搜索它，名为 libsnappy.so.X，X是一个数字。

如果从源代码构建，则将它复制到系统上的已知位置，例如`/opt/snappy/lib/`。

> In addition to the Snappy library, HBase also needs access to the Hadoop shared library, which will be called something like libhadoop.so.X.Y, where X and Y are both numbers. Make note of the location of the Hadoop library, or copy it to the same location as the Snappy library.

**除了 Snappy 库，HBase还需要访问 Hadoop 共享库，它将被称为 `libhadoop.so.X` 之类的东西**， X 和 Y 都是数字。注意 Hadoop 库的位置，或者将其复制到与 Snappy 库相同的位置。

> The Snappy and Hadoop libraries need to be available on each node of your cluster. See [compression.test](https://hbase.apache.org/2.2/book.html#compression.test) to find out how to test that this is the case.

Snappy 和 Hadoop 库需要在集群的每个节点上可用。

> See [hbase.regionserver.codecs](https://hbase.apache.org/2.2/book.html#hbase.regionserver.codecs) to configure your RegionServers to fail to start if a given compressor is not available.

如果给定的压缩器不可用，配置 RegionServers 的编解码器将无法启动。

> Each of these library locations need to be added to the environment variable HBASE_LIBRARY_PATH for the operating system user that runs HBase. You need to restart the RegionServer for the changes to take effect.

每个库的位置都需要添加到运行 HBase 的操作系统用户的环境变量 `HBASE_LIBRARY_PATH` 中。需要重新启动 RegionServer ，使更改生效。

#### CompressionTest

> You can use the CompressionTest tool to verify that your compressor is available to HBase:

你可以**使用 CompressionTest 工具来验证你的压缩器是否对 HBase 可用:**

	$ hbase org.apache.hadoop.hbase.util.CompressionTest hdfs://host/path/to/hbase snappy

#### Enforce Compression Settings On a RegionServer

> You can configure a RegionServer so that it will fail to restart if compression is configured incorrectly, by adding the option hbase.regionserver.codecs to the hbase-site.xml, and setting its value to a comma-separated list of codecs that need to be available. For example, if you set this property to lzo,gz, the RegionServer would fail to start if both compressors were not available. This would prevent a new server from being added to the cluster without having codecs configured properly.

**可以通过在 `hbase-site.xml` 中添加选项 `hbase.regionserver.codecs`，并将其值设置为可用的编解码器的逗号分隔列表，来配置 RegionServer，这样如果压缩配置错误，它将无法重新启动**。

例如，如果将此属性设置为 `lzo,gz`，那么如果两个压缩器都不可用，RegionServer 将无法启动。这将防止在没有正确配置编解码器的情况下，将新服务器添加到集群中。

### D.3.2. Enable Compression On a ColumnFamily

> To enable compression for a ColumnFamily, use an alter command. You do not need to re-create the table or copy data. If you are changing codecs, be sure the old codec is still available until all the old StoreFiles have been compacted.

**要启用对列族的压缩，请使用 `alter` 命令**。你不需要重新创建表或复制数据。如果你正在更改编解码器，请确保旧的编解码器仍然可用，直到所有旧的 StoreFiles 都已 compacted。

#### Enabling Compression on a ColumnFamily of an Existing Table using HBaseShell

```sh
hbase> disable 'test'
hbase> alter 'test', {NAME => 'cf', COMPRESSION => 'GZ'}
hbase> enable 'test'
Creating a New Table with Compression On a ColumnFamily
hbase> create 'test2', { NAME => 'cf2', COMPRESSION => 'SNAPPY' }
Verifying a ColumnFamily’s Compression Settings
hbase> describe 'test'
DESCRIPTION                                          ENABLED
 'test', {NAME => 'cf', DATA_BLOCK_ENCODING => 'NONE false
 ', BLOOMFILTER => 'ROW', REPLICATION_SCOPE => '0',
 VERSIONS => '1', COMPRESSION => 'GZ', MIN_VERSIONS
 => '0', TTL => 'FOREVER', KEEP_DELETED_CELLS => 'fa
 lse', BLOCKSIZE => '65536', IN_MEMORY => 'false', B
 LOCKCACHE => 'true'}
1 row(s) in 0.1070 seconds
```

### D.3.3. Testing Compression Performance

> HBase includes a tool called LoadTestTool which provides mechanisms to test your compression performance. You must specify either -write or -update-read as your first parameter, and if you do not specify another parameter, usage advice is printed for each option.

HBase 有一个名为 **LoadTestTool 的工具，它可以测试你的压缩性能**。

必须指定 `-write` 或 `-update-read` 作为第一个参数，如果不指定其他参数，则会为每个选项打印使用建议。

#### LoadTestTool Usage

```sh
$ bin/hbase org.apache.hadoop.hbase.util.LoadTestTool -h
usage: bin/hbase org.apache.hadoop.hbase.util.LoadTestTool <options>
Options:
 -batchupdate                 Whether to use batch as opposed to separate
                              updates for every column in a row
 -bloom <arg>                 Bloom filter type, one of [NONE, ROW, ROWCOL]
 -compression <arg>           Compression type, one of [LZO, GZ, NONE, SNAPPY,
                              LZ4]
 -data_block_encoding <arg>   Encoding algorithm (e.g. prefix compression) to
                              use for data blocks in the test column family, one
                              of [NONE, PREFIX, DIFF, FAST_DIFF, ROW_INDEX_V1].
 -encryption <arg>            Enables transparent encryption on the test table,
                              one of [AES]
 -generator <arg>             The class which generates load for the tool. Any
                              args for this class can be passed as colon
                              separated after class name
 -h,--help                    Show usage
 -in_memory                   Tries to keep the HFiles of the CF inmemory as far
                              as possible.  Not guaranteed that reads are always
                              served from inmemory
 -init_only                   Initialize the test table only, don't do any
                              loading
 -key_window <arg>            The 'key window' to maintain between reads and
                              writes for concurrent write/read workload. The
                              default is 0.
 -max_read_errors <arg>       The maximum number of read errors to tolerate
                              before terminating all reader threads. The default
                              is 10.
 -multiput                    Whether to use multi-puts as opposed to separate
                              puts for every column in a row
 -num_keys <arg>              The number of keys to read/write
 -num_tables <arg>            A positive integer number. When a number n is
                              speicfied, load test tool  will load n table
                              parallely. -tn parameter value becomes table name
                              prefix. Each table name is in format
                              <tn>_1...<tn>_n
 -read <arg>                  <verify_percent>[:<#threads=20>]
 -regions_per_server <arg>    A positive integer number. When a number n is
                              specified, load test tool will create the test
                              table with n regions per server
 -skip_init                   Skip the initialization; assume test table already
                              exists
 -start_key <arg>             The first key to read/write (a 0-based index). The
                              default value is 0.
 -tn <arg>                    The name of the table to read or write
 -update <arg>                <update_percent>[:<#threads=20>][:<#whether to
                              ignore nonce collisions=0>]
 -write <arg>                 <avg_cols_per_key>:<avg_data_size>[:<#threads=20>]
 -zk <arg>                    ZK quorum as comma-separated host names without
                              port numbers
 -zk_root <arg>               name of parent znode in zookeeper
```

#### Example Usage of LoadTestTool

```sh
$ hbase org.apache.hadoop.hbase.util.LoadTestTool -write 1:10:100 -num_keys 1000000
          -read 100:30 -num_tables 1 -data_block_encoding NONE -tn load_test_tool_NONE
```

## D.4. Enable Data Block Encoding

> Codecs are built into HBase so no extra configuration is needed. Codecs are enabled on a table by setting the DATA_BLOCK_ENCODING property. Disable the table before altering its DATA_BLOCK_ENCODING setting. Following is an example using HBase Shell:

**编解码器内置在 HBase 中，因此不需要额外的配置**。

**通过设置 `DATA_BLOCK_ENCODING` 属性，可以在表上启用编解码器**。在更改表的 `DATA_BLOCK_ENCODING` 设置之前禁用该表。

HBase Shell 使用示例如下:

#### Enable Data Block Encoding On a Table

```sh
hbase>  disable 'test'
hbase> alter 'test', { NAME => 'cf', DATA_BLOCK_ENCODING => 'FAST_DIFF' }
Updating all regions with the new schema...
0/1 regions updated.
1/1 regions updated.
Done.
0 row(s) in 2.2820 seconds
hbase> enable 'test'
0 row(s) in 0.1580 seconds
```

#### Verifying a ColumnFamily’s Data Block Encoding

```sh
hbase> describe 'test'
DESCRIPTION                                          ENABLED
 'test', {NAME => 'cf', DATA_BLOCK_ENCODING => 'FAST true
 _DIFF', BLOOMFILTER => 'ROW', REPLICATION_SCOPE =>
 '0', VERSIONS => '1', COMPRESSION => 'GZ', MIN_VERS
 IONS => '0', TTL => 'FOREVER', KEEP_DELETED_CELLS =
 > 'false', BLOCKSIZE => '65536', IN_MEMORY => 'fals
 e', BLOCKCACHE => 'true'}
1 row(s) in 0.0650 seconds
```