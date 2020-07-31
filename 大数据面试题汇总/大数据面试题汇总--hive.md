# 大数据面试题汇总--hive

[TOC]

## 数据仓库的架构分层

#### 为什么要分层：

(1) 随着企业业务的增加，企业数据量也随之增加，如果不有序、有结构的进行分类组织和存储，会给增加企业的管理成本。

(2) 分层可以给我们带来如下的好处：

	清晰数据结构：每一个数据分层都有它的作用域和职责，在使用表的时候能更方便地定位和理解

	减少重复开发：规范数据分层，开发一些通用的中间层数据，能够减少极大的重复计算

	统一数据口径：通过数据分层，提供统一的数据出口，统一对外输出的数据口径

	复杂问题简单化：将一个复杂的任务分解成多个步骤来完成，每一层解决特定的问题

#### 分层

![datawarehouse01](https://s1.ax1x.com/2020/07/03/NXfXa4.png)

(1)DB 是现有的数据来源，可以为mysql、SQLserver、文件日志等，为数据仓库提供数据来源的一般存在于现有的多个业务系统之中。

(2)ETL的是 Extract-Transform-Load 的缩写，用来描述将数据从来源迁移到目标的几个过程：

    Extract，数据抽取，把数据从数据源读出来。
    Transform，数据转换，把原始数据转换成期望的格式和维度。如果用在数据仓库的场景，Transform也包含数据清洗，清洗掉噪音数据。
    Load 数据加载，把处理后的数据加载到目标处，比如数据仓库。

(3)ODS(Operational Data Store) 操作性数据，直接从业务系统抽取过来的。（明细数据）

(4)DW (Data Warehouse)数据仓库，包括DWD、MID和DM(Data Mart)。DWD是清洗维度补充。MID进行轻度汇总和。DM按照部门或主题（特定用户群、特定主题）生成。

(5)APP（Application），面向用户应用和分析需求，包括前端报表、分析图表、KPI、仪表盘、OLAP、专题等分析，面向最终结果用户。

参考：[数据仓库--通用的数据仓库分层方法](https://www.cnblogs.com/itboys/p/10592871.html)
[干货：解码OneData，阿里的数仓之路](https://developer.aliyun.com/article/67011)

## 数据集出现数据缺失，怎么办 ##

(1)对于某属性的缺失量过大

	- 直接删除该属性；
	- 扩展该属性为更多属性，比如性别，有男、女、缺失三种情况，则映射成3个变量：是否男、是否女、是否缺失。好处是完整保留了原始数据的全部信息、不用考虑缺失值、不用考虑线性不可分之类的问题。缺点是计算量大大提升。

(2)对于某属性的缺失量不大

	填充：
		平均值、中值、分位数、众数、随机值、上下数据、插值法；(效果一般，因为等于人为增加了噪声。)
		算法拟合(有一个根本缺陷，如果其他变量和缺失变量无关，则预测的结果无意义。如果预测结果相当准确，则又说明这个变量是没必要加入建模的。)

参考：[机器学习中如何处理缺失数据](https://www.zhihu.com/question/26639110)

## hive优缺点

优点：

- 高可靠、高容错

    HIVE Sever采用:主备模式。有主有从。当主机挂掉，备机马上启动。即【高可用】单点故障。
    双MetaStore
 
- 采用了 hive sql 语法，底层执行 mapreduce 任务，容易上手，适合于批量处理海量数据

- 支持 UDF\UDAF\UDTF 来扩展用户程序。

    UDF：user defined functions 
    UDAF： user defined aggregates 
    UDTF：user defined table functions

- 自定义存储格式

    in the file_format to specify the name of a corresponding InputFormat and OutputFormat class as a string literal.

    For example, 'org.apache.hadoop.hive.contrib.fileformat.base64.Base64TextInputFormat'. 

- 多接口
    
    Hive Client：JDBC、ODBC、Thrift
    HiveServer2：Beeline

缺点：

    正是由于底层执行 mapreduce 任务，所以延迟性高。
    不适合联机事务处理


扩展阅读：

[Hive安装配置 metastore的三种配置方式详解](https://blog.csdn.net/u014414323/article/details/80862258?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param)
[Hive多Metastore](https://www.cnblogs.com/feiyuanxing/p/10043626.html)
[UDF\UDAF\UDTF创建](https://www.jianshu.com/p/61ddcd25e6d1)
[Hive 自定义数据格式](https://www.cnblogs.com/sowhat1412/p/12734268.html)

## hive和传统数据库的区别

(1)存储

    hive的数据存储在hdfs上，所以具有很好的扩展性，适合于海量数据的存储。
    数据库存储在本地文件系统。相比hive，扩展有限。

(2)执行引擎

    hive默认的执行引擎是mapreduce，但可以是spark。
    数据库有自己的执行引擎，如InnoDB、MyIsam

(3)延迟性

    当hive使用mapreduce时，会具有一定的延迟。相对的，数据库的延迟较低。

    当然，这个低是有条件的，即数据规模较小，当数据规模大到超过数据库的处理能力的时候，Hive的并行计算显然能体现出优势。  

(4)数据更新

    由于 Hive是针对数据仓库应用设计的，而数据仓库的内容是读多写少的。
    因此，Hive中不支持对数据的改写和添加，所有的数据都是在加载的时候中确定好的。
    而数据库中的数据通常是需要经常进行修改的，因此可以使用 INSERT INTO ...  VALUES添加数据，使用 UPDATE ... SET修改数据。

(5)查询语言

     Hive是类 SQL的查询语言 HQL。熟悉 SQL开发的开发者可以很方便的使用 Hive进行开发。

(6)数据格式

    Hive 中没有定义专门的数据格式，数据格式可以由用户指定。支持关系型数据中大多数基本数据类型。
    数据库中，不同的数据库有不同的存储引擎，定义了自己的数据格式。所有数据都会按照一定的组织存储，因此，数据库加载数据的过程会比较耗时。

(7)索引

    Hive要访问数据中满足条件的特定值时，需要暴力扫描整个数据，因此访问延迟较高。由于 MapReduce的引入，Hive可以并行访问数据，因此即使没有索引，对于大数据量的访问，Hive仍然可以体现出优势。

    数据库中，通常会针对一个或者几个列建立索引，因此对于少量的特定条件的数据的访问，数据库可以有很高的效率，较低的延迟。由于数据的访问延迟较高，决定了 Hive不适合在线数据查询。

原文链接：[Hive与传统数据库对比](https://blog.csdn.net/nisjlvhudy/article/details/47175705)

扩展阅读：[MySQL执行引擎对比与SQL优化](https://blog.csdn.net/qq_38258310/article/details/94468604)

## hive往表中导入数据的方式

1、load data [local] inpath "path/file.txt" overwrite into table 表名

    (1)从本地导入
            load data local inpath "path/file.txt" into table 表名;
    (2)从hdfs导入
            load data inpath "path/file.txt" into table 表名;

2、使用hadoop fs -put ... 导入到hive表的路径上

3、insert into(overwrite) table 表名 select_statement1 FROM from_statement

从Hive表导出数据方式

1、insert overwrite [local] directory "path"  select * from tablename;

    (1)insert overwrite local directory "path/" select * from db_hive_demo.emp ;
    (2)insert overwrite  directory 'hdfs://hadoop102:8020/user/hive/warehouse/emp2/emp2'  select * from emp where empno >7800;

2、Bash shell覆盖追加导出

    例如：$ bin/hive -e "select * from staff;"  > /home/z/backup.log

3、Sqoop把hive数据导出到外部

原文链接：[往HIVE表中导入导出数据的几种方式详解](https://blog.csdn.net/qq_26442553/article/details/79478839)

## hive分区

在 Hive Select 查询中一般会扫描整个表内容，会消耗很多时间做没必要的工作。
但有时候只需要扫描表中关心的一部分数据，因此建表时引入了分区概念。

分区表指的是在创建表时指定分区的空间。
   
一个表可以拥有一个或者多个分区，每个分区以文件夹的形式单独存在表文件夹的目录下。分区的键对应的一个唯一值定义表的一个分区。

Partition columns are virtual columns, they are not part of the data itself but are derived on load.

创建分区：

    单分区建表语句：create table day_table (id int, content string) partitioned by (dt string); 按天分区，在表结构中存在id，content，dt三列。
    
    双分区建表语句：create table day_hour_table (id int, content string) partitioned by (dt string, hour string);

数据加载：

    LOAD DATA [LOCAL] INPATH 'filepath' [OVERWRITE] INTO TABLE tablename [PARTITION (partcol1=val1, partcol2=val2 ...)]
    
    例：
        LOAD DATA INPATH '/user/pv.txt' INTO TABLE day_hour_table PARTITION(dt='2008-08- 08', hour='08');
        
        LOAD DATA local INPATH '/user/hua/*' INTO TABLE day_hour partition(dt='2010-07- 07');

添加分区：
            
    ALTER TABLE table_name ADD partition_spec [ LOCATION 'location1' ] partition_spec [ LOCATION 'location2' ] ... partition_spec: : PARTITION (partition_col = partition_col_value, partition_col = partiton_col_value, ...)
            
    用户可以用 ALTER TABLE ADD PARTITION 来向一个表中增加分区。

    当分区名是字符串时加引号。例：
        
    ALTER TABLE day_table ADD PARTITION (dt='2008-08-08', hour='08') location '/path/pv1.txt' PARTITION (dt='2008-08-08', hour='09') location '/path/pv2.txt';

删除分区语法：

    ALTER TABLE table_name DROP partition_spec, partition_spec,...
    
    用户可以用 ALTER TABLE DROP PARTITION 来删除分区。

    分区的元数据和数据将被一并删除。例：

    ALTER TABLE day_hour_table DROP PARTITION (dt='2008-08-08', hour='09');

修复分区

    就是重新同步hdfs上的分区信息。
    msck repair table table_name;

查询分区：

    show partitions table_name;

扩展阅读：

[Hive分区partition详解](https://blog.csdn.net/qq_36743482/article/details/78418343)
[Hive分区](https://blog.csdn.net/yidu_fanchen/article/details/77683558)
[hive分区（partition）](https://www.cnblogs.com/ilvutm/p/7152499.html)

## hive分桶

将表或分区组织成桶有以下几个目的：

(1)抽样更高效，因为在处理大规模的数据集时，在开发、测试阶段将所有的数据全部处理一遍可能不太现实，这时抽样就必不可少。

        抽样：
                SELECT * FROM table_name TABLESAMPLE(nPERCENT)；
                就是针对n%进行取样

        有了桶之后呢？
                SELECT * FROM film TABLESAMPLE(BUCKET x OUTOF y)
                    x：表示从哪一个桶开始抽样
                    y：抽样因素，必须是桶数的因子或者倍数,假设桶数是100那么y可以是200,10,20,25,5。
                       假设桶数是100，y=25时抽取(100/25) = 4个bucket数据;当y=200的时候(100/200) = 0.5个bucket的数据

(2)更好的查询处理效率。

        大表在JOIN的时候，效率低下。如果对两个表先分别按id分桶，那么相同id都会归入一个桶。
        那么此时再进行JOIN的时候是按照桶来JOIN的，那么大大减少了JOIN的数量。

创建分桶： 

在建立桶之前，需要设置hive.enforce.bucketing属性为true，使得hive能识别桶。

```sql
CREATE TABLE IF NOT EXISTS t_movie(id INT,name STRING,director STRING,country STRING,year STRING,month STRING
            )ROWFORMAT DELIMITED FIELDS TERMINATED BY ',';
            PARTITIONEDBY (area STRING)
            CLUSTERED BY (country) INTO 4 BUCKETS
            ROWFORMAT DELIMITED FIELDS TERMINATED BY ','
            STORED AS ORC;
```
导入数据：

```sql
INSERT INTO TABLE t_movie PARTITION(area='China') SELECT * FROM t_movie WHERE country = 'China';
```
