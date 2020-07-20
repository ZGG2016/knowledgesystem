# 官网：Spark SQL Guide03--Performance Tuning

*For some workloads, it is possible to improve performance by either caching data in memory, or by turning on some experimental options.*

考虑到工作负载，可以通过缓存数据到内存，或开启一些实验性选项，来优化性能。

## 1、Caching Data In Memory

*Spark SQL can cache tables using an in-memory columnar format by calling spark.catalog.cacheTable("tableName") or dataFrame.cache(). Then Spark SQL will scan only required columns and will automatically tune compression to minimize memory usage and GC pressure. You can call spark.catalog.uncacheTable("tableName") to remove the table from memory.*

*Configuration of in-memory caching can be done using the setConf method on SparkSession or by running SET key=value commands using SQL.*

`spark.catalog.cacheTable("tableName")` 或 `dataFrame.cache()` 可以缓存表。

然后 Spark SQL 就扫描某些列，自动压缩，以最小化内存使用和 gc 压力

`spark.catalog.uncacheTable("tableName")` 移除内存中的表。

内存缓存的配置可以使用 SparkSession 上的 setConf 方法或使用 SQL 运行 SET key=value 命令来完成。

Property Name | Defaul | Meaning | Since Version
---|:---|:---|:---
spark.sql.inMemoryColumnarStorage.compressed | true | When set to true Spark SQL will automatically select a compression codec for each column based on statistics of the data.是否压缩 | 1.0.1
spark.sql.inMemoryColumnarStorage.batchSize | 10000 | Controls the size of batches for columnar caching. Larger batch sizes can improve memory utilization and compression, but risk OOMs when caching data.压缩的size | 1.1.1

## 2、Other Configuration Options

*The following options can also be used to tune the performance of query execution. It is possible that these options will be deprecated in future release as more optimizations are performed automatically.*

下面的选项可以用来优化查询性能。这些选项可能会在将来的版本中被废弃，因为更多的优化是自动执行的。


Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.files.maxPartitionBytes | 134217728 (128 MB) | The maximum number of bytes to pack into a single partition when reading files. This configuration is effective only when using file-based sources such as Parquet, JSON and ORC. 读取文件时，打包进分区的数据的最大字节数。基于文件的源| 2.0.0
spark.sql.files.openCostInBytes | 4194304 (4 MB) | The estimated cost to open a file, measured by the number of bytes could be scanned in the same time. This is used when putting multiple files into a partition. It is better to over-estimated, then the partitions with small files will be faster than partitions with bigger files (which is scheduled first). This configuration is effective only when using file-based sources such as Parquet, JSON and ORC. 打开文件的估计费用(字节)| 2.0.0
spark.sql.broadcastTimeout | 300 | Timeout in seconds for the broadcast wait time in broadcast joins 广播连接中的广播等待时间超时（秒）| 1.3.0
spark.sql.autoBroadcastJoinThreshold | 10485760 (10 MB) | Configures the maximum size in bytes for a table that will be broadcast to all worker nodes when performing a join. By setting this value to -1 broadcasting can be disabled. Note that currently statistics are only supported for Hive Metastore tables where the command ANALYZE TABLE <tableName> COMPUTE STATISTICS noscan has been run. 将广播给所有工作节点的表的最大字节数| 1.1.0
spark.sql.shuffle.partitions | 200 | Configures the number of partitions to use when shuffling data for joins or aggregations. shuffle 时，使用的分区数| 1.1.0


## 3、Join Strategy Hints for SQL Queries  SQL查询的连接策略提示

*The join strategy hints, namely BROADCAST, MERGE, SHUFFLE_HASH and SHUFFLE_REPLICATE_NL, instruct Spark to use the hinted strategy on each specified relation when joining them with another relation. For example, when the BROADCAST hint is used on table ‘t1’, broadcast join (either broadcast hash join or broadcast nested loop join depending on whether there is any equi-join key) with ‘t1’ as the build side will be prioritized by Spark even if the size of table ‘t1’ suggested by the statistics is above the configuration spark.sql.autoBroadcastJoinThreshold.*

*When different join strategy hints are specified on both sides of a join, Spark prioritizes the BROADCAST hint over the MERGE hint over the SHUFFLE_HASH hint over the SHUFFLE_REPLICATE_NL hint. When both sides are specified with the BROADCAST hint or the SHUFFLE_HASH hint, Spark will pick the build side based on the join type and the sizes of the relations.*

*Note that there is no guarantee that Spark will choose the join strategy specified in the hint since a specific strategy may not support all join types.*

**A：对于python**

```python
spark.table("src").join(spark.table("records").hint("broadcast"), "key").show()
```
**B：对于java**

```java
spark.table("src").join(spark.table("records").hint("broadcast"), "key").show();
```
**C：对于scala**

```scala
spark.table("src").join(spark.table("records").hint("broadcast"), "key").show()
```

*For more details please refer to the documentation of [Join Hints](http://spark.apache.org/docs/latest/sql-ref-syntax-qry-select-hints.html#join-hints).*

## 4、Coalesce Hints for SQL Queries

*Coalesce hints allows the Spark SQL users to control the number of output files just like the coalesce, repartition and repartitionByRange in Dataset API, they can be used for performance tuning and reducing the number of output files. The “COALESCE” hint only has a partition number as a parameter. The “REPARTITION” hint has a partition number, columns, or both of them as parameters. The “REPARTITION_BY_RANGE” hint must have column names and a partition number is optional.*

Coalesce hints 可以控制输出文件的数量，就像 coalesce, repartition and repartitionByRange，用于性能调优和减少输出文件的数量。

- COALESCE 只接受 分区数 作为参数。
- REPARTITION 接收 分区数、列、或同时都有这两项 作为参数。
- REPARTITION_BY_RANGE 必须有 列名作为参数。分区数参数可选。

	SELECT /*+ COALESCE(3) */ * FROM t
	SELECT /*+ REPARTITION(3) */ * FROM t
	SELECT /*+ REPARTITION(c) */ * FROM t
	SELECT /*+ REPARTITION(3, c) */ * FROM t
	SELECT /*+ REPARTITION_BY_RANGE(c) */ * FROM t
	SELECT /*+ REPARTITION_BY_RANGE(3, c) */ * FROM t

*For more details please refer to the documentation of [Partitioning Hints](http://spark.apache.org/docs/latest/sql-ref-syntax-qry-select-hints.html#partitioning-hints).*

## 5、Adaptive Query Execution

*Adaptive Query Execution (AQE) is an optimization technique in Spark SQL that makes use of the runtime statistics to choose the most efficient query execution plan. AQE is disabled by default. Spark SQL can use the umbrella configuration of spark.sql.adaptive.enabled to control whether turn it on/off. As of Spark 3.0, there are three major features in AQE, including coalescing post-shuffle partitions, converting sort-merge join to broadcast join, and skew join optimization.*

Adaptive Query Execution (AQE) 是 Spark SQL 里的优化技术。使用执行时间统计信息来选择最有效率的查询执行方案。默认是关闭的。

`spark.sql.adaptive.enabled` 参数控制开关。

Spark 3.0 ，有三种主要特性：

- coalescing post-shuffle partitions
- converting sort-merge join to broadcast join
- skew join optimization

### 6.1、Coalescing Post Shuffle Partitions  合并Shuffle后分区

*This feature coalesces the post shuffle partitions based on the map output statistics when both spark.sql.adaptive.enabled and spark.sql.adaptive.coalescePartitions.enabled configurations are true. This feature simplifies the tuning of shuffle partition number when running queries. You do not need to set a proper shuffle partition number to fit your dataset. Spark can pick the proper shuffle partition number at runtime once you set a large enough initial number of shuffle partitions via spark.sql.adaptive.coalescePartitions.initialPartitionNum configuration.*

`spark.sql.adaptive.enabled=true` 和 `spark.sql.adaptive.coalescePartitions.enabled=true` 时，基于 map 输出的统计信息实现的 coalesces the post shuffle partitions。

通过 `spark.sql.adaptive.coalescePartitions.initialPartitionNum` 属性，为 shuffle 分区数设置一个足够大的初始值，Spark 就会在运行时选择一个合适的 shuffle 分区数。

Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.adaptive.coalescePartitions.enabled | true | When true and spark.sql.adaptive.enabled is true, Spark will coalesce contiguous shuffle partitions according to the target size (specified by spark.sql.adaptive.advisoryPartitionSizeInBytes), to avoid too many small tasks. | 3.0.0
spark.sql.adaptive.coalescePartitions.minPartitionNum | Default Parallelism | The minimum number of shuffle partitions after coalescing. If not set, the default value is the default parallelism of the Spark cluster. This configuration only has an effect when spark.sql.adaptive.enabled and spark.sql.adaptive.coalescePartitions.enabled are both enabled. 合并后的最小shuffle分区数| 3.0.0
spark.sql.adaptive.coalescePartitions.initialPartitionNum | 200 | The initial number of shuffle partitions before coalescing. By default it equals to spark.sql.shuffle.partitions. This configuration only has an effect when spark.sql.adaptive.enabled and spark.sql.adaptive.coalescePartitions.enabled are both enabled. 初始shuffle分区数| 3.0.0
spark.sql.adaptive.advisoryPartitionSizeInBytes | 64 MB | The advisory size in bytes of the shuffle partition during adaptive optimization (when spark.sql.adaptive.enabled is true). It takes effect when Spark coalesces small shuffle partitions or splits skewed shuffle partition.	自适应优化期间，shuffle 分区的建议大小(以字节为单位) | 3.0.0


### 6.2、Converting sort-merge join to broadcast join

*AQE converts sort-merge join to broadcast hash join when the runtime statistics of any join side is smaller than the broadcast hash join threshold. This is not as efficient as planning a broadcast hash join in the first place, but it’s better than keep doing the sort-merge join, as we can save the sorting of both the join sides, and read shuffle files locally to save network traffic(if spark.sql.adaptive.localShuffleReader.enabled is true)*

当任意 join 侧的运行时间小于 broadcast hash join 阈值时，AQE 转换 sort-merge join 到 broadcast hash join。 这和一开始就设置 broadcast hash join相比，并不高效，但这比继续执行 sort-merge join 要好，因为我们可以保存 join 两边的排序，并在本地读取 shuffle 文件以节省网络流量(if spark.sql.adaptive.localShuffleReader.enabled is true).


### 6.3、Optimizing Skew Join  优化倾斜join

*Data skew can severely downgrade the performance of join queries. This feature dynamically handles skew in sort-merge join by splitting (and replicating if needed) skewed tasks into roughly evenly sized tasks. It takes effect when both spark.sql.adaptive.enabled and spark.sql.adaptive.skewJoin.enabled configurations are enabled.*

数据倾斜会严重降低连接查询的性能。该特性通过将倾斜任务拆分(并在需要时复制)为大小大致相同的任务来动态处理排序合并连接中的倾斜。当sql.adaptive。和spark.sql.adaptive.skewJoin启用时生效。

Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.adaptive.skewJoin.enabled | true | When true and spark.sql.adaptive.enabled is true, Spark dynamically handles skew in sort-merge join by splitting (and replicating if needed) skewed partitions. | 3.0.0
spark.sql.adaptive.skewJoin.skewedPartitionFactor | 10 | A partition is considered as skewed if its size is larger than this factor multiplying the median partition size and also larger than spark.sql.adaptive.skewedPartitionThresholdInBytes.定义分区倾斜的条件 | 3.0.0
spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes | 256MB | A partition is considered as skewed if its size in bytes is larger than this threshold and also larger than spark.sql.adaptive.skewJoin.skewedPartitionFactor multiplying the median partition size. Ideally this config should be set larger than spark.sql.adaptive.advisoryPartitionSizeInBytes. 定义分区倾斜的条件| 3.0.0