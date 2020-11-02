# [获取所有部门中当前员工薪水最高的相关信息](https://www.nowcoder.com/practice/4a052e3e1df5435880d4353eb18a91c6?tpId=82&&tqId=29764&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)


## 1、题目

获取所有部门中当前(dept_emp.to_date = '9999-01-01')员工当前(salaries.to_date='9999-01-01')薪水最高的相关信息，给出dept_no, emp_no以及其对应的salary，按照部门编号升序排列。

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

注意点：一个部门有两个人的薪水都是最高的。

	利用窗口函数dense_rank()的性质：返回当前行在其分区中的排名，是连续的值。同级的行具有相同的排名。


```sql
select dept_no,emp_no,salary 
from (
    select d.dept_no,d.emp_no,s.salary,
    dense_rank() over(partition by d.dept_no order by s.salary desc) dr
    from dept_emp d 
    join salaries s on d.emp_no=s.emp_no
    where d.to_date = '9999-01-01' and s.to_date='9999-01-01'
) a  
where dr=1;
```

```sql
-- 也通过了？？？
select d.dept_no,d.emp_no,max(s.salary) 
from dept_emp d join salaries s 
on d.emp_no=s.emp_no
where d.to_date = '9999-01-01' and s.to_date='9999-01-01'
group by d.dept_no
order by d.dept_no;
```

注意查看`题解`中的讨论。

## 3、涉及内容

(1)窗口函数

	dense_rank()：返回当前行在其分区中的排名，是连续的值。同级的行具有相同的排名。

	rank()：返回当前行在它所属的分区内的排名，是不连续的值。同级的行具有相同的排名。

	row_number()：返回当前行在它所属的分区中的序号。会给同级的两行分配不同的序号。

```sql
mysql> SELECT
         val,
         ROW_NUMBER() OVER w AS 'row_number',
         RANK()       OVER w AS 'rank',
         DENSE_RANK() OVER w AS 'dense_rank'
       FROM numbers
       WINDOW w AS (ORDER BY val);
+------+------------+------+------------+
| val  | row_number | rank | dense_rank |
+------+------------+------+------------+
|    1 |          1 |    1 |          1 |
|    1 |          2 |    1 |          1 |
|    2 |          3 |    3 |          2 |
|    3 |          4 |    4 |          3 |
|    3 |          5 |    4 |          3 |
|    3 |          6 |    4 |          3 |
|    4 |          7 |    7 |          4 |
|    4 |          8 |    7 |          4 |
|    5 |          9 |    9 |          5 |
+------+------------+------+------------+
```