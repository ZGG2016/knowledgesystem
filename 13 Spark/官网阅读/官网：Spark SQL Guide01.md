# 官网：Spark SQL Guide01

[TOC]

Spark SQL 是处理结构化数据的模块。和基本的 Spark RDD API 不同，Spark SQL 为 Spark 提供了关于数据和执行计算的更多结构化信息。在内部，Spark SQL 使用这个额外的信息去执行额外的优化。 可以使用 SQL 和 Dataset API 跟 Spark SQL 交互。无论你使用哪种 API/语言，都会使用同一个引擎执行计算。这就意味着开发者可以在不同 APIs 间来回切换。

本页所有的样例数据都在 Spark 发行版里。可以使用 spark-shell、pyspark shell、sparkR shell 来运行。


## 1、SQL

Spark SQL 的作用之一就是执行 SQL 查询。也可以从 Hive 中读取数据。更详细信息参见[Hive Tables](http://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html)。当在其他编程语言运行 SQL 时，会返回一个 Dataset/DataFrame 。你也可以使用[命令行](http://spark.apache.org/docs/latest/sql-distributed-sql-engine.html#running-the-spark-sql-cli)或通过 [JDBC/ODBC](http://spark.apache.org/docs/latest/sql-distributed-sql-engine.html#running-the-thrift-jdbcodbc-server) 来和 SQL 接口交互。

## 2、Datasets and DataFrames

**Dataset 是一个分布式的数据集合**。 Dataset 是在 Spark 1.6 添加的新的接口，同时具备 RDDs 的优点(强类型化、lambda 函数) 和 Spark SQL 优化了的执行引擎的优点。 Dataset 可以从 [ JVM 对象中构造](http://spark.apache.org/docs/latest/sql-getting-started.html#creating-datasets)，然后可以使用 transformations 函数(map, flatMap, filter, etc.)。Dataset API在 [Scala](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html) 和 [Java](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html) 中均可用，Python 不支持。但是由于 Python 的动态特性，Dataset API 的优点早已具备。(如，通过 row.columnName 来访问一行的字段)。 R 也具有相似情况。

**DataFrame 是组织成指定列的 Dataset**。和关系数据库中的表、R/Python 中的 data frame 的概念相似，但底层进行了优化。 DataFrames 可以从各种各样的[数据源](http://spark.apache.org/docs/latest/sql-data-sources.html)中构造，**如结构化数据文件、Hive 表、外部数据库、已存在的 RDDs**。Dataset API在 Scala 、Java 、[Python](http://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrame) 、[R](http://spark.apache.org/docs/latest/api/R/index.html) 中均可用。 在 Scala 和 Java 中，**a DataFrame is represented by a Dataset of Rows.** 在 [Scala API](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html)中，DataFrame 仅仅是一个 Dataset[Row]类型的别名。在 [Java API](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html) 中，可以使用 Dataset<Row> 表示一个 DataFrame。

在此文档中，我们将常常会引用 Scala/Java Datasets 的 Rows 作为 DataFrames。


```java
// 创建 DataFrame
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

// a DataFrame is represented by a Dataset of Rows 
Dataset<Row> df = spark.read().json("examples/src/main/resources/people.json");

// Displays the content of the DataFrame to stdout
df.show(); // DataFrame 是组织成指定列的 Dataset
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```
