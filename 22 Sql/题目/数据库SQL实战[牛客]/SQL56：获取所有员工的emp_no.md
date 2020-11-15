# [SQL56：获取所有员工的emp_no](https://www.nowcoder.com/practice/e2dab5477fdd4ec0ba84031f8e817b8a?tpId=82&&tqId=29824&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取所有员工的emp_no、部门编号dept_no以及对应的bonus类型btype和received，没有分配奖金的员工不显示对应的bonus类型btype和received

【没有分配奖金的员工不显示对应的bonus类型btype和received：这里也要把员工信息显示出来】

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `emp_bonus`(
emp_no int(11) NOT NULL,
received datetime NOT NULL,
btype smallint(5) NOT NULL);

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
select e.emp_no,de.dept_no,eb.btype,eb.received
from employees e 
left join emp_bonus eb on e.emp_no =eb.emp_no 
join dept_emp de on e.emp_no =de.emp_no; 
```

## 3、涉及内容