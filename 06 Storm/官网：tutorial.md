# tutorial

v2.1.0

本部分包括了如何创建 Storm 拓扑，并部署到 Storm 集群中。Java 是主要的开发语言，也有些例子使用了 Python，主要是为表明 Storm 能够使用多种开发语言开发。

## Preliminaries

本部分使用的例子来自 [storm-starter](https://github.com/apache/storm/tree/v2.1.0/examples/storm-starter).建议克隆下来练习。阅读 [Setting up a development environment](http://storm.apache.org/releases/2.1.0/Setting-up-development-environment.html) 和 [Creating a new Storm project](http://storm.apache.org/releases/2.1.0/Creating-a-new-Storm-project.html) 准备开始。

## Components of a Storm cluster

表面看，Storm 集群和 Hadoop 集群有点像。运行在 Hadoop 的程序叫 "MapReduce jobs"，运行在 Storm 的程序叫 "topologies"，**这二者是非常不同的，最大不同之处就是 "MapReduce jobs" 最终会执行完，而 "topologies" 除非认为终止，否则会一致运行。**

Storm 集群有主节点和工作节点两类节点。**主节点运行的进程叫做 "Nimbus"，负责分发代码、分配任务、监控错误。**

每个工作节点运行的进程叫做 "Supervisor". **"Supervisor" 负责监听、接受分配的任务，基于 Nimbus 分配的任务，按需启动或停止工作进程。** 每个工作节点执行拓扑的一个子集。一个运行的拓扑由散布在多台机器上的工作进程组成。

![storm08](https://s1.ax1x.com/2020/06/29/NfXSSO.png)

**Nimbus 和 Supervisors 间的协调工作都通过 Zookeeper 集群完成**。另外，Nimbus 进程和 Supervisors进程都是 **fail-fast[任何异常情况发生时，进程自毁] 和 stateless[所有的状态保存在Zookeeper或本地硬盘上]**。所有的状态保存在Zookeeper或本地硬盘上，这意味着可以通过kill -9 杀死 Nimbus 和 Supervisors 进程。它们会自动恢复，就像没被杀死过一样。这个设计保证了Storm集群难以置信的稳定性。

## Topologies

Storm 需要创建 "topologies" 来执行实时计算。**一个 "topologies" 是一个计算图。拓扑(图)的每个节点都包含了处理逻辑，节点间的边表示数据在节点间传递的方式。**

运行一个拓扑，首先打包你的程序和依赖到Jar包，然后运行如下命令：
```
storm jar all-my-code.jar org.apache.storm.MyTopology arg1 arg2
```

运行了 org.apache.storm.MyTopology 类，参数为arg1、arg2。这个类的功能就是定义拓扑、提交给 Nimbus。storm jar 的部分负责链接 Nimbus，上传 jar 包。

因为拓扑是 Thrift 结构，Nimbus 是一个 Thrift 服务，所以你可以使用任何编程语言创建、提交拓扑。上面的例子是基于JVM语言的，更多信息请阅 [Running topologies on a production cluster](http://storm.apache.org/releases/2.1.0/Running-topologies-on-a-production-cluster.html)

## Streams

Storm 中核心的抽象概念就是 "stream"。 **一个流是一个无边界的元组[tuples]序列**。Storm 提供了一种分布式、可靠的方式来将一个流转换成另一个新的流。例如，你可以将 tweets 流转换成热门话题流。

Storm 使用 "spouts" 和 "bolts" 实现转换。你可以实现 spouts 和 bolts 接口，来编写你的应用程序。

**一个 spout 是一个流的源头**。例如，一个 spout 从 Kestrel 队列读取元组，以流的形式提交它们。或者一个 spout 可以链接到Twitter API，再提交 tweets 流。

**一个 bolt 使用输入流中的数据，做一些处理，可能还以新的流的形式提交它们**。一个复杂的流转换操作会涉及多个步骤，所以就会有多个 bolt，例如，从 tweets 流计算成热门话题流。bolt 可以做任何事情，如 **运行函数、过滤元组、流聚合、流合并、和数据库交互等。**

spouts 和 bolts 间的网络也被打包进拓扑，这是你提交到 Storm 集群执行的最高级别的抽象。**拓扑是一个流转换的图，图的每个节点可能是 spout，或者是 bolt。图的边表明 bolt 接收哪个流。** 当一个 spout 或 bolt 向一个流提交一个元组时，它就发送这个元组到每个订阅了这个流的bolt。

![storm09](https://s1.ax1x.com/2020/06/29/NfXCOH.png)

拓扑中，节点间的边表明了元组应该如何传递。例如，如果 Spout A 和 Bolt B 间有一个边， Spout A 和 Bolt C 间有一个边， Spout B 和 Bolt C 间有一个边，那么每当 Spout A 提交一个元组，它就会发送到 Bolt B 和 Bolt C。所有 Bolt B 的输出元组将流入Bolt C。

Storm 拓扑中的每个节点都是并行运行。在拓扑中，你 **可以指定各节点的并行度，Storm 会按照并行度在集群中启动相当的线程。**

拓扑会一直执行下去，除非人为停止。Storm 会自动重新分配失败的任务，此外，在机器宕机和消息丢失[messages are dropped]的情况下，Storm 也能保证数据不会丢失。

## Data model

**Storm 的数据模型是元组。一个元组是一个值列表，元组中的域[field]可以是任意类型的对象。Storm 支持所有基本类型、字符串和字节数组，作为元组域值。你可以通过实现serializer接口，使用其他数据类型。**

拓扑中的每个节点必须为提交的元组的事先声明输出域。例如，这个 bolt 声明了两个带有 "double" 和 "triple" 域的元组。
```java
public class DoubleAndTripleBolt extends BaseRichBolt {
    private OutputCollectorBase _collector;

    @Override
    public void prepare(Map conf, TopologyContext context, OutputCollectorBase collector) {
        _collector = collector;
    }

    @Override
    public void execute(Tuple input) {
        int val = input.getInteger(0);        
        _collector.emit(input, new Values(val*2, val*3));
        _collector.ack(input);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("double", "triple"));
    }    
}
```

declareOutputFields 函数声明了输出域 ["double", "triple"]。

## A simple topology

ExclamationTopology 的定义:
```java
TopologyBuilder builder = new TopologyBuilder();        
builder.setSpout("words", new TestWordSpout(), 10);        
builder.setBolt("exclaim1", new ExclamationBolt(), 3)
        .shuffleGrouping("words");
builder.setBolt("exclaim2", new ExclamationBolt(), 2)
        .shuffleGrouping("exclaim1");
```
这个拓扑包含了一个 spout 和两个 bolt。spout 提交 words，每个 bolt 在输入后追加字符串 "!!!"。 spout 提交到第一个 bolt，再提交到第二个 bolt。如果 spout 提交的元组是 ["bob"] 和 ["john"]，那么第二个 bolt 将会提交 ["bob!!!!!!"] 和 ["john!!!!!!"]。

代码中使用了 setSpout 和 setBolt 方法定义了节点。这些方法的第一个参数为用户指定的id、第二个参数为包含了执行逻辑的对象，第三个参数为并行度。此例中，spout 设置的id 为 "words"，bolts 设置的id 为 "exclaim1" and "exclaim2"。

包含处理逻辑的 spouts 对象实现了 [IRichSpout](http://storm.apache.org/releases/2.1.0/javadocs/org/apache/storm/topology/IRichSpout.html) 接口， bolts 对象实现了 [IRichBolt](http://storm.apache.org/releases/2.1.0/javadocs/org/apache/storm/topology/IRichBolt.html) 接口。并行度参数是可选。它表示集群中有多少执行线程，参数默认是1个线程。

setBolt 方法返回一个 [InputDeclarer](http://storm.apache.org/releases/2.1.0/javadocs/org/apache/storm/topology/InputDeclarer.html) 对象，此对象定义了 Bolt 的输入。组件 "exclaim1" 声明了，它要读取组件 "words" 通过 shuffle grouping 提交的元组。组件 "exclaim2" 声明了，它要读取组件 "exclaim1" 通过 shuffle grouping 提交的元组。shuffle grouping表示元组将有输入任务随机分发到 bolt 的任务。在组件间有多种数据分组的方法。

如果你想组件 "exclaim2" 读取由 "words" 和 "exclaim1" 提交的元组，那么你应该这么写：
```java
builder.setBolt("exclaim2", new ExclamationBolt(), 5)
            .shuffleGrouping("words")
            .shuffleGrouping("exclaim1");
```
所以，一个 bolt 可以有多个输入源。

下面看下 spouts 和 bolts 的实现。Spouts 的作用就是提交新的消息到拓扑。TestWordSpout 就是从 ["nathan", "mike", "jackson", "golda", "bertels"] 列表中随机选一个单词作为一个元组提交，时间间隔为100ms. TestWordSpout 中 nextTuple() 的实现如下所示：
```java
public void nextTuple() {
    Utils.sleep(100);
    final String[] words = new String[] {"nathan", "mike", "jackson", "golda", "bertels"};
    final Random rand = new Random();
    final String word = words[rand.nextInt(words.length)];
    _collector.emit(new Values(word));
}
```
ExclamationBolt 在它的输入后追加了字符串 "!!!"。实现如下：
```java
public static class ExclamationBolt implements IRichBolt {
    OutputCollector _collector;

    @Override
    public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
        _collector = collector;
    }

    @Override
    public void execute(Tuple tuple) {
        _collector.emit(tuple, new Values(tuple.getString(0) + "!!!"));
        _collector.ack(tuple);
    }

    @Override
    public void cleanup() {
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }

    @Override
    public Map<String, Object> getComponentConfiguration() {
        return null;
    }
}
```
prepare 方法定义了一个用来从这个 bolt 提交元组的 OutputCollector。元组可以从这个 bolt 在任何时间提交，包括在prepare, execute, or cleanup methods, even asynchronously in another thread。prepare方法保存 OutputCollector 为实例变量，它会在execute方法会用到。

execute 方法从 bolt 输入中接收一个元组。ExclamationBolt 从元组中获取第一个 field，然后追加 "!!!" 后提交一个新元组。如果 bolt 有多个输入源，你可以 Tuple#getSourceComponent 方法使用查看到元组来自哪个组件。

输入元组作为第一个参数提交，并在最后一行响应输入元组，这就是 Storm 可靠性API的一部分，以保证没有数据丢失。后面会讲。

cleanup 方法是在一个 bolt 停止后调用，用来清理资源。这个方法不一定会被调用。例如，当执行任务的机器宕机，则不会调用这个方法[if the machine the task is running on blows up, there's no way to invoke the method.]。cleanup 适用于 [local模式](http://storm.apache.org/releases/2.1.0/Local-mode.html)，也适用于你想在不泄露资源的情况下，运行、杀死许多拓扑的情况。

declareOutputFields 方法声明了 ExclamationBolt 提交带有一个 "word" 域的1-tuples。

getComponentConfiguration 方法可以配置组件运行的方法。[Configuration](http://storm.apache.org/releases/2.1.0/Configuration.html) 中会讲。

在 bolt 中，cleanup 和 getComponentConfiguration 不是必须的。你可以通过继承基类更简洁地定义 bolt，基类提供了一些默认的方法。ExclamationBolt 也可以这么写：
```java
public static class ExclamationBolt extends BaseRichBolt {
    OutputCollector _collector;

    @Override
    public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
        _collector = collector;
    }

    @Override
    public void execute(Tuple tuple) {
        _collector.emit(tuple, new Values(tuple.getString(0) + "!!!"));
        _collector.ack(tuple);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }    
}
```

## Running ExclamationTopology in local mode

Storm 有两种操作模式：本地模式和分布式模式。本地模式中，Storm 通过使用线程模拟工作节点来执行。本地模式可以用来测试和开发。可以深入阅读 [Local mode](http://storm.apache.org/releases/2.1.0/Local-mode.html)

在本地模式下，要使用 storm local 命令，而不是 storm jar.

## Stream groupings

stream grouping 的作用就是 **告诉拓扑，在两个组件间如何发送元组**。spouts 和 bolts总是并行在集群中执行任务，拓扑的执行流程如下图所示：

![storm11](https://s1.ax1x.com/2020/06/29/NfXGt0.png)

当 Bolt A 的一个任务向 Bolt B 发送元组时，应该发到 Bolt B 的哪个任务呢？

**stream groupings 就是用来告诉 Storm 如何在任务间发送元组**。在深入了解不同类的stream groupings之前，先看看 [storm-starter](https://github.com/apache/storm/tree/v2.1.0/examples/storm-starter) 中的另一个拓扑。[WordCountTopology]https://github.com/apache/storm/blob/v2.1.0/examples/storm-starter/src/jvm/org/apache/storm/starter/WordCountTopology.java) 从 spout 中读取句子，WordCountBolt 统计单词出现的次数。
```java
TopologyBuilder builder = new TopologyBuilder();

builder.setSpout("sentences", new RandomSentenceSpout(), 5);        
builder.setBolt("split", new SplitSentence(), 8)
        .shuffleGrouping("sentences");
builder.setBolt("count", new WordCount(), 12)
        .fieldsGrouping("split", new Fields("word"));
```
SplitSentence emits a tuple for each word in each sentence it receives, and WordCount keeps a map in memory from word to count. Each time WordCount receives a word, it updates its state and emits the new word count.

SplitSentence 将句子里的每个单词封装成一个元组，进行提交，WordCount 在内存中保存了一个 word 到 count 的映射。每当 WordCount 接收一个单词，就会更新状态，提交新的单词统计结果。

下面介绍 stream groupings：

最简单的分组是 "shuffle grouping"，它 **随机向任务发送元组**。此例中 WordCountTopology 从 RandomSentenceSpout 发送元组到 SplitSentence bolt 就是用的shuffle grouping。它可以将元组的处理工作均匀地分布到 SplitSentence bolt 的所有任务中。

另一个有趣的分组就是 "fields grouping"。此例中 WordCountTopology 从 SplitSentence bolt 发送元组到 WordCount bolt 就是用的 fields grouping。对于 WordCount bolt 来说，相同的单词总会进入相同的任务是非常重要的。否则，多个任务将看到相同的单词，并且它们各自会发出不正确的值，所以每个任务都有不完整的信息。**fields grouping 能够根据它的域分组一个数据流。这就可以实现相同值的域子集进入相同的任务。** 由于 WordCount 在 "word" 域上使用了 fields grouping 分组 SplitSentence 的输出流，相同的单词总会进入相同的任务，bolt 产生正确的结果。

Fields groupings是实现 streaming joins 和 streaming aggregations 的基础，**底层实现利用了mod hashing**。其他的分组方式见 [Concepts](http://storm.apache.org/releases/2.1.0/Concepts.html)。

## Defining Bolts in other languages

Bolts 可以使用任意语言开发，用 JVM-based 以外的语言开发的 Bolts 以子进程的方式运行，Storm 以 stdin/stdout 之上的 JSON 格式消息与子进程通信。通信协议用到了一个100行左右的适配器库，支持Ruby, Python, Fancy。

下面是 WordCountTopology 定义的 SplitSentence bolt：

```java
public static class SplitSentence extends ShellBolt implements IRichBolt {
    public SplitSentence() {
        super("python", "splitsentence.py");
    }

    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }
}
```

SplitSentence 重写了 ShellBolt 的方法，声明使用 python 语言，参数是 splitsentence.py。splitsentence.py实现如下：

```java
import storm

class SplitSentenceBolt(storm.BasicBolt):
    def process(self, tup):
        words = tup.values[0].split(" ")
        for word in words:
          storm.emit([word])

SplitSentenceBolt().run()
```
其他语言开发拓扑，见 [Using non-JVM languages with Storm](http://storm.apache.org/releases/2.1.0/Using-non-JVM-languages-with-Storm.html)

## Guaranteeing message processing

见 [Guaranteeing Message Processing](http://storm.apache.org/releases/2.1.0/Guaranteeing-message-processing.html)

## Transactional topologies

见 [Trident Tutorial](http://storm.apache.org/releases/2.1.0/Trident-tutorial.html)

## Distributed RPC

见 [Distributed RPC](http://storm.apache.org/releases/2.1.0/Distributed-RPC.html)
