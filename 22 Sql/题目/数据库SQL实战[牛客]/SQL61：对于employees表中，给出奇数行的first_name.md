# [SQL61：对于employees表中，给出奇数行的first_name](https://www.nowcoder.com/practice/e3cf1171f6cc426bac85fd4ffa786594?tpId=82&&tqId=29829&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

对于employees表中，输出first_name排名(按first_name升序排序)为奇数的first_name

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
-- 通过，但有重复数据时，出错
select
    e.first_name
from employees e join
(select 
	first_name, 
	row_number() over(order by first_name) as  rn
    from employees) ern 
on e.first_name = ern.first_name
where ern.rn % 2 != 0;

-- 解决有重复数据的问题
select
    distinct e.first_name
from employees e join
(select 
	first_name, 
	dense_rank() over(order by first_name) as  rn
    from employees) ern 
on e.first_name = ern.first_name
where ern.rn % 2 != 0;

-- 没通过 【没有重复数据时】  【输出顺序不同？？？】
select first_name from (
    select first_name,
    row_number() over(order by first_name) rn
    from employees
) a
where rn%2!=0;
+------------+
| first_name |
+------------+
| Anneke     |
| Georgi     |
+------------+

-- 窗口函数使用错误
-- 窗口函数的执行在 WHERE、GROUP BY 和 HAVING 处理之后，在 ORDER BY、LIMIT 和 SELECT DISTINCT 之前。
select first_name from (
    select first_name,
    row_number() over(order by first_name) rn
    from employees
    where rn%2!=0
) a;
```

## 3、涉及内容

-----------------------------------------------------

```sql
-- 有重复数据 10009
mysql> select * from employees;
+--------+------------+------------+-----------+--------+------------+
| emp_no | birth_date | first_name | last_name | gender | hire_date  |
+--------+------------+------------+-----------+--------+------------+
|  10001 | 1953-09-02 | Georgi     | Facello   | M      | 1986-06-26 |
|  10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |
|  10005 | 1955-01-21 | Kyoichi    | Maliniak  | M      | 1989-09-12 |
|  10006 | 1953-04-20 | Anneke     | Preusig   | F      | 1989-06-02 |
|  10009 | 1953-09-02 | Georgi     | Facello   | M      | 1986-06-26 |
+--------+------------+------------+-----------+--------+------------+

mysql> select 
    -> first_name, 
    -> row_number() over(order by first_name) as  rn
    -> from employees;
+------------+----+
| first_name | rn |
+------------+----+
| Anneke     |  1 |
| Bezalel    |  2 |
| Georgi     |  3 |
| Georgi     |  4 |
| Kyoichi    |  5 |
+------------+----+

mysql> select 
    -> first_name, 
    -> dense_rank() over(order by first_name) as  rn
    -> from employees;
+------------+----+
| first_name | rn |
+------------+----+
| Anneke     |  1 |
| Bezalel    |  2 |
| Georgi     |  3 |
| Georgi     |  3 |
| Kyoichi    |  4 |
+------------+----+

mysql> select
    ->     e.first_name,ern.first_name,ern.rn
    -> from employees e join
    -> (select 
    -> first_name, 
    -> row_number() over(order by first_name) as  rn
    ->     from employees) ern 
    -> on e.first_name = ern.first_name;
+------------+------------+----+
| first_name | first_name | rn |
+------------+------------+----+
| Georgi     | Georgi     |  3 |
| Georgi     | Georgi     |  4 |
| Bezalel    | Bezalel    |  2 |
| Kyoichi    | Kyoichi    |  5 |
| Anneke     | Anneke     |  1 |
| Georgi     | Georgi     |  3 |
| Georgi     | Georgi     |  4 |
+------------+------------+----+

mysql> select
    ->     e.first_name,ern.first_name,ern.rn
    -> from employees e join
    -> (select 
    -> first_name, 
    -> dense_rank() over(order by first_name) as  rn
    ->     from employees) ern 
    -> on e.first_name = ern.first_name;
+------------+------------+----+
| first_name | first_name | rn |
+------------+------------+----+
| Georgi     | Georgi     |  3 |
| Georgi     | Georgi     |  3 |
| Bezalel    | Bezalel    |  2 |
| Kyoichi    | Kyoichi    |  4 |
| Anneke     | Anneke     |  1 |
| Georgi     | Georgi     |  3 |
| Georgi     | Georgi     |  3 |
+------------+------------+----+

mysql> select
    ->     e.first_name
    -> from employees e join
    -> (select 
    -> first_name, 
    -> row_number() over(order by first_name) as  rn
    ->     from employees) ern 
    -> on e.first_name = ern.first_name
    -> where ern.rn % 2 != 0;
+------------+
| first_name |
+------------+
| Georgi     |
| Kyoichi    |
| Anneke     |
| Georgi     |
+------------+

mysql> select
    ->     distinct e.first_name
    -> from employees e join
    -> (select 
    -> first_name, 
    -> dense_rank() over(order by first_name) as  rn
    ->     from employees) ern 
    -> on e.first_name = ern.first_name
    -> where ern.rn % 2 != 0;
+------------+
| first_name |
+------------+
| Georgi     |
| Anneke     |
+------------+
```