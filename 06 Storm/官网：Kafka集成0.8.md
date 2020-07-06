# Storm集成Kafka

Kafka 0.8.X

## Deprecated

Storm-kafka 在未来的版本会被弃用。请更新到 storm-kafka-client。如果需要将提交的 offsets 迁移到新的 spout，可以考虑使用 storm-kafka-migration 工具。

为了能消费从 Kafka 0.8.x 传来的数据，提供了 core Storm and Trident spout 的实现。

## Spouts

我们支持 Trident 和 core Storm 的spout。对于这两种 spout 实现，我们使用 BorkerHosts 接口来跟踪 Kafka broker host partition 映射关系，用 KafkaConfig 来控制 Kafka 相关参数.

### BrokerHosts

为了初始化 Kafka spout/emitter，你需要构造一个 BrokerHosts 标记接口的实例。当前，我们支持以下两种实现方式.

##### ZkHosts

如果你想要动态的跟踪Kafka broker partition 映射关系，你应该使用ZkHosts。这个类使用 Kafka Zookeeper entries 跟踪 brokerHost -> partition 映射。你可以调用下面的方法来得到一个实例.
```java
public ZkHosts(String brokerZkStr, String brokerZkPath)
public ZkHosts(String brokerZkStr)
```
ZkStr 字符串格式是 ip:port（例如：localhost:2181）

brokerZkPath 是存储所有 topic 和 partition信息的根目录。

默认情况下，Kafka使用 /brokers路径.

默认情况下，broker-partition 映射关系每60s秒从Zookeeper刷新一次.如果你想要改变这个时间，你需要设置 host.refreshFreqSecs 配置.

##### StaticHosts

这是一种可替代的实现，broker->partition 是静态的.要构造这个类的实例，你需要先构造一个 GlobalPartitionInformation 的实例。
```java
	Broker brokerForPartition0 = new Broker("localhost");//localhost:9092

	Broker brokerForPartition1 = new Broker("localhost", 9092);//localhost:9092 but we specified the port explicitly

	Broker brokerForPartition2 = new Broker("localhost:9092");//localhost:9092 specified as one string.

	GlobalPartitionInformation partitionInfo = new GlobalPartitionInformation();

	partitionInfo.addPartition(0, brokerForPartition0);//mapping from partition 0 to brokerForPartition0

	partitionInfo.addPartition(1, brokerForPartition1);//mapping from partition 1 to brokerForPartition1

	partitionInfo.addPartition(2, brokerForPartition2);//mapping from partition 2 to brokerForPartition2

	StaticHosts hosts = new StaticHosts(partitionInfo);
```

## KafkaConfig

构造一个 KafkaSpout 的实例，第二件事情就是要实例化 KafkaConfig。
```java
public KafkaConfig(BrokerHosts hosts, String topic)
public KafkaConfig(BrokerHosts hosts, String topic, String clientId)
```
BrokerHosts 可以是上述 BrokerHosts 的任意实现。topic 就是 Kafka topic 的名称。可选择的 ClientId 就是 zk 的路径的一部分，存储着当前 spout 的消费 offset。

有两个 KafkaConfig 子类。

SpoutConfig 是 KafkaConfig 的子类，支持带有 Zookeeper 连接信息的其他的 fields，控制 KafkaSpout 的行为。Zkroot 被用来存储你的消费者的offset的源。id是识别你的spout的唯一的认证。

```java
public SpoutConfig(BrokerHosts hosts, String topic, String clientId, String zkRoot, String id);
public SpoutConfig(BrokerHosts hosts, String topic, String zkRoot, String id);
public SpoutConfig(BrokerHosts hosts, String topic, String id);
```

除此之外，SpoutConfig 包含下面这些 fields，用来控制 KafkaSpout 的行为：
```java
	// 设置多久向ZooKeeper存储当期那kafka offet
	public long stateUpdateIntervalMs = 2000;

	// Retry strategy for failed messages
	public String failedMsgRetryManagerClass = ExponentialBackoffMsgRetryManager.class.getName();

	// Exponential back-off retry settings. 被ExponentialBackoffMsgRetryManager重发messages在
	//一个bolt调用OutputCollector.fail()之后。
	//  These come into effect only if ExponentialBackoffMsgRetryManager is being used.
	// 在两次连续重试之间的间隔
	public long retryInitialDelayMs = 0;
	public double retryDelayMultiplier = 1.0;

	// Maximum delay between successive retries    
	public long retryDelayMaxMs = 60 * 1000;
	// 如果retryLimit小于0，发送失败的message将被无限重发。
	public int retryLimit = -1;     
```
Core KafkaSpout 只接受 SpoutConfig 实例化的对象。

TridentKafkaConfig是KafkaConfig的另一个子类。TridentKafkaEmitter 只接受TridentKafkaConfig。

KafkaConfig类也有一些公共变量来控制你的应用程序的行为。以下是默认值：
```java
public int fetchSizeBytes = 1024 * 1024;
public int socketTimeoutMs = 10000;
public int fetchMaxWait = 10000;
public int bufferSizeBytes = 1024 * 1024;
public MultiScheme scheme = new RawMultiScheme();
public boolean ignoreZkOffsets = false;
public long startOffsetTime = kafka.api.OffsetRequest.EarliestTime();
public long maxOffsetBehind = Long.MAX_VALUE;
public boolean useStartOffsetTimeIfOffsetOutOfRange = true;
public int metricsTimeBucketSizeInSecs = 60;
```
Most of them are self explanatory except MultiScheme.

## MultiScheme

MultiScheme 是一个接口，暗示了 ByteBuffer 如何消费来自 kafka 的数据，并将其转成一个 storm 元组。它也控制着你的输出域的命名。
```java
	public Iterable<List<Object>> deserialize(ByteBuffer ser);
	public Fields getOutputFields();
```

默认的 RawMultiScheme 接受 ByteBuffer 参数，并返回一个 tuple.就是将ByteBuffer 转换成 byte[].outPutField 的名称是 “bytes”。还有可选的的实现，像 SchemeAsMultiScheme 和 KeyValueSchemeAsMultiScheme，他们会将 ByteBuffer 转换成 String.

还有一个 SchemeAsMultiScheme 的子类 --MessageMetadataSchemeAsMultiScheme，它有一个额外的反序列化方法
```java
	public Iterable<List<Object>> deserializeMessageWithMetadata(ByteBuffer message, Partition partition, long offset)
```
上面这个方法对于 auditing/replaying Kafka topic 上任意一个点的消息非常有用，保存了每条消息的 partition和 offset，而不是保留整个消息.

## Failed message retry

FailedMsgRetryManager 是一个定义发送失败的消息重发策略的接口，默认的实现是ExponentialBackoffMsgRetryManager，它在连续两次重试之间以指数延迟重试。要使用自定义实现，请将SpoutConfig.failedMsgRetryManagerClass设置为完整的实现类名称。
```java
	 // Spout initialization can go here. This can be called multiple times during lifecycle of a worker.
    void prepare(SpoutConfig spoutConfig, Map stormConf);

    // Message corresponding to offset has failed. This method is called only if retryFurther returns true for offset.
    void failed(Long offset);

    // Message corresponding to offset has been acked.  
    void acked(Long offset);

    // Message corresponding to the offset, has been re-emitted and under transit.
    void retryStarted(Long offset);

    /**
     * The offset of message, which is to be re-emitted. Spout will fetch messages starting from this offset
     * and resend them, except completed messages.
     */
    Long nextFailedMessageToRetry();

    /**
     * @return True if the message corresponding to the offset should be emitted NOW. False otherwise.
     */
    boolean shouldReEmitMsg(Long offset);

    /**
     * Spout will clean up the state for this offset if false is returned. If retryFurther is set to true,
     * spout will called failed(offset) in next call and acked(offset) otherwise
     */
    boolean retryFurther(Long offset);

    /**
     * Clear any offsets before kafkaOffset. These offsets are no longer available in kafka.
     */
    Set<Long> clearOffsetsBefore(Long kafkaOffset);
```
## Examples

Core Spout
```java
	BrokerHosts hosts = new ZkHosts(zkConnString);

	SpoutConfig spoutConfig = new SpoutConfig(hosts, topicName, "/" + topicName, UUID.randomUUID().toString());

	spoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());

	KafkaSpout kafkaSpout = new KafkaSpout(spoutConfig);
```
Trident Spout
```java
	TridentTopology topology = new TridentTopology();

	BrokerHosts zk = new ZkHosts("localhost");

	TridentKafkaConfig spoutConf = new TridentKafkaConfig(zk, "test-topic");

	spoutConf.scheme = new SchemeAsMultiScheme(new StringScheme());

	OpaqueTridentKafkaSpout spout = new OpaqueTridentKafkaSpout(spoutConf);
```

## KafkaSpout如何存储Kafka topic的offset，以及如何从failures中恢复？

可以通过设置 KafkaConfig.startOffsetTime 来控制从Kafka topic 的哪个端口开始读取，如下所示：

	kafka.api.OffsetRequest.EarliestTime(): 从topic 初始位置读取消息 (例如，从最老的那个消息开始)

	kafka.api.OffsetRequest.LatestTime(): 从topic尾部开始读取消息 (例如，新写入topic的信息)

	A Unix timestamp aka seconds since the epoch (e.g. via System.currentTimeMillis()): see How do I accurately get offsets of messages for a certain timestamp using OffsetRequest? in the Kafka FAQ

当topology（拓扑）运行Kafka Spout ，并跟踪读取和发送的offset，并将状态信息存储到zk path SpoutConfig.zkRoot+ "/" + SpoutConfig.id.在故障的情况下，它会从ZooKeeper的最后一次写入偏移中恢复。

    Important: 新部署topology（拓扑）时，请确保SpoutConfig.zkRoot和SpoutConfig.id的设置未被修改， 否则spout将无法从ZooKeeper中读取以前的消费者状态信息（即偏移量）导致意外的行为和/或数据丢失，具体取决于您的用例。

这意味着当topology（拓扑）运行一旦设置KafkaConfig.startOffsetTime将不会对 topology（拓扑）的后续运行产生影响， 因为现在 topology（拓扑）将依赖于ZooKeeper中的消费者状态信息（偏移量）来确定从哪里开始（更多准确地：简历）阅读。 如果要强制该端口忽略存储在ZooKeeper中的任何消费者状态信息，则应将参数KafkaConfig.ignoreZkOffsets 设置为true。如果为true， 则如上所述，spout 将始终从KafkaConfig.startOffsetTime定义的偏移量开始读取。

## Using storm-kafka with different versions of Kafka

Storm-kafka's Kafka dependency is defined as provided scope in maven, meaning it will not be pulled in as a transitive dependency. This allows you to use a version of Kafka dependency-compatible with your Kafka cluster.

When building a project with storm-kafka, you must explicitly add the Kafka dependency. For example, to use Kafka 0.8.1.1 built against Scala 2.10, you would use the following dependency in your pom.xml:
```
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka_2.10</artifactId>
    <version>0.8.1.1</version>
    <exclusions>
        <exclusion>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
        </exclusion>
        <exclusion>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```
Note that the ZooKeeper and log4j dependencies are excluded to prevent version conflicts with Storm's dependencies.

You can also override the kafka dependency version while building from maven, with parameter storm.kafka.version and storm.kafka.artifact.id e.g. mvn clean install -Dstorm.kafka.artifact.id=kafka_2.11 -Dstorm.kafka.version=0.9.0.1

When selecting a kafka dependency version, you should ensure -

kafka api is compatible with storm-kafka. Currently, only 0.9.x and 0.8.x client API is supported by storm-kafka module. If you want to use a higher version, storm-kafka-client module should be used instead.
The kafka client selected by you should be wire compatible with the broker. e.g. 0.9.x client will not work with 0.8.x broker.

## Writing to Kafka as part of your topology

您可以创建一个 org.apache.storm.kafka.bolt.KafkaBolt 的实例，并将其作为组件附加到 topology（拓扑）中，或者如果您使用 Trident，则可以使用 org.apache.storm.kafka.trident.TridentState，org.apache .storm.kafka.trident.TridentStateFactory和org.apache.storm.kafka.trident.TridentKafkaUpdater。

您需要提供以下2个接口的实现:

### TupleToKafkaMapper and TridentTupleToKafkaMapper

这个接口有下面两个方法:
```java
    K getKeyFromTuple(Tuple/TridentTuple tuple);
    V getMessageFromTuple(Tuple/TridentTuple tuple);
```
这些方法被称为将 tuple 映射到 Kafka key 和Kafka 消息。 如果您只需要一个字段作为键和一个字段作为值，则可以使用提供的 FieldNameBasedTupleToKafkaMapper.java 实现。在 KafkaBolt 中，如果使用默认构造函数构造 FieldNameBasedTupleToKafkaMapper，则实现始终会查找字段名称为 “key” 和 “message” 的字段。 或者，您也可以使用非默认构造函数指定不同的键和消息字段。在 TridentKafkaState 中，您必须指定键和消息的字段名称，因为没有默认构造函数。 在构造 FieldNameBasedTupleToKafkaMapper 实例时应该指定这些。

### KafkaTopicSelector and trident

KafkaTopicSelector：

这个接口只有一个方法：
```java
	public interface KafkaTopicSelector {
	    String getTopics(Tuple/TridentTuple tuple);
	}
```
该接口的实现应该返回要发布的 tuple 的 key/message 映射的 topic。您也可以返回一个 null，那么该消息将被忽略。如果您有一个静态的 topic 名称，那么可以使用 DefaultTopicSelector.java 并在构造函数中设置主题的名称。

FieldNameTopicSelector 和 FieldIndexTopicSelector 用于支持决定哪个 topic 应该从 tuple 送消息。 用户可以在 tuple 中指定字段名称或字段索引，selector 将使用该值作为发布消息的 topic 名称。 当找不到 topic 名称时，KafkaBolt 会将消息写入默认 topic。请确保已创建默认 topic。

#### 指定Kafka生产者的属性

可以在拓扑中通过调用 KafkaBolt.withProducerProperties() and TridentKafkaStateFactory.withProducerProperties() 来提供所有生产者的属性。

#### Using wildcard kafka topic match

可以指定一个指定通配符topic来匹配多个topic。
```java
	Config config = new Config();
	config.put("kafka.topic.wildcard.match",true);
```

### 整合
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
	stream.partitionPersist(stateFactory, fields, new TridentKafkaUpdater(), new Fields());

	Config conf = new Config();
	StormSubmitter.submitTopology("kafkaTridentTest", conf, topology.build());
```
