# 官网：RDD Programming Guide

## 一、Overview

从一个高层次的角度来看，**每个 Spark application 都由一个驱动程序组成**。
这个驱动程序一个在集群上运行着用户的 **main 函数和执行着各种并行操作**。

Spark 提供的主要抽象是一个弹性分布式数据集 **RDD**，它是 **在集群中分区的、执行并行操作的元素集合**。

RDD 可以根据 **Hadoop 文件系统（或者任何其它 Hadoop 支持的文件系统）中的一个文件** 创建RRD，
也可以通过 **转换驱动程序中已存在的 Scala 集合**来创建RRD。

为了让RDD在整个并行操作中更高效的重用，Spark **persist（持久化）一个 RDD 到内存中**。

最后，**RDD 会自动的从节点故障中恢复**。

在 Spark 中的第二个抽象是能够用于并行操作的 **共享变量**，
默认情况下，当 Spark 的一个函数作为一组不同节点上的任务运行时，它 **将每个变量的副本应用到每个任务的函数中去**。
有时候，一个变量需要在多个任务间，或者在任务和驱动程序间来共享。

Spark 支持 **两种类型的共享变量：广播变量和累加器**。

	广播变量用于在所有节点上的内存中缓存一个值。
	累加器是一个只能被 “added（增加）” 的变量，例如 counters 和 sums。

本指南介绍了每一种 Spark 所支持的语言的特性。如果启动 Spark 的交互式 shell 来学习是很容易的，要么是 Scala shell[bin/spark-shell]，要么是Python shell[ bin/pyspark]。

## 二、Linking with Spark

#### (1)对于scala

#### (2)对于java

#### (3)对于python

Spark 3.0.0 支持 Python 2.7+ 或 Python 3.4+。可以使用标准的 CPython 解释器，那么像 NumPy 一样的C 库就可以使用了。 同时也支持 PyPy 2.3+。

注意：在Spark 3.0.0版本，Python 2 被弃用了。

在 Python 中配置运行 Spark applications 所需信息，既可以在 bin/spark-submit 脚本中添加，也可以在 setup.py 中添加如下内容：

	install_requires=[
		'pyspark=={site.SPARK_VERSION}'
	]

如果不是通过 `pip installing PySpark` 安装的 PySpark，可以使用 Spark 目录下的`bin/spark-submit` 脚本运行 Spark applications。这个脚本会载入 Spark 的 Java/Scala 库，并向集群提交应用程序。你也可以使用 `bin/pyspark` 启动一个 Python shell。


If you wish to access HDFS data, you need to use a build of PySpark linking to your version of HDFS. Prebuilt packages are also available on the Spark homepage for common HDFS versions.

Finally, you need to import some Spark classes into your program. Add the following line:

from pyspark import SparkContext, SparkConf
PySpark requires the same minor version of Python in both driver and workers. It uses the default python version in PATH, you can specify which version of Python you want to use by PYSPARK_PYTHON, for example:

$ PYSPARK_PYTHON=python3.4 bin/pyspark
$ PYSPARK_PYTHON=/opt/pypy-2.5/bin/pypy bin/spark-submit examples/src/main/python/pi.py