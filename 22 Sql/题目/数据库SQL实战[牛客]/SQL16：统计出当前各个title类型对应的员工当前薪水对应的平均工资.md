# [统计出当前各个title类型对应的员工当前薪水对应的平均工资](https://www.nowcoder.com/practice/c8652e9e5a354b879e2a244200f1eaae?tpId=82&&tqId=29768&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

统计出当前(titles.to_date='9999-01-01')各个title类型对应的员工当前(salaries.to_date='9999-01-01')薪水对应的平均工资。结果给出title以及平均工资avg。

	CREATE TABLE `salaries` (
	`emp_no` int(11) NOT NULL,
	`salary` int(11) NOT NULL,
	`from_date` date NOT NULL,
	`to_date` date NOT NULL,
	PRIMARY KEY (`emp_no`,`from_date`));

	CREATE TABLE IF NOT EXISTS "titles" (
	`emp_no` int(11) NOT NULL,
	`title` varchar(50) NOT NULL,
	`from_date` date NOT NULL,
	`to_date` date DEFAULT NULL);

## 2、题解

```sql
select t.title,avg(salary) avg
from salaries s 
inner join titles t on s.emp_no=t.emp_no
where t.to_date='9999-01-01' and s.to_date='9999-01-01'
group by t.title;
```

## 3、涉及内容

(1)AVG() 函数：返回数值列的平均值。

	SELECT AVG(column_name) FROM table_name