# 官网：Spark Streaming Programming Guide

[TOC]

## 1、Overview

*Spark Streaming is an extension of the core Spark API that enables scalable, high-throughput, fault-tolerant stream processing of live data streams. Data can be ingested from many sources like Kafka, Kinesis, or TCP sockets, and can be processed using complex algorithms expressed with high-level functions like map, reduce, join and window. Finally, processed data can be pushed out to filesystems, databases, and live dashboards. In fact, you can apply Spark’s [machine learning](http://spark.apache.org/docs/latest/ml-guide.html) and [graph processing algorithms](http://spark.apache.org/docs/latest/graphx-programming-guide.html) on data streams.*


Spark Streaming 是 Spark core API 的扩展，具有可扩展性、高吞吐、容错。

- 输入可以是Kafka, Kinesis, or TCP sockets。

- 可以使用 map, reduce, join and window 等高级函数处理数据。

- 处理后的数据可以输出到文件系统、数据库、实时 dashboards

![spark02](./image/spark02.png)

*Internally, it works as follows. Spark Streaming receives live input data streams and divides the data into batches, which are then processed by the Spark engine to generate the final stream of results in batches.*

内部流程是：Spark Streaming接收实时输入数据流，将其划分成多个批次，Spark 引擎处理批次，生成各批次的最终的结果流。

![spark03](./image/spark03.png)

*Spark Streaming provides a high-level abstraction called discretized stream or DStream, which represents a continuous stream of data. DStreams can be created either from input data streams from sources such as Kafka, and Kinesis, or by applying high-level operations on other DStreams. Internally, a DStream is represented as a sequence of RDDs.*

DStream 表示一个持续的数据流。可以从 Kafka或Kinesis等数据源创建，也可以从其他 DStream 创建。 

在内部，一个 DStream 就是一个 [RDD](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/rdd/RDD.html) 序列。

*This guide shows you how to start writing Spark Streaming programs with DStreams. You can write Spark Streaming programs in Scala, Java or Python (introduced in Spark 1.2), all of which are presented in this guide. You will find tabs throughout this guide that let you choose between code snippets of different languages.*

*Note: There are a few APIs that are either different or not available in Python. Throughout this guide, you will find the tag Python API highlighting these differences.*

## 2、A Quick Example

*Before we go into the details of how to write your own Spark Streaming program, let’s take a quick look at what a simple Spark Streaming program looks like. Let’s say we want to count the number of words in text data received from a data server listening on a TCP socket. All you need to do is as follows.*

从 TCP socket 发送数据，再统计文本中单词的数量。

**A：对于python**

*First, we import StreamingContext, which is the main entry point for all streaming functionality. We create a local StreamingContext with two execution threads, and batch interval of 1 second.*

先导入程序主入口 StreamingContext，并创建，两个执行线程，批次为间隔1秒。

```python
from pyspark import SparkContext
from pyspark.streaming import StreamingContext

# Create a local StreamingContext with two working thread and batch interval of 1 second
sc = SparkContext("local[2]", "NetworkWordCount")
ssc = StreamingContext(sc, 1)
```
*Using this context, we can create a DStream that represents streaming data from a TCP source, specified as hostname (e.g. localhost) and port (e.g. 9999).*

创建 DStream

```python
# Create a DStream that will connect to hostname:port, like localhost:9999
lines = ssc.socketTextStream("localhost", 9999)
```
*This lines DStream represents the stream of data that will be received from the data server. Each record in this DStream is a line of text. Next, we want to split the lines by space into words.*

此处使用了 DStream 表示数据已接收。

DStream 的每个记录是文本的一行。

下面的程序就是将行划分成单词。

```python
# Split each line into words
words = lines.flatMap(lambda line: line.split(" "))
```

*flatMap is a one-to-many DStream operation that creates a new DStream by generating multiple new records from each record in the source DStream. In this case, each line will be split into multiple words and the stream of words is represented as the words DStream. Next, we want to count these words.*

flatMap 由原 DStream 中的每条记录生成多条记录，返回一个新的 DStream。

那么 words 流由 words DStream 表示。

```python
# Count each word in each batch
pairs = words.map(lambda word: (word, 1))
wordCounts = pairs.reduceByKey(lambda x, y: x + y)

# Print the first ten elements of each RDD generated in this DStream to the console
wordCounts.pprint()
```
*The words DStream is further mapped (one-to-one transformation) to a DStream of (word, 1) pairs, which is then reduced to get the frequency of words in each batch of data. Finally, wordCounts.pprint() will print a few of the counts generated every second.*

- words DStream 被映射成 (word, 1) pairs DStream。

- 然后 reduceByKey 得到数据的每个批次中单词的数量。

- 最后，wordCounts.print()将打印每秒生成的一些计数。

*Note that when these lines are executed, Spark Streaming only sets up the computation it will perform when it is started, and no real processing has started yet. To start the processing after all the transformations have been setup, we finally call*

请注意，当这些行被执行的时候，Spark Streaming 仅仅设置了计算，并没有开始真正地处理，只有在启动时才会执行。为了在所有的转换都已经设置好之后开始处理，我们在最后调用:

```python
ssc.start()             # Start the computation
ssc.awaitTermination()  # Wait for the computation to terminate
```

*The complete code can be found in the Spark Streaming example [NetworkWordCount](https://github.com/apache/spark/blob/v3.0.0/examples/src/main/python/streaming/network_wordcount.py).*

*If you have already downloaded and built Spark, you can run this example as follows. You will first need to run Netcat (a small utility found in most Unix-like systems) as a data server by using*

```sh
$ nc -lk 9999
```

*Then, in a different terminal, you can start the example by using*

```sh
$ ./bin/spark-submit examples/src/main/python/streaming/network_wordcount.py localhost 9999
```
*Then, any lines typed in the terminal running the netcat server will be counted and printed on screen every second. It will look something like the following.*

终端1：

	# TERMINAL 1:
	# Running Netcat

	$ nc -lk 9999

	hello world



	...

终端2：

	# TERMINAL 2: RUNNING network_wordcount.py

	$ ./bin/spark-submit examples/src/main/python/streaming/network_wordcount.py localhost 9999
	...
	-------------------------------------------
	Time: 2014-10-14 15:25:21
	-------------------------------------------
	(hello,1)
	(world,1)
	...

**B：对于java**

*First, we create a JavaStreamingContext object, which is the main entry point for all streaming functionality. We create a local StreamingContext with two execution threads, and a batch interval of 1 second.*

[JavaStreamingContext](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/streaming/api/java/JavaStreamingContext.html)

```java
import org.apache.spark.*;
import org.apache.spark.api.java.function.*;
import org.apache.spark.streaming.*;
import org.apache.spark.streaming.api.java.*;
import scala.Tuple2;

// Create a local StreamingContext with two working thread and batch interval of 1 second
SparkConf conf = new SparkConf().setMaster("local[2]").setAppName("NetworkWordCount");
JavaStreamingContext jssc = new JavaStreamingContext(conf, Durations.seconds(1));
```
*Using this context, we can create a DStream that represents streaming data from a TCP source, specified as hostname (e.g. localhost) and port (e.g. 9999).*

```java
// Create a DStream that will connect to hostname:port, like localhost:9999
JavaReceiverInputDStream<String> lines = jssc.socketTextStream("localhost", 9999);
```

*This lines DStream represents the stream of data that will be received from the data server. Each record in this stream is a line of text. Then, we want to split the lines by space into words.*

```java
// Split each line into words
JavaDStream<String> words = lines.flatMap(x -> Arrays.asList(x.split(" ")).iterator());
```
*flatMap is a DStream operation that creates a new DStream by generating multiple new records from each record in the source DStream. In this case, each line will be split into multiple words and the stream of words is represented as the words DStream. Note that we defined the transformation using a 'FlatMapFunction](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/api/java/function/FlatMapFunction.html) object. As we will discover along the way, there are a number of such convenience classes in the Java API that help defines DStream transformations.*

*Next, we want to count these words.*

```java
// Count each word in each batch
JavaPairDStream<String, Integer> pairs = words.mapToPair(s -> new Tuple2<>(s, 1));
JavaPairDStream<String, Integer> wordCounts = pairs.reduceByKey((i1, i2) -> i1 + i2);

// Print the first ten elements of each RDD generated in this DStream to the console
wordCounts.print();
```

*The words DStream is further mapped (one-to-one transformation) to a DStream of (word, 1) pairs, using a [PairFunction](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/api/java/function/PairFunction.html) object. Then, it is reduced to get the frequency of words in each batch of data, using a [Function2](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/api/java/function/Function2.html) object. Finally, wordCounts.print() will print a few of the counts generated every second.*

*Note that when these lines are executed, Spark Streaming only sets up the computation it will perform after it is started, and no real processing has started yet. To start the processing after all the transformations have been setup, we finally call start method.*

```java
jssc.start();              // Start the computation
jssc.awaitTermination();   // Wait for the computation to terminate
```

*The complete code can be found in the Spark Streaming example [JavaNetworkWordCount](https://github.com/apache/spark/blob/v3.0.0/examples/src/main/java/org/apache/spark/examples/streaming/JavaNetworkWordCount.java).*

*If you have already downloaded and [built](http://spark.apache.org/docs/latest/index.html#building) Spark, you can run this example as follows. You will first need to run Netcat (a small utility found in most Unix-like systems) as a data server by using*

```sh
$ nc -lk 9999
```

*Then, in a different terminal, you can start the example by using*

```sh
$ ./bin/run-example streaming.JavaNetworkWordCount localhost 9999
```

*Then, any lines typed in the terminal running the netcat server will be counted and printed on screen every second. It will look something like the following.*

	# TERMINAL 1:
	# Running Netcat

	$ nc -lk 9999

	hello world



	...

	# TERMINAL 2: RUNNING JavaNetworkWordCount

	$ ./bin/run-example streaming.JavaNetworkWordCount localhost 9999
	...
	-------------------------------------------
	Time: 1357008430000 ms
	-------------------------------------------
	(hello,1)
	(world,1)
	...

**C：对于scala**

*First, we import the names of the Spark Streaming classes and some implicit conversions from StreamingContext into our environment in order to add useful methods to other classes we need (like DStream). StreamingContext is the main entry point for all streaming functionality. We create a local StreamingContext with two execution threads, and a batch interval of 1 second.*

```scala
import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._ // not necessary since Spark 1.3

// Create a local StreamingContext with two working thread and batch interval of 1 second.
// The master requires 2 cores to prevent a starvation scenario.

val conf = new SparkConf().setMaster("local[2]").setAppName("NetworkWordCount")
val ssc = new StreamingContext(conf, Seconds(1))
```
*Using this context, we can create a DStream that represents streaming data from a TCP source, specified as hostname (e.g. localhost) and port (e.g. 9999).*

```scala
// Create a DStream that will connect to hostname:port, like localhost:9999
val lines = ssc.socketTextStream("localhost", 9999)
```
*This lines DStream represents the stream of data that will be received from the data server. Each record in this DStream is a line of text. Next, we want to split the lines by space characters into words.*

```scala
// Split each line into words
val words = lines.flatMap(_.split(" "))
```
*flatMap is a one-to-many DStream operation that creates a new DStream by generating multiple new records from each record in the source DStream. In this case, each line will be split into multiple words and the stream of words is represented as the words DStream. Next, we want to count these words.*

```scala
import org.apache.spark.streaming.StreamingContext._ // not necessary since Spark 1.3
// Count each word in each batch
val pairs = words.map(word => (word, 1))
val wordCounts = pairs.reduceByKey(_ + _)

// Print the first ten elements of each RDD generated in this DStream to the console
wordCounts.print()
```

*The words DStream is further mapped (one-to-one transformation) to a DStream of (word, 1) pairs, which is then reduced to get the frequency of words in each batch of data. Finally, wordCounts.print() will print a few of the counts generated every second.*

*Note that when these lines are executed, Spark Streaming only sets up the computation it will perform when it is started, and no real processing has started yet. To start the processing after all the transformations have been setup, we finally call*

```scala
ssc.start()             // Start the computation
ssc.awaitTermination()  // Wait for the computation to terminate
```
*The complete code can be found in the Spark Streaming example NetworkWordCount. *

*If you have already downloaded and built Spark, you can run this example as follows. You will first need to run Netcat (a small utility found in most Unix-like systems) as a data server by using*

```sh
$ nc -lk 9999
```

*Then, in a different terminal, you can start the example by using*

```sh
$ ./bin/run-example streaming.NetworkWordCount localhost 9999
```
*Then, any lines typed in the terminal running the netcat server will be counted and printed on screen every second. It will look something like the following.*

	# TERMINAL 1:
	# Running Netcat

	$ nc -lk 9999

	hello world



	...

	# TERMINAL 2: RUNNING NetworkWordCount

	$ ./bin/run-example streaming.NetworkWordCount localhost 9999
	...
	-------------------------------------------
	Time: 1357008430000 ms
	-------------------------------------------
	(hello,1)
	(world,1)
	...

## 3、Basic Concepts

### 3.1、Linking

*Similar to Spark, Spark Streaming is available through Maven Central. To write your own Spark Streaming program, you will have to add the following dependency to your SBT or Maven project.*

需要先添加依赖。

```xml
<dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-streaming_2.12</artifactId>
    <version>3.0.0</version>
    <scope>provided</scope>
</dependency>
```

```sbt
libraryDependencies += "org.apache.spark" % "spark-streaming_2.12" % "3.0.0" % "provided"
```

*For ingesting data from sources like Kafka and Kinesis that are not present in the Spark Streaming core API, you will have to add the corresponding artifact spark-streaming-xyz_2.12 to the dependencies. For example, some of the common ones are as follows.*

还需要添加像Kafka and Kinesis的依赖。

Source | Artifact
---|:---
Kafka | spark-streaming-kafka-0-10_2.12
Kinesis | spark-streaming-kinesis-asl_2.12 [Amazon Software License]

*For an up-to-date list, please refer to the [Maven repository](https://search.maven.org/search?q=g:org.apache.spark%20AND%20v:3.0.0) for the full list of supported sources and artifacts.*

### 3.2、Initializing StreamingContext
### 3.3、Discretized Streams (DStreams)
### 3.4、Input DStreams and Receivers
### 3.5、Transformations on DStreams
### 3.6、Output Operations on DStreams
### 3.7、DataFrame and SQL Operations
### 3.8、MLlib Operations
### 3.9、Caching / Persistence
### 3.10、Checkpointing
### 3.11、Accumulators, Broadcast Variables, and Checkpoints
### 3.12、Deploying Applications
### 3.13、Monitoring Applications
## 4、Performance Tuning
### 4.1、Reducing the Batch Processing Times
### 4.2、Setting the Right Batch Interval
### 4.3、Memory Tuning
## 5、Fault-tolerance Semantics
## 6、Where to Go from Here