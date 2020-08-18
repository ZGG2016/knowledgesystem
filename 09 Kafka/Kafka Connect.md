# 使用 Kafka Connect 来 导入/导出 数据

1、创建一些种子数据用来测试：

	echo -e "foo\nbar" > test.txt

2、修改connect-standalone.properties

	把localhost改成namenode1(自己的主机名)

然后	

	bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties

这是示例的配置文件，使用默认的本地集群配置并创建了2个连接器：第一个是导入连接器，从导入文件中读取并发布到Kafka主题，第二个是导出连接器，从kafka主题读取消息输出到外部文件，在启动过程中，你会看到一些日志消息，包括一些连接器实例化的说明。一旦kafka Connect进程已经开始，导入连接器应该读取从

	test.txt

和写入到topic

	connect-test（会自动创建）

导出连接器从主题

	connect-test

读取消息写入到文件

	test.sink.txt（会自动创建）

我们可以通过验证输出文件的内容来验证数据数据已经全部导出：

	cat test.sink.txt
	 foo
	 bar

注意，导入的数据也已经在Kafka主题

	connect-test

所以我们可以使用该命令查看这个主题

	bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic connect-test --from-beginning
	 {"schema":{"type":"string","optional":false},"payload":"foo"}
	 {"schema":{"type":"string","optional":false},"payload":"bar"}


连接器继续处理数据，因此我们可以添加数据到文件并通过管道移动：

	echo "Another line" >> test.txt

你应该会看到出现在消费者控台输出一行信息并导出到文件。