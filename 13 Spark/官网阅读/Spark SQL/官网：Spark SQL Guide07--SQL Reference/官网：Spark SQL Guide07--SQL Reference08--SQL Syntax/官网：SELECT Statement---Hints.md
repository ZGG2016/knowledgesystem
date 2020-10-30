# 官网：SELECT Statement---Hints

[TOC]

## 1、Description

*Hints give users a way to suggest how Spark SQL to use specific approaches to generate its execution plan.*

**Hints 是建议 Spark SQL 如何使用指定的方法来生成执行计划。**

## 2、Syntax

	/*+ hint [ , ... ] */

## 3、Partitioning Hints

*Partitioning hints allow users to suggest a partitioning stragety that Spark should follow. COALESCE, REPARTITION, and REPARTITION_BY_RANGE hints are supported and are equivalent to coalesce, repartition, and repartitionByRange Dataset APIs, respectively. These hints give users a way to tune performance and control the number of output files in Spark SQL. When multiple partitioning hints are specified, multiple nodes are inserted into the logical plan, but the leftmost hint is picked by the optimizer.*

Partitioning hints 允许用户建议 Spark 应该遵循的一种分区策略。

支持的策略有`COALESCE, REPARTITION, and REPARTITION_BY_RANGE `，等同于 Dataset APIs 中的 `coalesce, repartition, and repartitionByRange`。

在 Spark SQL ，这些 hints 为用户提供了一种调优的方式，和控制输出文件的数量。

当指定了多个 partitioning hints，那么多个节点会插入到逻辑计划中，但是最左边的 hint 是被优化器选择的。

### 2.1、Partitioning Hints Types

- COALESCE

COALESCE hint 用来减少分区数到指定数量。其参数是分区数。

*The COALESCE hint can be used to reduce the number of partitions to the specified number of partitions. It takes a partition number as a parameter.*

- REPARTITION

REPARTITION hint 通过使用指定的分区表达式，来重新分区到指定数量。其参数是分区数、列名、或者二者都有。

*The REPARTITION hint can be used to repartition to the specified number of partitions using the specified partitioning expressions. It takes a partition number, column names, or both as parameters.*

- REPARTITION_BY_RANGE

REPARTITION_BY_RANGE hint 通过使用指定的分区表达式，来重新分区到指定数量。其参数是列名，和一个可选的分区数参数。

*The REPARTITION_BY_RANGE hint can be used to repartition to the specified number of partitions using the specified partitioning expressions. It takes column names and an optional partition number as parameters.*

Examples：

```sql
SELECT /*+ COALESCE(3) */ * FROM t;

SELECT /*+ REPARTITION(3) */ * FROM t;

SELECT /*+ REPARTITION(c) */ * FROM t;

SELECT /*+ REPARTITION(3, c) */ * FROM t;

SELECT /*+ REPARTITION_BY_RANGE(c) */ * FROM t;

SELECT /*+ REPARTITION_BY_RANGE(3, c) */ * FROM t;

-- multiple partitioning hints
EXPLAIN EXTENDED SELECT /*+ REPARTITION(100), COALESCE(500), REPARTITION_BY_RANGE(3, c) */ * FROM t;
== Parsed Logical Plan ==
'UnresolvedHint REPARTITION, [100]
+- 'UnresolvedHint COALESCE, [500]
   +- 'UnresolvedHint REPARTITION_BY_RANGE, [3, 'c]
      +- 'Project [*]
         +- 'UnresolvedRelation [t]

== Analyzed Logical Plan ==
name: string, c: int
Repartition 100, true
+- Repartition 500, false
   +- RepartitionByExpression [c#30 ASC NULLS FIRST], 3
      +- Project [name#29, c#30]
         +- SubqueryAlias spark_catalog.default.t
            +- Relation[name#29,c#30] parquet

== Optimized Logical Plan ==
Repartition 100, true
+- Relation[name#29,c#30] parquet

== Physical Plan ==
Exchange RoundRobinPartitioning(100), false, [id=#121]
+- *(1) ColumnarToRow
   +- FileScan parquet default.t[name#29,c#30] Batched: true, DataFilters: [], Format: Parquet,
      Location: CatalogFileIndex[file:/spark/spark-warehouse/t], PartitionFilters: [],
      PushedFilters: [], ReadSchema: struct<name:string>
```

## 3、Join Hints

*Join hints allow users to suggest the join strategy that Spark should use. Prior to Spark 3.0, only the BROADCAST Join Hint was supported. MERGE, SHUFFLE_HASH and SHUFFLE_REPLICATE_NL Joint Hints support was added in 3.0. When different join strategy hints are specified on both sides of a join, Spark prioritizes hints in the following order: BROADCAST over MERGE over SHUFFLE_HASH over SHUFFLE_REPLICATE_NL. When both sides are specified with the BROADCAST hint or the SHUFFLE_HASH hint, Spark will pick the build side based on the join type and the sizes of the relations. Since a given strategy may not support all join types, Spark is not guaranteed to use the join strategy suggested by the hint.*

Join hints 允许用户建议 Spark 应该使用何种 join 策略。

在 Spark 3.0 之前，仅支持 BROADCAST Join Hint。在版本 Spark 3.0 ，增加了 `MERGE, SHUFFLE_HASH and SHUFFLE_REPLICATE_NL`。

当在 join 的两端指定了不同的 join 策略，Spark 采用顺序是：`BROADCAST > MERGE > SHUFFLE_HASH > SHUFFLE_REPLICATE_NL`。

当两端同时指定了 `BROADCAST` 或者 `SHUFFLE_HASH`，Spark 将基于 join 类型和关系的大小，来决定 build side。

不能保证 Spark 会选择 hint 建议的 join 策略，因为特定的策略可能不支持所有的 join 类型。

### 3.1、Join Hints Types

- BROADCAST

建议使用 `broadcast join`。 hint 的 join 侧将被广播，不管是否启用了`autoBroadcastJoinThreshold`。

如果两端都选择了 broadcast hints ，Spark 选择将选择最小侧(根据统计信息)作为 build side。

`BROADCAST` 的别名是 `BROADCASTJOIN` 和 `MAPJOIN`

*Suggests that Spark use broadcast join. The join side with the hint will be broadcast regardless of autoBroadcastJoinThreshold. If both sides of the join have the broadcast hints, the one with the smaller size (based on stats) will be broadcast. The aliases for BROADCAST are BROADCASTJOIN and MAPJOIN.*

- MERGE

建议使用 `shuffle sort merge join`。 `MERGE` 的别名是 `SHUFFLE_MERGE` 和 `MERGEJOIN`

*Suggests that Spark use shuffle sort merge join. The aliases for MERGE are SHUFFLE_MERGE and MERGEJOIN.*

- SHUFFLE_HASH

建议使用 `shuffle hash join` 。如果两端都选择了 shuffle hash hints ，Spark 选择将选择最小侧(根据统计信息)作为 build side。

*Suggests that Spark use shuffle hash join. If both sides have the shuffle hash hints, Spark chooses the smaller side (based on stats) as the build side.*

- SHUFFLE_REPLICATE_NL

建议使用 `shuffle-and-replicate nested loop join`

*Suggests that Spark use shuffle-and-replicate nested loop join.*

Examples

```sql
-- Join Hints for broadcast join
SELECT /*+ BROADCAST(t1) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;
SELECT /*+ BROADCASTJOIN (t1) */ * FROM t1 left JOIN t2 ON t1.key = t2.key;
SELECT /*+ MAPJOIN(t2) */ * FROM t1 right JOIN t2 ON t1.key = t2.key;

-- Join Hints for shuffle sort merge join
SELECT /*+ SHUFFLE_MERGE(t1) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;
SELECT /*+ MERGEJOIN(t2) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;
SELECT /*+ MERGE(t1) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;

-- Join Hints for shuffle hash join
SELECT /*+ SHUFFLE_HASH(t1) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;

-- Join Hints for shuffle-and-replicate nested loop join
SELECT /*+ SHUFFLE_REPLICATE_NL(t1) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;

-- When different join strategy hints are specified on both sides of a join, Spark
-- prioritizes the BROADCAST hint over the MERGE hint over the SHUFFLE_HASH hint
-- over the SHUFFLE_REPLICATE_NL hint.
-- Spark will issue Warning in the following example
-- org.apache.spark.sql.catalyst.analysis.HintErrorLogger: Hint (strategy=merge)
-- is overridden by another hint and will not take effect.
SELECT /*+ BROADCAST(t1), MERGE(t1, t2) */ * FROM t1 INNER JOIN t2 ON t1.key = t2.key;
```


```sh
spark-sql> SELECT /*+ BROADCAST(t1) */ * FROM test t1 INNER JOIN test t2 ON t1.dept = t2.dept;
20/10/30 15:18:07 INFO metastore.HiveMetaStore: 0: get_table : db=default tbl=test
20/10/30 15:18:07 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_table : db=default tbl=test
20/10/30 15:18:07 INFO metastore.HiveMetaStore: 0: get_table : db=default tbl=test
20/10/30 15:18:07 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_table : db=default tbl=test
20/10/30 15:18:08 INFO codegen.CodeGenerator: Code generated in 22.364338 ms
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_9 stored as values in memory (estimated size 401.0 KB, free 364.6 MB)
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_9_piece0 stored as bytes in memory (estimated size 40.4 KB, free 364.5 MB)
20/10/30 15:18:08 INFO storage.BlockManagerInfo: Added broadcast_9_piece0 in memory on zgg:40151 (size: 40.4 KB, free: 366.1 MB)
20/10/30 15:18:08 INFO spark.SparkContext: Created broadcast 9 from 
20/10/30 15:18:08 INFO mapred.FileInputFormat: Total input paths to process : 1
20/10/30 15:18:08 INFO spark.SparkContext: Starting job: run at ThreadPoolExecutor.java:1149
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Got job 4 (run at ThreadPoolExecutor.java:1149) with 1 output partitions
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Final stage: ResultStage 5 (run at ThreadPoolExecutor.java:1149)
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Parents of final stage: List()
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Missing parents: List()
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Submitting ResultStage 5 (MapPartitionsRDD[28] at run at ThreadPoolExecutor.java:1149), which has no missing parents
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_10 stored as values in memory (estimated size 11.2 KB, free 364.5 MB)
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_10_piece0 stored as bytes in memory (estimated size 5.7 KB, free 364.5 MB)
20/10/30 15:18:08 INFO storage.BlockManagerInfo: Added broadcast_10_piece0 in memory on zgg:40151 (size: 5.7 KB, free: 366.1 MB)
20/10/30 15:18:08 INFO spark.SparkContext: Created broadcast 10 from broadcast at DAGScheduler.scala:1161
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Submitting 1 missing tasks from ResultStage 5 (MapPartitionsRDD[28] at run at ThreadPoolExecutor.java:1149) (first 15 tasks are for partitions Vector(0))
20/10/30 15:18:08 INFO scheduler.TaskSchedulerImpl: Adding task set 5.0 with 1 tasks
20/10/30 15:18:08 INFO scheduler.TaskSetManager: Starting task 0.0 in stage 5.0 (TID 7, localhost, executor driver, partition 0, ANY, 7899 bytes)
20/10/30 15:18:08 INFO executor.Executor: Running task 0.0 in stage 5.0 (TID 7)
20/10/30 15:18:08 INFO rdd.HadoopRDD: Input split: hdfs://zgg:9000/root/data/hive/hive.txt:0+70
20/10/30 15:18:08 INFO executor.Executor: Finished task 0.0 in stage 5.0 (TID 7). 1534 bytes result sent to driver
20/10/30 15:18:08 INFO scheduler.TaskSetManager: Finished task 0.0 in stage 5.0 (TID 7) in 42 ms on localhost (executor driver) (1/1)
20/10/30 15:18:08 INFO scheduler.TaskSchedulerImpl: Removed TaskSet 5.0, whose tasks have all completed, from pool 
20/10/30 15:18:08 INFO scheduler.DAGScheduler: ResultStage 5 (run at ThreadPoolExecutor.java:1149) finished in 0.054 s
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Job 4 finished: run at ThreadPoolExecutor.java:1149, took 0.056691 s
20/10/30 15:18:08 INFO codegen.CodeGenerator: Code generated in 9.738186 ms
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_11 stored as values in memory (estimated size 8.0 MB, free 356.5 MB)
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_11_piece0 stored as bytes in memory (estimated size 269.0 B, free 356.5 MB)
20/10/30 15:18:08 INFO storage.BlockManagerInfo: Added broadcast_11_piece0 in memory on zgg:40151 (size: 269.0 B, free: 366.1 MB)
20/10/30 15:18:08 INFO spark.SparkContext: Created broadcast 11 from run at ThreadPoolExecutor.java:1149
20/10/30 15:18:08 INFO codegen.CodeGenerator: Code generated in 23.092071 ms
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_12 stored as values in memory (estimated size 401.0 KB, free 356.1 MB)
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_12_piece0 stored as bytes in memory (estimated size 40.4 KB, free 356.1 MB)
20/10/30 15:18:08 INFO storage.BlockManagerInfo: Added broadcast_12_piece0 in memory on zgg:40151 (size: 40.4 KB, free: 366.1 MB)
20/10/30 15:18:08 INFO spark.SparkContext: Created broadcast 12 from 
20/10/30 15:18:08 INFO mapred.FileInputFormat: Total input paths to process : 1
20/10/30 15:18:08 INFO spark.SparkContext: Starting job: processCmd at CliDriver.java:376
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Got job 5 (processCmd at CliDriver.java:376) with 1 output partitions
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Final stage: ResultStage 6 (processCmd at CliDriver.java:376)
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Parents of final stage: List()
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Missing parents: List()
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Submitting ResultStage 6 (MapPartitionsRDD[34] at processCmd at CliDriver.java:376), which has no missing parents
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_13 stored as values in memory (estimated size 13.4 KB, free 356.1 MB)
20/10/30 15:18:08 INFO memory.MemoryStore: Block broadcast_13_piece0 stored as bytes in memory (estimated size 6.5 KB, free 356.1 MB)
20/10/30 15:18:08 INFO storage.BlockManagerInfo: Added broadcast_13_piece0 in memory on zgg:40151 (size: 6.5 KB, free: 366.1 MB)
20/10/30 15:18:08 INFO spark.SparkContext: Created broadcast 13 from broadcast at DAGScheduler.scala:1161
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Submitting 1 missing tasks from ResultStage 6 (MapPartitionsRDD[34] at processCmd at CliDriver.java:376) (first 15 tasks are for partitions Vector(0))
20/10/30 15:18:08 INFO scheduler.TaskSchedulerImpl: Adding task set 6.0 with 1 tasks
20/10/30 15:18:08 INFO scheduler.TaskSetManager: Starting task 0.0 in stage 6.0 (TID 8, localhost, executor driver, partition 0, ANY, 7899 bytes)
20/10/30 15:18:08 INFO executor.Executor: Running task 0.0 in stage 6.0 (TID 8)
20/10/30 15:18:08 INFO rdd.HadoopRDD: Input split: hdfs://zgg:9000/root/data/hive/hive.txt:0+70
20/10/30 15:18:08 INFO executor.Executor: Finished task 0.0 in stage 6.0 (TID 8). 1824 bytes result sent to driver
20/10/30 15:18:08 INFO scheduler.TaskSetManager: Finished task 0.0 in stage 6.0 (TID 8) in 33 ms on localhost (executor driver) (1/1)
20/10/30 15:18:08 INFO scheduler.TaskSchedulerImpl: Removed TaskSet 6.0, whose tasks have all completed, from pool 
20/10/30 15:18:08 INFO scheduler.DAGScheduler: ResultStage 6 (processCmd at CliDriver.java:376) finished in 0.045 s
20/10/30 15:18:08 INFO scheduler.DAGScheduler: Job 5 finished: processCmd at CliDriver.java:376, took 0.048433 s
d1      user3   3000    d1      user1   1000
d1      user2   2000    d1      user1   1000
d1      user1   1000    d1      user1   1000
d1      user3   3000    d1      user2   2000
d1      user2   2000    d1      user2   2000
d1      user1   1000    d1      user2   2000
d1      user3   3000    d1      user3   3000
d1      user2   2000    d1      user3   3000
d1      user1   1000    d1      user3   3000
d2      user5   5000    d2      user4   4000
d2      user4   4000    d2      user4   4000
d2      user5   5000    d2      user5   5000
d2      user4   4000    d2      user5   5000
Time taken: 0.872 seconds, Fetched 13 row(s)
20/10/30 15:18:08 INFO thriftserver.SparkSQLCLIDriver: Time taken: 0.872 seconds, Fetched 13 row(s)
```