# [SQL57：使用含有关键字exists查找未分配具体部门的员工的所有信息](https://www.nowcoder.com/practice/c39cbfbd111a4d92b221acec1c7c1484?tpId=82&&tqId=29825&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

使用含有关键字exists查找未分配具体部门的员工的所有信息。

```
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
```

## 2、题解


```sql
select emp_no,birth_date,first_name,last_name,gender,hire_date
from employees e
where not exists (select emp_no from dept_emp de where e.emp_no=de.emp_no);
```

## 3、涉及内容

(1)EXISTS 运算符

用于判断查询子句是否有记录，如果有一条或多条记录存在返回 True，否则返回 False。

SQL EXISTS 语法

	SELECT column_name(s)
	FROM table_name
	WHERE EXISTS
	(SELECT column_name FROM table_name WHERE condition);