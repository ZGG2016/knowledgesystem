# [SQL60：统计salary的累计和running_total](https://www.nowcoder.com/practice/58824cd644ea47d7b2b670c506a159a6?tpId=82&&tqId=29828&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

按照salary的累计和running_total，其中running_total为前N个当前( to_date = '9999-01-01')员工的salary累计和，其他以此类推。 具体结果如下Demo展示。

```sql
CREATE TABLE `salaries` ( 
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

输出格式:

emp_no | salary | running_total
---|:---|:---
10001  | 88958	| 88958
10002  | 72527	| 161485
10003  | 43311	| 204796
10004  | 74057	| 278853

## 2、题解


```sql
select emp_no,salary,
sum(salary) over(order by emp_no) running_total
from salaries
where to_date = '9999-01-01';

-- 不使用窗口函数
select s1.emp_no,s1.salary,
(select sum(s2.salary) from salaries s2 
 where s2.to_date = '9999-01-01' 
 and s2.emp_no <=s1.emp_no) running_total
from salaries s1
where s1.to_date = '9999-01-01'
order by s1.emp_no;
```

## 3、涉及内容

(1)聚合函数作为窗口函数

如果使用了窗口操作就不会把一组数据规约成一行输出数据。而是，每一个对应一个结果。

```sql
mysql> select * from access_log;
+-----+---------+-------+------------+
| aid | site_id | count | date       |
+-----+---------+-------+------------+
|   1 |       1 |     3 | 2016-05-10 |
|   2 |       3 |     2 | 2016-05-13 |
|   3 |       1 |     5 | 2016-05-14 |
|   4 |       2 |     4 | 2016-05-14 |
|   5 |       5 |     4 | 2016-05-14 |
|   6 |       5 |     5 | 2016-05-12 |
|   6 |       1 |     1 | 9999-12-12 |
|   6 |       5 |     5 | 2016-05-12 |
+-----+---------+-------+------------+
8 rows in set (0.00 sec)

mysql> select aid,sum(count) over(order by aid) s from access_log;
+-----+------+
| aid | s    |
+-----+------+
|   1 |    3 |
|   2 |    5 |
|   3 |   10 |
|   4 |   14 |
|   5 |   18 |
|   6 |   29 |
|   6 |   29 |
|   6 |   29 |
+-----+------+
8 rows in set (0.01 sec)

mysql> select aid,sum(count) over() s from access_log;            
+-----+------+
| aid | s    |
+-----+------+
|   1 |   29 |
|   2 |   29 |
|   3 |   29 |
|   4 |   29 |
|   5 |   29 |
|   6 |   29 |
|   6 |   29 |
|   6 |   29 |
+-----+------+
8 rows in set (0.00 sec)

mysql> select aid,sum(count) over(partition by aid) s from access_log;     
+-----+------+
| aid | s    |
+-----+------+
|   1 |    3 |
|   2 |    2 |
|   3 |    5 |
|   4 |    4 |
|   5 |    4 |
|   6 |   11 |
|   6 |   11 |
|   6 |   11 |
+-----+------+
```