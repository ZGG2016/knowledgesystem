# 官网：Spark SQL Guide03--Data Sources--JDBC To Other Databases

[TOC]

*Spark SQL also includes a data source that can read data from other databases using JDBC. This functionality should be preferred over using JdbcRDD. This is because the results are returned as a DataFrame and they can easily be processed in Spark SQL or joined with other data sources. The JDBC data source is also easier to use from Java or Python as it does not require the user to provide a ClassTag. (Note that this is different than the Spark SQL JDBC server, which allows other applications to run queries using Spark SQL).*

Spark SQL 还包含了一个使用 JDBC 从其他数据库读取数据的数据源。这个功能更倾向使用的是 JdbcRDD。因为返回的是 DataFrame ，可以很容易地在 Spark SQL 处理，或者和其他数据源 join。 
[使用 JDBC ，和指定数据库交互]


JDBC 数据源也可以在 Java 、 Python 里使用，不需要用户提供 ClassTag。这和 Spark SQL JDBC server 不同，[Spark SQL JDBC server]允许其他程序使用 Spark SQL 执行查询。

*To get started you will need to include the JDBC driver for your particular database on the spark classpath. For example, to connect to postgres from the Spark Shell you would run the following command:*

首先需要**将你的数据的 JDBC driver 添加到你的 spark classpath**。例如，从 Spark shell 连接 postgres，需要执行如下命令：

```sh
./bin/spark-shell --driver-class-path postgresql-9.4.1207.jar --jars postgresql-9.4.1207.jar
```

*Tables from the remote database can be loaded as a DataFrame or Spark SQL temporary view using the Data Sources API. Users can specify the JDBC connection properties in the data source options. user and password are normally provided as connection properties for logging into the data sources. In addition to the connection properties, Spark also supports the following case-insensitive options:*

**远程数据库的表使用 Data Sources API 以 DataFrame 或 Spark SQL 临时视图的形式载入**。

**用户可以在数据源选项中，指定 JDBC connection 属性**。用户账号和密码放在 connection 属性中。Spark 还支持以下不区分大小写的选项:

[不区分大小写的选项](http://spark.apache.org/docs/latest/sql-data-sources-jdbc.html)

**sql**

```sql
CREATE TEMPORARY VIEW jdbcTable
USING org.apache.spark.sql.jdbc
OPTIONS (
  url "jdbc:postgresql:dbserver",
  dbtable "schema.tablename",
  user 'username',
  password 'password'
)

INSERT INTO TABLE jdbcTable
SELECT * FROM resultTable
```

**A：对于python**

```python
# Note: JDBC loading and saving can be achieved via either the load/save or jdbc methods
# Loading data from a JDBC source
jdbcDF = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql:dbserver") \
    .option("dbtable", "schema.tablename") \
    .option("user", "username") \
    .option("password", "password") \
    .load()

jdbcDF2 = spark.read \
    .jdbc("jdbc:postgresql:dbserver", "schema.tablename",
          properties={"user": "username", "password": "password"})

# Specifying dataframe column data types on read
jdbcDF3 = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql:dbserver") \
    .option("dbtable", "schema.tablename") \
    .option("user", "username") \
    .option("password", "password") \
    .option("customSchema", "id DECIMAL(38, 0), name STRING") \
    .load()

# Saving data to a JDBC source
jdbcDF.write \
    .format("jdbc") \
    .option("url", "jdbc:postgresql:dbserver") \
    .option("dbtable", "schema.tablename") \
    .option("user", "username") \
    .option("password", "password") \
    .save()

jdbcDF2.write \
    .jdbc("jdbc:postgresql:dbserver", "schema.tablename",
          properties={"user": "username", "password": "password"})

# Specifying create table column data types on write
jdbcDF.write \
    .option("createTableColumnTypes", "name CHAR(64), comments VARCHAR(1024)") \
    .jdbc("jdbc:postgresql:dbserver", "schema.tablename",
          properties={"user": "username", "password": "password"})
```
*Find full example code at "examples/src/main/python/sql/datasource.py" in the Spark repo.*


**B：对于java**

```java
// Note: JDBC loading and saving can be achieved via either the load/save or jdbc methods
// Loading data from a JDBC source
Dataset<Row> jdbcDF = spark.read()
  .format("jdbc")
  .option("url", "jdbc:postgresql:dbserver")
  .option("dbtable", "schema.tablename")
  .option("user", "username")
  .option("password", "password")
  .load();

Properties connectionProperties = new Properties();
connectionProperties.put("user", "username");
connectionProperties.put("password", "password");
Dataset<Row> jdbcDF2 = spark.read()
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties);

// Saving data to a JDBC source
jdbcDF.write()
  .format("jdbc")
  .option("url", "jdbc:postgresql:dbserver")
  .option("dbtable", "schema.tablename")
  .option("user", "username")
  .option("password", "password")
  .save();

jdbcDF2.write()
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties);

// Specifying create table column data types on write
jdbcDF.write()
  .option("createTableColumnTypes", "name CHAR(64), comments VARCHAR(1024)")
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties);
```

Find full example code at "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" in the Spark repo.


**C：对于scala**

```java
// Note: JDBC loading and saving can be achieved via either the load/save or jdbc methods
// Loading data from a JDBC source
val jdbcDF = spark.read
  .format("jdbc")
  .option("url", "jdbc:postgresql:dbserver")
  .option("dbtable", "schema.tablename")
  .option("user", "username")
  .option("password", "password")
  .load()

val connectionProperties = new Properties()
connectionProperties.put("user", "username")
connectionProperties.put("password", "password")
val jdbcDF2 = spark.read
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)
// Specifying the custom data types of the read schema
connectionProperties.put("customSchema", "id DECIMAL(38, 0), name STRING")
val jdbcDF3 = spark.read
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)

// Saving data to a JDBC source
jdbcDF.write
  .format("jdbc")
  .option("url", "jdbc:postgresql:dbserver")
  .option("dbtable", "schema.tablename")
  .option("user", "username")
  .option("password", "password")
  .save()

jdbcDF2.write
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)

// Specifying create table column data types on write
jdbcDF.write
  .option("createTableColumnTypes", "name CHAR(64), comments VARCHAR(1024)")
  .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)
```

*Find full example code at "examples/src/main/scala/org/apache/spark/examples/sql/SQLDataSourceExample.scala" in the Spark repo.*