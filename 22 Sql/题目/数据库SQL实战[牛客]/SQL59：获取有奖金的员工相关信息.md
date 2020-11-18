# [SQL59：获取有奖金的员工相关信息](https://www.nowcoder.com/practice/5cdbf1dcbe8d4c689020b6b2743820bf?tpId=82&&tqId=29827&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取有奖金的员工相关信息。

给出emp_no、first_name、last_name、奖金类型btype、对应的当前薪水情况salary以及奖金金额bonus。 

bonus类型btype为1其奖金为薪水salary的10%，btype为2其奖金为薪水的20%，其他类型均为薪水的30%。 

当前薪水表示to_date='9999-01-01'

```sql
CREATE TABLE `employees` (
`emp_no` int(11) NOT NULL,
`birth_date` date NOT NULL,
`first_name` varchar(14) NOT NULL,
`last_name` varchar(16) NOT NULL,
`gender` char(1) NOT NULL,
`hire_date` date NOT NULL,
PRIMARY KEY (`emp_no`));

CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

create table emp_bonus(
emp_no int not null,
received datetime not null,
btype smallint not null);

CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL, PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

```sql
select e.emp_no,e.first_name,e.last_name,eb.btype,s.salary,
(case eb.btype when 1 then s.salary*0.1 
 when 2 then s.salary*0.2 
 else s.salary*0.3 end) bonus
from employees e
join emp_bonus eb on e.emp_no=eb.emp_no
join salaries s on e.emp_no=s.emp_no
where s.to_date='9999-01-01';
```

## 3、涉及内容

(1)case when ... then ... else ... end

MySQL 的 case when 的语法有两种：

简单函数 

    CASE [col_name] WHEN [value1] THEN [result1]…ELSE [default] END
    枚举这个字段所有可能的值

搜索函数 

    CASE WHEN [expr] THEN [result1]…ELSE [default] END
    搜索函数可以写判断，并且搜索函数只会返回第一个符合条件的值，其他case被忽略


```sql
MariaDB [mysql]> select * from websites;
+----+--------------+---------------------------+-------+---------+
| id | name         | url                       | alexa | country |
+----+--------------+---------------------------+-------+---------+
|  1 | Google       | https://www.google.cm/    |     1 | USA     |
|  2 | 淘宝         | https://www.taobao.com/   |    13 | CN      |
|  3 | 菜鸟教程     | http://www.runoob.com/    |  4689 | CN      |
|  4 | 微博         | http://weibo.com/         |    20 | CN      |
|  5 | Facebook     | https://www.facebook.com/ |     3 | USA     |
+----+--------------+---------------------------+-------+---------+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case when alexa<=20 THEN 'a' ELSE 'b' end rlt from websites;
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | a   |
|  3 | b   |
|  4 | a   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case country when 'USA' THEN 'a' else 'b' end rlt from websites; 
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | b   |
|  3 | b   |
|  4 | b   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case when alexa>0 and alexa<=10 THEN 'a'  when alexa>10 and alexa<=20 then 'b' ELSE 'c' end rlt from websites;
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | b   |
|  3 | c   |
|  4 | b   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)

```