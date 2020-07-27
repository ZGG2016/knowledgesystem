# storm 与 JMS 集成

[百度解释JMS](https://baike.baidu.com/item/JMS/2836691?fr=aladdin)

## 关于 Storm JMS

Storm JMS 是在 Storm 框架内集成 JMS 消息传递的通过框架。

Storm-JMS 允许您通过 JMS spout 将数据注入到 Storm，并通过通用JMS bolt 从 Storm 消费数据。

JMS Spout 和 Bolt 都是数据不可知的。要使用它们，您需要提供一个简单的Java类，用于桥接 JMS 和 Storm API 以及封装和特定域的逻辑。

## 组件

#### JMS Spout

JMS Spout 组件允许将发布到 JMS topic 或 queue 的数据由 Storm topology 消费。 **JMS Spout 连接到 JMS Destination(主题或队列)，并根据收到的 JMS Messages 的内容发送给 Storm "Tuple" 对象**。[接收消息封装成元组]

#### JMS Bolt

JMS Bolt 组件允许将 Storm 拓扑中的数据发布到 JMS Destination（主题或队列）。

JMS Bolt **连接到 JMS Destination，并根据接收的 Storm "Tuple" 对象发布 JMS 消息**。

## Example Topology

### Example Storm JMS Topology

storm-jms 源代码包含一个示例项目(在“examples”目录中)，它构建了一个使用 JMS Spout 和 JMS Bolt 组件的 multi-bolt/multi-spout 拓扑(如下所示)。

![storm10](https://s1.ax1x.com/2020/06/29/Nfs2y4.png)

绿色组件表示 storm-jms 组件的实例。白色组件表示 “标准” storm bolt(在本例中，这些bolt是 GenericBolt 的实例，它只是记录有关它接收和发出的元组的信息)。

灰色箭头表示JMS消息，而黑色箭头表示Storm元组对象流。

### JMS Transactions and Gauranteed Processing

示例被设置为 “事务性”，这意味着 JMS Spout 将使用 Storm 的处理保证功能来确定 JMS 消息是否被确认了。拓扑中的每个 bolt 将锚定到它接收到的每个元组。**如果每个 bolt 成功地处理并 acks 链中的每个元组，则会确认原始 JMS 消息，而底层 JMS 实现将不会尝试重新传递该消息。如果一个 bolt 未能处理/ack 一个元组，那么JMS消息将不会被确认，JMS实现将对该消息进行排队等待重新传递。**

##### Data Flow

拓扑包含了两个链路：一个 连接到队列的JMS Spout，另一个连接到主题的JMS Spout。

Chain #1

- The "JMS Queue Spout" receives a JMS Message object from the queue, and emits a tuple to the "Intermediate Bolt"
- The "Intermediate Bolt" emits a tuple to the "Final Bolt" and the "JMS Topic Bolt", and acks the tuple it recieved.
- The "Final Bolt" receives the tuple and simply acks it, it does not emit anything.
The "JMS Topic Bolt" receives a tuple, constructs a JMS Message from the tuple's values, and publishes the message to a JMS Topic.
- If the "JMS Topic Bolt" successfully publishes the JMS message, it will ack the tuple.
- The "JMS Queue Spout" will recieve notification if all bolts in the chain have acked and acknowledge the original JMS Message. If one or more bolts in the chain fail to ack a tuple, the "JMS Queue Spout" will not acknowledge the JMS message.

Chain #2

- The "JMS Topic Spout" receives a JMS message from the topic and emits a tuple to "Another Bolt."
- The "Another Bolt" receives and acks the tuple.
- The "JMS Topic Spout" acknowledges the JMS message.

### Building the Example Topology
```
$ cd storm-jms
$ mvn clean install
```
##### Running the Example Topology Locally

[实例](https://github.com/apache/storm/tree/master/examples/storm-jms-examples) 中使用了 ApacheMQ 5.4.0。下载并安装 Apache ActiveMQ

这里没有进行配置，仅仅是启动ActiveMQ：
```
$ [ACTIVEMQ_HOME]/bin/activemq
```
在实例目录运行实例拓扑：
```
$ mvn exec:java
```
当拓扑运行时，将会链接到 ActiveMQ 。JMS Destinations 将被创建：
```
backtype.storm.contrib.example.queue
backtype.storm.contrib.example.topic
```
发布消息到 backtype.storm.contrib.example.queue queue:

    - Open the ActiveMQ Queue admin console: http://localhost:8161/admin/queues.jsp
    - Click the Send To link for the backtupe.storm.example.queue queue entry.
    - On the "Send a JMS Message" form, select the "Persistent Delivery" checkbox, enter some text for the message body, and click "Send".

在终端你会看到如下输出：

      DEBUG (backtype.storm.contrib.jms.bolt.JmsBolt:183) - Connecting JMS..
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:213) - sending tuple: ActiveMQTextMessage {commandId = 5, responseRequired = true, messageId = ID:budreau.home-51286-1321074044423-2:4:1:1:1, originalDestination = null, originalTransactionId = null, producerId = ID:budreau.home-51286-1321074044423-2:4:1:1, destination = queue://backtype.storm.contrib.example.queue, transactionId = null, expiration = 0, timestamp = 1321735055910, arrival = 0, brokerInTime = 1321735055910, brokerOutTime = 1321735055921, correlationId = , replyTo = null, persistent = true, type = , priority = 0, groupID = null, groupSequence = 0, targetConsumerId = null, compressed = false, userID = null, content = null, marshalledProperties = org.apache.activemq.util.ByteSequence@6c27ca12, dataStructure = null, redeliveryCounter = 0, size = 0, properties = {secret=880412b7-de71-45dd-8a80-8132589ccd22}, readOnlyProperties = true, readOnlyBody = true, droppable = false, text = Hello storm-jms!}
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:219) - Requested deliveryMode: CLIENT_ACKNOWLEDGE
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:220) - Our deliveryMode: CLIENT_ACKNOWLEDGE
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:224) - Requesting acks.
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:60) - [INTERMEDIATE_BOLT] Received message: source: 1:10, stream: 1, id: {-7100026097570233628=-7100026097570233628}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:66) - [INTERMEDIATE_BOLT] emitting: source: 1:10, stream: 1, id: {-7100026097570233628=-7100026097570233628}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:75) - [INTERMEDIATE_BOLT] ACKing tuple: source: 1:10, stream: 1, id: {-7100026097570233628=-7100026097570233628}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.bolt.JmsBolt:136) - Tuple received. Sending JMS message.
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:60) - [FINAL_BOLT] Received message: source: 2:2, stream: 1, id: {-7100026097570233628=-5393763013502927792}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:75) - [FINAL_BOLT] ACKing tuple: source: 2:2, stream: 1, id: {-7100026097570233628=-5393763013502927792}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.bolt.JmsBolt:144) - ACKing tuple: source: 2:2, stream: 1, id: {-7100026097570233628=-9118586029611278300}, [Hello storm-jms!]
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:251) - JMS Message acked: ID:budreau.home-51286-1321074044423-2:4:1:1:1
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:213) - sending tuple: ActiveMQTextMessage {commandId = 5, responseRequired = true, messageId = ID:budreau.home-60117-1321735025796-0:0:1:1:1, originalDestination = null, originalTransactionId = null, producerId = ID:budreau.home-60117-1321735025796-0:0:1:1, destination = topic://backtype.storm.contrib.example.topic, transactionId = null, expiration = 0, timestamp = 1321735056258, arrival = 0, brokerInTime = 1321735056260, brokerOutTime = 1321735056260, correlationId = null, replyTo = null, persistent = true, type = null, priority = 4, groupID = null, groupSequence = 0, targetConsumerId = null, compressed = false, userID = null, content = null, marshalledProperties = null, dataStructure = null, redeliveryCounter = 0, size = 0, properties = null, readOnlyProperties = true, readOnlyBody = true, droppable = false, text = source: 2:2, stream: 1, id: {-710002609757023... storm-jms!]}
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:219) - Requested deliveryMode: CLIENT_ACKNOWLEDGE
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:220) - Our deliveryMode: CLIENT_ACKNOWLEDGE
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:224) - Requesting acks.
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:60) - [ANOTHER_BOLT] Received message: source: 5:9, stream: 1, id: {-5117078009445186058=-5117078009445186058}, [source: 2:2, stream: 1, id: {-7100026097570233628=-9118586029611278300}, [Hello storm-jms!]]
      DEBUG (backtype.storm.contrib.jms.example.GenericBolt:75) - [ANOTHER_BOLT] ACKing tuple: source: 5:9, stream: 1, id: {-5117078009445186058=-5117078009445186058}, [source: 2:2, stream: 1, id: {-7100026097570233628=-9118586029611278300}, [Hello storm-jms!]]
      DEBUG (backtype.storm.contrib.jms.spout.JmsSpout:251) - JMS Message acked: ID:budreau.home-60117-1321735025796-0:0:1:1:1

拓扑会运行两分钟，然后优雅关闭。

## Using Spring JMS

Connecting to JMS Using Spring's JMS Support

Create a Spring applicationContext.xml file that defines one or more destination (topic/queue) beans, as well as a connecton factory.
```
<?xml version="1.0" encoding="UTF-8"?>
<beans
  xmlns="http://www.springframework.org/schema/beans"
  xmlns:amq="http://activemq.apache.org/schema/core"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd
  http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">

    <amq:queue id="notificationQueue" physicalName="backtype.storm.contrib.example.queue" />

    <amq:topic id="notificationTopic" physicalName="backtype.storm.contrib.example.topic" />

    <amq:connectionFactory id="jmsConnectionFactory"
        brokerURL="tcp://localhost:61616" />

</beans>
``
