# Quick Start

**V3.0.0**

本教程是使用 Spark 的快速入门。首先通过 Spark 交互式的 shell（在 Python 或 Scala 中）来介绍 API，然后展示如何使用 Java，Scala 和 Python 来编写应用程序。

为了继续阅读本指南，首先从 [Spark 官网](https://spark.apache.org/downloads.html) 下载 Spark 的发行包。因为我们不使用 HDFS，所以你可以下载任一一个 Hadoop 版本的软件包。

请注意，**在 Spark 2.0 之前，Spark 的主要编程接口是弹性分布式数据集（RDD）。 在 Spark 2.0 之后，RDD 被 Dataset 替换** ，它是像 RDD 一样的 strongly-typed（强类型），但是更加优化。 RDD 接口仍然受支持，您可以在 [RDD programming guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html) 中获得更完整的参考。 但是，我们强烈建议您切换到使用 Dataset（数据集），其性能要更优于 RDD。 请参阅 [SQL programming guide](https://spark.apache.org/docs/latest/sql-programming-guide.html) 获取更多有关 Dataset 的信息。

备注：强类型语言中，所有基本数据类型（整型，字符型，浮点型等等）都作为该语言的一部分被预定义。程序中的所有变量和常量都必须借助这些数据类型来表示。数据和数据类型绑定，**在定义变量/常量时必须同时指出它的数据类型**。对数据可执行的操作也因数据类型的不同而异。

来源：[强类型解释](https://blog.csdn.net/u012689588/article/details/18901645)

## 1、Security 安全

默认情况下，Spark 的安全模式处于关闭状态。这意味着您在默认情况下容易受到攻击。在下载和运行 Spark 之前，请参阅 [Spark Security](https://spark.apache.org/docs/latest/security.html)。

## 2、Interactive Analysis with the Spark Shell 使用 Spark Shell 进行交互式分析

###	2.1、Basics 基础

Spark shell 提供了一种比较简单的方式、和一个强大的交互式数据分析工具，来学习该 API 。可以运行在 Scala（运行于 Java 虚拟机之上，并能很好的调用已有的 Java 类库）或者 Python 中。通过在 Spark 目录中运行以下的命令来启动它:

```sh
./bin/spark-shell    #scala
./bin/pyspark        #python
```
**对于scala**

Spark 的主要抽象是一个称为 Dataset 的分布式的 item 集合。**Datasets 可以从 Hadoop 的 InputFormats（例如 HDFS文件）或者通过其它的 Datasets 转换来创建。** 让我们从 Spark 源目录中的 README 文件来创建一个新的 Dataset:

```sh
scala> val textFile = spark.read.textFile("README.md")
textFile: org.apache.spark.sql.Dataset[String] = [value: string]
```

您可以直接从 Dataset 中获取值，通过对 Dataset 使用一些 actions（动作）或者 transform（转换） 可以获得一个新的 Dataset 。更多细节，请参阅 [API doc](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html)。

```sh
scala> textFile.count() // Number of items in this Dataset
res0: Long = 126 // May be different from yours as README.md will change over time, similar to other outputs

scala> textFile.first() // First item in this Dataset
res1: String = # Apache Spark
```

现在让我们由这个 Dataset 转换获得一个新的 Dataset 。我们调用 filter 来返回一个新的 Dataset，这个 Dataset 是文件中所有行的一个子集。

```sh
scala> val linesWithSpark = textFile.filter(line => line.contains("Spark"))
linesWithSpark: org.apache.spark.sql.Dataset[String] = [value: string]
We can chain together transformations and actions:

scala> textFile.filter(line => line.contains("Spark")).count() // How many lines contain "Spark"?
res3: Long = 15
```

**对于python**

如果在当前环境下使用 pip 安装了 PySpark，可以这么启动：

```sh
pyspark
```
Spark 的主要抽象是一个称为 Dataset 的分布式的 item 集合。**Datasets 可以从 Hadoop 的 InputFormats（例如 HDFS文件）或者通过其它的 Datasets 转换来创建。** 由于 Python 具有动态特性，所以在 Python 中不需要是 Datasets 是强类型。**在 Python 中，所有的 Datasets 都是 Dataset[Row] ，我们称它为 DataFrame** ，以和 Pandas 和 R 中的 data frame 概念 一致。让我们从 Spark 源目录中的 README 文件来创建一个新的 DataFrame:

```sh
>>> textFile = spark.read.text("README.md")
```

您可以直接从 DataFrame 中获取值，通过对 DataFrame 使用一些 actions（动作）或者 transform（转换） 可以获得一个新的 DataFrame 。更多细节，请参阅 [API doc](https://spark.apache.org/docs/latest/api/python/index.html#pyspark.sql.DataFrame)。

```sh
>>> textFile.count()  # Number of rows in this DataFrame
126

>>> textFile.first()  # First row in this DataFrame
Row(value=u'# Apache Spark')
```

现在让我们由这个 DataFrame 转换获得一个新的 DataFrame。我们调用 filter 来返回一个新的 DataFrame，这个 DataFrame 是文件中所有行的一个子集。

```sh
>>> linesWithSpark = textFile.filter(textFile.value.contains("Spark"))
```

可以链式操作 transformation（转换）和 action（动作）:

```sh
>>> textFile.filter(textFile.value.contains("Spark")).count()  # How many lines contain "Spark"?
15
```

### 2.2、More on Dataset Operations

Dataset actions（操作）和 transformations（转换）可以用于更复杂的计算。例如，统计字数最多的行 :

**对于scala**

```sh
scala> textFile.map(line => line.split(" ").size).reduce((a, b) => if (a > b) a else b)
res4: Long = 15
```

第一个 map 操作创建一个新的 Dataset，将一行数据映射为一个整型值。在 Dataset 上调用 reduce 来找到字数最多的行。map 与 reduce 的参数是 Scala 函数的字面量（closures），并且可以使用任何语言特性或者 Scala/Java 库。例如，我们可以很容易地调用函数声明，我们将定义一个 max 函数来使代码更易于理解 :

```sh
scala> import java.lang.Math
import java.lang.Math

scala> textFile.map(line => line.split(" ").size).reduce((a, b) => Math.max(a, b))
res5: Int = 15
```

一种常见的数据流模式是被 Hadoop 所推广的 MapReduce。Spark 可以很容易实现 MapReduce:

```sh
scala> val wordCounts = textFile.flatMap(line => line.split(" ")).groupByKey(identity).count()
wordCounts: org.apache.spark.sql.Dataset[(String, Long)] = [value: string, count(1): bigint]
```

在这里，我们调用了 flatMap 以转换一个 lines 的 Dataset 为一个 words 的 Dataset，然后结合 groupByKey 和 count 来计算文件中每个单词的 counts ，结果以一个 (String, Long) 的 Dataset pairs 的形式输出。要在 shell 中收集 word counts，我们可以调用 collect:

```sh
scala> wordCounts.collect()
res6: Array[(String, Int)] = Array((means,1), (under,2), (this,3), (Because,1), (Python,2), (agree,1), (cluster.,1), ...)
```

**对于python**

```sh
>>> from pyspark.sql.functions import *
>>> textFile.select(size(split(textFile.value, "\s+")).name("numWords")).agg(max(col("numWords"))).collect()
[Row(max(numWords)=15)]
```

首先创建一个新的 DataFrame，将一行数据映射为一个整型值，命名为 “numWords”。在 DataFrame 上调用 agg 方法找到字数最多的行。select 和 agg 的参数都是 Column。我们可以使用 df.colName 来获取一行。我们也可以导入 pyspark.sql.functions，它提供了很多从旧的 Column 便利的构建新 Column 的方法。

一种常见的数据流模式是被 Hadoop 所推广的 MapReduce。Spark 可以很容易实现 MapReduce:

```sh
>>> wordCounts = textFile.select(explode(split(textFile.value, "\s+")).alias("word")).groupBy("word").count()
```

这里，我们在 select 使用了 explode 方法，来转换一个 lines 的 Dataset 到 words 的 Dataset。然后结合 groupBy 和 count，计算文件中每个单词的计数，生成的结果为两行的 DataFrame：“word” and “count”。要在 shell 中收集 word counts，我们可以调用 collect:

```sh
>>> wordCounts.collect()
[Row(word=u'online', count=1), Row(word=u'graphs', count=1), ...]
```

### 2.3、Caching 缓存

Spark 还支持 **Pulling（拉取）数据集到一个群集范围的内存缓存中**。在数据被重复访问时是非常高效的，例如当查询一个小的 “hot” 数据集或运行一个像 PageRANK 这样的迭代算法时。举一个简单的例子，让我们拉取 linesWithSpark 数据集到缓存中:

```sh
scala> linesWithSpark.cache()
res7: linesWithSpark.type = [value: string]

scala> linesWithSpark.count()
res8: Long = 15

scala> linesWithSpark.count()
res9: Long = 15
```

```sh
# python
>>> linesWithSpark.cache()

>>> linesWithSpark.count()
15

>>> linesWithSpark.count()
15
```

使用 Spark 来探索和缓存一个 100 行的文本文件看起来比较愚蠢。有趣的是，即使在他们跨越几十或者几百个节点时，这些相同的函数也可以用于非常大的数据集。您也可以通过连接 bin/spark-shell 或 bin/pyspark 到集群中，使用交互式的方式来做这件事情，详情请见 [RDD programming guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html#using-the-shell)。

## 3、Self-Contained Applications 独立的应用

假设我们希望使用 Spark API 来创建一个独立的应用程序。我们在 Scala（SBT），Java（Maven）和 Python 中练习一个简单应用程序。

**对于scala**

SimpleApp.scala:我们将在 Scala 中创建一个非常简单的 Spark 应用程序，名为 SimpleApp.scala:

```scala
/* SimpleApp.scala */
import org.apache.spark.sql.SparkSession

object SimpleApp {
  def main(args: Array[String]) {
    val logFile = "YOUR_SPARK_HOME/README.md" // Should be some file on your system
    val spark = SparkSession.builder.appName("Simple Application").getOrCreate()
    val logData = spark.read.textFile(logFile).cache()
    val numAs = logData.filter(line => line.contains("a")).count()
    val numBs = logData.filter(line => line.contains("b")).count()
    println(s"Lines with a: $numAs, Lines with b: $numBs")
    spark.stop()
  }
}
```

注意，这个应用程序我们应该定义一个 main() 方法而不是去扩展 scala.App。使用 scala.App 的子类可能不会正常运行。

该程序仅仅统计了 Spark README 文件中包含 ‘a’ 的数量和包含 ‘b’ 的行数。注意，您需要将 YOUR_SPARK_HOME 替换为您 Spark 安装的位置。不像先前使用 spark shell 操作的示例，它们初始化了它们自己的 SparkContext，我们在应用程序里初始化了一个 SparkContext。

我们调用 SparkSession.builder 以构造一个 SparkSession，然后设置 application name（应用名称），最终调用 getOrCreate 以获得 SparkSession 实例。

我们的应用依赖了 Spark API，所以我们将包含一个名为 build.sbt 的 sbt 配置文件，它描述了 Spark 的依赖。该文件也会添加一个 Spark 依赖的 repository:

```
name := "Simple Project"

version := "1.0"

scalaVersion := "2.12.10"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.0.0"
```
为了让 sbt 正常的运行，我们需要根据经典的目录结构来布局 SimpleApp.scala 和 build.sbt 文件。在完成后，我们可以创建一个包含应用程序代码的 JAR 包，然后使用 spark-submit 脚本来运行我们的程序。

```sh
# Your directory layout should look like this
$ find .
.
./build.sbt
./src
./src/main
./src/main/scala
./src/main/scala/SimpleApp.scala

# Package a jar containing your application
$ sbt package
...
[info] Packaging {..}/{..}/target/scala-2.12/simple-project_2.12-1.0.jar

# Use spark-submit to run your application
$ YOUR_SPARK_HOME/bin/spark-submit \
  --class "SimpleApp" \
  --master local[4] \
  target/scala-2.12/simple-project_2.12-1.0.jar
...
Lines with a: 46, Lines with b: 23
```
**对于java**

This example will use Maven to compile an application JAR, but any similar build system will work.
这个例子使用 Maven 来编译一个 application JAR，其他的构建系统（如Ant、Gradle，译者注）也可以。

我们会创建一个非常简单的Spark应用，SimpleApp.java:

```java
/* SimpleApp.java */
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Dataset;

public class SimpleApp {
  public static void main(String[] args) {
    String logFile = "YOUR_SPARK_HOME/README.md"; // Should be some file on your system
    SparkSession spark = SparkSession.builder().appName("Simple Application").getOrCreate();
    Dataset<String> logData = spark.read().textFile(logFile).cache();

    long numAs = logData.filter(s -> s.contains("a")).count();
    long numBs = logData.filter(s -> s.contains("b")).count();

    System.out.println("Lines with a: " + numAs + ", lines with b: " + numBs);

    spark.stop();
  }
}
```

这个程序计算 Spark README 文档中包含字母’a’和字母’b’的行数。注意把 YOUR_SPARK_HOME 修改成你的 Spark 的安装目录。跟使用的 Spark shell 运行的例子不同，我们需要在程序中初始化 SparkSession。

把 Spark 依赖添加到 Maven 的 pom.xml 文件里。 注意 Spark 的 artifacts 使用 Scala 版本进行标记。

```xml
<project>
  <groupId>edu.berkeley</groupId>
  <artifactId>simple-project</artifactId>
  <modelVersion>4.0.0</modelVersion>
  <name>Simple Project</name>
  <packaging>jar</packaging>
  <version>1.0</version>
  <dependencies>
    <dependency> <!-- Spark dependency -->
      <groupId>org.apache.spark</groupId>
      <artifactId>spark-sql_2.12</artifactId>
      <version>3.0.0</version>
      <scope>provided</scope>
    </dependency>
  </dependencies>
</project>
```

我们按照 Maven 经典的目录结构组织这些文件：

```sh
$ find .
./pom.xml
./src
./src/main
./src/main/java
./src/main/java/SimpleApp.java
```

现在我们用 Maven 打包这个应用，然后用./bin/spark-submit执行它。

```sh
# Package a JAR containing your application
$ mvn package
...
[INFO] Building jar: {..}/{..}/target/simple-project-1.0.jar

# Use spark-submit to run your application
$ YOUR_SPARK_HOME/bin/spark-submit \
  --class "SimpleApp" \
  --master local[4] \
  target/simple-project-1.0.jar
...
Lines with a: 46, Lines with b: 23
```

**对于python**

现在我们来展示如何用python API(pyspark) 来写一个应用。

如果要打包的PySpark应用程序或库，则可以添加以下内容到setup.py文件中：

```
    install_requires=[
        'pyspark=={site.SPARK_VERSION}'
    ]
```

我们以一个简单的例子为例，创建一个简单的pyspark 应用 SimpleApp.py:

```python
"""SimpleApp.py"""
from pyspark.sql import SparkSession

logFile = "YOUR_SPARK_HOME/README.md"  # Should be some file on your system
spark = SparkSession.builder.appName("SimpleApp").getOrCreate()
logData = spark.read.text(logFile).cache()

numAs = logData.filter(logData.value.contains('a')).count()
numBs = logData.filter(logData.value.contains('b')).count()

print("Lines with a: %i, lines with b: %i" % (numAs, numBs))

spark.stop()
```

该程序只是统计计算在该文本中包含a字母和包含b字母的行数. 请注意你需要将 YOUR_SPARK_HOME 替换成你的spark路径。就像 scala 示例和java示例一样，我们使用 SparkSession 来创建数据集，对于使用自定义类或者第三方库的应用程序，我们还 **可以通过 spark-submit 带着 --py-files 来添加代码依赖**，我们 **也可以通过把代码打成zip包来进行依赖添加 (详细请看 spark-submit --help )**. SimpleApp 是个简单的例子我们不需要添加特别的代码或自定义类.

我们可以 **通过 bin/spark-submit 脚本来运行应用**:

```sh
# Use spark-submit to run your application
$ YOUR_SPARK_HOME/bin/spark-submit \
  --master local[4] \
  SimpleApp.py
...
Lines with a: 46, Lines with b: 23
```

如果您的环境中已安装 pip install pyspark ，则可以使用常规 Python 解释器运行应用程序，也可以根据需要使用前面的 “spark-submit”。

```sh
# Use the Python interpreter to run your application
$ python SimpleApp.py
...
Lines with a: 46, Lines with b: 23
```

## 4、Where to Go from Here

更多 API 的深入概述，从 [RDD programming guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html) 和 [SQL programming guide](https://spark.apache.org/docs/latest/sql-programming-guide.html) 这里开始，或者看看 “编程指南” 菜单中的其它组件。

为了在集群上运行应用程序，请前往 [deployment overview](https://spark.apache.org/docs/latest/cluster-overview.html).

最后，在 Spark 的 examples 目录中包含了一些 ([Scala](https://github.com/apache/spark/tree/master/examples/src/main/scala/org/apache/spark/examples)，[Java](https://github.com/apache/spark/tree/master/examples/src/main/java/org/apache/spark/examples)，[Python](https://github.com/apache/spark/tree/master/examples/src/main/python)，[R](https://github.com/apache/spark/tree/master/examples/src/main/r)) 示例。您可以按照如下方式来运行它们:

```sh
# For Scala and Java, use run-example:
./bin/run-example SparkPi

# For Python examples, use spark-submit directly:
./bin/spark-submit examples/src/main/python/pi.py

# For R examples, use spark-submit directly:
./bin/spark-submit examples/src/main/r/dataframe.R
```

参考：[spark](https://home.apachecn.org/docs/)
