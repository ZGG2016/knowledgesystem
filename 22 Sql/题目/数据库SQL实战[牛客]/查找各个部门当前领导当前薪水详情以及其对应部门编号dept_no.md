# [查找各个部门当前领导当前薪水详情以及其对应部门编号dept_no](https://www.nowcoder.com/practice/c63c5b54d86e4c6d880e4834bfd70c3b?tpId=82&&tqId=29755&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找各个部门当前(dept_manager.to_date='9999-01-01')领导当前(salaries.to_date='9999-01-01')薪水详情以及其对应部门编号dept_no
(注:输出结果以salaries.emp_no升序排序，并且请注意输出结果里面dept_no列是最后一列)

```sql
CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL, -- '员工编号',
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
CREATE TABLE `dept_manager` (
`dept_no` char(4) NOT NULL, -- '部门编号'
`emp_no` int(11) NOT NULL, --  '员工编号'
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));
```

## 2、题解


```sql
select s.emp_no,s.salary,s.from_date,s.to_date,d.dept_no 
from dept_manager d join salaries s on d.emp_no=s.emp_no
where d.to_date='9999-01-01' and s.to_date='9999-01-01'
order by s.emp_no;
-- 对此题要注意两个时间字段。
-- salaries的from_date是当前薪水的开始时间，dept_manager的from_date是作为部门经理的开始时间。
```