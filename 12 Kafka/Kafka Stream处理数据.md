# Kafka Stream处理数据

Kafka Stream 是 kafka 的客户端库，用于实时流处理和分析存储在 kafka broker 的数据。

这个快速入门示例将演示如何运行一个流应用程序。一个 WordCountDemo 的例子。

```java
public class MyKafkaStreams {
	public static void main(String[] args){
	    Properties props = new Properties();
	
	    props.put(StreamsConfig.APPLICATION_ID_CONFIG,"wordcount-application");
	    props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG,"namenode1:9092,datanode1:9092,datanode2:9092");
	    props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG,Serdes.String().getClass());
	    props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG,Serdes.String().getClass());
	
	    StreamsConfig config = new StreamsConfig(props);
	
	    KStreamBuilder builder = new KStreamBuilder();
	    KStream<String,String> textLines = builder.stream("InputTopic");
	    KTable<String,Long> wordCounts = textLines
	     //通过空格划分文本行
	        .flatMapValues(textLine -> Arrays.asList(textLine.toLowerCase().split("\\W+")))
	        .groupBy((key, word) -> word)
	        .count("Counts");
	
	    wordCounts.to(Serdes.String(),Serdes.Long(),"OutputTopic");
	
	    KafkaStreams streams = new KafkaStreams(builder, config);
	    streams.start();
	
	    }
	}
```

1、创建topic：InputTopic、OutputTopic

	bin/kafka-topics.sh --create \
    --zookeeper localhost:2181 \
    --replication-factor 1 \
    --partitions 1 \
    --topic InputTopic

	bin/kafka-topics.sh --create \
    --zookeeper localhost:2181 \
    --replication-factor 1 \
    --partitions 1 \
    --topic OutputTopic

2、运行代码

（可以打成jar包，实例如下：）

	bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo

3、生产

	bin/kafka-console-producer.sh --broker-list namenode1:9092,datanode1:9092,datanode2:9092 --topic InputTopic

4、检查WordCountDemo应用，从输出的topic读取。

	bin/kafka-console-consumer --zookeeper namenode1:2181 
            --topic OutputTopic 
            --from-beginning 
            --formatter kafka.tools.DefaultMessageFormatter 
            --property print.key=true 
            --property print.value=true 
            --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer 
            --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer

来一条数据处理一条数据