# 官网：Spark SQL Guide03--Distributed SQL Engine

[TOC]

*Spark SQL can also act as a distributed query engine using its JDBC/ODBC or command-line interface. In this mode, end-users or applications can interact with Spark SQL directly to run SQL queries, without the need to write any code.*

Spark SQL 可以使用其 JDBC/ODBC 或命令行界面的作为分布式查询引擎。在这种模式下，终端用户或应用程序可以直接与 Spark SQL 交互运行 SQL 查询，而不需要编写任何代码。

## 1、Running the Thrift JDBC/ODBC server

*The Thrift JDBC/ODBC server implemented here corresponds to the HiveServer2 in built-in Hive. You can test the JDBC server with the beeline script that comes with either Spark or compatible Hive.*

*To start the JDBC/ODBC server, run the following in the Spark directory:*

这里的 Thrift JDBC/ODBC 服务器对应于 Hive 中的 HiveServer2。您可以使用 Spark 或兼容的 Hive 附带的 beeline 脚本测试 JDBC server 。

要启动 JDBC/ODBC 服务器，请在 Spark 目录中运行以下命令:

```sh
./sbin/start-thriftserver.sh
```
*This script accepts all bin/spark-submit command line options, plus a --hiveconf option to specify Hive properties. You may run ./sbin/start-thriftserver.sh --help for a complete list of all available options. By default, the server listens on localhost:10000. You may override this behaviour via either environment variables, i.e.:*

此脚本接受所有 bin/spark-submit 命令行选项，以及 --hiveconf 选项来指定 Hive 属性。

默认情况下，服务器监听 localhost:10000 。您可以通过环境变量覆盖此行为，即:

```sh
export HIVE_SERVER2_THRIFT_PORT=<listening-port>
export HIVE_SERVER2_THRIFT_BIND_HOST=<listening-host>
./sbin/start-thriftserver.sh \
  --master <master-uri> \
  ...
```
or system properties:

```sh
./sbin/start-thriftserver.sh \
  --hiveconf hive.server2.thrift.port=<listening-port> \
  --hiveconf hive.server2.thrift.bind.host=<listening-host> \
  --master <master-uri>
  ...
```
*Now you can use beeline to test the Thrift JDBC/ODBC server:*

```sh
./bin/beeline
```

*Connect to the JDBC/ODBC server in beeline with:*

```sh
beeline> !connect jdbc:hive2://localhost:10000
```

*Beeline will ask you for a username and password. In non-secure mode, simply enter the username on your machine and a blank password. For secure mode, please follow the instructions given in the beeline documentation.*

需要输入用户名和密码。非安全模式下，输入机器名称和空的密码。安全模式下，按要求输入。

*Configuration of Hive is done by placing your hive-site.xml, core-site.xml and hdfs-site.xml files in conf/.*

将 hive-site.xml, core-site.xml and hdfs-site.xml 复制到 conf/ 目录下，完成 Hive 的配置。

*You may also use the beeline script that comes with Hive.*

*Thrift JDBC server also supports sending thrift RPC messages over HTTP transport. Use the following setting to enable HTTP mode as system property or in hive-site.xml file in conf/:*

Thrift JDBC server 支持通过 HTTP 发生 thrift RPC 消息。

	hive.server2.transport.mode - Set this to value: http
	hive.server2.thrift.http.port - HTTP port number to listen on; default is 10001
	hive.server2.http.endpoint - HTTP endpoint; default is cliservice

*To test, use beeline to connect to the JDBC/ODBC server in http mode with:*

```sh
beeline> !connect jdbc:hive2://<host>:<port>/<database>?hive.server2.transport.mode=http;hive.server2.thrift.http.path=<http_endpoint>
```
*If you closed a session and do CTAS, you must set fs.%s.impl.disable.cache to true in hive-site.xml. See more details in [SPARK-21067].*

在 hive-site.xml 中，设置 `set fs.%s.impl.disable.cache = true`，关闭 session and do CTAS。

更多细节见[SPARK-21067](https://issues.apache.org/jira/browse/SPARK-21067)


## 2、Running the Spark SQL CLI

*The Spark SQL CLI is a convenient tool to run the Hive metastore service in local mode and execute queries input from the command line. Note that the Spark SQL CLI cannot talk to the Thrift JDBC server.*

Spark SQL CLI 可以在本地模式下运行 Hive metastore service，执行命令行输入的查询。但不会和 Thrift JDBC server 通信。

*To start the Spark SQL CLI, run the following in the Spark directory:*
```sh
./bin/spark-sql
```

*Configuration of Hive is done by placing your hive-site.xml, core-site.xml and hdfs-site.xml files in conf/. You may run ./bin/spark-sql --help for a complete list of all available options.*

可以运行 `./bin/spark-sql --help` 查看完成的参数列表。

```sh
spark-sql> show tables;
20/10/28 23:00:35 INFO metastore.HiveMetaStore: 0: get_database: global_temp
20/10/28 23:00:35 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_database: global_temp
20/10/28 23:00:35 WARN metastore.ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
20/10/28 23:00:35 INFO metastore.HiveMetaStore: 0: get_database: default
20/10/28 23:00:35 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_database: default
20/10/28 23:00:35 INFO metastore.HiveMetaStore: 0: get_database: default
20/10/28 23:00:35 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_database: default
20/10/28 23:00:35 INFO metastore.HiveMetaStore: 0: get_tables: db=default pat=*
20/10/28 23:00:35 INFO HiveMetaStore.audit: ugi=root    ip=unknown-ip-addr      cmd=get_tables: db=default pat=*
20/10/28 23:00:35 INFO codegen.CodeGenerator: Code generated in 182.247876 ms
default src     false
default srcc    false
default test    false
Time taken: 1.916 seconds, Fetched 3 row(s)
20/10/28 23:00:35 INFO thriftserver.SparkSQLCLIDriver: Time taken: 1.916 seconds, Fetched 3 row(s)
```