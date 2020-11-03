# [SQL：获取当前薪水第二多的员工的emp_no以及其对应的薪水salary](https://www.nowcoder.com/practice/8d2c290cc4e24403b98ca82ce45d04db?tpId=82&&tqId=29769&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取当前（to_date='9999-01-01'）薪水第二多的员工的emp_no以及其对应的薪水salary

```sql
CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

薪水第二多的员工可能不止一个。

```sql
-- 根据salary分组
select emp_no,salary
from salaries
where to_date='9999-01-01'
and salary = (
    select salary 
    from salaries
    where to_date='9999-01-01'
    group by salary
    order by salary desc
    limit 1,1
)

-- 使用dense_rank()
select emp_no,salary
from (select emp_no,salary,from_date,to_date, 
      dense_rank() over(order by salary desc) dr
      from salaries)
where to_date='9999-01-01' and dr=2;
```

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