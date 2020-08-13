# spark streaming对接kafka

Spark Streaming 3.0.0 兼容 Kafka 0.10 及更高。

注意：

- Kafka 0.8 兼容 0.9 和 0.10。但 0.10 不兼容更早版本的。
- Spark 2.3.0 对 Kafka 0.8 的支持被弃用。

![sparkkafka01](./image/sparkkafka01.png)

所以在 `spark-streaming-kafka-0-10` 中仅支持 `Direct DStream` ，在 `	spark-streaming-kafka-0-8` 支持 `Direct DStream` 和 `Receiver DStream`


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

new Kafka consumer API 会先把消息拉取到缓存。因此，出于性能考虑，Spark 集成将缓存中的消费者放在 executors 上(而不是为每个 batch 重新创建它们)，而且更倾向于在拥有合适消费者的主机位置调度分区。

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




------------------------------------------------------------
### 1、直连方式：KafkaUtils类的createDirectStream方法

    def createDirectStream[
        K: ClassTag,
        V: ClassTag,
        KD <: Decoder[K]: ClassTag,
        VD <: Decoder[V]: ClassTag] (
          ssc: StreamingContext,
          kafkaParams: Map[String, String],
          topics: Set[String]
      ): InputDStream[(K, V)] = {...}

参数解析：
   
    ssc： SparkStreaming 对象
    kafkaParams：kafka参数信息，里面包括zookeepr集群等参数。
    topics：kafka topic logstash 写入的哪个topic 我们就读取哪个topic 这个topics 参数上一个集合对象Set[String]   

创建链接kafka需要参数kafkaParams
   
    val kafkaParamsDirect = Map[String, String](
    
      "serializer.class" -> "kafka.serializer.StringEncoder",
      "zookeeper.connect" -> zkQuorum,
      "group.id" -> "consumergroup",
      "metadata.broker.list" -> brokers,
      "auto.offset.reset" -> "smallest"

    )
    
参数解析：
   
    auto.offset.reset：设置从kafka哪个偏移量开始读 smallest 表示从头开始读
    zookeeper.connect：zookeeper集群信息
    group.id：消费者所在组的ID如果没有就填写1
    metadata.broker.list：kafka broker信息 kafka集群
    serializer.class：设置kafka 压缩和序列化

连接：

    val lines = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParamsDirect,  Set(topics))

### 2、pull方式：KafkaUtils类的createStream方法

    def createStream[K: ClassTag, V: ClassTag, U <: Decoder[_]: ClassTag, T <: Decoder[_]: ClassTag](
          ssc: StreamingContext,
          kafkaParams: Map[String, String],
          topics: Map[String, Int],
          storageLevel: StorageLevel
        ): ReceiverInputDStream[(K, V)] = {
        val walEnabled = WriteAheadLogUtils.enableReceiverLog(ssc.conf)
        new KafkaInputDStream[K, V, U, T](ssc, kafkaParams, topics, walEnabled, storageLevel)
      }

参数解析：
   
      ssc： SparkStreaming 对象
      kafkaParams：kafka参数信息，里面包括zookeepr集群等参数。
      topics：kafka topic logstash 写入的哪个topic 我们就读取哪个topic
      storageLevel:存储级别 默认是StorageLevel.MEMORY_AND_DISK_SER_2

创建链接kafka需要参数kafkaParams
   
    val kafkaParams = Map[String,String](
      "auto.offset.reset"->"smallest",
      "zookeeper.connect"->zkQuorum,
      "group.id"->group
    )

参数解析：
   
    auto.offset.reset：设置从kafka哪个偏移量开始读 smallest 表示从头开始读
    zookeeper.connect：zookeeper集群信息
    group.id：消费者所在组的ID如果没有就填写1

连接：

    val lines = KafkaUtils.createStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topicMap,StorageLevel.MEMORY_AND_DISK)



