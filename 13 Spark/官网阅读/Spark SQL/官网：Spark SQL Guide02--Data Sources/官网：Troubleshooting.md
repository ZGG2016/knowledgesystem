# 官网：Spark SQL Guide03--Data Sources--Troubleshooting

*The JDBC driver class must be visible to the primordial class loader on the client session and on all executors. This is because Java’s DriverManager class does a security check that results in it ignoring all drivers not visible to the primordial class loader when one goes to open a connection. One convenient way to do this is to modify compute_classpath.sh on all worker nodes to include your driver JARs.*

- **JDBC 驱动类必须对 client session  和所有 executors 上的原始类装载器可见**。这是因为 Java 的 DriverManager 类会做了个安全检查，当打开连接时，它会忽略对原始类装载器不可见的所有驱动程序。**一种方便的方法是修改所有 worker 节点上的 `compute_classpath.sh`，以包含驱动 JARs。**

*Some databases, such as H2, convert all names to upper case. You’ll need to use upper case to refer to those names in Spark SQL.*

- 一些数据库，如 H2，将所有名称转换为大写。您需要**在 Spark SQL 中使用大写来引用这些名称**。

*Users can specify vendor-specific JDBC connection properties in the data source options to do special treatment. For example, spark.read.format("jdbc").option("url", oracleJdbcUrl).option("oracle.jdbc.mapDateToTimestamp", "false"). oracle.jdbc.mapDateToTimestamp defaults to true, users often need to disable this flag to avoid Oracle date being resolved as timestamp.*

- **在数据源选项中，用户可以指定特定于供应商的 JDBC 连接属性来进行特殊处理**。例如，`spark.read.format("jdbc").option("url", oracleJdbcUrl).option("oracle.jdbc.mapDateToTimestamp", "false")` 。 `mapDateToTimestamp`默认值为 true，用户经常需要禁用这个标志，以避免 Oracle 日期被解析为时间戳。

