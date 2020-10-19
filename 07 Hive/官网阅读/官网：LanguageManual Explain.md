# 官网：LanguageManual Explain

[TOC]

[explain plan](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Explain)

## 1、EXPLAIN Syntax

EXPLAIN 命令展示查询的执行计划。

	EXPLAIN [EXTENDED|CBO|AST|DEPENDENCY|AUTHORIZATION|LOCKS|VECTORIZATION|ANALYZE] query

*The use of EXTENDED in the EXPLAIN statement produces extra information about the operators in the plan. This is typically physical information like file names.*

EXTENDED 参数可以输出操作的额外信息。这通常是物理信息，如文件名。

*A Hive query gets converted into a sequence (it is more a Directed Acyclic Graph) of stages. These stages may be map/reduce stages or they may even be stages that do metastore or file system operations like move and rename. The explain output has three parts:*

一个 Hive 查询会转换成一个个阶段。这些阶段可以是 map/reduce ，也可以是操作元数据的阶段，也可以是像移除和重命名这样的文件系统操作行为。

explain 的输出由以下三部分组成：

- 查询的抽象语法树
- 不同阶段间的依赖关系
- 对每个阶段的描述

*The Abstract Syntax Tree for the query
The dependencies between the different stages of the plan
The description of each of the stages*

*The description of the stages itself shows a sequence of operators with the metadata associated with the operators. The metadata may comprise things like filter expressions for the FilterOperator or the select expressions for the SelectOperator or the output file names for the FileSinkOperator.*

阶段本身的描述显示了一系列操作元数据的操作符。元数据可以包括 FilterOperator 的过滤表达式、 SelectOperator 的选择表达式或 FileSinkOperator 的输出文件名等内容。

### 1.1、Example

As an example, consider the following EXPLAIN query:

	EXPLAIN
	FROM src INSERT OVERWRITE TABLE dest_g1 SELECT src.key, sum(substr(src.value,4)) GROUP BY src.key;

The output of this statement contains the following parts:

- The Dependency Graph 依赖关系图

		STAGE DEPENDENCIES:
		  Stage-1 is a root stage
		  Stage-2 depends on stages: Stage-1
		  Stage-0 depends on stages: Stage-2

This shows that Stage-1 is the root stage, Stage-2 is executed after Stage-1 is done and Stage-0 is executed after Stage-2 is done.

- The plans of each Stage 每个阶段的执行计划

		STAGE PLANS:
		  Stage: Stage-1
		    Map Reduce
		      Alias -> Map Operator Tree:
		        src
		            Reduce Output Operator
		              key expressions:
		                    expr: key
		                    type: string
		              sort order: +
		              Map-reduce partition columns:
		                    expr: rand()
		                    type: double
		              tag: -1
		              value expressions:
		                    expr: substr(value, 4)
		                    type: string
		      Reduce Operator Tree:
		        Group By Operator
		          aggregations:
		                expr: sum(UDFToDouble(VALUE.0))
		          keys:
		                expr: KEY.0
		                type: string
		          mode: partial1
		          File Output Operator
		            compressed: false
		            table:
		                input format: org.apache.hadoop.mapred.SequenceFileInputFormat
		                output format: org.apache.hadoop.mapred.SequenceFileOutputFormat
		                name: binary_table
		 
		  Stage: Stage-2
		    Map Reduce
		      Alias -> Map Operator Tree:
		        /tmp/hive-zshao/67494501/106593589.10001
		          Reduce Output Operator
		            key expressions:
		                  expr: 0
		                  type: string
		            sort order: +
		            Map-reduce partition columns:
		                  expr: 0
		                  type: string
		            tag: -1
		            value expressions:
		                  expr: 1
		                  type: double
		      Reduce Operator Tree:
		        Group By Operator
		          aggregations:
		                expr: sum(VALUE.0)
		          keys:
		                expr: KEY.0
		                type: string
		          mode: final
		          Select Operator
		            expressions:
		                  expr: 0
		                  type: string
		                  expr: 1
		                  type: double
		            Select Operator
		              expressions:
		                    expr: UDFToInteger(0)
		                    type: int
		                    expr: 1
		                    type: double
		              File Output Operator
		                compressed: false
		                table:
		                    input format: org.apache.hadoop.mapred.TextInputFormat
		                    output format: org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat
		                    serde: org.apache.hadoop.hive.serde2.dynamic_type.DynamicSerDe
		                    name: dest_g1
		 
		  Stage: Stage-0
		    Move Operator
		      tables:
		            replace: true
		            table:
		                input format: org.apache.hadoop.mapred.TextInputFormat
		                output format: org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat
		                serde: org.apache.hadoop.hive.serde2.dynamic_type.DynamicSerDe
		                name: dest_g1

*In this example there are 2 map/reduce stages (Stage-1 and Stage-2) and 1 File System related stage (Stage-0). Stage-0 basically moves the results from a temporary directory to the directory corresponding to the table dest_g1.
Sort order indicates the number of columns in key expressions that are used for sorting. Each "+" represents one column sorted in ascending order, and each "-" represents a column sorted in descending order.*

本例中，有两个 map/reduce 阶段和一个文件系统相关的阶段。 Stage-0 将结果从临时目录移动到表 dest_g1 对应的目录。

Sort order 表示 key expressions 中用于排序的列数。"+"表示按照一列升序排序，"-"表示按照一列降序排序。"++"表示按照两列升序排序。

*A map/reduce stage itself has 2 parts:*

一个 map/reduce 阶段包含两个部分：

(1)从 table alias 到 Map Operator Tree 的一个映射。这个映射告诉 mappers 调用哪个操作符树去处理特定表或前一个 map/reduce 阶段的结果的一行数据。上例中，在 Stage-1 中，src 表中的行数据由 Reduce Output Operator 处理。类似的，在 Stage-2 中，Stage-1 中的结果数据由另一个 Reduce Output Operator 处理。根据元数据中的规则，这些 Reduce Output Operator 把数据划分到不同 reducers 中。

(2)A Reduce Operator Tree. 这是处理 map/reduce job 中的 reducer 中的所有行数据。上例中，在 Stage-1 中的 Reducer Operator Tree 执行部分聚合，而 Stage-2 中的  Reducer Operator Tree 根据 Stage-1 中计算的部分聚合计算最终聚合。

	一些常见的Operator：
		TableScan 读取数据，常见的属性 alias
		Select Operator 选取操作
		Group By Operator 分组聚合，常见的属性 aggregations、mode，当没有keys属性时只有一个分组。
		Reduce Output Operator 输出结果给Reduce，常见的属性 sort order
		Fetch Operator 客户端获取数据，常见属性 limit

*A mapping from table alias to Map Operator Tree – This mapping tells the mappers which operator tree to call in order to process the rows from a particular table or result of a previous map/reduce stage. In Stage-1 in the above example, the rows from src table are processed by the operator tree rooted at a Reduce Output Operator. Similarly, in Stage-2 the rows of the results of Stage-1 are processed by another operator tree rooted at another Reduce Output Operator. Each of these Reduce Output Operators partitions the data to the reducers according to the criteria shown in the metadata.
A Reduce Operator Tree – This is the operator tree which processes all the rows on the reducer of the map/reduce job. In Stage-1 for example, the Reducer Operator Tree is carrying out a partial aggregation whereas the Reducer Operator Tree in Stage-2 computes the final aggregation from the partial aggregates computed in Stage-1.*

### 1.2、The CBO Clause

*The CBO clause outputs the plan generated by Calcite optimizer. It can optionally include information about the cost of the plan using Calcite default cost model and cost model used for join reordering. Since Hive release 4.0.0 (HIVE-17503 / HIVE-21184).*

CBO 子句输出 Calcite 优化器产生的执行计划。可以包含使用 Calcite 的默认成本模型和用于联接重排的成本模型执行的成本信息。

	Syntax: EXPLAIN [FORMATTED] CBO [COST|JOINCOST]

- COST 选项打印执行计划和使用 Calcite 的默认成本模型计算的成本信息。

- JOINCOST 选项打印执行计划和使用 Calcite 的用于联接重排的模型计算的成本信息。

*COST option prints the plan and cost calculated using Calcite default cost model.
JOINCOST option prints the plan and cost calculated using the cost model used for join reordering.
For example, we can execute the following statement:*


示例如下，执行下列语句：

	EXPLAIN CBO
	WITH customer_total_return AS
	(SELECT sr_customer_sk AS ctr_customer_sk,
	  sr_store_sk AS ctr_store_sk,
	  SUM(SR_FEE) AS ctr_total_return
	  FROM store_returns, date_dim
	  WHERE sr_returned_date_sk = d_date_sk
	    AND d_year =2000
	  GROUP BY sr_customer_sk, sr_store_sk)
	SELECT c_customer_id
	FROM customer_total_return ctr1, store, customer
	WHERE ctr1.ctr_total_return > (SELECT AVG(ctr_total_return)*1.2
	FROM customer_total_return ctr2
	WHERE ctr1.ctr_store_sk = ctr2.ctr_store_sk)
	  AND s_store_sk = ctr1.ctr_store_sk
	  AND s_state = 'NM'
	  AND ctr1.ctr_customer_sk = c_customer_sk
	ORDER BY c_customer_id
	LIMIT 100

The query will be optimized and Hive produces the following output:

	CBO PLAN:
	HiveSortLimit(sort0=[$0], dir0=[ASC], fetch=[100])
	  HiveProject(c_customer_id=[$1])
	    HiveJoin(condition=[AND(=($3, $7), >($4, $6))], joinType=[inner], algorithm=[none], cost=[not available])
	      HiveJoin(condition=[=($2, $0)], joinType=[inner], algorithm=[none], cost=[not available])
	        HiveProject(c_customer_sk=[$0], c_customer_id=[$1])
	          HiveFilter(condition=[IS NOT NULL($0)])
	            HiveTableScan(table=[[default, customer]], table:alias=[customer])
	        HiveJoin(condition=[=($3, $1)], joinType=[inner], algorithm=[none], cost=[not available])
	          HiveProject(sr_customer_sk=[$0], sr_store_sk=[$1], $f2=[$2])
	            HiveAggregate(group=[{1, 2}], agg#0=[sum($3)])
	              HiveJoin(condition=[=($0, $4)], joinType=[inner], algorithm=[none], cost=[not available])
	                HiveProject(sr_returned_date_sk=[$0], sr_customer_sk=[$3], sr_store_sk=[$7], sr_fee=[$14])
	                  HiveFilter(condition=[AND(IS NOT NULL($0), IS NOT NULL($7), IS NOT NULL($3))])
	                    HiveTableScan(table=[[default, store_returns]], table:alias=[store_returns])
	                HiveProject(d_date_sk=[$0])
	                  HiveFilter(condition=[AND(=($6, 2000), IS NOT NULL($0))])
	                    HiveTableScan(table=[[default, date_dim]], table:alias=[date_dim])
	          HiveProject(s_store_sk=[$0])
	            HiveFilter(condition=[AND(=($24, _UTF-16LE'NM'), IS NOT NULL($0))])
	              HiveTableScan(table=[[default, store]], table:alias=[store])
	      HiveProject(_o__c0=[*(/($1, $2), 1.2)], ctr_store_sk=[$0])
	        HiveAggregate(group=[{1}], agg#0=[sum($2)], agg#1=[count($2)])
	          HiveProject(sr_customer_sk=[$0], sr_store_sk=[$1], $f2=[$2])
	            HiveAggregate(group=[{1, 2}], agg#0=[sum($3)])
	              HiveJoin(condition=[=($0, $4)], joinType=[inner], algorithm=[none], cost=[not available])
	                HiveProject(sr_returned_date_sk=[$0], sr_customer_sk=[$3], sr_store_sk=[$7], sr_fee=[$14])
	                  HiveFilter(condition=[AND(IS NOT NULL($0), IS NOT NULL($7))])
	                    HiveTableScan(table=[[default, store_returns]], table:alias=[store_returns])
	                HiveProject(d_date_sk=[$0])
	                  HiveFilter(condition=[AND(=($6, 2000), IS NOT NULL($0))])
	                    HiveTableScan(table=[[default, date_dim]], table:alias=[date_dim])

In turn, we can execute the following command:

	EXPLAIN CBO COST
	WITH customer_total_return AS
	(SELECT sr_customer_sk AS ctr_customer_sk,
	  sr_store_sk AS ctr_store_sk,
	  SUM(SR_FEE) AS ctr_total_return
	  FROM store_returns, date_dim
	  WHERE sr_returned_date_sk = d_date_sk
	    AND d_year =2000
	  GROUP BY sr_customer_sk, sr_store_sk)
	SELECT c_customer_id
	FROM customer_total_return ctr1, store, customer
	WHERE ctr1.ctr_total_return > (SELECT AVG(ctr_total_return)*1.2
	FROM customer_total_return ctr2
	WHERE ctr1.ctr_store_sk = ctr2.ctr_store_sk)
	  AND s_store_sk = ctr1.ctr_store_sk
	  AND s_state = 'NM'
	  AND ctr1.ctr_customer_sk = c_customer_sk
	ORDER BY c_customer_id
	LIMIT 100

It will produce a similar plan, but the cost for each operator will be embedded next to the operator descriptors:

	CBO PLAN:
	HiveSortLimit(sort0=[$0], dir0=[ASC], fetch=[100]): rowcount = 100.0, cumulative cost = {2.395588892021712E26 rows, 1.197794434438787E26 cpu, 0.0 io}, id = 1683
	  HiveProject(c_customer_id=[$1]): rowcount = 1.1977944344387866E26, cumulative cost = {2.395588892021712E26 rows, 1.197794434438787E26 cpu, 0.0 io}, id = 1681
	    HiveJoin(condition=[AND(=($3, $7), >($4, $6))], joinType=[inner], algorithm=[none], cost=[not available]): rowcount = 1.1977944344387866E26, cumulative cost = {1.1977944575829254E26 rows, 4.160211553874922E10 cpu, 0.0 io}, id = 1679
	      HiveJoin(condition=[=($2, $0)], joinType=[inner], algorithm=[none], cost=[not available]): rowcount = 2.3144135067474273E18, cumulative cost = {2.3144137967122499E18 rows, 1.921860676139634E10 cpu, 0.0 io}, id = 1663
	        HiveProject(c_customer_sk=[$0], c_customer_id=[$1]): rowcount = 7.2E7, cumulative cost = {2.24E8 rows, 3.04000001E8 cpu, 0.0 io}, id = 1640
	          HiveFilter(condition=[IS NOT NULL($0)]): rowcount = 7.2E7, cumulative cost = {1.52E8 rows, 1.60000001E8 cpu, 0.0 io}, id = 1638
	            HiveTableScan(table=[[default, customer]], table:alias=[customer]): rowcount = 8.0E7, cumulative cost = {8.0E7 rows, 8.0000001E7 cpu, 0.0 io}, id = 1055
	        HiveJoin(condition=[=($3, $1)], joinType=[inner], algorithm=[none], cost=[not available]): rowcount = 2.1429754692105807E11, cumulative cost = {2.897408225471977E11 rows, 1.891460676039634E10 cpu, 0.0 io}, id = 1661
	          HiveProject(sr_customer_sk=[$0], sr_store_sk=[$1], $f2=[$2]): rowcount = 6.210443022113779E9, cumulative cost = {7.544327346205959E10 rows, 1.891460312135634E10 cpu, 0.0 io}, id = 1685
	            HiveAggregate(group=[{1, 2}], agg#0=[sum($3)]): rowcount = 6.210443022113779E9, cumulative cost = {6.92328304399458E10 rows, 2.8327405501500005E8 cpu, 0.0 io}, id = 1654
	              HiveJoin(condition=[=($0, $4)], joinType=[inner], algorithm=[none], cost=[not available]): rowcount = 6.2104430221137794E10, cumulative cost = {6.2246082040067795E10 rows, 2.8327405501500005E8 cpu, 0.0 io}, id = 1652
	                HiveProject(sr_returned_date_sk=[$0], sr_customer_sk=[$3], sr_store_sk=[$7], sr_fee=[$14]): rowcount = 4.198394835000001E7, cumulative cost = {1.4155904670000002E8 rows, 2.8311809440000004E8 cpu, 0.0 io}, id = 1645
	                  HiveFilter(condition=[AND(IS NOT NULL($0), IS NOT NULL($7), IS NOT NULL($3))]): rowcount = 4.198394835000001E7, cumulative cost = {9.957509835000001E7 rows, 1.15182301E8 cpu, 0.0 io}, id = 1643
	                    HiveTableScan(table=[[default, store_returns]], table:alias=[store_returns]): rowcount = 5.759115E7, cumulative cost = {5.759115E7 rows, 5.7591151E7 cpu, 0.0 io}, id = 1040
	                HiveProject(d_date_sk=[$0]): rowcount = 9861.615, cumulative cost = {92772.23000000001 rows, 155960.615 cpu, 0.0 io}, id = 1650
	                  HiveFilter(condition=[AND(=($6, 2000), IS NOT NULL($0))]): rowcount = 9861.615, cumulative cost = {82910.615 rows, 146099.0 cpu, 0.0 io}, id = 1648
	                    HiveTableScan(table=[[default, date_dim]], table:alias=[date_dim]): rowcount = 73049.0, cumulative cost = {73049.0 rows, 73050.0 cpu, 0.0 io}, id = 1043
	          HiveProject(s_store_sk=[$0]): rowcount = 230.04000000000002, cumulative cost = {2164.08 rows, 3639.04 cpu, 0.0 io}, id = 1659
	            HiveFilter(condition=[AND(=($24, _UTF-16LE'NM'), IS NOT NULL($0))]): rowcount = 230.04000000000002, cumulative cost = {1934.04 rows, 3409.0 cpu, 0.0 io}, id = 1657
	              HiveTableScan(table=[[default, store]], table:alias=[store]): rowcount = 1704.0, cumulative cost = {1704.0 rows, 1705.0 cpu, 0.0 io}, id = 1050
	      HiveProject(_o__c0=[*(/($1, $2), 1.2)], ctr_store_sk=[$0]): rowcount = 6.900492246793088E8, cumulative cost = {8.537206083312463E10 rows, 2.2383508777352882E10 cpu, 0.0 io}, id = 1677
	        HiveAggregate(group=[{1}], agg#0=[sum($2)], agg#1=[count($2)]): rowcount = 6.900492246793088E8, cumulative cost = {8.468201160844533E10 rows, 2.1003410327994267E10 cpu, 0.0 io}, id = 1675
	          HiveProject(sr_customer_sk=[$0], sr_store_sk=[$1], $f2=[$2]): rowcount = 6.900492246793088E9, cumulative cost = {8.381945007759619E10 rows, 2.1003410327994267E10 cpu, 0.0 io}, id = 1686
	            HiveAggregate(group=[{1, 2}], agg#0=[sum($3)]): rowcount = 6.900492246793088E9, cumulative cost = {7.69189578308031E10 rows, 3.01933587615E8 cpu, 0.0 io}, id = 1673
	              HiveJoin(condition=[=($0, $4)], joinType=[inner], algorithm=[none], cost=[not available]): rowcount = 6.900492246793088E10, cumulative cost = {6.915590405316087E10 rows, 3.01933587615E8 cpu, 0.0 io}, id = 1671
	                HiveProject(sr_returned_date_sk=[$0], sr_customer_sk=[$3], sr_store_sk=[$7], sr_fee=[$14]): rowcount = 4.66488315E7, cumulative cost = {1.50888813E8 rows, 3.01777627E8 cpu, 0.0 io}, id = 1667
	                  HiveFilter(condition=[AND(IS NOT NULL($0), IS NOT NULL($7))]): rowcount = 4.66488315E7, cumulative cost = {1.042399815E8 rows, 1.15182301E8 cpu, 0.0 io}, id = 1665
	                    HiveTableScan(table=[[default, store_returns]], table:alias=[store_returns]): rowcount = 5.759115E7, cumulative cost = {5.759115E7 rows, 5.7591151E7 cpu, 0.0 io}, id = 1040
	                HiveProject(d_date_sk=[$0]): rowcount = 9861.615, cumulative cost = {92772.23000000001 rows, 155960.615 cpu, 0.0 io}, id = 1650
	                  HiveFilter(condition=[AND(=($6, 2000), IS NOT NULL($0))]): rowcount = 9861.615, cumulative cost = {82910.615 rows, 146099.0 cpu, 0.0 io}, id = 1648
	                    HiveTableScan(table=[[default, date_dim]], table:alias=[date_dim]): rowcount = 73049.0, cumulative cost = {73049.0 rows, 73050.0 cpu, 0.0 io}, id = 1043

### 1.3、The AST Clause

Outputs the query's Abstract Syntax Tree.  只输出抽象语法树

Example:

	EXPLAIN AST
	FROM src INSERT OVERWRITE TABLE dest_g1 SELECT src.key, sum(substr(src.value,4)) GROUP BY src.key;

Outputs:

	ABSTRACT SYNTAX TREE:
	  (TOK_QUERY (TOK_FROM (TOK_TABREF src)) (TOK_INSERT (TOK_DESTINATION (TOK_TAB dest_g1)) (TOK_SELECT (TOK_SELEXPR (TOK_COLREF src key)) (TOK_SELEXPR (TOK_FUNCTION sum (TOK_FUNCTION substr (TOK_COLREF src value) 4)))) (TOK_GROUPBY (TOK_COLREF src key))))

### 1.4、The DEPENDENCY Clause

*The use of DEPENDENCY in the EXPLAIN statement produces extra information about the inputs in the plan. It shows various attributes for the inputs. For example, for a query like:*

展示输入的多种属性。

	EXPLAIN DEPENDENCY
	  SELECT key, count(1) FROM srcpart WHERE ds IS NOT NULL GROUP BY key

the following output is produced:

	{"input_partitions":[{"partitionName":"default<at:var at:name="srcpart" />ds=2008-04-08/hr=11"},{"partitionName":"default<at:var at:name="srcpart" />ds=2008-04-08/hr=12"},{"partitionName":"default<at:var at:name="srcpart" />ds=2008-04-09/hr=11"},{"partitionName":"default<at:var at:name="srcpart" />ds=2008-04-09/hr=12"}],"input_tables":[{"tablename":"default@srcpart","tabletype":"MANAGED_TABLE"}]}

*The inputs contain both the tables and the partitions. Note that the table is present even if none of the partitions is accessed in the query.*

输入包含了表和分区。即使表中没有设置分区，表也会展现。

*The dependencies show the parents in case a table is accessed via a view. Consider the following queries:*

当一个表通过视图来访问时，会展示其父。【这个视图及其引用的表】

	CREATE VIEW V1 AS SELECT key, value from src;
	EXPLAIN DEPENDENCY SELECT * FROM V1;

The following output is produced:

	{"input_partitions":[],"input_tables":[{"tablename":"default@v1","tabletype":"VIRTUAL_VIEW"},{"tablename":"default@src","tabletype":"MANAGED_TABLE","tableParents":"[default@v1]"}]}

*As above, the inputs contain the view V1 and the table 'src' that the view V1 refers to.*

输入包含了视图 V1 和表 src。

*All the outputs are shown if a table is being accessed via multiple parents.*

当一个表通过一层层的视图来访问时，所有的输出都会展示。【这个视图及其引用的视图、表】

	CREATE VIEW V2 AS SELECT ds, key, value FROM srcpart WHERE ds IS NOT NULL;
	CREATE VIEW V4 AS
	  SELECT src1.key, src2.value as value1, src3.value as value2
	  FROM V1 src1 JOIN V2 src2 on src1.key = src2.key JOIN src src3 ON src2.key = src3.key;
	EXPLAIN DEPENDENCY SELECT * FROM V4;

The following output is produced.

	{"input_partitions":[{"partitionParents":"[default@v2]","partitionName":"default<at:var at:name="srcpart" />ds=2008-04-08/hr=11"},{"partitionParents":"[default@v2]","partitionName":"default<at:var at:name="srcpart" />ds=2008-04-08/hr=12"},{"partitionParents":"[default@v2]","partitionName":"default<at:var at:name="srcpart" />ds=2008-04-09/hr=11"},{"partitionParents":"[default@v2]","partitionName":"default<at:var at:name="srcpart" />ds=2008-04-09/hr=12"}],"input_tables":[{"tablename":"default@v4","tabletype":"VIRTUAL_VIEW"},{"tablename":"default@v2","tabletype":"VIRTUAL_VIEW","tableParents":"[default@v4]"},{"tablename":"default@v1","tabletype":"VIRTUAL_VIEW","tableParents":"[default@v4]"},{"tablename":"default@src","tabletype":"MANAGED_TABLE","tableParents":"[default@v4, default@v1]"},{"tablename":"default@srcpart","tabletype":"MANAGED_TABLE","tableParents":"[default@v2]"}]}

As can be seen, src is being accessed via parents v1 and v4.

### 1.5、The AUTHORIZATION Clause

*The use of AUTHORIZATION in the EXPLAIN statement shows all entities needed to be authorized to execute the query and authorization failures if any exist. For example, for a query like:*

所有实体都需要被授权才能执行查询，如果存在，则授权失败。

	EXPLAIN AUTHORIZATION
	  SELECT * FROM src JOIN srcpart;

the following output is produced:

	INPUTS:
	  default@srcpart
	  default@src
	  default@srcpart@ds=2008-04-08/hr=11
	  default@srcpart@ds=2008-04-08/hr=12
	  default@srcpart@ds=2008-04-09/hr=11
	  default@srcpart@ds=2008-04-09/hr=12
	OUTPUTS:
	  hdfs://localhost:9000/tmp/.../-mr-10000
	CURRENT_USER:
	  navis
	OPERATION:
	  QUERY
	AUTHORIZATION_FAILURES:
	  Permission denied: Principal [name=navis, type=USER] does not have following privileges for operation QUERY [[SELECT] on Object [type=TABLE_OR_VIEW, name=default.src], [SELECT] on Object [type=TABLE_OR_VIEW, name=default.srcpart]]

With the FORMATTED keyword, it will be returned in JSON format.

	"OUTPUTS":["hdfs://localhost:9000/tmp/.../-mr-10000"],"INPUTS":["default@srcpart","default@src","default@srcpart@ds=2008-04-08/hr=11","default@srcpart@ds=2008-04-08/hr=12","default@srcpart@ds=2008-04-09/hr=11","default@srcpart@ds=2008-04-09/hr=12"],"OPERATION":"QUERY","CURRENT_USER":"navis","AUTHORIZATION_FAILURES":["Permission denied: Principal [name=navis, type=USER] does not have following privileges for operation QUERY [[SELECT] on Object [type=TABLE_OR_VIEW, name=default.src], [SELECT] on Object [type=TABLE_OR_VIEW, name=default.srcpart]]"]}

### 1.6、The LOCKS Clause

*This is useful to understand what locks the system will acquire to run the specified query. Since Hive release 3.2.0 (HIVE-17683).*

这有助于理解系统将获取哪些锁来运行指定的查询。

For example

	EXPLAIN LOCKS UPDATE target SET b = 1 WHERE p IN (SELECT t.q1 FROM source t WHERE t.a1=5)

Will produce output like this.

	LOCK INFORMATION:
	default.source -> SHARED_READ
	default.target.p=1/q=2 -> SHARED_READ
	default.target.p=1/q=3 -> SHARED_READ
	default.target.p=2/q=2 -> SHARED_READ
	default.target.p=2/q=2 -> SHARED_WRITE
	default.target.p=1/q=3 -> SHARED_WRITE
	default.target.p=1/q=2 -> SHARED_WRITE

`EXPLAIN FORMATTED LOCKS <sql>` is also supported which will produce JSON encoded output.

### 1.7、The VECTORIZATION Clause

*Adds detail to the EXPLAIN output showing why Map and Reduce work is not vectorized. Since Hive release 2.3.0 (HIVE-11394).*

解释 Map 和 Reduce 工作为什么不需要矢量化

	Syntax: EXPLAIN VECTORIZATION [ONLY] [SUMMARY|OPERATOR|EXPRESSION|DETAIL]

- ONLY option suppresses most non-vectorization elements.
- SUMMARY (default) shows vectorization information for the PLAN (is vectorization enabled) and a summary of Map and Reduce work.
- OPERATOR shows vectorization information for operators. E.g. Filter Vectorization. Includes all information of SUMMARY.
- EXPRESSION shows vectorization information for expressions. E.g. predicateExpression. Includes all information of SUMMARY and OPERATOR.
- DETAIL shows detail-level vectorization information.  It includes all information of SUMMARY, OPERATOR, and EXPRESSION.

The optional clause defaults are not ONLY and SUMMARY.

See HIVE-11394 for more details and examples.

### 1.8、The ANALYZE Clause

Annotates the plan with actual row counts. Since in Hive 2.2.0 (HIVE-14362)

	Format is: (estimated row count) / (actual row count)

Example:

	For the below tablescan; the estimation was 500 rows; but actually the scan only yielded 13 rows.

	[...]
	              TableScan [TS_13] (rows=500/13 width=178)
	                Output:["key","value"]
	[...]

### 1.9、User-level Explain Output

Since HIVE-8600 in Hive 1.1.0, we support a user-level explain extended output for any query at the log4j INFO level after set[hive.log.explain.output](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.log.explain.output)=true (default is false).

Since HIVE-18469 in Hive 3.1.0, the user-level explain extended output for any query will be shown in the WebUI / Drilldown / Query Plan after set [hive.server2.webui.explain.output](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.server2.webui.explain.output)=true (default is false).

Since HIVE-9780 in Hive 1.2.0, we support a user-level explain for Hive on Tez users. After set [hive.explain.user](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.explain.user)=true (default is false) if the following query is sent, the user can see a much more clearly readable tree of operations.

Since HIVE-11133 in Hive 3.0.0, we support a user-level explain for Hive on Spark users. A separate configuration is used for Hive-on-Spark, [hive.spark.explain.user](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.spark.explain.user) which is set to false by default.

	EXPLAIN select sum(hash(key)), sum(hash(value)) from src_orc_merge_test_part where ds='2012-01-03' and ts='2012-01-03+14:46:31'

	Plan optimized by CBO.
	Vertex dependency in root stage
	Reducer 2 <- Map 1 (SIMPLE_EDGE)
	Stage-0
	   Fetch Operator
	      limit:-1
	      Stage-1
	         Reducer 2
	         File Output Operator [FS_8]
	            compressed:false
	            Statistics:Num rows: 1 Data size: 16 Basic stats: COMPLETE Column stats: NONE
	            table:{"serde:":"org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe","input format:":"org.apache.hadoop.mapred.TextInputFormat","output format:":"org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"}
	            Group By Operator [GBY_6]
	            |  aggregations:["sum(VALUE._col0)","sum(VALUE._col1)"]
	            |  outputColumnNames:["_col0","_col1"]
	            |  Statistics:Num rows: 1 Data size: 16 Basic stats: COMPLETE Column stats: NONE
	            |<-Map 1 [SIMPLE_EDGE]
	               Reduce Output Operator [RS_5]
	                  sort order:
	                  Statistics:Num rows: 1 Data size: 16 Basic stats: COMPLETE Column stats: NONE
	                  value expressions:_col0 (type: bigint), _col1 (type: bigint)
	                  Group By Operator [GBY_4]
	                     aggregations:["sum(_col0)","sum(_col1)"]
	                     outputColumnNames:["_col0","_col1"]
	                     Statistics:Num rows: 1 Data size: 16 Basic stats: COMPLETE Column stats: NONE
	                     Select Operator [SEL_2]
	                        outputColumnNames:["_col0","_col1"]
	                        Statistics:Num rows: 500 Data size: 47000 Basic stats: COMPLETE Column stats: NONE
	                        TableScan [TS_0]
	                           alias:src_orc_merge_test_part
	                           Statistics:Num rows: 500 Data size: 47000 Basic stats: COMPLETE Column stats: NONE