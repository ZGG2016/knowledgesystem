# KafkaOffsetMonitor

1、下载

	KafkaOffsetMonitor-assembly-0.2.0.jar

2、写启动、暂停脚本

新建目录

	mkdir kafka-offset-console

写脚本

	vi start.sh

	#!/bin/bash
	java -Xms512M -Xmx512M -Xss1024K -XX:PermSize=256m -XX:MaxPermSize=512m -cp KafkaOffsetMonitor-assembly-0.2.0.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb --zk namenode1:2181,datanode1:2181,datanode2:2181,datanode3:2181 --port 8086 --refresh 10.seconds --retain 7.days 1>/data/kafka-offset-console/kafkamonitorlogs/stdout.log 2>/data/kafka-offset-console/kafkamonitorlogs/stderr.log &

	vi stop.sh

	#!/bin/bash
	killnum=`jps | grep OffsetGetterWeb | awk '{print $1}'`
	kill -9 ${killnum}
	echo "OK...."

3、启动
	
	 chmod +x start.sh
	 ./start.sh

![](https://i.imgur.com/VYCp9P3.png)

![](https://i.imgur.com/1nA5yPW.png)