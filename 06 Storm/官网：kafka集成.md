# storm 与 kafka（0.10.x+） 集成

使用 kafka-client jar 进行 Storm 和 Kafka 集成

这部分包含新的 Apache Kafka consumer API.

## 兼容性

**Apache Kafka 版本 0.10+**。如果在使用 1.1.0, 1.1.1 or 2.0.0 版本，请及时更新。

## 写入Kafka （作为bolt）

您可以通过创建 ```org.apache.storm.kafka.bolt.KafkaBolt``` 实例，将其作为组件附加到您的topology。如果您使用 trident，您可以通过使用以下对象完成 ```org.apache.storm.kafka.trident.TridentState, org.apache.storm.kafka.trident.TridentStateFactory and org.apache.storm.kafka.trident.TridentKafkaUpdater```.

需要实现以下两个接口:

#### TupleToKafkaMapper 和 TridentTupleToKafkaMapper

这些接口有两个抽象方法:
```
K getKeyFromTuple(Tuple/TridentTuple tuple);
V getMessageFromTuple(Tuple/TridentTuple tuple);
```    
顾名思义，**调用这两个方法从 tuple 取出 Kafka key 和 Kafka message** ([Kafka message理解](https://www.cnblogs.com/liuming1992/p/6425492.html))。如果你只想要一个字段[field]作为键和一个字段[field]作为值，那么您可以使用提供的 FieldNameBasedTupleToKafkaMapper.java 实现。在 KafkaBolt 中，使用 **默认构造函数** 构造 FieldNameBasedTupleToKafkaMapper 需要一个名称为 "key" 和 "message" 的字段 以实现向后兼容。 或者，如果不使用默认构造函数，那么需要指定一个不同的 key 和 message 字段。在使用 TridentKafkaState 时你必须指定 key 和 message 的字段名称，因为 TridentKafkaState 没有默认的构造函数。在构造 FieldNameBasedTupleToKafkaMapper 的实例时应明确这些。

#### KafkaTopicSelector 和 trident KafkaTopicSelector

这个接口只有一个方法:
```
public interface KafkaTopicSelector {
    String getTopics(Tuple/TridentTuple tuple);
}
```
实现接口的类应该要 **根据 tuple 的 key/message 返回相应的 Kafka topic**，如果返回 null 则该消息将被忽略掉。如果您只需要一个静态 topic 名称，那么可以使用 DefaultTopicSelector.java 并在构造函数中设置 topic 的名称。
**FieldNameTopicSelector 和 FieldIndexTopicSelector 用于决定 tuple 要发送到哪个 topic** ，用户只需要指定 tuple 中 存储 topic 名称 的字段[field]名称或字段[field]索引即可(即tuple中的某个字段是kafka topic的名称)。当 topic 的名称不存在时， Field*TopicSelector 会将 tuple 写入到默认的 topic。请确保默认topic已经在 kafka 中创建并且在Field*TopicSelector正确设置。

#### 设置 Kafka producer 属性

你可以在 topology 通过调用 KafkaBolt.withProducerProperties() 和 TridentKafkaStateFactory.withProducerProperties() 设置 kafka producer 的所有属性。Kafka producer配置在[Important configuration properties for the producer](http://kafka.apache.org/documentation.html#newproducerconfigs)查看更多详情。所有的 kafka producer 配置项的key都在 org.apache.kafka.clients.producer.ProducerConfig类中。

#### 使用通配符匹配 Kafka topic

通过添加如下属性 **开启通配符匹配 topic**(此功能是为了 storm 可以动态读取多个 kafka topic 中的数据，并支持动态发现.看相关功能的实现需求feture)
```
Config config = new Config();
config.put("kafka.topic.wildcard.match",true);
```
之后，您可以指定一个通配符 topic，例如 ```clickstream.*.log```。 这将匹配 clickstream.my.log , clickstream.cart.log 等topic。

## 综合一起

For the bolt :
```java
TopologyBuilder builder = new TopologyBuilder();

Fields fields = new Fields("key", "message");
FixedBatchSpout spout = new FixedBatchSpout(fields, 4,
            new Values("storm", "1"),
            new Values("trident", "1"),
            new Values("needs", "1"),
            new Values("javadoc", "1")
);
spout.setCycle(true);
builder.setSpout("spout", spout, 5);
//set producer properties.
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("acks", "1");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

KafkaBolt bolt = new KafkaBolt()
        .withProducerProperties(props)
        .withTopicSelector(new DefaultTopicSelector("test"))
        .withTupleToKafkaMapper(new FieldNameBasedTupleToKafkaMapper());
builder.setBolt("forwardToKafka", bolt, 8).shuffleGrouping("spout");

Config conf = new Config();

StormSubmitter.submitTopology("kafkaboltTest", conf, builder.createTopology());
```
For Trident:
```java
Fields fields = new Fields("word", "count");
FixedBatchSpout spout = new FixedBatchSpout(fields, 4,
        new Values("storm", "1"),
        new Values("trident", "1"),
        new Values("needs", "1"),
        new Values("javadoc", "1")
);
spout.setCycle(true);

TridentTopology topology = new TridentTopology();
Stream stream = topology.newStream("spout1", spout);

//set producer properties.
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("acks", "1");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

TridentKafkaStateFactory stateFactory = new TridentKafkaStateFactory()
        .withProducerProperties(props)
        .withKafkaTopicSelector(new DefaultTopicSelector("test"))
        .withTridentTupleToKafkaMapper(new FieldNameBasedTupleToKafkaMapper("word", "count"));
stream.partitionPersist(stateFactory, fields, new TridentKafkaStateUpdater(), new Fields());

Config conf = new Config();
StormSubmitter.submitTopology("kafkaTridentTest", conf, topology.build());
```
## 读取Kafka (Spouts)

#### 配置

spout 通过 **使用 KafkaSpoutConfig 类来指定配置**。 此类使用 Builder 模式，可以通过调用其中一个 Builders 构造函数 或 通过调用 KafkaSpoutConfig 类中的静态方法创建一个Builder。创建 builder 的 **构造方法或静态方法** 需要几个键值（稍后可以更改），但这是启动一个 spout 的所需的最小配置。

bootstrapServers 与 Kafka 消费者属性里的 "bootstrap.servers" 相同。 配置项`topics` 配置的是 spout 将消费的kafka topic，它可以是 特定主题名称（1个或多个）的集合列表 或 正则表达式Pattern，任何与正则表达式Pattern匹配的 topic 都将被消费。

在使用构造函数的情况下，您可能还需要 **指定 key deserializer 和 value deserializer**。这是为了通过使用 Java 泛型来保证类型安全。可以通过在消费者属性里设置 setProp 来设置使用哪种 deserializer 。在 KafkaConsumer 配置文档中了解详情。

下面是一些需要特别注意的关键配置项。

**setFirstPollOffsetStrategy** 作用是 **设置从哪里开始消费数据**。 这在 故障恢复 和 第一次启动spout 的情况下会被使用。在 FirstPollOffsetStrategy.javadocs 中列出了可选的的值。

**setProcessingGuarantee** 作用是 **配置 spout 将提供的处理保证**。这将影响提交消耗的偏移量的时间以及提交的频率。有关详细信息，请参阅 ProcessingGuarantee javadoc。

**setRecordTranslator** 作用是 **修改 spout 如何将一个 Kafka Consumer Record 转换为一个 tuple，以及将该 tuple 发布到哪个 stream 中**。默认情况下，"topic" 、"partition"、"offset"、"key" 和 "value" 将被发送到 "default" stream。如果要将条目根据 topic 输出到不同的 stream 中，Storm提供了 "ByTopicRecordTranslator" 。有关如何使用这些的更多示例,请参阅下文。

**setProp 和 setProps 用来设置 KafkaConsumer 属性**。可以在 KafkaConsumer 属性文档中找到属性列表。 KafkaConsumer 是不支持自动提交的。如果设置了 "enable.auto.commit" 属性，KafkaSpoutConfig 的构造方法会抛出异常，所以设置其为 false. 也可以通过实现 KafkaSpoutConfig builder 中的 setProcessingGuarantee 方法，以实现自动提交。

##  Usage Examples

#### 创建一个简单的不可靠spout。

以下将消费发布到 "topic" 的所有事件，并将其发送到 MyBolt，其中包含"topic"、"partition"、"offset"、"key"、"value"。
```java
final TopologyBuilder tp = new TopologyBuilder();
tp.setSpout("kafka_spout", new KafkaSpout<>(KafkaSpoutConfig.builder("127.0.0.1:" + port, "topic").build()), 1);
tp.setBolt("bolt", new myBolt()).shuffleGrouping("kafka_spout");
```

#### 通配符 Topics

通配符 topics 将消费所有符合通配符的 topics. 在下面的例子中 "topic"、 "topic_foo" 和 "topic_bar" 适配通配符 `"topic.*"`， 但是 "not_my_topic" 并不适配.
```java
final TopologyBuilder tp = new TopologyBuilder();
tp.setSpout("kafka_spout", new KafkaSpout<>(KafkaSpoutConfig.builder("127.0.0.1:" + port, Pattern.compile("topic.*")).build()), 1);
tp.setBolt("bolt", new myBolt()).shuffleGrouping("kafka_spout");
...
```
#### 多个 Streams
```java
final TopologyBuilder tp = new TopologyBuilder();
//默认情况下，spout 消费但未被match到的topic的message的"topic"、"key"和"value"将发送到"STREAM_1"
ByTopicRecordTranslator<String, String> byTopic = new ByTopicRecordTranslator<>(
    (r) -> new Values(r.topic(), r.key(), r.value()),
    new Fields("topic", "key", "value"), "STREAM_1");
//topic_2 所有的消息的 "key" and "value" 将发送到 "STREAM_2"中
byTopic.forTopic("topic_2", (r) -> new Values(r.key(), r.value()), new Fields("key", "value"), "STREAM_2");

tp.setSpout("kafka_spout", new KafkaSpout<>(KafkaSpoutConfig.builder("127.0.0.1:" + port, "topic_1", "topic_2", "topic_3").build()), 1);
tp.setBolt("bolt", new myBolt()).shuffleGrouping("kafka_spout", "STREAM_1");
tp.setBolt("another", new myOtherBolt()).shuffleGrouping("kafka_spout", "STREAM_2");
...
```
#### Trident
```java
final TridentTopology tridentTopology = new TridentTopology();
final Stream spoutStream = tridentTopology.newStream("kafkaSpout",
    new KafkaTridentSpoutOpaque<>(KafkaSpoutConfig.builder("127.0.0.1:" + port, Pattern.compile("topic.*")).build()))
      .parallelismHint(1)
...
```
Trident 不支持多个 stream 且不支持设置将 strem 分发到多个 output. 并且，如果每个 output 的 topic 的字段不一致会抛出异常而不会继续。

#### Example topologies

storm-kafka-client 中使用的实例拓扑可以在 [examples/storm-kafka-client-examples](https://github.com/apache/storm/tree/master/examples/storm-kafka-client-examples) 目录找到。

## 自定义 RecordTranslator(高级特性)

在大多数情况下，内置的 SimpleRecordTranslator 和 ByTopicRecordTranslator 应该满足您的使用。如果您遇到需要定制的情况那么这个文档将会描述如何正确地做到这一点，涉及到一些不太常用的类。

适用的要点是 使用 ConsumerRecord 并将其转换为可以提交的 List <object> 。难点是如何告诉 spout 将其发送到指定的 stream 中。为此，您将需要返回一个 "org.apache.storm.kafka.spout.KafkaTuple" 的实例. 这提供了一个方法 **routedTo，它将说明 tuple 将要发送到哪个特定 stream** 。

```java
return new KafkaTuple(1, 2, 3, 4).routedTo("bar");
```

将会使tuple发送到 "bar" stream中。

在编写自定义 record translators 时要小心，因为在Storm spout 中，需要保持自我一致性。 streams 方法应该返回这个 translator 将会尝试发到 streams 的完整列表。另外，getFieldsFor 应该为每一个 stream 返回一个有效的Fields对象(就是说通过字段名称可以拿到对应的正确的对象)。 如果您使用 Trident 执行此操作，则 Fields 对象中指定字段的所有值必须在 stream 名称的列表中，否则 trident 抛出异常.（原文:If you are doing this for Trident a value must be in the List returned by apply for every field in the Fields object for that stream）

## Manual Partition Assignment  手动分区控制 (高级特性)

默认情况下，Kafka 使用循环策略进行分区，KafkaSpout 实例就可以被分配到分区。 **如果想要自定义分区策略，要实现 ManualPartitioner 接口。** 你可以将类传给 KafkaSpoutConfig.Builder 构造方法。当应用自定义分区策略时，要小心。因为 ManualPartitioner 实现错误将会导致不能读取一些分区，或者同时读取多个 spout 实例。 如何实现这个功能见 RoundRobinManualPartitioner。

#### Manual partition discovery

通过 **实现 TopicFilter 接口，可以自定义 spout 发现已存在分区的方式**。Storm-kafka-client 附带了一些实现。与 ManualPartitioner 类似，您可以将您的类传递给 KafkaSpoutConfig.Builder 的构造函数。注意，TopicFilter 只负责发现分区，ManualPartitioner 负责决定要订阅哪个已发现的分区。

## Using storm-kafka-client with different versions of kafka

Storm-kafka-client 的 Kafka 依赖关系在 maven 中被定义为 provided，这意味着它不会被拉入 作为传递依赖。 这允许您使用与 kafka 集群兼容的 Kafka 依赖版本.

**当使用 storm-kafka-client 构建项目时，必须显式添加 Kafka clients 依赖关系。** 例如，使用Kafka client 0.10.0.0，您将使用以下依赖 pom.xml:
```
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>0.10.0.0</version>
        </dependency>
```
你也可以 **在使用 maven build 时通过指定参数 storm.kafka.client.version 来指定 kafka clients 版本**。例如 mvn clean install -Dstorm.kafka.client.version=0.10.0.0

选择 kafka client 版本时，您应该确保：

    1. kafka api是兼容的。**storm-kafka-client 模块仅支持 0.10 或更新的 kafka 客户端API**。 对于旧版本，您可以使用storm-kafka模块 (https://github.com/apache/storm/tree/master/external/storm-kafka).
    2. 您选择的 **kafka client 应与 broker 兼容**。 例如 0.9.x client 将无法使用 0.8.x broker。具体见[Kafka compatibility matrix](https://cwiki.apache.org/confluence/display/KAFKA/Compatibility+Matrix)

## Kafka Spout Performance Tuning  Kafka Spout 性能调整

Kafka spout 提供了两个内置参数来调节其性能. 参数可以通过 KafkaSpoutConfig 的 setOffsetCommitPeriodMs 和 setMaxUncommittedOffsets 方法进行设置

    "offset.commit.period.ms" 控制 spout 多久向 kafka 注册一次 offset
    "max.uncommitted.offsets" 控制读取多少条 message 向 kafka 注册一次 offset

Kafka consumer config 参数也可能对 spout 的性能产生影响。以下Kafka参数可能是 spout 性能中影响最大的一些参数：

    "fetch.min.bytes"
    "fetch.max.wait.ms"
    Kafka spout 使用 KafkaSpoutConfig 的 setPollTimeoutMs 方法设置 Kafka Consumer 读取数据的超时时间。

根据您的 Kafka 集群的结构、数据的分布和数据的可用性，这些参数必须正确配置。请参考关于 Kafka 参数调整的Kafka文档。

#### kafka spout配置默认值

目前 Kafka spout 有如下默认值，这在blog post所述的测试环境中表现出了良好的性能

    poll.timeout.ms = 200
    offset.commit.period.ms = 30000 (30s)
    max.uncommitted.offsets = 10000000

## Tuple Tracking

**当处理保证是 AT_LEAST_ONCE 时，默认情况下，spout 会追踪提交的元组**。使用其他的处理保证对于跟踪已发出的元组来说是有必要的，以受益于 Storm 特性，比如在UI中显示完整的延迟，或者使用 Config.TOPOLOGY_MAX_SPOUT_PENDING启用backpressure。[It may be necessary to track emitted tuples with other processing guarantees to benefit from Storm features such as showing complete latency in the UI, or enabling backpressure with Config.TOPOLOGY_MAX_SPOUT_PENDING.]
```java
KafkaSpoutConfig<String, String> kafkaConf = KafkaSpoutConfig
  .builder(String bootstrapServers, String ... topics)
  .setProcessingGuarantee(ProcessingGuarantee.AT_MOST_ONCE)
  .setTupleTrackingEnforced(true)
```
Note: This setting has no effect with AT_LEAST_ONCE processing guarantee, where tuple tracking is required and therefore always enabled.

参考：[Storm Kafka 集成（0.10.x+）](http://storm.apachecn.org/#/docs/56)

## Mapping from storm-kafka to storm-kafka-client spout properties
