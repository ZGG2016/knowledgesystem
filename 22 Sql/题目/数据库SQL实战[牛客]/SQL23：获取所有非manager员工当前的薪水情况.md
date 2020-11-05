# [SQL23：获取所有非manager员工当前的薪水情况](https://www.nowcoder.com/practice/8fe212a6c71b42de9c15c56ce354bebe?tpId=82&&tqId=29776&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取所有非manager员工当前的薪水情况，给出dept_no、emp_no以及salary ，当前表示to_date='9999-01-01'

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `dept_manager` (
`dept_no` char(4) NOT NULL,
`emp_no` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `employees` (
`emp_no` int(11) NOT NULL,
`birth_date` date NOT NULL,
`first_name` varchar(14) NOT NULL,
`last_name` varchar(16) NOT NULL,
`gender` char(1) NOT NULL,
`hire_date` date NOT NULL,
PRIMARY KEY (`emp_no`));

CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

dept_emp:职工及所属部门表

dept_manager:经理及所属部门表

employees：所有员工表（职工+经理）

salaries：薪水表

```sql
select de.dept_no,a.emp_no,s.salary
from 
(select emp_no from employees  -- 使用employees表，克可虑没有部门的职工
where emp_no not in (select emp_no from dept_manager)) a 
join dept_emp de on a.emp_no=de.emp_no 
join salaries s on a.emp_no=s.emp_no
where s.to_date='9999-01-01';
```

## 3、涉及内容