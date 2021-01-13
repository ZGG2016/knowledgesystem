# flume+kafka 整合---spooldir

1、配置kafka.properties

	agent.sources = s1                                                                                                                  
	agent.channels = c1                                                                                                                 
	agent.sinks = k1                                                                                                                    

	agent.sources.s1.type=spooldir                                                                                                          
	agent.sources.s1.spoolDir=/usr/local/test                                                                                
	agent.sources.s1.channels=c1                                                                                                        
	agent.channels.c1.type=memory                                                                                                       
	agent.channels.c1.capacity=10000                                                                                                    
	agent.channels.c1.transactionCapacity=100                                                                                           

	#设置Kafka接收器                                                                                                                    
	agent.sinks.k1.type= org.apache.flume.sink.kafka.KafkaSink                                                                          
	#设置Kafka的broker地址和端口号                                                                                                      
	agent.sinks.k1.brokerList=master:9092,slaver1:9092,slaver2:9092                                                                                               
	#设置Kafka的Topic                                                                                                                   
	agent.sinks.k1.topic=tvprogram                                                                                                      
	#设置序列化方式                                                                                                                     
	agent.sinks.k1.serializer.class=kafka.serializer.StringEncoder                                                                      

	agent.sinks.k1.channel=c1

2、在/usr/local目录下新建目录test

3、kafka安装目录下启动zk,kafka

4、建立Topic kafkatest

	bin/kafka-topics.sh --create --zookeeper master:2181 --replication-factor 1 --partitions 1 --topic kafkatest

5、打开新终端，在kafka安装目录下执行如下命令，生成对topic kafkatest 的消费

	bin/kafka-console-consumer.sh --zookeeper master:2181 --topic mytopic --from-beginning

6、启动flume

	bin/flume-ng agent --conf-file  conf/kafka.properties -c conf/ --name agent -Dflume.root.logger=DEBUG,console

7、新开一个终端，在test目录下追加文件

	echo "1" > /usr/local/test/1.txt
	echo "2" > /usr/local/test/2.txt
	echo "3" > /usr/local/test/3.txt
	....

8、在kafka消费端会一直有数字输出。
