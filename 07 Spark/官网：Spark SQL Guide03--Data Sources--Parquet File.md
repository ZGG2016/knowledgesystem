# 官网：Spark SQL Guide03--Data Sources--Parquet Files

[TOC]

*Parquet is a columnar format that is supported by many other data processing systems. Spark SQL provides support for both reading and writing Parquet files that automatically preserves the schema of the original data. When reading Parquet files, all columns are automatically converted to be nullable for compatibility reasons.*

Parquet 是柱状格式。Spark SQL 支持读写 Parquet 文件，可自动保存原始数据的结构。当读取 Parquet 文件时，出于兼容性原因，所有列都将自动转换为可为空的。

## 1、Loading Data Programmatically  载入数据

**sql**

```sql
CREATE TEMPORARY VIEW parquetTable
USING org.apache.spark.sql.parquet
OPTIONS (
  path "examples/src/main/resources/people.parquet"
)

SELECT * FROM parquetTable
```

**A：对于python**

```python
peopleDF = spark.read.json("examples/src/main/resources/people.json")

# DataFrames can be saved as Parquet files, maintaining the schema information.
peopleDF.write.parquet("people.parquet")

# Read in the Parquet file created above.
# Parquet files are self-describing so the schema is preserved.
# The result of loading a parquet file is also a DataFrame.
parquetFile = spark.read.parquet("people.parquet")

# Parquet files can also be used to create a temporary view and then used in SQL statements.
parquetFile.createOrReplaceTempView("parquetFile")
teenagers = spark.sql("SELECT name FROM parquetFile WHERE age >= 13 AND age <= 19")
teenagers.show()
# +------+
# |  name|
# +------+
# |Justin|
# +------+
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

Dataset<Row> peopleDF = spark.read().json("examples/src/main/resources/people.json");

// DataFrames can be saved as Parquet files, maintaining the schema information
peopleDF.write().parquet("people.parquet");

// Read in the Parquet file created above.
// Parquet files are self-describing so the schema is preserved
// The result of loading a parquet file is also a DataFrame
Dataset<Row> parquetFileDF = spark.read().parquet("people.parquet");

// Parquet files can also be used to create a temporary view and then used in SQL statements
parquetFileDF.createOrReplaceTempView("parquetFile");
Dataset<Row> namesDF = spark.sql("SELECT name FROM parquetFile WHERE age BETWEEN 13 AND 19");
Dataset<String> namesDS = namesDF.map(
    (MapFunction<Row, String>) row -> "Name: " + row.getString(0),
    Encoders.STRING());
namesDS.show();
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
// Encoders for most common types are automatically provided by importing spark.implicits._
import spark.implicits._

val peopleDF = spark.read.json("examples/src/main/resources/people.json")

// DataFrames can be saved as Parquet files, maintaining the schema information
peopleDF.write.parquet("people.parquet")

// Read in the parquet file created above
// Parquet files are self-describing so the schema is preserved
// The result of loading a Parquet file is also a DataFrame
val parquetFileDF = spark.read.parquet("people.parquet")

// Parquet files can also be used to create a temporary view and then used in SQL statements
parquetFileDF.createOrReplaceTempView("parquetFile")
val namesDF = spark.sql("SELECT name FROM parquetFile WHERE age BETWEEN 13 AND 19")
namesDF.map(attributes => "Name: " + attributes(0)).show()
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

## 2、Partition Discovery  分区发现

*Table partitioning is a common optimization approach used in systems like Hive. In a partitioned table, data are usually stored in different directories, with partitioning column values encoded in the path of each partition directory. All built-in file sources (including Text/CSV/JSON/ORC/Parquet) are able to discover and infer partitioning information automatically. For example, we can store all our previously used population data into a partitioned table using the following directory structure, with two extra columns, gender and country as partitioning columns:*

分区表是一种常见的优化方法。每个分区的数据存储在不同的目录。所有内置的文件数据源(including Text/CSV/JSON/ORC/Parquet)都能自动发现和推断分区信息。

例如，我们可以使用以下目录结构将所有以前使用的人口数据存储到分区表中，其中有两个额外的列 gender 和 country 作为分区列:

	path
	└── to
	    └── table
	        ├── gender=male
	        │   ├── ...
	        │   │
	        │   ├── country=US
	        │   │   └── data.parquet
	        │   ├── country=CN
	        │   │   └── data.parquet
	        │   └── ...
	        └── gender=female
	            ├── ...
	            │
	            ├── country=US
	            │   └── data.parquet
	            ├── country=CN
	            │   └── data.parquet
	            └── ...

*By passing path/to/table to either SparkSession.read.parquet or SparkSession.read.load, Spark SQL will automatically extract the partitioning information from the paths. Now the schema of the returned DataFrame becomes:*

通过将 path/to/table 传递给 SparkSession.read.parquet 或 SparkSession.read.load，Spark SQL 将自动从路径中提取分区信息。现在返回的 DataFrame 的结构变成:

	root
	|-- name: string (nullable = true)
	|-- age: long (nullable = true)
	|-- gender: string (nullable = true)
	|-- country: string (nullable = true)

*Notice that the data types of the partitioning columns are automatically inferred. Currently, numeric data types, date, timestamp and string type are supported. Sometimes users may not want to automatically infer the data types of the partitioning columns. For these use cases, the automatic type inference can be configured by spark.sql.sources.partitionColumnTypeInference.enabled, which is default to true. When type inference is disabled, string type will be used for the partitioning columns.*

数值、日期、时间戳和字符串数据类型的分区列可以被自动推断。如果不想自动推断，可以配置属性 `spark.sql.sources.partitionColumnTypeInference.enabled`，默认是true


*Starting from Spark 1.6.0, partition discovery only finds partitions under the given paths by default. For the above example, if users pass path/to/table/gender=male to either SparkSession.read.parquet or SparkSession.read.load, gender will not be considered as a partitioning column. If users need to specify the base path that partition discovery should start with, they can set basePath in the data source options. For example, when path/to/table/gender=male is the path of the data and users set basePath to path/to/table/, gender will be a partitioning column.*

从 Spark 1.6.0 开始，默认情况下，分区发现只能找到给定路径下的分区。对于上述示例，如果用户将 path/to/table/gender=male 传递给 SparkSession.read.parquet 或 SparkSession.read.load，则 gender 将不被视为分区列。如果用户需要指定分区发现应该开始的基本路径，则可以在数据源选项中设置 basePath。例如，当 path/to/table/gender=male 是数据的路径并且用户将 basePath 设置为 path/to/table/，gender 将是一个分区列。

## 3、Schema Merging  结构合并

*Like Protocol Buffer, Avro, and Thrift, Parquet also supports schema evolution. Users can start with a simple schema, and gradually add more columns to the schema as needed. In this way, users may end up with multiple Parquet files with different but mutually compatible schemas. The Parquet data source is now able to automatically detect this case and merge schemas of all these files.*

用户可以根据一个简单的结构，逐渐的往里添加列。这种情况下，用户最终可能会得到多个具有不同但相互兼容模式的 Parquet 文件。 Parquet 数据源现在能够自动检测这种情况，并合并所有这些文件的结构。

*Since schema merging is a relatively expensive operation, and is not a necessity in most cases, we turned it off by default starting from 1.5.0. You may enable it by*

结构合并是一个昂贵，且不必要的操作，默认是关闭此功能。你可以这样启动：

- 设置 mergeSchema = true
- 或全局选项，设置 spark.sql.parquet.mergeSchema = true

*setting data source option mergeSchema to true when reading Parquet files (as shown in the examples below), or setting the global SQL option spark.sql.parquet.mergeSchema to true.*

**A：对于python**

```python
from pyspark.sql import Row

# spark is from the previous example.
# Create a simple DataFrame, stored into a partition directory
sc = spark.sparkContext

squaresDF = spark.createDataFrame(sc.parallelize(range(1, 6))
                                  .map(lambda i: Row(single=i, double=i ** 2)))
squaresDF.write.parquet("data/test_table/key=1")

# Create another DataFrame in a new partition directory,
# adding a new column and dropping an existing column
cubesDF = spark.createDataFrame(sc.parallelize(range(6, 11))
                                .map(lambda i: Row(single=i, triple=i ** 3)))
cubesDF.write.parquet("data/test_table/key=2")

# Read the partitioned table
mergedDF = spark.read.option("mergeSchema", "true").parquet("data/test_table")
mergedDF.printSchema()

# The final schema consists of all 3 columns in the Parquet files together
# with the partitioning column appeared in the partition directory paths.
# root
#  |-- double: long (nullable = true)
#  |-- single: long (nullable = true)
#  |-- triple: long (nullable = true)
#  |-- key: integer (nullable = true)
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

public static class Square implements Serializable {
  private int value;
  private int square;

  // Getters and setters...

}

public static class Cube implements Serializable {
  private int value;
  private int cube;

  // Getters and setters...

}

List<Square> squares = new ArrayList<>();
for (int value = 1; value <= 5; value++) {
  Square square = new Square();
  square.setValue(value);
  square.setSquare(value * value);
  squares.add(square);
}

// Create a simple DataFrame, store into a partition directory
Dataset<Row> squaresDF = spark.createDataFrame(squares, Square.class);
squaresDF.write().parquet("data/test_table/key=1");

List<Cube> cubes = new ArrayList<>();
for (int value = 6; value <= 10; value++) {
  Cube cube = new Cube();
  cube.setValue(value);
  cube.setCube(value * value * value);
  cubes.add(cube);
}

// Create another DataFrame in a new partition directory,
// adding a new column and dropping an existing column
Dataset<Row> cubesDF = spark.createDataFrame(cubes, Cube.class);
cubesDF.write().parquet("data/test_table/key=2");

// Read the partitioned table
Dataset<Row> mergedDF = spark.read().option("mergeSchema", true).parquet("data/test_table");
mergedDF.printSchema();

// The final schema consists of all 3 columns in the Parquet files together
// with the partitioning column appeared in the partition directory paths
// root
//  |-- value: int (nullable = true)
//  |-- square: int (nullable = true)
//  |-- cube: int (nullable = true)
//  |-- key: int (nullable = true)
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
// This is used to implicitly convert an RDD to a DataFrame.
import spark.implicits._

// Create a simple DataFrame, store into a partition directory
val squaresDF = spark.sparkContext.makeRDD(1 to 5).map(i => (i, i * i)).toDF("value", "square")
squaresDF.write.parquet("data/test_table/key=1")

// Create another DataFrame in a new partition directory,
// adding a new column and dropping an existing column
val cubesDF = spark.sparkContext.makeRDD(6 to 10).map(i => (i, i * i * i)).toDF("value", "cube")
cubesDF.write.parquet("data/test_table/key=2")

// Read the partitioned table
val mergedDF = spark.read.option("mergeSchema", "true").parquet("data/test_table")
mergedDF.printSchema()

// The final schema consists of all 3 columns in the Parquet files together
// with the partitioning column appeared in the partition directory paths
// root
//  |-- value: int (nullable = true)
//  |-- square: int (nullable = true)
//  |-- cube: int (nullable = true)
//  |-- key: int (nullable = true)
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

## 4、Hive metastore Parquet table conversion

*When reading from Hive metastore Parquet tables and writing to non-partitioned Hive metastore Parquet tables, Spark SQL will try to use its own Parquet support instead of Hive SerDe for better performance. This behavior is controlled by the spark.sql.hive.convertMetastoreParquet configuration, and is turned on by default.*

当读取和写入 Hive metastore Parquet tables时，Spark SQL 将尝试使用自己的Parquet 支持，而不是 Hive SerDe 来获得更好的性能。此行为由 spark.sql.hive.convertMetastoreParquet 配置控制，默认情况下打开。

### 4.1、Hive/Parquet Schema Reconciliation

*There are two key differences between Hive and Parquet from the perspective of table schema processing.*

*Hive is case insensitive, while Parquet is not*
*Hive considers all columns nullable, while nullability in Parquet is significant*


Hive 和 Parquet 呈现表结构有两点不同：

- Hive 不区分大小写，Parquet 区分
- Hive 认为所有列都可以为空，而 Parquet 的可空性是 significant 的。（？？？）


*Due to this reason, we must reconcile Hive metastore schema with Parquet schema when converting a Hive metastore Parquet table to a Spark SQL Parquet table. The reconciliation rules are:*

*Fields that have the same name in both schema must have the same data type regardless of nullability. The reconciled field should have the data type of the Parquet side, so that nullability is respected.*

*The reconciled schema contains exactly those fields defined in Hive metastore schema.*

*Any fields that only appear in the Parquet schema are dropped in the reconciled schema.*
*Any fields that only appear in the Hive metastore schema are added as nullable field in the reconciled schema.*


由于这个原因，当将 Hive 元数据库的 Parquet 表转换为 Spark SQL Parquet 表时，必须使 Hive 元数据库结构与 Parquet 结构一致。规则是:

- 在两个结构中具有相同名称的字段必须具有相同的数据类型，而不管可空性。调整的字段应具有 Parquet 侧的数据类型。

- 调整的结构要包含 Hive 元数据库的 Parquet 表中定义的那些字段：

	只出现在 Parquet 结构中的任何字段都要在调整的结构中将被删除。

	仅在 Hive 元数据库结构中出现的任何字段在调整的结构中作为可空字段添加。

### 4.2、Metadata Refreshing  元数据刷新

*Spark SQL caches Parquet metadata for better performance. When Hive metastore Parquet table conversion is enabled, metadata of those converted tables are also cached. If these tables are updated by Hive or other external tools, you need to refresh them manually to ensure consistent metadata.*

Spark SQL 缓存 Parquet 元数据以获得更好的性能。当启用 Hive 元数据库的 Parquet 表转换时，这些 转换表的元数据也被缓存。如果这些表由 Hive 或其他外部工具更新，则需要手动刷新以确保元数据一致。

**sql**

```sql
REFRESH TABLE my_table;
```

**A：对于python**

```python
# spark is an existing SparkSession
spark.catalog.refreshTable("my_table")
```

**B：对于java**

```java
// spark is an existing SparkSession
spark.catalog().refreshTable("my_table");
```
**C：对于scala**

```scala
// spark is an existing SparkSession
spark.catalog.refreshTable("my_table")
```
## 5、Configuration

*Configuration of Parquet can be done using the setConf method on SparkSession or by running SET key=value commands using SQL.*

可以使用 SparkSession 上的 setConf 方法或使用 SQL 运行 SET key = value 命令来完成 Parquet 的配置.


Property Name | Default | Meaning | Since Version
---|:---|:---|:---
spark.sql.parquet.binaryAsString | false | Some other Parquet-producing systems, in particular Impala, Hive, and older versions of Spark SQL, do not differentiate between binary data and strings when writing out the Parquet schema. This flag tells Spark SQL to interpret binary data as a string to provide compatibility with these systems. | 1.1.1
spark.sql.parquet.int96AsTimestamp | true | Some Parquet-producing systems, in particular Impala and Hive, store Timestamp into INT96. This flag tells Spark SQL to interpret INT96 data as a timestamp to provide compatibility with these systems. | 1.3.0
spark.sql.parquet.compression.codec | nappy | Sets the compression codec used when writing Parquet files. If either compression or parquet.compression is specified in the table-specific options/properties, the precedence would be compression, parquet.compression, spark.sql.parquet.compression.codec. Acceptable values include: none, uncompressed, snappy, gzip, lzo, brotli, lz4, zstd. Note that zstd requires ZStandardCodec to be installed before Hadoop 2.9.0, brotli requires BrotliCodec to be installed. | 1.1.1
spark.sql.parquet.filterPushdown | true | Enables Parquet filter push-down optimization when set to true. | 1.2.0
spark.sql.hive.convertMetastoreParquet | true | When set to false, Spark SQL will use the Hive SerDe for parquet tables instead of the built in support. | 1.1.1
spark.sql.parquet.mergeSchema | false | When true, the Parquet data source merges schemas collected from all data files, otherwise the schema is picked from the summary file or a random data file if no summary file is available. | 1.5.0
spark.sql.parquet.writeLegacyFormat | false | If true, data will be written in a way of Spark 1.4 and earlier. For example, decimal values will be written in Apache Parquet's fixed-length byte array format, which other systems such as Apache Hive and Apache Impala use. If false, the newer format in Parquet will be used. For example, decimals will be written in int-based format. If Parquet output is intended for use with systems that do not support this newer format, set to true. | 1.6.0