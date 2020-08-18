# 官网：LanguageManual SortBy

[TOC]

## 1、Order, Sort, Cluster, and Distribute By

*This describes the syntax of SELECT clauses ORDER BY, SORT BY, CLUSTER BY, and DISTRIBUTE BY.  See [Select Syntax](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select#LanguageManualSelect-SelectSyntax) for general information.*

```sql
[WITH CommonTableExpression (, CommonTableExpression)*]    (Note: Only available starting with Hive 0.13.0)
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
  FROM table_reference
  [WHERE where_condition]
  [GROUP BY col_list]
  [ORDER BY col_list]
  [CLUSTER BY col_list
    | [DISTRIBUTE BY col_list] [SORT BY col_list]
  ]
 [LIMIT [offset,] rows]
```

### 1.1、Syntax of Order By

*The ORDER BY syntax in Hive QL is similar to the syntax of ORDER BY in SQL language.*

类似于 SQL 中的 ORDER BY

```sql
colOrder: ( ASC | DESC )
colNullOrder: (NULLS FIRST | NULLS LAST)           -- (Note: Available in Hive 2.1.0 and later)
orderBy: ORDER BY colName colOrder? colNullOrder? (',' colName colOrder? colNullOrder?)*

query: SELECT expression (',' expression)* FROM src orderBy
```
*There are some limitations in the "order by" clause. In the strict mode (i.e., [hive.mapred.mode](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.mapred.mode)=strict), the order by clause has to be followed by a "limit" clause. The limit clause is not necessary if you set hive.mapred.mode to nonstrict. The reason is that in order to impose total order of all results, there has to be one reducer to sort the final output. If the number of rows in the output is too large, the single reducer could take a very long time to finish.*

使用 order by 有限制。

如果设置了 `hive.mapred.mode=strict` ，那么 order by 子句必须跟在 limit 子句后。如果没有设置，那么就无所谓。

原因是，为了能使所有的结果全局有序，必须有一个 reducer 去排序，得到最终输出。如果输出的行数很大，单个 reducer 会花费很长时间排序。

*Note that columns are specified by name, not by position number. However in [Hive 0.11.0](https://issues.apache.org/jira/browse/HIVE-581) and later, columns can be specified by position when configured as follows:*

注意：要用列名来指定，而不能是列的位置标号。

在 Hive 0.11.0 及之后的版本，如果配置了如下属性，那么就可以用列的位置标号指定。

- Hive 0.11.0 到 2.1.x，设置 `hive.groupby.orderby.position.alias=true`

- Hive 2.2.0及之后的版本，设置 `ive.orderby.position.alias=true`

*For Hive 0.11.0 through 2.1.x, set [hive.groupby.orderby.position.alias](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.groupby.orderby.position.alias) to true (the default is false).*

*For Hive 2.2.0 and later, [hive.orderby.position.alias](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.orderby.position.alias) is true by default.*

*The default sorting order is ascending (ASC).*

默认是升序排序。

*In [Hive 2.1.0](https://issues.apache.org/jira/browse/HIVE-12994) and later, specifying the null sorting order for each of the columns in the "order by" clause is supported. The default null sorting order for ASC order is NULLS FIRST, while the default null sorting order for DESC order is NULLS LAST.*

在 Hive 2.1.0 及之后的版本，可以在 order by 子句指定 null sorting order。对于 ASC ，默认是 NULLS FIRST。对于 DESC ，默认是 NULLS LAST。

[如果Order by 中指定了表达式Nulls first则表示null值的记录将排在最前.
如果Order by 中指定了表达式Nulls last则表示null值的记录将排在最后](https://blog.csdn.net/q3dxdx/article/details/49029543?utm_source=blogxgwz9)

*In [Hive 3.0.0](https://issues.apache.org/jira/browse/HIVE-6348) and later, order by without limit in [subqueries](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+SubQueries) and [views](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-Create/Drop/AlterView) will be removed by the optimizer. To disable it, set [hive.remove.orderby.in.subquery](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.remove.orderby.in.subquery) to false.*

在 Hive 3.0.0 及之后的版本，在子句查询和视图中，没有 limit 的 order by 将被优化器移除。可以设置 `hive.remove.orderby.in.subquery=false` 来取消这个功能。


### 1.2、Syntax of Sort By

The SORT BY syntax is similar to the syntax of ORDER BY in SQL language.

类似于 SQL 中的 ORDER BY

```sql
colOrder: ( ASC | DESC )
sortBy: SORT BY colName colOrder? (',' colName colOrder?)*

query: SELECT expression (',' expression)* FROM src sortBy
```

*Hive uses the columns in SORT BY to sort the rows before feeding the rows to a reducer. The sort order will be dependent on the column types. If the column is of numeric type, then the sort order is also in numeric order. If the column is of string type, then the sort order will be lexicographical order.*

Hive 使用 SORT BY 指定的列来排序行，在行传给 reducer 前。

排序规则依赖于列的类型。如果是数值类型，把么排序规则就是数值排序。如果是字符串类型，那么就是字典顺序。

*In [Hive 3.0.0](https://issues.apache.org/jira/browse/HIVE-6348)  and later, sort by without limit in [subqueries](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+SubQueries) and [views](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-Create/Drop/AlterView) will be removed by the optimizer. To disable it, set [hive.remove.orderby.in.subquery](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.remove.orderby.in.subquery) to false.*

#### 1.2.1、Difference between Sort By and Order By

*Hive supports SORT BY which sorts the data per reducer. The difference between "order by" and "sort by" is that the former guarantees total order in the output while the latter only guarantees ordering of the rows within a reducer. If there are more than one reducer, "sort by" may give partially ordered final results.*

SORT BY 排序每个 reducer 中的数据。

order by 和 sort by 的区别就是：

- order by 保证了输出数据的**全局有序**。

- sort by 保证了每个 reducer 中的行有序。

若超过了一个 reducer ，sort by 的结果可能是**部分有序**。

*Note: It may be confusing as to the difference between SORT BY alone of a single column and CLUSTER BY. The difference is that CLUSTER BY partitions by the field and SORT BY if there are multiple reducers partitions randomly in order to distribute data (and load) uniformly across the reducers.*

*Basically, the data in each reducer will be sorted according to the order that the user specified. The following example shows*

```sql
SELECT key, value FROM src SORT BY key ASC, value DESC
```

*The query had 2 reducers, and the output of each is:*

	0   5
	0   3
	3   6
	9   1


	0   4
	0   3
	1   1
	2   5

#### 1.2.2、Setting Types for Sort By

*After a transform, variable types are generally considered to be strings, meaning that numeric data will be sorted lexicographically. To overcome this, a second SELECT statement with casts can be used before using SORT BY.*

transform 之后，变量类型通常一致当成字符串，就意味着，数值数据按照字段顺序排序。

为避免这个，在 SORT BY 前，第二个 SELECT 语句加上 cast

```sql
FROM (FROM (FROM src
            SELECT TRANSFORM(value)
            USING 'mapper'
            AS value, count) mapped
      SELECT cast(value as double) AS value, cast(count as int) AS count
      SORT BY value, count) sorted
SELECT TRANSFORM(value, count)
USING 'reducer'
AS whatever
```

### 1.3、Syntax of Cluster By and Distribute By

*Cluster By and Distribute By are used mainly with the [Transform/Map-Reduce Scripts](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Transform). But, it is sometimes useful in SELECT statements if there is a need to partition and sort the output of a query for subsequent queries.*

Cluster By 和 Distribute By 主要用在 Transform/Map-Reduce Scripts 中。但有时用在 SELECT 语句中也是可以的。

*Cluster By is a short-cut for both Distribute By and Sort By.*

Cluster By 等同于 Distribute By and Sort By。

*Hive uses the columns in Distribute By to distribute the rows among reducers. All rows with the same Distribute By columns will go to the same reducer. However, Distribute By does not guarantee clustering or sorting properties on the distributed keys.*

Hive 使用 Distribute By 在 reducers 间分发行数据。具有相同 Distribute By 的列的行数据进入同一个 reducer。它并不保证根据分发的 key 进行分类或排序。

*For example, we are Distributing By x on the following 5 rows to 2 reducer:*

	x1
	x2
	x4
	x3
	x1

*Reducer 1 got*

	x1
	x2
	x1

*Reducer 2 got*

	x4
	x3

*Note that all rows with the same key x1 is guaranteed to be distributed to the same reducer (reducer 1 in this case), but they are not guaranteed to be clustered in adjacent positions.*

注意：所有具有相同 key x1 的行被分发到同一个 reducer，但并没保证被 clustered 到相邻位置。

*In contrast, if we use Cluster By x, the two reducers will further sort rows on x:*

*Reducer 1 got*

	x1
	x1
	x2

*Reducer 2 got*

	x3
	x4

*Instead of specifying Cluster By, the user can specify Distribute By and Sort By, so the partition columns and sort columns can be different. The usual case is that the partition columns are a prefix of sort columns, but that is not required*

除了 Cluster By，用户可以使用 Distribute By 和 Sort By，这样分区列和排序列就可以不同了。

通常情况，分区列是排序列的前缀，但不是必须的。

```sql
SELECT col1, col2 FROM t1 CLUSTER BY col1
```

```sql
SELECT col1, col2 FROM t1 DISTRIBUTE BY col1
 
SELECT col1, col2 FROM t1 DISTRIBUTE BY col1 SORT BY col1 ASC, col2 DESC
```

```sql
FROM (
  FROM pv_users
  MAP ( pv_users.userid, pv_users.date )
  USING 'map_script'
  AS c1, c2, c3
  DISTRIBUTE BY c2
  SORT BY c2, c1) map_output
INSERT OVERWRITE TABLE pv_users_reduced
  REDUCE ( map_output.c1, map_output.c2, map_output.c3 )
  USING 'reduce_script'
  AS date, count;
```