# python连接hive

linux环境下

### 1、在 `hive-site.xml` 配置 HiveServer2

参考官网说明和`hive-site.xml`

### 2、 启动 HiveServer2

```sh
[root@zgg hive-3.1.2]# nohup hive --service metastore & 
[2] 15056

[root@zgg hive-3.1.2]# hive --service hiveserver2
...
Hive Session ID = 62f203cb-bed9-4e38-8a2e-1548f3ef0572
Hive Session ID = adc21919-4eb6-4119-bce1-40580b000e83

[root@zgg hive-3.1.2]# beeline
Beeline version 2.3.7 by Apache Hive

------------------------------------------------

# hive.server2.transport.mode = binary

# 复制到命令行下，就连接失败
------------------------------------------------

beeline> !connect jdbc:hive2://zgg:10000/default;auth=noSasl
Connecting to jdbc:hive2://zgg:10000/default;auth=noSasl

------------------------------------------------

# 注意：在hive-site.xml设置的用户名和密码

------------------------------------------------

Enter username for jdbc:hive2://zgg:10000/default: root
Enter password for jdbc:hive2://zgg:10000/default: ****
2020-12-14 23:50:57,775 INFO jdbc.Utils: Supplied authorities: zgg:10000
2020-12-14 23:50:57,775 INFO jdbc.Utils: Resolved authority: zgg:10000
Connected to: Apache Hive (version 3.1.2)
Driver: Hive JDBC (version 2.3.7)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://zgg:10000/default> select * from employees;
INFO  : Compiling command(queryId=root_20201215000117_88c125d0-cb07-47a5-8980-ed8e39f0c4a5): select * from employees
INFO  : Concurrency mode is disabled, not creating a lock manager
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:employees.emp_no, type:int, comment:null), FieldSchema(name:employees.first_name, type:string, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=root_20201215000117_88c125d0-cb07-47a5-8980-ed8e39f0c4a5); Time taken: 0.2 seconds
INFO  : Concurrency mode is disabled, not creating a lock manager
INFO  : Executing command(queryId=root_20201215000117_88c125d0-cb07-47a5-8980-ed8e39f0c4a5): select * from employees
INFO  : Completed executing command(queryId=root_20201215000117_88c125d0-cb07-47a5-8980-ed8e39f0c4a5); Time taken: 0.003 seconds
INFO  : OK
INFO  : Concurrency mode is disabled, not creating a lock manager
+-------------------+-----------------------+
| employees.emp_no  | employees.first_name  |
+-------------------+-----------------------+
| 10001             | Georgi                |
| 10002             | Bezalel               |
| 10005             | Kyoichi               |
| 10006             | Anneke                |
| 10009             | Georgi                |
+-------------------+-----------------------+
5 rows selected (0.312 seconds)
```

#### 2.1、方式一

(1) 安装pyhive

先安装所需依赖包：

	pip install thrift thrift_sasl sasl

再安装pyhive

	pip install pyhive

(1) 测试

```python
from pyhive import hive

conn = hive.Connection(host='zgg', 
	                     port=10000, 
	                     auth='NOSASL')

cur = conn.cursor()
cur.execute("select * from employees")

for row in cur.fetchall():
    print row
```

执行成功：

```sh
[root@zgg python_script]# python pyhive_test.py
(10001, u'Georgi')
(10002, u'Bezalel')
(10005, u'Kyoichi')
(10006, u'Anneke')
(10009, u'Georgi')
```

其他用法：[https://github.com/dropbox/PyHive](https://github.com/dropbox/PyHive)

#### 2.2、方式二

安装pyhs2

	pip install pyhs2


```python
import pyhs2

with pyhs2.connect(host='zgg',
                   port=10000,
                   authMechanism="NOSASL",
                   user='root',
                   password='root',
                   database='default') as conn:
    with conn.cursor() as cur:
        # Show databases
        print cur.getDatabases()

        # Execute query
        cur.execute("select * from employees")

        # Return column info from query
        print cur.getSchema()

        # Fetch table results
        for i in cur.fetch():
            print i
```

执行成功：

```sh
[root@zgg python_script]# python pyhs2_test.py 
[['default', '']]
[{'comment': None, 'columnName': 'employees.emp_no', 'type': 'INT_TYPE'}, {'comment': None, 'columnName': 'employees.first_name', 'type': 'STRING_TYPE'}]
[10001, 'Georgi']
[10002, 'Bezalel']
[10005, 'Kyoichi']
[10006, 'Anneke']
[10009, 'Georgi']
```

[https://github.com/BradRuderman/pyhs2](https://github.com/BradRuderman/pyhs2)

---------------------------------------------------------------------------

```sh
----------------------------------------------------------

# hive.server2.transport.mode = http

----------------------------------------------------------

beeline> !connect jdbc:hive2://zgg:10001/default;transportMode=http;httpPath=cliservice
Connecting to jdbc:hive2://zgg:10001/default;transportMode=http;httpPath=cliservice
Enter username for jdbc:hive2://zgg:10001/default: root
Enter password for jdbc:hive2://zgg:10001/default: ****   【hive】
2020-12-14 23:14:30,056 INFO jdbc.Utils: Supplied authorities: zgg:10001
2020-12-14 23:14:30,057 INFO jdbc.Utils: Resolved authority: zgg:10001
Connected to: Apache Hive (version 3.1.2)
Driver: Hive JDBC (version 2.3.7)
Transaction isolation: TRANSACTION_REPEATABLE_READ

0: jdbc:hive2://zgg:10001/default> 
```

http模式下两类库均未执行成功：

出现问题 `thrift.transport.TTransport.TTransportException: TSocket read 0 bytes`


