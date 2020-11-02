# [获取所有员工当前的manager](https://www.nowcoder.com/practice/e50d92b8673a440ebdf3a517b5b37d62?tpId=82&&tqId=29763&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取所有员工当前的(dept_manager.to_date='9999-01-01')manager，如果员工是manager的话不显示(也就是如果当前的manager是自己的话结果不显示)。输出结果第一列给出当前员工的emp_no,第二列给出其manager对应的emp_no。

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL, -- '所有的员工编号'
`dept_no` char(4) NOT NULL, -- '部门编号'
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `dept_manager` (
`dept_no` char(4) NOT NULL, -- '部门编号'
`emp_no` int(11) NOT NULL, -- '经理编号'
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));
```

## 2、题解


```sql
select e.emp_no,m.emp_no 
from dept_emp e join dept_manager m on e.dept_no=m.dept_no
where e.to_date='9999-01-01' and m.to_date='9999-01-01' and e.emp_no!=m.emp_no;
-- 部门的员工可能也有一些离职的，所以e.to_date='9999-01-01'
```