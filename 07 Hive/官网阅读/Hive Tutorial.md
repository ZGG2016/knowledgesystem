# Hive Tutorial

[TOC]

## 1、Concepts

### 1.1、What Is Hive

### 1.2、What Hive Is NOT

### 1.3、Getting Started

### 1.4、Data Units

*In the order of granularity - Hive data is organized into:*

hive 数据有如下组织形式：

*Databases: Namespaces function to avoid naming conflicts for tables, views, partitions, columns, and so on.  Databases can also be used to enforce security for a user or group of users.*

> 数据库：名称空间函数，以避免表、视图、分区、列等的命名冲突。数据库还可以用于为一个用户或一组用户实施安全性。

*Tables: Homogeneous units of data which have the same schema. An example of a table could be page_views table, where each row could comprise of the following columns (schema):*

*timestamp—which is of INT type that corresponds to a UNIX timestamp of when the page was viewed.
userid —which is of BIGINT type that identifies the user who viewed the page.
page_url—which is of STRING type that captures the location of the page.
referer_url—which is of STRING that captures the location of the page from where the user arrived at the current page.
IP—which is of STRING type that captures the IP address from where the page request was made.*

> 表：具有相同schema的同种数据单元。一个表的示例就是page_views表，表中每行都由下面的列组成：

		timestamp：INT类型，页面浏览时间
		userid：BIGINT类型，
		page_url：STRING类型，
		referer_url：STRING类型，
		IP：STRING类型，

*Partitions: Each Table can have one or more partition Keys which determines how the data is stored. Partitions—apart from being storage units—also allow the user to efficiently identify the rows that satisfy a specified criteria; for example, a date_partition of type STRING and country_partition of type STRING. Each unique value of the partition keys defines a partition of the Table. For example, all "US" data from "2009-12-23" is a partition of the page_views table. Therefore, if you run analysis on only the "US" data for 2009-12-23, you can run that query only on the relevant partition of the table, thereby speeding up the analysis significantly. Note however, that just because a partition is named 2009-12-23 does not mean that it contains all or only data from that date; partitions are named after dates for convenience; it is the user's job to guarantee the relationship between partition name and data content! Partition columns are virtual columns, they are not part of the data itself but are derived on load.*

> 分区：

每个表有一个或多个分区 key ，这些 key 决定了数据如何被存储。

**除了作为存储单元之外，分区还允许用户有效地标识满足指定条件的行**。例如，STRING 类型的 date_partition 和 STRING 类型的 country_partition。

**每个唯一的分区 key 对应表的一个分区**。例如，从"2009-12-23"开始的所有"US"下的数据都是 page_views 表的一个分区中的数据。

因此，如果基于"US"下2009-12-23的数据分析，你可以只在相关分区下执行查询。从而，可以**提高分析效率**。

然而，**仅仅因为一个分区命名为2009-12-23，并不意味着它包含或仅包含该日期的所有数据，分区以日期命名是为了方便。**

保证分区名和数据内容之间的关系是用户的工作!**分区列是虚拟列，它们不是数据本身的一部分**，而是在加载时派生的。

*Buckets (or Clusters): Data in each partition may in turn be divided into Buckets based on the value of a hash function of some column of the Table. For example the page_views table may be bucketed by userid, which is one of the columns, other than the partitions columns, of the page_view table. These can be used to efficiently sample the data.*

> 分桶:

**通过计算表的某些列的 hash 值，分区中的数据再被划分到桶中。这可以被用来高效地抽样数据。**

例如，page_views 表根据 userid 分桶，**userid 是 page_view 表的列之一，而不是分区列**。

*Note that it is not necessary for tables to be partitioned or bucketed, but these abstractions allow the system to prune large quantities of data during query processing, resulting in faster query execution.*

分区或分桶并不是必要的。但是这些抽象允许系统在查询处理期间删除大量数据，从而加快查询的执行。

### 1.5、Type System

### 1.6、Built In Operators and Functions

### 1.7、Language Capabilities

## 2、Usage and Examples

*NOTE: Many of the following examples are out of date.  More up to date information can be found in the [LanguageManual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual).*

### 2.1、Creating, Showing, Altering, and Dropping Tables

### 2.2、Loading Data

### 2.3、Querying and Inserting Data