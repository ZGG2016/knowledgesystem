welcome

```python
import os

print("start zookeeper...")

for i in range([1,2,3]):
	start_zk = "ssh node%d && bin/zkServer.sh start" % i
	os.system(start_zk)

print("start journalnode...")

for i in range([1,2,3]):
	start_jn = "ssh node%d && /opt/hadoop-3.2.1/bin/hdfs --daemon start journalnode" % i
	os.system(start_jn)

print("start zkfc...")

for i in range([1,2,3]):
	start_zkfc = "ssh node%d && /opt/hadoop-3.2.1/bin/hdfs --daemon start zkfc" % i
	os.system(start_zkfc)

print("start nm、dn、rm、nm...")

for i in range([1,2,3]):
	start_all = "ssh node%d && /opt/hadoop-3.2.1/sbin/start-all.sh" % i
	os.system(start_all)

print("Done!!!")
```