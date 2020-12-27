# SequenceFile类

官网API地址：[https://hadoop.apache.org/docs/r3.2.1/api/index.html](https://hadoop.apache.org/docs/r3.2.1/api/index.html)

---------------------------------------------------------------------------

	@InterfaceAudience.Public
	@InterfaceStability.Stable
	public class SequenceFile
	extends Object

SequenceFile 是由二进制键值对组成的平面文件。

SequenceFile 类提供了 `SequenceFile.Writer`、`SequenceFile.Reader` 和 `SequenceFile.Sorter` 类来分别提供写入、读取和排序的功能。

有三种基于 `SequenceFile.CompressionType` 的 Writers，用来压缩键值对：

- 1.Writer：未压缩的记录。

- 2.RecordCompressWriter：压缩记录的文件，仅压缩值。

- 3.BlockCompressWriter：压缩块的文件，键和值分别收集到块里压缩。块的大小可配置。

压缩算法可以通过 `CompressionCodec` 来指定。

推荐使用由 SequenceFile 提供的静态 `createWriter` 方法来选择首选的格式。

`SequenceFile.Reader` 充当桥梁的角色，可以读取上述任何一种 SequenceFile 格式。

**SequenceFile Formats**

上述三种不同的 SequenceFile 格式取决于指定的 `CompressionType`。它们均共享一个下方描述的 header。

**SequenceFile Header**

- 版本：3个字节的魔术头SEQ，后面是1个字节的实际版本号(例如SEQ4或SEQ6)

- keyClassName：key 类

- valueClassName：value 类

- compression：一个布尔值，指定是否对文件中的键/值进行压缩。

- blockCompression：一个布尔值，定是否对文件中的键/值是否开启了块压缩。

- compression codec：CompressionCodec 类，用于对键和/或值进行压缩(如果启用了压缩)。

- 元数据：此文件的`SequenceFile.Metadata`。

- sync：一个标志头文件结束的同步标记。

**未压缩的 SequenceFile 格式**

- Header

- Record

	- Record length

	- Key length

	- Key

	- Value

- A sync-marker every few 100 kilobytes or so.

**压缩记录的 SequenceFile 格式**

- Header

- Record

	- Record length

	- Key length

	- Key

	- Compressed Value

- A sync-marker every few 100 kilobytes or so.

**压缩块的 SequenceFile 格式**

- Header

- Record Block

	- Uncompressed number of records in the block

	- Compressed key-lengths block-size 

	- Compressed key-lengths block

	- Compressed keys block-size

	- Compressed keys block

	- Compressed value-lengths block-size

	- Compressed value-lengths block

	- Compressed values block-size

	- Compressed values block

- A sync-marker every block.

键长度和值长度的压缩块由以 ZeroCompressedInteger 格式编码的单个键/值的实际长度组成。


**使用 SequenceFile 作为 MapReduce 的输出：**

```java
//设置outputformat
job.setOutputFormatClass(SequenceFileOutputFormat.class);

FileInputFormat.addInputPath(job, new Path("/user/root/input"));
FileOutputFormat.setOutputPath(job, new Path(outpath));
//设置压缩
FileOutputFormat.setCompressOutput(job, true);
//设置用哪种算法进行压缩
FileOutputFormat.setOutputCompressorClass(job, Lz4Codec.class);
//必须通过SequenceFileOutputFormat.setOutputCompressionType来指定SequenceFile文件的压缩类型
SequenceFileOutputFormat.setOutputCompressionType(job, SequenceFile.CompressionType.BLOCK);


```


帮助理解：

[https://blog.csdn.net/qq_23120963/article/details/104632012](https://blog.csdn.net/qq_23120963/article/details/104632012)

[https://www.cnblogs.com/asker009/p/10375402.html](https://www.cnblogs.com/asker009/p/10375402.html)