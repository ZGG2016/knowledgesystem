# 官网：Spark SQL Guide03--Data Sources--Binary File Data Source

*Since Spark 3.0, Spark supports binary file data source, which reads binary files and converts each file into a single record that contains the raw content and metadata of the file. It produces a DataFrame with the following columns and possibly partition columns:*

从 Spark 3.0 开始，Spark 支持二进制文件数据源，读取二进制文件，把每个文件转换成一条记录，这条记录包含了原始内容和文件的元数据。

会产生一个 DataFrame 包含下列列和可能的分区列：

- path: StringType

- modificationTime: TimestampType

- length: LongType

- content: BinaryType

*To read whole binary files, you need to specify the data source format as binaryFile. To load files with paths matching a given glob pattern while keeping the behavior of partition discovery, you can use the general data source option pathGlobFilter. For example, the following code reads all PNG files from the input directory:*

为了读取整个二进制文件，你需要指定数据源类型为 `binaryFile`。

要加载与给定的 glob 模式匹配的路径下的文件，同时保持分区发现的行为，可以使用通用数据源选项 `pathGlobFilter`。

例如，下面的代码从输入目录读取所有 PNG 文件:

**A：对于python**

```python
spark.read.format("binaryFile").option("pathGlobFilter", "*.png").load("/path/to/data")

```

**B：对于java**

```java
spark.read().format("binaryFile").option("pathGlobFilter", "*.png").load("/path/to/data");

```

**C：对于scala**

```java
spark.read.format("binaryFile").option("pathGlobFilter", "*.png").load("/path/to/data")

```

**D：对于r**

```r
read.df("/path/to/data", source = "binaryFile", pathGlobFilter = "*.png")

```

*Binary file data source does not support writing a DataFrame back to the original files.*

二进制文件数据源不支持将 DataFrame 写入原始文件。

