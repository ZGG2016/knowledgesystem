# flume+kafka 整合--exec

1、配置kafka.properties

	agent.sources = s1                                                                                                                  
	agent.channels = c1                                                                                                                 
	agent.sinks = k1                                                                                                                    

	agent.sources.s1.type=exec                                                                                                          
	agent.sources.s1.command=tail -F /usr/local/kafka.log                                                                                
	agent.sources.s1.channels=c1                                                                                                        
	agent.channels.c1.type=memory                                                                                                       
	agent.channels.c1.capacity=10000                                                                                                    
	agent.channels.c1.transactionCapacity=100                                                                                           

	#设置Kafka接收器                                                                                                                    
	agent.sinks.k1.type= org.apache.flume.sink.kafka.KafkaSink                                                                          
	#设置Kafka的broker地址和端口号                                                                                                      
	agent.sinks.k1.brokerList=master:9092,slaver1:9092,slaver2:9092                                                                                               
	#设置Kafka的Topic                                                                                                                   
	agent.sinks.k1.topic=kafkatest                                                                                                      
	#设置序列化方式                                                                                                                     
	agent.sinks.k1.serializer.class=kafka.serializer.StringEncoder                                                                      

	agent.sinks.k1.channel=c1

2、建立空文件kafka.log
3、新建脚本kafkaoutput.sh(一定要给予可执行权限)

	chmod u+x kafkaoutput.sh

输入内容：

	for((i=0;i<=1000;i++));
	do echo "kafka_test-"+$i>>/tmp/logs/kafka.log;
	done

4、kafka安装目录下启动zk,kafka

5、建立Topic kafkatest

	bin/kafka-topics.sh --create --zookeeper master:2181 --replication-factor 1 --partitions 1 --topic kafkatest

6、打开新终端，在kafka安装目录下执行如下命令，生成对topic kafkatest 的消费

	bin/kafka-console-consumer.sh --zookeeper master:2181 --topic mytopic --from-beginning

7、启动flume

	bin/flume-ng agent --conf-file  conf/kafka.properties -c conf/ --name agent -Dflume.root.logger=DEBUG,console

8、执行kafkaoutput.sh脚本，观察kafka.log内容及消费终端接收到的内容
