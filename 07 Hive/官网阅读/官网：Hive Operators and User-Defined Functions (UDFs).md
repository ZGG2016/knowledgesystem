# 官网：Hive Operators and User-Defined Functions (UDFs)

[TOC]

## 1、Built-in Operators

### 1.1、Operators Precedences

### 1.2、Relational Operators

### 1.3、Arithmetic Operators

### 1.4、Logical Operators

### 1.5、String Operators

### 1.6、Complex Type Constructors

### 1.7、Operators on Complex Types

## 2、Built-in Functions

### 2.1、Mathematical Functions

#### 2.1.1、Mathematical Functions and Operators for Decimal Datatypes

### 2.2、Collection Functions

### 2.3、Type Conversion Functions

### 2.4、Date Functions

### 2.5、Conditional Functions

Return Type | Name(Signature) | Description
---|:---|:---
boolean | isnull( a ) | Returns true if a is NULL and false otherwise.
boolean | isnotnull ( a ) | Returns true if a is not NULL and false otherwise.
T | if(boolean testCondition, T valueTrue, T valueFalseOrNull) | Returns valueTrue when testCondition is true, returns valueFalseOrNull otherwise.
T | nvl(T value, T default_value) | Returns default value if value is null else returns value (as of HIve 0.11).
T | COALESCE(T v1, T v2, ...) | Returns the first v that is not NULL, or NULL if all v's are NULL.
T | CASE a WHEN b THEN c [WHEN d THEN e]* [ELSE f] END  | When a = b, returns c; when a = d, returns e; else returns f.
T | CASE WHEN a THEN b [WHEN c THEN d]* [ELSE e] END | When a = true, returns b; when c = true, returns d; else returns e.
T | nullif( a, b )	| Returns NULL if a=b; otherwise returns a **(as of Hive 2.2.0)**.Shorthand for: CASE WHEN a = b then NULL else a
void | assert_true(boolean condition) | Throw an exception if 'condition' is not true, otherwise return null (as of Hive 0.8.0). For example, select assert_true (2<1).

```sh
hive> select * from emp;
OK
ID      Name    Salary  Designation     Dept
1201    Gopal   45000   Technical manager       TP
1202    Manisha 45000   Proofreader     PR
1203    Masthanvali     40000   Technical writer        TP
1204    Krian   40000   Hr Admin        HR
1205    Kranthi 30000   Op Admin        Admin
1206    Mike    20000   Worker  NULL
Time taken: 0.036 seconds, Fetched: 7 row(s)

hive> select name,if(dept=='TP',1,0) from emp;
OK
Name    0
Gopal   1
Manisha 0
Masthanvali     1
Krian   0
Kranthi 0
Mike    0
Time taken: 0.06 seconds, Fetched: 7 row(s)

hive> select Name,nvl(Dept,'AA')  from emp;
OK
Name    Dept
Gopal   TP
Manisha PR
Masthanvali     TP
Krian   HR
Kranthi Admin
Mike    AA
Time taken: 0.056 seconds, Fetched: 7 row(s)

hive> select assert_true(Dept) from emp;
OK
Failed with exception java.io.IOException:org.apache.hadoop.hive.ql.metadata.HiveException: ASSERT_TRUE(): assertion failed.
Time taken: 0.072 seconds
hive> select assert_true(id) from emp;
OK
NULL
NULL
NULL
NULL
NULL
NULL
NULL
Time taken: 0.046 seconds, Fetched: 7 row(s)

hive> select coalesce(null,2,3); 
OK
2
Time taken: 0.038 seconds, Fetched: 1 row(s)
```

### 2.6、String Functions

### 2.7、Data Masking Functions

### 2.8、Misc. Functions

#### 2.8。1、xpath

#### 2.8.2、get_json_object

## 3、Built-in Aggregate Functions (UDAF)

## 4、Built-in Table-Generating Functions (UDTF)

### 4.1、explode

### 4.2、posexplode

### 4.3、json_tuple

### 4.4、parse_url_tuple

## 5、GROUPing and SORTing on f(column)

## 6、UDF internals

## 7、Creating Custom UDFs