# 官网：Spark SQL Guide03--Data Sources--Hive Tables

*Spark SQL also supports reading and writing data stored in Apache Hive. However, since Hive has a large number of dependencies, these dependencies are not included in the default Spark distribution. If Hive dependencies can be found on the classpath, Spark will load them automatically. Note that these Hive dependencies must also be present on all of the worker nodes, as they will need access to the Hive serialization and deserialization libraries (SerDes) in order to access data stored in Hive.*

读写 Hive 需要在 classpath 添加许多依赖，Spark 会自动载入。这些依赖也必须添加在所有的 worker 节点。

*Configuration of Hive is done by placing your hive-site.xml, core-site.xml (for security configuration), and hdfs-site.xml (for HDFS configuration) file in conf/.*

将 hive-site.xml, core-site.xml 和 hdfs-site.xml 放到 conf/. 目录下。

*When working with Hive, one must instantiate SparkSession with Hive support, including connectivity to a persistent Hive metastore, support for Hive serdes, and Hive user-defined functions. Users who do not have an existing Hive deployment can still enable Hive support. When not configured by the hive-site.xml, the context automatically creates metastore_db in the current directory and creates a directory configured by spark.sql.warehouse.dir, which defaults to the directory spark-warehouse in the current directory that the Spark application is started. Note that the hive.metastore.warehouse.dir property in hive-site.xml is deprecated since Spark 2.0.0. Instead, use spark.sql.warehouse.dir to specify the default location of database in warehouse. You may need to grant write privilege to the user who starts the Spark application.*

使用 Hive，需要先实例化一个 Hive 支持的 SparkSession，它连接到一个持久化 Hive 元数据库，支持 Hive serdes 和 用户自定义函数。

没有部署 Hive ，也能实现对 Hive 的支持。如果没有配置 hive-site.xml 文件，context 会在当前目录下自动创建一个 metastore_db，并根据配置的 `spark.sql.warehouse.dir` 创建一个目录，这个目录是 Spark 应用程序启动的当前目录下的 spark-warehouse 目录。

注意：`hive.metastore.warehouse.dir` 属性被 `spark.sql.warehouse.dir` 替代了。作用是指定仓库下数据库的默认位置。

还需要为启动 Spark 程序的用户授予写权限。


**A：对于python**

```python
from os.path import join, abspath

from pyspark.sql import SparkSession
from pyspark.sql import Row

# warehouse_location points to the default location for managed databases and tables
warehouse_location = abspath('spark-warehouse')

spark = SparkSession \
    .builder \
    .appName("Python Spark SQL Hive integration example") \
    .config("spark.sql.warehouse.dir", warehouse_location) \
    .enableHiveSupport() \
    .getOrCreate()

# spark is an existing SparkSession
spark.sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING) USING hive")
spark.sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src")

# Queries are expressed in HiveQL
spark.sql("SELECT * FROM src").show()
# +---+-------+
# |key|  value|
# +---+-------+
# |238|val_238|
# | 86| val_86|
# |311|val_311|
# ...

# Aggregation queries are also supported.
spark.sql("SELECT COUNT(*) FROM src").show()
# +--------+
# |count(1)|
# +--------+
# |    500 |
# +--------+

# The results of SQL queries are themselves DataFrames and support all normal functions.
sqlDF = spark.sql("SELECT key, value FROM src WHERE key < 10 ORDER BY key")

# The items in DataFrames are of type Row, which allows you to access each column by ordinal.
stringsDS = sqlDF.rdd.map(lambda row: "Key: %d, Value: %s" % (row.key, row.value))
for record in stringsDS.collect():
    print(record)
# Key: 0, Value: val_0
# Key: 0, Value: val_0
# Key: 0, Value: val_0
# ...

# You can also use DataFrames to create temporary views within a SparkSession.
Record = Row("key", "value")
recordsDF = spark.createDataFrame([Record(i, "val_" + str(i)) for i in range(1, 101)])
recordsDF.createOrReplaceTempView("records")

# Queries can then join DataFrame data with data stored in Hive.
spark.sql("SELECT * FROM records r JOIN src s ON r.key = s.key").show()
# +---+------+---+------+
# |key| value|key| value|
# +---+------+---+------+
# |  2| val_2|  2| val_2|
# |  4| val_4|  4| val_4|
# |  5| val_5|  5| val_5|
# ...
```
*Find full example code at "examples/src/main/python/sql/hive.py" in the Spark repo.*

**B：对于java**

```java
import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

public static class Record implements Serializable {
  private int key;
  private String value;

  public int getKey() {
    return key;
  }

  public void setKey(int key) {
    this.key = key;
  }

  public String getValue() {
    return value;
  }

  public void setValue(String value) {
    this.value = value;
  }
}

// warehouseLocation points to the default location for managed databases and tables
String warehouseLocation = new File("spark-warehouse").getAbsolutePath();
SparkSession spark = SparkSession
  .builder()
  .appName("Java Spark Hive Example")
  .config("spark.sql.warehouse.dir", warehouseLocation)
  .enableHiveSupport()
  .getOrCreate();

spark.sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING) USING hive");
spark.sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src");

// Queries are expressed in HiveQL
spark.sql("SELECT * FROM src").show();
// +---+-------+
// |key|  value|
// +---+-------+
// |238|val_238|
// | 86| val_86|
// |311|val_311|
// ...

// Aggregation queries are also supported.
spark.sql("SELECT COUNT(*) FROM src").show();
// +--------+
// |count(1)|
// +--------+
// |    500 |
// +--------+

// The results of SQL queries are themselves DataFrames and support all normal functions.
Dataset<Row> sqlDF = spark.sql("SELECT key, value FROM src WHERE key < 10 ORDER BY key");

// The items in DataFrames are of type Row, which lets you to access each column by ordinal.
Dataset<String> stringsDS = sqlDF.map(
    (MapFunction<Row, String>) row -> "Key: " + row.get(0) + ", Value: " + row.get(1),
    Encoders.STRING());
stringsDS.show();
// +--------------------+
// |               value|
// +--------------------+
// |Key: 0, Value: val_0|
// |Key: 0, Value: val_0|
// |Key: 0, Value: val_0|
// ...

// You can also use DataFrames to create temporary views within a SparkSession.
List<Record> records = new ArrayList<>();
for (int key = 1; key < 100; key++) {
  Record record = new Record();
  record.setKey(key);
  record.setValue("val_" + key);
  records.add(record);
}
Dataset<Row> recordsDF = spark.createDataFrame(records, Record.class);
recordsDF.createOrReplaceTempView("records");

// Queries can then join DataFrames data with data stored in Hive.
spark.sql("SELECT * FROM records r JOIN src s ON r.key = s.key").show();
// +---+------+---+------+
// |key| value|key| value|
// +---+------+---+------+
// |  2| val_2|  2| val_2|
// |  2| val_2|  2| val_2|
// |  4| val_4|  4| val_4|
// ...
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/hive/JavaSparkHiveExample.java" in the Spark repo.*

**C：对于scala**


```scala
import java.io.File

import org.apache.spark.sql.{Row, SaveMode, SparkSession}

case class Record(key: Int, value: String)

// warehouseLocation points to the default location for managed databases and tables
val warehouseLocation = new File("spark-warehouse").getAbsolutePath

val spark = SparkSession
  .builder()
  .appName("Spark Hive Example")
  .config("spark.sql.warehouse.dir", warehouseLocation)
  .enableHiveSupport()
  .getOrCreate()

import spark.implicits._
import spark.sql

sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING) USING hive")
sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src")

// Queries are expressed in HiveQL
sql("SELECT * FROM src").show()
// +---+-------+
// |key|  value|
// +---+-------+
// |238|val_238|
// | 86| val_86|
// |311|val_311|
// ...

// Aggregation queries are also supported.
sql("SELECT COUNT(*) FROM src").show()
// +--------+
// |count(1)|
// +--------+
// |    500 |
// +--------+

// The results of SQL queries are themselves DataFrames and support all normal functions.
val sqlDF = sql("SELECT key, value FROM src WHERE key < 10 ORDER BY key")

// The items in DataFrames are of type Row, which allows you to access each column by ordinal.
val stringsDS = sqlDF.map {
  case Row(key: Int, value: String) => s"Key: $key, Value: $value"
}
stringsDS.show()
// +--------------------+
// |               value|
// +--------------------+
// |Key: 0, Value: val_0|
// |Key: 0, Value: val_0|
// |Key: 0, Value: val_0|
// ...

// You can also use DataFrames to create temporary views within a SparkSession.
val recordsDF = spark.createDataFrame((1 to 100).map(i => Record(i, s"val_$i")))
recordsDF.createOrReplaceTempView("records")

// Queries can then join DataFrame data with data stored in Hive.
sql("SELECT * FROM records r JOIN src s ON r.key = s.key").show()
// +---+------+---+------+
// |key| value|key| value|
// +---+------+---+------+
// |  2| val_2|  2| val_2|
// |  4| val_4|  4| val_4|
// |  5| val_5|  5| val_5|
// ...

// Create a Hive managed Parquet table, with HQL syntax instead of the Spark SQL native syntax
// `USING hive`
sql("CREATE TABLE hive_records(key int, value string) STORED AS PARQUET")
// Save DataFrame to the Hive managed table
val df = spark.table("src")
df.write.mode(SaveMode.Overwrite).saveAsTable("hive_records")
// After insertion, the Hive managed table has data now
sql("SELECT * FROM hive_records").show()
// +---+-------+
// |key|  value|
// +---+-------+
// |238|val_238|
// | 86| val_86|
// |311|val_311|
// ...

// Prepare a Parquet data directory
val dataDir = "/tmp/parquet_data"
spark.range(10).write.parquet(dataDir)
// Create a Hive external Parquet table
sql(s"CREATE EXTERNAL TABLE hive_bigints(id bigint) STORED AS PARQUET LOCATION '$dataDir'")
// The Hive external table should already have data
sql("SELECT * FROM hive_bigints").show()
// +---+
// | id|
// +---+
// |  0|
// |  1|
// |  2|
// ... Order may vary, as spark processes the partitions in parallel.

// Turn on flag for Hive Dynamic Partitioning
spark.sqlContext.setConf("hive.exec.dynamic.partition", "true")
spark.sqlContext.setConf("hive.exec.dynamic.partition.mode", "nonstrict")
// Create a Hive partitioned table using DataFrame API
df.write.partitionBy("key").format("hive").saveAsTable("hive_part_tbl")
// Partitioned column `key` will be moved to the end of the schema.
sql("SELECT * FROM hive_part_tbl").show()
// +-------+---+
// |  value|key|
// +-------+---+
// |val_238|238|
// | val_86| 86|
// |val_311|311|
// ...

spark.stop()
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/hive/SparkHiveExample.scala" in the Spark repo.*

## 1、Specifying storage format for Hive tables  指定存储格式

*When you create a Hive table, you need to define how this table should read/write data from/to file system, i.e. the “input format” and “output format”. You also need to define how this table should deserialize the data to rows, or serialize rows to data, i.e. the “serde”. The following options can be used to specify the storage format(“serde”, “input format”, “output format”), e.g. CREATE TABLE src(id int) USING hive OPTIONS(fileFormat 'parquet'). By default, we will read the table files as plain text. Note that, Hive storage handler is not supported yet when creating table, you can create a table using storage handler at Hive side, and use Spark SQL to read it.*

当创建一个 Hive 表时，需要定义这个表如何从文件系统读取/写入，如“input format” and “output format”。也要定义这个表如何将数据反序列化 rows，将 rows 序列化成数据，如 “serde”。 下面列出的选项就是用来指定存储格式，如 `CREATE TABLE src(id int) USING hive OPTIONS(fileFormat 'parquet')`。默认是以纯文本形式读取表文件。


Property Name | Meaning
---|:---
fileFormat | A fileFormat is kind of a package of storage format specifications, including "serde", "input format" and "output format". Currently we support 6 fileFormats: 'sequencefile', 'rcfile', 'orc', 'parquet', 'textfile' and 'avro'. 一种指定的存储格式的包
inputFormat, outputFormat | These 2 options specify the name of a corresponding InputFormat and OutputFormat class as a string literal, e.g. org.apache.hadoop.hive.ql.io.orc.OrcInputFormat. These 2 options must be appeared in a pair, and you can not specify them if you already specified the fileFormat option. 指定了输入输出格式。必须成对出现。
serde | This option specifies the name of a serde class. When the fileFormat option is specified, do not specify this option if the given fileFormat already include the information of serde. Currently "sequencefile", "textfile" and "rcfile" don't include the serde information and you can use this option with these 3 fileFormats. 此选项指定serde类的名称。
fieldDelim, escapeDelim, collectionDelim, mapkeyDelim, lineDelim | These options can only be used with "textfile" fileFormat. They define how to read delimited files into rows.读取有界文件

All other properties defined with OPTIONS will be regarded as Hive serde properties. 

## 2、Interacting with Different Versions of Hive Metastore 和不同版本的 Metastore 交互

*One of the most important pieces of Spark SQL’s Hive support is interaction with Hive metastore, which enables Spark SQL to access metadata of Hive tables. Starting from Spark 1.4.0, a single binary build of Spark SQL can be used to query different versions of Hive metastores, using the configuration described below. Note that independent of the version of Hive that is being used to talk to the metastore, internally Spark SQL will compile against built-in Hive and use those classes for internal execution (serdes, UDFs, UDAFs, etc).*

Spark SQL 的 Hive 支持的最重要的部分之一是与 Hive metastore 进行交互，这使得 Spark SQL 能够访问 Hive 表的元数据。

*The following options can be used to configure the version of Hive that is used to retrieve metadata:*

Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.hive.metastore.version | 2.3.7 | Version of the Hive metastore. Available options are 0.12.0 through 2.3.7 and 3.0.0 through 3.1.2. 元数据库版本| 1.4.0
spark.sql.hive.metastore.jars | builtin | 用来实例化HiveMetastoreClient的JAR的位置。This property can be one of three options:(1)builtin:当启用-Phive时，使用Hive2.3.7，它与Spark程序集捆绑在一起。选择此选项时，spark.sql.hive.metastore.version 必须为 2.3.7 或未定义。(2)maven:通常不建议在生产部署中使用此配置。(3)该类路径必须包含所有Hive及其依赖项，包括正确版本的 Hadoop。这些罐只需要存在于 driver 程序中，但如果您正在运行在 yarn 集群模式，那么您必须确保它们与应用程序一起打包。 | 1.4.0
spark.sql.hive.metastore.sharedPrefixes | com.mysql.jdbc,org.postgresql,com.microsoft.sqlserver,oracle.jdbc |  | 使用逗号分隔的类前缀列表，应使用在 Spark SQL 和特定版本的 Hive 之间共享的类加载器来加载。一个共享类的示例就是用来访问 Hive metastore 的 JDBC driver。其它需要共享的类，是需要与已经共享的类进行交互的。例如，log4j 使用的自定义 appender。| 1.4.0
spark.sql.hive.metastore.barrierPrefixes | (empty)	| 一个逗号分隔的类前缀列表，应该明确地为 Spark SQL 正在通信的 Hive 的每个版本重新加载。例如，在通常将被共享的前缀中声明的 Hive UDF（即： org.apache.spark.*）。| 1.4.0