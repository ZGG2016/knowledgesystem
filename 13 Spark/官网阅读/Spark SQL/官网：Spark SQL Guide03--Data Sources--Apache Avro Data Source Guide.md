# 官网：Spark SQL Guide03--Data Sources--Apache Avro Data Source Guide

[TOC]

Since Spark 2.4 release, Spark SQL provides built-in support for reading and writing Apache Avro data.

## 1、Deploying

**The spark-avro module is external and not included in spark-submit or spark-shell by default.**

**默认情况下，spark-avro 模块是外部的、不包含在 spark-submit 或 spark-shell 中的。**

**As with any Spark applications, spark-submit is used to launch your application. spark-avro_2.12 and its dependencies can be directly added to spark-submit using --packages, such as,**

spark-avro_2.12 和它的依赖可以直接使用 `--packages` 添加到 spark-submit

	./bin/spark-submit --packages org.apache.spark:spark-avro_2.12:3.0.0 ...

**For experimenting on spark-shell, you can also use --packages to add org.apache.spark:spark-avro_2.12 and its dependencies directly,**

也可以使用 `--packages` ，将 `org.apache.spark:spark-avro_2.12` 它的依赖添加到 spark-shell

	./bin/spark-shell --packages org.apache.spark:spark-avro_2.12:3.0.0 ...

**See [Application Submission Guide](https://spark.apache.org/docs/3.0.0/submitting-applications.html) for more details about submitting applications with external dependencies.**

## 2、Load and Save Functions

*Since spark-avro module is external, there is no .avro API in DataFrameReader or DataFrameWriter.*

*To load/save data in Avro format, you need to specify the data source option format as avro(or org.apache.spark.sql.avro).*

在 `DataFrameReader or DataFrameWriter` 中，没有 `.avro` API，所以，为了 `load/save` 数据，**需要指定数据源格式为 `avro` 或 `org.apache.spark.sql.avro`**

**A：对于python**

```python
df = spark.read.format("avro").load("examples/src/main/resources/users.avro")
df.select("name", "favorite_color").write.format("avro").save("namesAndFavColors.avro")
```

**B：对于java**

```java
Dataset<Row> usersDF = spark.read().format("avro").load("examples/src/main/resources/users.avro");
usersDF.select("name", "favorite_color").write().format("avro").save("namesAndFavColors.avro");
```

**C：对于scala**

```java
val usersDF = spark.read.format("avro").load("examples/src/main/resources/users.avro")
usersDF.select("name", "favorite_color").write.format("avro").save("namesAndFavColors.avro")
```

**D：对于r**

```r
df <- read.df("examples/src/main/resources/users.avro", "avro")
write.df(select(df, "name", "favorite_color"), "namesAndFavColors.avro", "avro")
```

## 3、to_avro() and from_avro()

*The Avro package provides function to_avro to encode a column as binary in Avro format, and from_avro() to decode Avro binary data into a column. Both functions transform one column to another column, and the input/output SQL data type can be a complex type or a primitive type.*

Avro 包提供了 `to_avro` 函数将一列数据编码成 Avro 格式的二进制数据，`from_avro` 函数将二进制数据解码成一列数据。

这两个函数都是将一列转换成另一列。输入输出 SQL 数据类型可以是复杂类型，也可以是基本类型。

*Using Avro record as columns is useful when reading from or writing to a streaming source like Kafka. Each Kafka key-value record will be augmented with some metadata, such as the ingestion timestamp into Kafka, the offset in Kafka, etc.*

当从 Kafka 这样的流数据源读取或写入数据时，使用 Avro 记录作为列是非常有用的。**每个 Kafka 键值记录都将添加一些元数据**，比如进入 Kafka 的时间戳、在 Kafka 中的偏移量等等。

*If the “value” field that contains your data is in Avro, you could use from_avro() to extract your data, enrich it, clean it, and then push it downstream to Kafka again or write it out to a file.
to_avro() can be used to turn structs into Avro records. This method is particularly useful when you would like to re-encode multiple columns into a single one when writing data out to Kafka.
Both functions are currently only available in Scala and Java.*

- 如果包含数据的 value 字段在 Avro，你可以使用 `from_avro()`抽取你的数据、丰富它、清理它、再把它推向 Kafka 的下游，或者写入到文件。

- `to_avro()` 可以把 structs 转成 Avro 记录。当你想把多列重新编码成一列，写入 Kafka 时，这个方法是有用的。

这两个方法在 Scala 和 Java 都可用。

**A. 对于python**

```python
from pyspark.sql.avro.functions import from_avro, to_avro

# `from_avro` requires Avro schema in JSON string format.
jsonFormatSchema = open("examples/src/main/resources/user.avsc", "r").read()

df = spark\
  .readStream\
  .format("kafka")\
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")\
  .option("subscribe", "topic1")\
  .load()

# 1. Decode the Avro data into a struct;
# 2. Filter by column `favorite_color`;
# 3. Encode the column `name` in Avro format.
output = df\
  .select(from_avro("value", jsonFormatSchema).alias("user"))\
  .where('user.favorite_color == "red"')\
  .select(to_avro("user.name").alias("value"))

query = output\
  .writeStream\
  .format("kafka")\
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")\
  .option("topic", "topic2")\
  .start()

```

**B. 对于java**

```java
import static org.apache.spark.sql.functions.col;
import static org.apache.spark.sql.avro.functions.*;

// `from_avro` requires Avro schema in JSON string format.
String jsonFormatSchema = new String(Files.readAllBytes(Paths.get("./examples/src/main/resources/user.avsc")));

Dataset<Row> df = spark
  .readStream()
  .format("kafka")
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")
  .option("subscribe", "topic1")
  .load();

// 1. Decode the Avro data into a struct;
// 2. Filter by column `favorite_color`;
// 3. Encode the column `name` in Avro format.
Dataset<Row> output = df
  .select(from_avro(col("value"), jsonFormatSchema).as("user"))
  .where("user.favorite_color == \"red\"")
  .select(to_avro(col("user.name")).as("value"));

StreamingQuery query = output
  .writeStream()
  .format("kafka")
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")
  .option("topic", "topic2")
  .start();
```

**C. 对于scala**

```java
import org.apache.spark.sql.avro.functions._

// `from_avro` requires Avro schema in JSON string format.
val jsonFormatSchema = new String(Files.readAllBytes(Paths.get("./examples/src/main/resources/user.avsc")))

val df = spark
  .readStream
  .format("kafka")
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")
  .option("subscribe", "topic1")
  .load()

// 1. Decode the Avro data into a struct;
// 2. Filter by column `favorite_color`;
// 3. Encode the column `name` in Avro format.
val output = df
  .select(from_avro('value, jsonFormatSchema) as 'user)
  .where("user.favorite_color == \"red\"")
  .select(to_avro($"user.name") as 'value)

val query = output
  .writeStream
  .format("kafka")
  .option("kafka.bootstrap.servers", "host1:port1,host2:port2")
  .option("topic", "topic2")
  .start()
```

## 4、Data Source Option

Data source options of Avro can be set via:

- the `.option` method on `DataFrameReader` or `DataFrameWriter`.

- the `options` parameter in function `from_avro`.

[参数详解见原网页](https://spark.apache.org/docs/3.0.0/sql-data-sources-avro.html)

## 5、Configuration

Configuration of Avro can be done using the `setConf` method on SparkSession or by running `SET key=value` commands using SQL.

Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.legacy.replaceDatabricksSparkAvro.enabled | true | If it is set to true, the data source provider com.databricks.spark.avro is mapped to the built-in but external Avro data source module for backward compatibility. | 2.4.0
spark.sql.avro.compression.codec | snappy | Compression codec used in writing of AVRO files. Supported codecs: uncompressed, deflate, snappy, bzip2 and xz. Default codec is snappy. | 2.4.0
spark.sql.avro.deflate.level | -1 | Compression level for the deflate codec used in writing of AVRO files. Valid value must be in the range of from 1 to 9 inclusive or -1. The default value is -1 which corresponds to 6 level in the current implementation. | 2.4.0

## 6、Compatibility with Databricks spark-avro

*This Avro data source module is originally from and compatible with Databricks’s open source repository [spark-avro](https://github.com/databricks/spark-avro).*

此 Avro 数据源模块来源于、且兼容 Databricks’s spark-avr

*By default with the SQL configuration spark.sql.legacy.replaceDatabricksSparkAvro.enabled enabled, the data source provider com.databricks.spark.avro is mapped to this built-in Avro module. For the Spark tables created with Provider property as com.databricks.spark.avro in catalog meta store, the mapping is essential to load these tables if you are using this built-in Avro module.*

默认情况下，`spark.sql.legacy.replaceDatabricksSparkAvro.enabled` 是启用的，数据源提供者 `com.databricks.spark.avro ` 映射到内置的 Avro 模块。

对于使用 `com.databricks.spark.avro` 属性创建的 Spark 表，如果你使用这个内置的 Avro 模块，映射对于载入这些表是必要的。

*Note in Databricks’s spark-avro, implicit classes AvroDataFrameWriter and AvroDataFrameReader were created for shortcut function .avro(). In this built-in but external module, both implicit classes are removed. Please use .format("avro") in DataFrameWriter or DataFrameReader instead, which should be clean and good enough.*

使用 `.format("avro")` 来创建 `DataFrameWriter or DataFrameReader`。

*If you prefer using your own build of spark-avro jar file, you can simply disable the configuration spark.sql.legacy.replaceDatabricksSparkAvro.enabled, and use the option --jars on deploying your applications. Read the Advanced Dependency Management section in [Application Submission Guide](https://spark.apache.org/docs/latest/submitting-applications.html#advanced-dependency-management) for more details.*

如果你想使用自己构建的 spark-avro jar 文件，你可以禁用 `spark.sql.legacy.replaceDatabricksSparkAvro.enabled`，使用 `--jars` 选项来部署你的应用程序。

## 7、Supported types for Avro -> Spark SQL conversion

Currently Spark supports reading all [primitive types](https://avro.apache.org/docs/1.8.2/spec.html#schema_primitive) and [complex types](https://avro.apache.org/docs/1.8.2/spec.html#schema_complex) under records of Avro.

[类型对比见原网页](https://spark.apache.org/docs/3.0.0/sql-data-sources-avro.html)

*In addition to the types listed above, it supports reading union types. The following three types are considered basic union types:*

除了上述列的类型，还支持读取 `union` 类型：

- union(int, long) will be mapped to LongType.

- union(float, double) will be mapped to DoubleType.

- union(something, null), where something is any supported Avro type. This will be mapped to the same Spark SQL type as that of something, with nullable set to true. All other union types are considered complex. They will be mapped to StructType where field names are member0, member1, etc., in accordance with members of the union. This is consistent with the behavior when converting between Avro and Parquet.

*It also supports reading the following [Avro logical types](https://avro.apache.org/docs/1.8.2/spec.html#Logical+Types):*

也支持下列的 Avro 逻辑类型：

Avro logical type | Avro type | Spark SQL type
---|:---|:---
date | int | DateType
timestamp-millis | long | TimestampType
timestamp-micros | long | TimestampType
decimal | fixed | DecimalType
decimal | bytes | DecimalType

*At the moment, it ignores docs, aliases and other properties present in the Avro file.*

在 Avro 文件中，会忽略 docs、别名和其他属性表示。

## 8、Supported types for Spark SQL -> Avro conversion

*Spark supports writing of all Spark SQL types into Avro. For most types, the mapping from Spark types to Avro types is straightforward (e.g. IntegerType gets converted to int); however, there are a few special cases which are listed below:*

Spark 支持所有 Spark SQL 类型写入 Avro。对于大多数类型，Spark 类型到 Avro 类型的映射是直接的(如，IntegerType转换成int)。然而，也有下列几种特殊情况：

Spark SQL type | Avro type | Avro logical type
---|:---|:---
ByteType | int | 	
ShortType | int | 	
BinaryType | bytes | 	
DateType | int | date
TimestampType | long | timestamp-micros
DecimalType | fixed | decimal

*You can also specify the whole output Avro schema with the option avroSchema, so that Spark SQL types can be converted into other Avro types. The following conversions are not applied by default and require user specified Avro schema:*

你也可以使用选项 avroSchema 指定整个输出的 Avro schema，为了 Spark SQL 类型能转换成其他 Avro 类型。下面的转换默认是不允许的，除非用户指定 Avro schema：

Spark SQL type | Avro type | Avro logical type
---|:---|:---
BinaryType | fixed | 	
StringType | enum | 	
TimestampType | long | timestamp-millis
DecimalType | bytes | decimal