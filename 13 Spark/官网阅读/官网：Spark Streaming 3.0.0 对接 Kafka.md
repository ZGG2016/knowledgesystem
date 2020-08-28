# Spark Streaming 3.0.0 对接 Kafka

[TOC]

------------------------------------------------------

Spark Streaming 3.0.0 兼容 Kafka 0.10 及更高，仅支持直连方式。

Spark Streaming 2.4.4 兼容 Kafka 0.8 及更高，支持直连和 Receiver 两种方式，但要分 Kafka 版本。

    Kafka 0.8：支持直连和Receiver
    Kafka 0.10：支持直连

具体见另一个文档。

------------------------------------------------------

## 1、Spark Streaming + Kafka Integration Guide (Kafka broker version 0.10.0 or higher)

*The Spark Streaming integration for Kafka 0.10 provides simple parallelism, 1:1 correspondence between Kafka partitions and Spark partitions, and access to offsets and metadata. However, because the newer integration uses the [new Kafka consumer API](https://kafka.apache.org/documentation.html#newconsumerapi) instead of the simple API, there are notable differences in usage.*

Spark Streaming 集成 Kafka 0.10 提供了简单的并行性，kafka 分区和 spark 分区是一一对应的，以及对偏移量和元数据的访问。

这个版本的集成是实验性的，所以 API 可能会变化。

### 1.1、Linking

*For Scala/Java applications using SBT/Maven project definitions, link your streaming application with the following artifact (see [Linking section](http://spark.apache.org/docs/2.4.4/streaming-programming-guide.html#linking) in the main programming guide for further information).*

添加如下依赖：

    groupId = org.apache.spark
    artifactId = spark-streaming-kafka-0-10_2.12
    version = 3.0.0

*Do not manually add dependencies on org.apache.kafka artifacts (e.g. kafka-clients). The spark-streaming-kafka-0-10 artifact has the appropriate transitive dependencies already, and different versions may be incompatible in hard to diagnose ways.*

不用手动在 `org.apache.kafka artifacts (e.g. kafka-clients)` 上添加依赖。

### 1.2、Creating a Direct Stream

*Note that the namespace for the import includes the version, org.apache.spark.streaming.kafka010*

**对于scala**

```scala
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.streaming.kafka010._
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe

val kafkaParams = Map[String, Object](
  "bootstrap.servers" -> "localhost:9092,anotherhost:9092",
  "key.deserializer" -> classOf[StringDeserializer],
  "value.deserializer" -> classOf[StringDeserializer],
  "group.id" -> "use_a_separate_group_id_for_each_stream",
  "auto.offset.reset" -> "latest",
  "enable.auto.commit" -> (false: java.lang.Boolean)
)

val topics = Array("topicA", "topicB")
val stream = KafkaUtils.createDirectStream[String, String](
  streamingContext,
  PreferConsistent,
  Subscribe[String, String](topics, kafkaParams)
)

stream.map(record => (record.key, record.value))
```
*Each item in the stream is a [ConsumerRecord](http://kafka.apache.org/0100/javadoc/org/apache/kafka/clients/consumer/ConsumerRecord.html)*

流中的每一项是一个 ConsumerRecord。

【ConsumerRecord：A key/value pair to be received from Kafka. This consists of a topic name and a partition number, from which the record is being received and an offset that points to the record in a Kafka partition.】

*For possible kafkaParams, see [Kafka consumer config docs](http://kafka.apache.org/documentation.html#newconsumerconfigs). If your Spark batch duration is larger than the default Kafka heartbeat session timeout (30 seconds), increase heartbeat.interval.ms and session.timeout.ms appropriately. For batches larger than 5 minutes, this will require changing group.max.session.timeout.ms on the broker. Note that the example sets enable.auto.commit to false, for discussion see [Storing Offsets](http://spark.apache.org/docs/2.4.4/streaming-kafka-0-10-integration.html#storing-offsets) below.*

如果 Spark batch 的时长大于默认的 Kafka heartbeat session timeout (30 seconds)，那么就需要增大 `heartbeat.interval.ms` 和 `session.timeout.ms`。

对于大于5分钟的 batches，则需要改变 broker 上的 `group.max.session.timeout.ms`。

**对于java**

```java
import java.util.*;
import org.apache.spark.SparkConf;
import org.apache.spark.TaskContext;
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.*;
import org.apache.spark.streaming.api.java.*;
import org.apache.spark.streaming.kafka010.*;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import scala.Tuple2;

Map<String, Object> kafkaParams = new HashMap<>();
kafkaParams.put("bootstrap.servers", "localhost:9092,anotherhost:9092");
kafkaParams.put("key.deserializer", StringDeserializer.class);
kafkaParams.put("value.deserializer", StringDeserializer.class);
kafkaParams.put("group.id", "use_a_separate_group_id_for_each_stream");
kafkaParams.put("auto.offset.reset", "latest");
kafkaParams.put("enable.auto.commit", false);

Collection<String> topics = Arrays.asList("topicA", "topicB");

JavaInputDStream<ConsumerRecord<String, String>> stream =
  KafkaUtils.createDirectStream(
    streamingContext,
    LocationStrategies.PreferConsistent(),
    ConsumerStrategies.<String, String>Subscribe(topics, kafkaParams)
  );

stream.mapToPair(record -> new Tuple2<>(record.key(), record.value()));
```
*For possible kafkaParams, see [Kafka consumer config docs](http://kafka.apache.org/documentation.html#newconsumerconfigs). If your Spark batch duration is larger than the default Kafka heartbeat session timeout (30 seconds), increase heartbeat.interval.ms and session.timeout.ms appropriately. For batches larger than 5 minutes, this will require changing group.max.session.timeout.ms on the broker. Note that the example sets enable.auto.commit to false, for discussion see [Storing Offsets](http://spark.apache.org/docs/2.4.4/streaming-kafka-0-10-integration.html#storing-offsets) below.*

### 1.3、LocationStrategies

*The new Kafka consumer API will pre-fetch messages into buffers. Therefore it is important for performance reasons that the Spark integration keep cached consumers on executors (rather than recreating them for each batch), and prefer to schedule partitions on the host locations that have the appropriate consumers.*

new Kafka consumer API 会先把消息拉取到缓存。因此，出于性能考虑，Spark 集成将缓存中的消费者放在 executors 上(而不是为每个 batch 重新创建它们)，而且**更倾向于在拥有合适消费者的主机位置调度分区**。

*In most cases, you should use LocationStrategies.PreferConsistent as shown above. This will distribute partitions evenly across available executors. If your executors are on the same hosts as your Kafka brokers, use PreferBrokers, which will prefer to schedule partitions on the Kafka leader for that partition. Finally, if you have a significant skew in load among partitions, use PreferFixed. This allows you to specify an explicit mapping of partitions to hosts (any unspecified partitions will use a consistent location).*

在大多数情况下，使用 `LocationStrategies.PreferConsistent`。 这将平均分布分区到各个可用的 executors 上。

如果 executors 和 Kafka brokers 在同一主机，使用 `PreferBrokers`，这就会在 Kafka leader 上调度分区。

如果分区之间的负载有很大的倾斜，那么使用 `PreferFixed` 。这将指定分区到主机的显式映射(任何未指定的分区都将使用一致的位置)。

*The cache for consumers has a default maximum size of 64. If you expect to be handling more than (64 * number of executors) Kafka partitions, you can change this setting via spark.streaming.kafka.consumer.cache.maxCapacity.*

存放 consumers 的缓存默认最大是64。如果要处理超多 `(64 * number of executors)` 的 kafka 分区，可用设置 `spark.streaming.kafka.consumer.cache.maxCapacity`

*If you would like to disable the caching for Kafka consumers, you can set spark.streaming.kafka.consumer.cache.enabled to false.*

如果不想缓存消息，可用设置 `spark.streaming.kafka.consumer.cache.enabled=false`

*The cache is keyed by topicpartition and group.id, so use a separate group.id for each call to createDirectStream.*

每次调用的 createDirectStream ，使用一个独立的 `group.id`.

### 1.4、ConsumerStrategies

*The new Kafka consumer API has a number of different ways to specify topics, some of which require considerable post-object-instantiation setup. ConsumerStrategies provides an abstraction that allows Spark to obtain properly configured consumers even after restart from checkpoint.*

new Kafka consumer API 有多种方式指定 topic ，其中一些要求在实例化对象之后进行大量的配置，ConsumerStrategies 提供了一个抽象，允许 Spark 为 consumer 获取适合的配置，甚至在 checkpoint 重启之后也可以获取适合的配置。

*ConsumerStrategies.Subscribe, as shown above, allows you to subscribe to a fixed collection of topics. SubscribePattern allows you to use a regex to specify topics of interest. Note that unlike the 0.8 integration, using Subscribe or SubscribePattern should respond to adding partitions during a running stream. Finally, Assign allows you to specify a fixed collection of partitions. All three strategies have overloaded constructors that allow you to specify the starting offset for a particular partition.*

`ConsumerStrategies.Subscribe` 允许你订阅一个固定的 topic 集合。

`SubscribePattern` 可以使用正则表达式去指定所需要的 topic.

`Assign` 可以指定一个固定的分区集合。

这三种策略可以重载构造函数，允许你指定一个分区及其开始的偏移量。

注意：不同于 0.8 集成，使用 `Subscribe` 或 `SubscribePattern` 会在运行流时响应添加分区。

*If you have specific consumer setup needs that are not met by the options above, ConsumerStrategy is a public class that you can extend.*

可以通过继承 `ConsumerStrategy` 类，可以自定义策略。

### 1.5、Creating an RDD

*If you have a use case that is better suited to batch processing, you can create an RDD for a defined range of offsets.*

如果你的需求更适合进行批处理的话，你可以根据 Kafka 的偏移范围创建 RDD。

**对于scala**

```scala
// Import dependencies and create kafka params as in Create Direct Stream above

val offsetRanges = Array(
  // topic, partition, inclusive starting offset, exclusive ending offset
  OffsetRange("test", 0, 0, 100),
  OffsetRange("test", 1, 0, 100)
)

val rdd = KafkaUtils.createRDD[String, String](sparkContext, kafkaParams, offsetRanges, PreferConsistent)

```
*Note that you cannot use PreferBrokers, because without the stream there is not a driver-side consumer to automatically look up broker metadata for you. Use PreferFixed with your own metadata lookups if necessary.*

这种情况下不要使用 `PreferBrokers` 。因为没有 stream 的话就没有 driver 端的 consumer 检索元数据。必要时候，使用 PreferFixed 策略检索元数据。

**对于java**

```java
// Import dependencies and create kafka params as in Create Direct Stream above

OffsetRange[] offsetRanges = {
  // topic, partition, inclusive starting offset, exclusive ending offset
  OffsetRange.create("test", 0, 0, 100),
  OffsetRange.create("test", 1, 0, 100)
};

JavaRDD<ConsumerRecord<String, String>> rdd = KafkaUtils.createRDD(
  sparkContext,
  kafkaParams,
  offsetRanges,
  LocationStrategies.PreferConsistent()
);
```

### 1.6、Obtaining Offsets

**对于scala**

```scala
stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
  rdd.foreachPartition { iter =>
    val o: OffsetRange = offsetRanges(TaskContext.get.partitionId)
    println(s"${o.topic} ${o.partition} ${o.fromOffset} ${o.untilOffset}")
  }
}
```

Note that the typecast to HasOffsetRanges will only succeed if it is done in the first method called on the result of createDirectStream, not later down a chain of methods. Be aware that the one-to-one mapping between RDD partition and Kafka partition does not remain after any methods that shuffle or repartition, e.g. reduceByKey() or window().


注意：只有在 createDirectStream 的结果上调用第一个方法完成后，类型才能转换为 HasOffsetRanges ，而不是在后面的一系列方法之后。

在执行 shuffle 或分区的方法(reduceByKey() or window())执行完后，RDD 分区和 Kafka 分区就不再一对一映射。


**对于java**

```java
stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();
  rdd.foreachPartition(consumerRecords -> {
    OffsetRange o = offsetRanges[TaskContext.get().partitionId()];
    System.out.println(
      o.topic() + " " + o.partition() + " " + o.fromOffset() + " " + o.untilOffset());
  });
});
```

### 1.7、Storing Offsets

*Kafka delivery semantics in the case of failure depend on how and when offsets are stored. Spark output operations are [at-least-once](http://spark.apache.org/docs/latest/streaming-programming-guide.html#semantics-of-output-operations). So if you want the equivalent of exactly-once semantics, you must either store offsets after an idempotent output, or store offsets in an atomic transaction alongside output. With this integration, you have 3 options, in order of increasing reliability (and code complexity), for how to store offsets.*

失败情况下，Kafka 交付语义依赖于偏移量的存储方式和时间。Spark 的输出操作是 at-least-once ，但如果想要 exactly-once 语义，那么必须在幂等输出之后存储偏移量，或者在与输出一起的原子事务中存储偏移量。

有三种方法：

#### 1.7.1、Checkpoints

*If you enable Spark [checkpointing](http://spark.apache.org/docs/latest/streaming-programming-guide.html#checkpointing), offsets will be stored in the checkpoint. This is easy to enable, but there are drawbacks. Your output operation must be idempotent, since you will get repeated outputs; transactions are not an option. Furthermore, you cannot recover from a checkpoint if your application code has changed. For planned upgrades, you can mitigate this by running the new code at the same time as the old code (since outputs need to be idempotent anyway, they should not clash). But for unplanned failures that require code changes, you will lose data unless you have another way to identify known good starting offsets.*

如果启用了 Spark checkpointing，则偏移量在 checkpoint 中存储。这很容易启用，但也有缺点。

输出操作必须是幂等的，因为你会得到重复的输出;

事务不是一个选项。

如果应用程序代码已更改，则无法从 checkpoint 中恢复。

对于计划中的升级，可以通过在运行旧代码的同时运行新代码来缓解这一问题(因为输出必须是幂等的，所以它们不应该冲突)。

但是对于需要更改代码的计划外失败，除非有另一种方法来识别已知的良好起始偏移量，否则将丢失数据。


#### 1.7.2、Kafka itself

*Kafka has an offset commit API that stores offsets in a special Kafka topic. By default, the new consumer will periodically auto-commit offsets. This is almost certainly not what you want, because messages successfully polled by the consumer may not yet have resulted in a Spark output operation, resulting in undefined semantics. This is why the stream example above sets “enable.auto.commit” to false. However, you can commit offsets to Kafka after you know your output has been stored, using the commitAsync API. The benefit as compared to checkpoints is that Kafka is a durable store regardless of changes to your application code. However, Kafka is not transactional, so your outputs must still be idempotent.*

Kafka 有一个偏移量提交 API，它在一个特殊的 Kafka topic 中存储偏移量。

默认情况下，新的 consumer 将定期自动提交偏移量。这几乎肯定不是您想要的结果，因为由 consumer 成功轮询的消息可能还没有导致 Spark 输出操作，从而导致语义未定义。这就是为什么上面的流示例将“enable.auto.commit”设置为false。

但是，可以在知道输出已经被存储之后，使用 commitAsync API 向 Kafka 提交偏移量。与 checkpoints 相比，Kafka 的优点是无论应用程序代码如何更改，它都是一个持久存储。然而，Kafka 不是事务性的，所以你的输出必须仍然是幂等的。

**对于scala**

```scala
stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

  // some time later, after outputs have completed
  stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)
}
```

*As with HasOffsetRanges, the cast to CanCommitOffsets will only succeed if called on the result of createDirectStream, not after transformations. The commitAsync call is threadsafe, but must occur after outputs if you want meaningful semantics.*

**对于java**

```java
stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();

  // some time later, after outputs have completed
  ((CanCommitOffsets) stream.inputDStream()).commitAsync(offsetRanges);
});
```

#### 1.7.3、Your own data store

*For data stores that support transactions, saving offsets in the same transaction as the results can keep the two in sync, even in failure situations. If you’re careful about detecting repeated or skipped offset ranges, rolling back the transaction prevents duplicated or lost messages from affecting results. This gives the equivalent of exactly-once semantics. It is also possible to use this tactic even for outputs that result from aggregations, which are typically hard to make idempotent.*

对于支持事务的数据存储，在同一事务中保存偏移量作为结果，可以使两者保持同步，即使在失败的情况下也是如此。

如果小心地检测重复或跳过的偏移范围，回滚事务可以防止重复或丢失的消息影响结果。这就给出了等效的 exactly-once  语义。甚至对于聚合产生的输出也可以使用这种策略，而聚合通常很难使其幂等。

**对于scala**

```scala
// The details depend on your data store, but the general idea looks like this

// begin from the offsets committed to the database
val fromOffsets = selectOffsetsFromYourDatabase.map { resultSet =>
  new TopicPartition(resultSet.string("topic"), resultSet.int("partition")) -> resultSet.long("offset")
}.toMap

val stream = KafkaUtils.createDirectStream[String, String](
  streamingContext,
  PreferConsistent,
  Assign[String, String](fromOffsets.keys.toList, kafkaParams, fromOffsets)
)

stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

  val results = yourCalculation(rdd)

  // begin your transaction

  // update results
  // update offsets where the end of existing offsets matches the beginning of this batch of offsets
  // assert that offsets were updated correctly

  // end your transaction
}
```

**对于java**

```java
// The details depend on your data store, but the general idea looks like this

// begin from the offsets committed to the database
Map<TopicPartition, Long> fromOffsets = new HashMap<>();
for (resultSet : selectOffsetsFromYourDatabase)
  fromOffsets.put(new TopicPartition(resultSet.string("topic"), resultSet.int("partition")), resultSet.long("offset"));
}

JavaInputDStream<ConsumerRecord<String, String>> stream = KafkaUtils.createDirectStream(
  streamingContext,
  LocationStrategies.PreferConsistent(),
  ConsumerStrategies.<String, String>Assign(fromOffsets.keySet(), kafkaParams, fromOffsets)
);

stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();
  
  Object results = yourCalculation(rdd);

  // begin your transaction

  // update results
  // update offsets where the end of existing offsets matches the beginning of this batch of offsets
  // assert that offsets were updated correctly

  // end your transaction
});
```

### 1.8、SSL / TLS

*The new Kafka consumer [supports SSL](http://kafka.apache.org/documentation.html#security_ssl). To enable it, set kafkaParams appropriately before passing to createDirectStream / createRDD. Note that this only applies to communication between Spark and Kafka brokers; you are still responsible for separately [securing](http://spark.apache.org/docs/latest/security.html) Spark inter-node communication.*

new Kafka consumer 支持 SSL，在 kafkaParams 中配置。

它仅负责 Spark 和 Kafka brokers 间的通信，Spark 内部结点间的通信安全还需要自己设置。

**对于scala**

```scala
val kafkaParams = Map[String, Object](
  // the usual params, make sure to change the port in bootstrap.servers if 9092 is not TLS
  "security.protocol" -> "SSL",
  "ssl.truststore.location" -> "/some-directory/kafka.client.truststore.jks",
  "ssl.truststore.password" -> "test1234",
  "ssl.keystore.location" -> "/some-directory/kafka.client.keystore.jks",
  "ssl.keystore.password" -> "test1234",
  "ssl.key.password" -> "test1234"
)
```

**对于java**

```java
Map<String, Object> kafkaParams = new HashMap<String, Object>();
// the usual params, make sure to change the port in bootstrap.servers if 9092 is not TLS
kafkaParams.put("security.protocol", "SSL");
kafkaParams.put("ssl.truststore.location", "/some-directory/kafka.client.truststore.jks");
kafkaParams.put("ssl.truststore.password", "test1234");
kafkaParams.put("ssl.keystore.location", "/some-directory/kafka.client.keystore.jks");
kafkaParams.put("ssl.keystore.password", "test1234");
kafkaParams.put("ssl.key.password", "test1234");
```

### 1.9、Deploying

*As with any Spark applications, spark-submit is used to launch your application.*

*For Scala and Java applications, if you are using SBT or Maven for project management, then package spark-streaming-kafka-0-10_2.12 and its dependencies into the application JAR. Make sure spark-core_2.12 and spark-streaming_2.12 are marked as provided dependencies as those are already present in a Spark installation. Then use spark-submit to launch your application (see [Deploying section](http://spark.apache.org/docs/latest/streaming-programming-guide.html#deploying-applications) in the main programming guide).*


对 scala 和 java，添加 `spark-streaming-kafka-0-10_2.12` 依赖。且保证版本一致 `spark-core_2.12` 、 `spark-streaming_2.12`。然后使用 `spark-submit` 启动应用程序。

### 1.10、Security

*See [Structured Streaming Security](http://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html#security).*

#### 1.10.1、Additional Caveats

*Kafka native sink is not available so delegation token used only on consumer side.*

------------------------------------------------------------
