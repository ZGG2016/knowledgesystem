# python连接hive

linux环境下

1、下载包：

	pip install sasl

	pip install thrift

	pip install thrift-sasl

	pip install pyhive[hive]

2、启动 `HiveServer2 `

3、

先修改 `hive.server2.authentication` 为 NOSASL ，然后在 `hive.connection()`的传入参数中也加入`auth='NOSASL'`,

```python
from pyhive import hive

conn = hive.Connection(host='zgg', port=10000, username='hive',auth='NOSASL', database='default')
cursor = conn.cursor()
cursor.execute('desc emp')
for result in cursor.fetchall():
    print(result)

conn.close()

```


[https://github.com/dropbox/PyHive](https://github.com/dropbox/PyHive)