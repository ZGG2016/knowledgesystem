# 大数据面试题汇总03--storm

[TOC]

## storm都从哪输入

**kafka**

（1）在pom文件中添加依赖
（2）
```
final TopologyBuilder tp = new TopologyBuilder();
tp.setSpout("kafka_spout", new KafkaSpout<>(KafkaSpoutConfig.builder("127.0.0.1:" + port, "topic").build()), 1);
tp.setBolt("bolt", new myBolt()).shuffleGrouping("kafka_spout");
```
（3）也可以通过通配符匹配topic.
（4）一个 KafkaSpout 流入多个 bolt
```
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
**JMS**

JMS Spout 连接到 JMS Destination(主题或队列)，并根据收到的 JMS Messages 的内容发送给 Storm "Tuple" 对象。

JMS Bolt **连接到 JMS Destination，并根据接收的 Storm "Tuple" 对象发布 JMS 消息**。
```
// JMS Queue Provider
        JmsProvider jmsQueueProvider = new SpringJmsProvider(
                "jms-activemq.xml", "jmsConnectionFactory",
                "notificationQueue");

        // JMS Producer
        JmsTupleProducer producer = new JsonTupleProducer();

        // JMS Queue Spout
        JmsSpout queueSpout = new JmsSpout();
        queueSpout.setJmsProvider(jmsQueueProvider);
        queueSpout.setJmsTupleProducer(producer);
        queueSpout.setJmsAcknowledgeMode(Session.CLIENT_ACKNOWLEDGE);


        // JMS Topic provider
        JmsProvider jmsTopicProvider = new SpringJmsProvider(
                "jms-activemq.xml", "jmsConnectionFactory",
                "notificationTopic");

        // bolt that subscribes to the intermediate bolt, and publishes to a JMS Topic
        JmsBolt jmsBolt = new JmsBolt();
        jmsBolt.setJmsProvider(jmsTopicProvider);

        // anonymous message producer just calls toString() on the tuple to create a jms message
        jmsBolt.setJmsMessageProducer(new JmsMessageProducer() {
            @Override
            public Message toMessage(Session session, ITuple input) throws JMSException {
                System.out.println("Sending JMS Message:" + input.toString());
                TextMessage tm = session.createTextMessage(input.toString());
                return tm;
            }
        });

        builder.setBolt(JMS_TOPIC_BOLT, jmsBolt).shuffleGrouping(INTERMEDIATE_BOLT);

        // JMS Topic spout
        JmsSpout topicSpout = new JmsSpout();
        topicSpout.setJmsProvider(jmsTopicProvider);
        topicSpout.setJmsTupleProducer(producer);
        topicSpout.setJmsAcknowledgeMode(Session.CLIENT_ACKNOWLEDGE);
        topicSpout.setDistributed(false);

        builder.setSpout(JMS_TOPIC_SPOUT, topicSpout);

        builder.setBolt(ANOTHER_BOLT, new GenericBolt("ANOTHER_BOLT", true, true), 1).shuffleGrouping(
                JMS_TOPIC_SPOUT);
```

[MQTT](http://storm.apache.org/releases/2.1.0/storm-mqtt.html)

[Kinesis](http://storm.apache.org/releases/2.1.0/storm-kinesis.html)

[Kestrel](http://storm.apache.org/releases/2.1.0/Kestrel-and-Storm.html)

## storm的节点

    nimbus:分布代码，分配任务，监控集群。
    supervisor:接收任务，分配给worker进程处理，管理worker进程
    zookeeper:负责Nimbus节点和Supervisor节点之间的协调工作，存放集群元数据(心跳信息、配置信息)，
    			      nimbus将分配给supervisor的任务写入zookeeper。

## storm构成一个图的节点，可以上游的bolt输出到下游的两个bolt中吗

可以。

    在topology提交时，在 grouping 中指定接收哪个流。
    在发送消息时，指定哪些数据通过哪个流(流ID)传输。
    接受消息时，需要判断数据流。

## spark和storm的区别  

spark是一个基于内存的大数据计算引擎，执行实时计算的库是spark streaming。Storm是分布式实时大数据计算系统。所以Storm侧重于计算的实时性，Spark侧重计算庞大数据（类似于Hadoop的MR）。

Spark流模块(Spark Streaming)与Storm类似，但有区别：

    1.Storm纯实时，数据流以元组为基本单元，每个Tuple类似于数据库中的一行记录[元组详解](https://www.cnblogs.com/zlslch/p/5989281.html)；SparkStreaming准实时，对一个时间段内的数据收集起来，作为一个RDD，再做处理。
    2.Storm响应时间毫秒级；Spark Streaming响应时间秒级
    3.Storm可以动态调整并行度；SparkStreaming不行
    storm rebalance topology-name [-w wait-time-secs] [-n new-num-workers] [-e component=parallelism]
    4.可靠性：SparkStreaming仅处理一次，Storm至少处理一次

Storm应用场景：

    1、对于需要纯实时，不能忍受1秒以上延迟的场景
    2、要求可靠的事务机制和可靠性机制，即数据的处理完全精准
    3、如果还需要针对高峰低峰时间段，动态调整实时计算程序的并行度，以最大限度利用集群资源

Spark Streaming应用场景：

    1、Spark Streaming可以和Spark Core、Spark SQL等无缝整合，如果一个项目除了实时计算之外，还包括了离线批处理、交互式查询等业务功能，考虑使用Spark Streaming。

Flink也是分布式流计算系统，其核心是流处理，批量处理是流处理的一个特殊应用。当输入数据流是无界时，Flink被视作流处理，当输入数据流是有界时，Flink被视作批量处理。数据仅处理一次。

参考：[Storm与Spark区别](https://www.cnblogs.com/moxiaotao/p/9939047.html)
[流式计算的三种框架：Storm、Spark和Flink](https://segmentfault.com/a/1190000020465688?utm_source=tag-newest)

## storm的ack-fail机制

ack-fail 机制为 storm 提供了可靠性保证。当一个元组从 spout 发出时，会为其赋予一个唯一的 msg id 。 发出的 tuple 经过后续的 bolt 处理，会形成一个元组树。bolt 每收到一个 tuple 都会向上游确认。

如果元组树上的原始 tuple 被每个 bolt 都确认应答了，则 spout 调用的 ack 方法来标记此消息被完全处理了。如果任何一个 bolt 处理 tuple 超时或出错，storm 会调用在 Spout 的 fail 方法。

当衍生的 tuple 从 bolt 发出时，会锚定读入的 tuple ，当消息被处理成功就会 调用 ack 方法。当处理失败，则会调用 fail 方法，再由 spout 重新发送 tuple 。

（锚定：建立读入 tuple 和衍生 tuple 间的联系）

## storm的分组策略，及各自含义

当 Bolt A 的一个任务向 Bolt B 发送元组时，应该发到 Bolt B 的哪个任务呢？

**stream groupings 就是用来告诉 Storm 如何在任务间发送元组**

### 1、Shuffle Grouping 

随机分组，随机派发 stream 里面的 tuple，保证每个 bolt task 接收到的 tuple 数目大致相同。

轮询，平均分配 

### 2、 Fields Grouping（相同fields去分发到同一个Bolt）

按字段分组，比如，按 "user-id" 这个字段来分组，那么具有同样 "user-id" 的 tuple 会被分到相同的 Bolt 里的一个 task， 而不同的 "user-id" 则可能会被分配到不同的 task。 

### 3、 All Grouping

广播发送，对于每一个 tuple，所有的 bolts 都会收到 

### 4、 Global Grouping

全局分组，所有的 tuple 将会发送给拥有最小 task_id 的 bolt 任务处理。

### 5、 None Grouping

不分组，不关注并行处理负载均衡策略时使用该方式，目前等同于shuffle grouping，另外 storm 将会把 bolt 任务和他的上游提供数据的任务安排在同一个线程下。

### 6、 Direct Grouping

指向型分组， tuple 的发送者指定由消息接收者的哪个 task 处理这个消息。只有被声明为 Direct Stream 的消息流可以声明这种分组方法。而且这种消息 tuple 必须使用 emitDirect 方法来发射。消息处理者可以通过 TopologyContext 来获取处理它的消息的task的id (OutputCollector.emit方法也会返回task的id)  

### 7、Local or shuffle grouping

本地或随机分组。如果目标 bolt 有一个或者多个 task 与源 bolt 的 task 在同一个工作进程中，tuple 将会被随机发送给这些同进程中的 tasks。否则，和普通的 Shuffle Grouping 行为一致

### 8、Partial Key grouping

The stream is partitioned by the fields specified in the grouping, like the Fields grouping, but are load balanced between two downstream bolts, which provides better utilization of resources **when the incoming data is skewed.** [This paper](https://melmeric.files.wordpress.com/2014/11/the-power-of-both-choices-practical-load-balancing-for-distributed-stream-processing-engines.pdf) provides a good explanation of how it works and the advantages it provides.

当数据倾斜的时候

### 9、customGrouping

自定义，相当于mapreduce那里自己去实现一个partition一样。

```java
// 一个自定义分组，总是把数据分到第一个Task：

public class MyFirstStreamGrouping implements CustomStreamGrouping {
    private static Logger log = LoggerFactory.getLogger(MyFirstStreamGrouping.class);

    private List<Integer> tasks;

    @Override
    public void prepare(WorkerTopologyContext context, GlobalStreamId stream,
        List<Integer> targetTasks) {
        this.tasks = targetTasks;
        log.info(tasks.toString());
    }   
    @Override
    public List<Integer> chooseTasks(int taskId, List<Object> values) {
        log.info(values.toString());
        return Arrays.asList(tasks.get(0));
    }
}
```
原文链接：

[【Storm篇】--Storm分组策略](https://www.cnblogs.com/LHWorldBlog/p/8352994.html) 、 [Twitter Storm Stream Grouping编写自定义分组实现](https://my.oschina.net/zhzhenqin/blog/223304)

## storm中spout和bolt间的通信协议

![storm通信机制](https://blog.csdn.net/qq_41455420/article/details/79391338)
