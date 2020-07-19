# 官网：Spark SQL Guide03--Data Sources--Generic Load/Save Functions

*In the simplest form, the default data source (parquet unless otherwise configured by spark.sql.sources.default) will be used for all operations.*

所有的操作使用的是默认数据源(parquet，除非配置 `spark.sql.sources.default`)

**A：对于python**

```python
df = spark.read.load("examples/src/main/resources/users.parquet")
df.select("name", "favorite_color").write.save("namesAndFavColors.parquet")
```

Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```java
Dataset<Row> usersDF = spark.read().load("examples/src/main/resources/users.parquet");
usersDF.select("name", "favorite_color").write().save("namesAndFavColors.parquet");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
val usersDF = spark.read.load("examples/src/main/resources/users.parquet")
usersDF.select("name", "favorite_color").write.save("namesAndFavColors.parquet")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

## 1、Manually Specifying Options 手动指定可选项

*You can also manually specify the data source that will be used along with any extra options that you would like to pass to the data source. Data sources are specified by their fully qualified name (i.e., org.apache.spark.sql.parquet), but for built-in sources you can also use their short names (json, parquet, jdbc, orc, libsvm, csv, text). DataFrames loaded from any data source type can be converted into other types using this syntax.*

*Please refer the API documentation for available options of built-in sources, for example, org.apache.spark.sql.DataFrameReader and org.apache.spark.sql.DataFrameWriter. The options documented there should be applicable through non-Scala Spark APIs (e.g. PySpark) as well. For other formats, refer to the API documentation of the particular format.*

你可以指定数据源类型，需要名字要完整合格，如 `org.apache.spark.sql.parquet`。对于内置源，可以使用简单的名字，如json, parquet, jdbc, orc, libsvm, csv, text。

内置源的可选项请见API。可选项应当也能用在非 Scala 的 Spark APIs (e.g. PySpark)

To load a JSON file you can use:

**A：对于python**

```python
df = spark.read.load("examples/src/main/resources/people.json", format="json")
df.select("name", "age").write.save("namesAndAges.parquet", format="parquet")
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```python
Dataset<Row> peopleDF =
  spark.read().format("json").load("examples/src/main/resources/people.json");
peopleDF.select("name", "age").write().format("parquet").save("namesAndAges.parquet");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
val peopleDF = spark.read.format("json").load("examples/src/main/resources/people.json")
peopleDF.select("name", "age").write.format("parquet").save("namesAndAges.parquet")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

To load a CSV file you can use:

**A：对于python**

```python
df = spark.read.load("examples/src/main/resources/people.csv",
                     format="csv", sep=":", inferSchema="true", header="true")
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```java
Dataset<Row> peopleDFCsv = spark.read().format("csv")
  .option("sep", ";")
  .option("inferSchema", "true")
  .option("header", "true")
  .load("examples/src/main/resources/people.csv");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
val peopleDFCsv = spark.read.format("csv")
  .option("sep", ";")
  .option("inferSchema", "true")
  .option("header", "true")
  .load("examples/src/main/resources/people.csv")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

*The extra options are also used during write operation. For example, you can control bloom filters and dictionary encodings for ORC data sources. The following ORC example will create bloom filter and use dictionary encoding only for favorite_color. For Parquet, there exists parquet.enable.dictionary, too. To find more detailed information about the extra ORC/Parquet options, visit the official Apache ORC/Parquet websites.*

写操作也有一些可选项，如，对 ORC 的  bloom filters 和 dictionary encodings。

对于 Parquet ，也有 parquet.enable.dictionary

**A：对于python**

```python
df = spark.read.orc("examples/src/main/resources/users.orc")
(df.write.format("orc")
    .option("orc.bloom.filter.columns", "favorite_color")
    .option("orc.dictionary.key.threshold", "1.0")
    .option("orc.column.encoding.direct", "name")
    .save("users_with_options.orc"))
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**
```java
usersDF.write().format("orc")
  .option("orc.bloom.filter.columns", "favorite_color")
  .option("orc.dictionary.key.threshold", "1.0")
  .option("orc.column.encoding.direct", "name")
  .save("users_with_options.orc");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
usersDF.write.format("orc")
  .option("orc.bloom.filter.columns", "favorite_color")
  .option("orc.dictionary.key.threshold", "1.0")
  .option("orc.column.encoding.direct", "name")
  .save("users_with_options.orc")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

## 2、Run SQL on files directly  直接在文件上运行 SQL

*Instead of using read API to load a file into DataFrame and query it, you can also query that file directly with SQL.*

除了使用 read 来读取文件到 DataFrame ，并从中插叙。也可以直接在文件上运行 SQL

**A：对于python**

```python
df = spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```java
Dataset<Row> sqlDF =
  spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
val sqlDF = spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

## 3、Save Modes

*Save operations can optionally take a SaveMode, that specifies how to handle existing data if present. It is important to realize that these save modes do not utilize any locking and are not atomic. Additionally, when performing an Overwrite, the data will be deleted before writing out the new data.*

存储操作可选择 SaveMode 选项。 这些存储模式不使用任何锁定，并且不是原子的。另外，当执行覆盖 时，数据将在新数据写出之前被删除。

Scala/Java | Any Language| Meaning
---|:---|:---
SaveMode.ErrorIfExists (default) | "error" or "errorifexists" (default) | When saving a DataFrame to a data source, if data already exists, an exception is expected to be thrown.存储的时候，数据已存在，就抛异常。
SaveMode.Append | "append" | When saving a DataFrame to a data source, if data/table already exists, contents of the DataFrame are expected to be appended to existing data.存储的时候，数据已存在，就追加。
SaveMode.Overwrite | "overwrite" | Overwrite mode means that when saving a DataFrame to a data source, if data/table already exists, existing data is expected to be overwritten by the contents of the DataFrame.存储的时候，数据已存在，就覆盖。
SaveMode.Ignore | "ignore" | Ignore mode means that when saving a DataFrame to a data source, if data already exists, the save operation is expected not to save the contents of the DataFrame and not to change the existing data. This is similar to a CREATE TABLE IF NOT EXISTS in SQL.存储的时候，数据已存在，就不再往里写数据。

## 4、Saving to Persistent Tables 保存到持久表

*DataFrames can also be saved as persistent tables into Hive metastore using the saveAsTable command. Notice that an existing Hive deployment is not necessary to use this feature. Spark will create a default local Hive metastore (using Derby) for you. Unlike the createOrReplaceTempView command, saveAsTable will materialize the contents of the DataFrame and create a pointer to the data in the Hive metastore. Persistent tables will still exist even after your Spark program has restarted, as long as you maintain your connection to the same metastore. A DataFrame for a persistent table can be created by calling the table method on a SparkSession with the name of the table.*

DataFrames 可以使用 saveAsTable 以持久表的形式存入 Hive 元数据库。此特性不需要先部署 Hive。 Spark 会创建一个默认的本地 Hive 元数据库(使用 Derby)。和 createOrReplaceTempView 不同，saveAsTable会物化 DataFrame 的内容，创建一个指向 Hive 元数据库的指针。只要依然连接在先沟通的元数据库，即使 Spark 程序重启后，持久表也会存在。 可以通过使用表的名称在 SparkSession 上调用 table 方法来创建持久表的 DataFrame。

*For file-based data source, e.g. text, parquet, json, etc. you can specify a custom table path via the path option, e.g. df.write.option("path", "/some/path").saveAsTable("t"). When the table is dropped, the custom table path will not be removed and the table data is still there. If no custom table path is specified, Spark will write data to a default table path under the warehouse directory. When the table is dropped, the default table path will be removed too.*

像 text、 parquet、 json 的基于文件的数据源。可以通过 path 参数指定自定义表的路径，如 `df.write.option("path", "/some/path").saveAsTable("t")` 。当表被删除，这个自定义路径和表数据仍旧会存在。如果不指定一个路径，Spark 会写入数据到仓库目录下的默认表路径，当表删除后，此默认表路径也会被删除。

*Starting from Spark 2.1, persistent datasource tables have per-partition metadata stored in the Hive metastore. This brings several benefits:*

从 Spark 2.1 开始，持久性数据源表将每个分区元数据存储在 Hive 元数据库中。这带来了几个好处:

*Since the metastore can return only necessary partitions for a query, discovering all the partitions on the first query to the table is no longer needed.
Hive DDLs such as ALTER TABLE PARTITION ... SET LOCATION are now available for tables created with the Datasource API.*

- 由于元数据库只能返回查询所需的分区，因此不再需要第一个查询语句就返回所有分区。
- Hive DDLs 如 ALTER TABLE PARTITION ... SET LOCATION 现在可用于使用 Datasource API 创建的表。

*Note that partition information is not gathered by default when creating external datasource tables (those with a path option). To sync the partition information in the metastore, you can invoke MSCK REPAIR TABLE.*

请注意，创建外部数据源表（带有 path 选项）时，默认情况下不会收集分区信息。要同步元数据库中的分区信息，可以调用 MSCK REPAIR TABLE。

## 5、Bucketing, Sorting and Partitioning

*For file-based data source, it is also possible to bucket and sort or partition the output. Bucketing and sorting are applicable only to persistent tables:*

基于文件的数据源，分桶、排序、分区输出是可能的。分桶、排序只能用在持久表。

*sql*

```sql
CREATE TABLE users_bucketed_by_name(
  name STRING,
  favorite_color STRING,
  favorite_numbers array<integer>
) USING parquet
CLUSTERED BY(name) INTO 42 BUCKETS;
```

**A：对于python**

```python
df.write.bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed")
```

*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
peopleDF.write().bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed");
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
peopleDF.write.bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed")
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

*while partitioning can be used with both save and saveAsTable when using the Dataset APIs.*

当使用 Dataset APIs 时，分区可以用于 save 和 saveAsTable 

**sql**

```sql
CREATE TABLE users_by_favorite_color(
  name STRING,
  favorite_color STRING,
  favorite_numbers array<integer>
) USING csv PARTITIONED BY(favorite_color);
```

**A：对于python**

```python
df.write.partitionBy("favorite_color").format("parquet").save("namesPartByColor.parquet")
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```java
usersDF
  .write()
  .partitionBy("favorite_color")
  .format("parquet")
  .save("namesPartByColor.parquet");
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
usersDF.write.partitionBy("favorite_color").format("parquet").save("namesPartByColor.parquet")
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

*It is possible to use both partitioning and bucketing for a single table:*

在一个表上，可以同时使用分区和分桶

**sql**
```sql
CREATE TABLE users_bucketed_and_partitioned(
  name STRING,
  favorite_color STRING,
  favorite_numbers array<integer>
) USING parquet
PARTITIONED BY (favorite_color)
CLUSTERED BY(name) SORTED BY (favorite_numbers) INTO 42 BUCKETS;
```

**A：对于python**

```python
df = spark.read.parquet("examples/src/main/resources/users.parquet")
(df
    .write
    .partitionBy("favorite_color")
    .bucketBy(42, "name")
    .saveAsTable("people_partitioned_bucketed"))
```
Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.

**B：对于java**

```java
peopleDF
  .write()
  .partitionBy("favorite_color")
  .bucketBy(42, "name")
  .saveAsTable("people_partitioned_bucketed");
```
Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.

**C：对于scala**

```scala
usersDF
  .write
  .partitionBy("favorite_color")
  .bucketBy(42, "name")
  .saveAsTable("users_partitioned_bucketed")
```
Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.

*partitionBy creates a directory structure as described in the Partition Discovery section. Thus, it has limited applicability to columns with high cardinality. In contrast bucketBy distributes data across a fixed number of buckets and can be used when the number of unique values is unbounded.*

[Partition Discovery 部分](http://spark.apache.org/docs/latest/sql-data-sources-parquet.html#partition-discovery)，partitionBy 创建一个目录结构。因此，对基数较高的列的适用性有限。相反，bucketBy 可以在固定数量的 buckets 中分发数据，并且当在多个唯一值是无界时使用数据。