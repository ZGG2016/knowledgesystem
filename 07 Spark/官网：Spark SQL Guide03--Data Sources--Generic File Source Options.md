# 官网：Spark SQL Guide03--Data Sources--Generic File Source Options

*These generic options/configurations are effective only when using file-based sources: parquet, orc, avro, json, csv, text.*

只要在使用基于文件的源(如，parquet, orc, avro, json, csv, text)时，这些通用配置才有效。

*Please note that the hierarchy of directories used in examples below are:*

本页例子中目录层次结构如下：

	dir1/
	 ├── dir2/
	 │    └── file2.parquet (schema: <file: string>, content: "file2.parquet")
	 └── file1.parquet (schema: <file, string>, content: "file1.parquet")
	 └── file3.json (schema: <file, string>, content: "{'file':'corrupt.json'}")

## 1、Ignore Corrupt Files  忽略损坏文件

*Spark allows you to use spark.sql.files.ignoreCorruptFiles to ignore corrupt files while reading data from files. When set to true, the Spark jobs will continue to run when encountering corrupted files and the contents that have been read will still be returned.*

`spark.sql.files.ignoreCorruptFiles = true` 在读取中遇到损坏的文件，程序会继续运行，返回读到内容。

*To ignore corrupt files while reading data files, you can use:*

**A：对于python**

```python
# enable ignore corrupt files
spark.sql("set spark.sql.files.ignoreCorruptFiles=true")
# dir1/file3.json is corrupt from parquet's view
test_corrupt_df = spark.read.parquet("examples/src/main/resources/dir1/",
                                     "examples/src/main/resources/dir1/dir2/")
test_corrupt_df.show()
# +-------------+
# |         file|
# +-------------+
# |file1.parquet|
# |file2.parquet|
# +-------------+
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
// enable ignore corrupt files
spark.sql("set spark.sql.files.ignoreCorruptFiles=true");
// dir1/file3.json is corrupt from parquet's view
Dataset<Row> testCorruptDF = spark.read().parquet(
        "examples/src/main/resources/dir1/",
        "examples/src/main/resources/dir1/dir2/");
testCorruptDF.show();
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// |file2.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
// enable ignore corrupt files
spark.sql("set spark.sql.files.ignoreCorruptFiles=true")
// dir1/file3.json is corrupt from parquet's view
val testCorruptDF = spark.read.parquet(
  "examples/src/main/resources/dir1/",
  "examples/src/main/resources/dir1/dir2/")
testCorruptDF.show()
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// |file2.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

## 2、Ignore Missing Files 忽略缺失文件

*Spark allows you to use spark.sql.files.ignoreMissingFiles to ignore missing files while reading data from files. Here, missing file really means the deleted file under directory after you construct the DataFrame. When set to true, the Spark jobs will continue to run when encountering missing files and the contents that have been read will still be returned.*

缺失文件指：构造 DataFrame 后，又删除了目录下的文件。

`spark.sql.files.ignoreMissingFiles=true` 在读取中遇到缺失的文件，程序会继续运行，返回读到内容。

## 3、Path Global Filter  路径全局过滤

*pathGlobFilter is used to only include files with file names matching the pattern. The syntax follows org.apache.hadoop.fs.GlobFilter. It does not change the behavior of partition discovery.*

pathGlobFilter 用来过滤掉不符合匹配规则的文件。

需要配置 `org.apache.hadoop.fs.GlobFilter.`

它不会改变分区发现的行为。

*To load files with paths matching a given glob pattern while keeping the behavior of partition discovery, you can use:*

**A：对于python**

```python
df = spark.read.load("examples/src/main/resources/dir1",
                     format="parquet", pathGlobFilter="*.parquet")
df.show()
# +-------------+
# |         file|
# +-------------+
# |file1.parquet|
# +-------------+
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
Dataset<Row> testGlobFilterDF = spark.read().format("parquet")
        .option("pathGlobFilter", "*.parquet") // json file should be filtered out
        .load("examples/src/main/resources/dir1");
testGlobFilterDF.show();
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
val testGlobFilterDF = spark.read.format("parquet")
  .option("pathGlobFilter", "*.parquet") // json file should be filtered out
  .load("examples/src/main/resources/dir1")
testGlobFilterDF.show()
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*

## 4、Recursive File Lookup  递归查找文件

*recursiveFileLookup is used to recursively load files and it disables partition inferring. Its default value is false. If data source explicitly specifies the partitionSpec when recursiveFileLookup is true, exception will be thrown.*

`recursiveFileLookup` 会递归载入文件，但会停止分区推断。 默认false。

当设为 true ，如果数据源明确指定了 partitionSpec，则会抛出异常。

*To load all files recursively, you can use:*

**A：对于python**

```python
recursive_loaded_df = spark.read.format("parquet")\
    .option("recursiveFileLookup", "true")\
    .load("examples/src/main/resources/dir1")
recursive_loaded_df.show()
# +-------------+
# |         file|
# +-------------+
# |file1.parquet|
# |file2.parquet|
# +-------------+
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*

**B：对于java**

```java
Dataset<Row> recursiveLoadedDF = spark.read().format("parquet")
        .option("recursiveFileLookup", "true")
        .load("examples/src/main/resources/dir1");
recursiveLoadedDF.show();
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// |file2.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.*

**C：对于scala**

```scala
val recursiveLoadedDF = spark.read.format("parquet")
  .option("recursiveFileLookup", "true")
  .load("examples/src/main/resources/dir1")
recursiveLoadedDF.show()
// +-------------+
// |         file|
// +-------------+
// |file1.parquet|
// |file2.parquet|
// +-------------+
```
*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*