# 官网：Spark SQL Guide03--Data Sources--ORC Files

*Since Spark 2.3, Spark supports a vectorized ORC reader with a new ORC file format for ORC files. To do that, the following configurations are newly added. The vectorized reader is used for the native ORC tables (e.g., the ones created using the clause USING ORC) when spark.sql.orc.impl is set to native and spark.sql.orc.enableVectorizedReader is set to true. For the Hive ORC serde tables (e.g., the ones created using the clause USING HIVE OPTIONS (fileFormat 'ORC')), the vectorized reader is used when spark.sql.hive.convertMetastoreOrc is also set to true.*

从 Spark 2.3 开始，Spark 支持向量化的 ORC 阅读器，为 ORC 文件提供新的 ORC 文件格式。为了实现这个，需要添加如下配置。

当 `spark.sql.orc.impl=native` 和 `spark.sql.orc.enableVectorizedReader=true`，向量化的 ORC 阅读器用来读取原生的 ORC 表(例如，使用 `USING ORC` 创建的表)。

当 `spark.sql.hive.convertMetastoreOrc=true` 时，向量化的 ORC 阅读器用来读取 Hive ORC serde tables (例如，使用 `SING HIVE OPTIONS (fileFormat 'ORC')` 创建的表)

Property Name |	Default | Meaning	| Since Version
---|:---|:---|:---
spark.sql.orc.impl | native | The name of ORC implementation. It can be one of native and hive. native means the native ORC support. hive means the ORC library in Hive. | 2.3.0
spark.sql.orc.enableVectorizedReader | true | Enables vectorized orc decoding in native implementation. If false, a new non-vectorized ORC reader is used in native implementation. For hive implementation, this is ignored. | 2.3.0