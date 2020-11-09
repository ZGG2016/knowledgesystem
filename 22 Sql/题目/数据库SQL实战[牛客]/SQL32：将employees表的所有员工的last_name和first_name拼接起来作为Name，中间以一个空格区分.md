# [SQL32：将employees表的所有员工的last_name和first_name拼接起来作为Name，中间以一个空格区分](https://www.nowcoder.com/practice/6744b90bbdde40209f8ecaac0b0516fe?tpId=82&&tqId=29800&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

将employees表的所有员工的last_name和first_name拼接起来作为Name，中间以一个空格区分
(注：sqllite,字符串拼接为 || 符号，不支持concat函数，mysql支持concat函数)

```sql
CREATE TABLE `employees` ( 
`emp_no` int(11) NOT NULL,
`birth_date` date NOT NULL,
`first_name` varchar(14) NOT NULL,
`last_name` varchar(16) NOT NULL,
`gender` char(1) NOT NULL,
`hire_date` date NOT NULL,
PRIMARY KEY (`emp_no`));
```

## 2、题解


```sql
select CONCAT_WS(' ',last_name,first_name) Name from employees;
```

## 3、涉及内容

(1)concat函数

	CONCAT(str1,str2,…) 

返回结果为连接参数产生的字符串。如有任何一个参数为NULL ，则返回值为 NULL。

```sql
mysql> select concat('11','22','33');
  +------------------------+
  | concat('11','22','33') |
  +------------------------+
  | 112233 |
 +------------------------+

 mysql> select concat('11','22',null);
 +------------------------+
 | concat('11','22',null) |
 +------------------------+
 | NULL |
 +------------------------+
```

(2)concat_ws函数

	CONCAT_WS(separator,str1,str2,...)

第一个参数是其它参数的分隔符。

分隔符的位置放在要连接的两个字符串之间。分隔符可以是一个字符串，也可以是其它参数。

如果分隔符为 NULL，则结果为 NULL。函数会忽略任何分隔符参数后的 NULL 值。

```sql
mysql> select concat_ws(',','11','22','33');

  +-------------------------------+
  | concat_ws(',','11','22','33') |
  +-------------------------------+
  | 11,22,33 |
  +-------------------------------+
  1 row in set (0.00 sec)

mysql> select concat_ws(',','11','22',NULL);

  +-------------------------------+
  | concat_ws(',','11','22',NULL) |
  +-------------------------------+
  | 11,22 |
  +-------------------------------+
```

(3)group_concat函数

	group_concat([DISTINCT] 要连接的字段 [Order BY ASC/DESC 排序字段] [Separator '分隔符'])

```sql
   mysql> select * from aa;

   +------+------+
   | id| name |
   +------+------+
   |1 | 10|
   |1 | 20|
   |1 | 20|
   |2 | 20|
   |3 | 200 |
   |3 | 500 |
  +------+------+
   6 rows in set (0.00 sec)

-- 以id分组，把name字段的值打印在一行，逗号分隔(默认)
mysql> select id,group_concat(name) from aa group by id;

  +------+--------------------+
   | id| group_concat(name) |
   +------+--------------------+
   |1 | 10,20,20|
   |2 | 20 |
   |3 | 200,500|
   +------+--------------------+
   
-- 以id分组，把去冗余的name字段的值打印在一行，逗号分隔：
mysql> select id,group_concat(distinct name) from aa group by id;
  +------+-----------------------------+
  | id| group_concat(distinct name) |
  +------+-----------------------------+
  |1 | 10,20|
  |2 | 20 |
  |3 | 200,500 |
  +------+-----------------------------+
  3 rows in set (0.00 sec)

-- 以id分组，把name字段的值打印在一行，逗号分隔，以name排倒序： 
mysql> select id,group_concat(name order by name desc) from aa group by id;
  +------+---------------------------------------+
  | id| group_concat(name order by name desc) |
  +------+---------------------------------------+
  |1 | 20,20,10 |
  |2 | 20|
  |3 | 500,200|
  +------+---------------------------------------+

```