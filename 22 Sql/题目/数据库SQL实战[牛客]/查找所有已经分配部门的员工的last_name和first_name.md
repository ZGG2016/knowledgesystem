# [查找所有已经分配部门的员工的last_name和first_name](https://www.nowcoder.com/practice/6d35b1cd593545ab985a68cd86f28671?tpId=82&&tqId=29756&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找所有已经分配部门的员工的last_name和first_name以及dept_no(请注意输出描述里各个列的前后顺序)

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
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
```

## 2、题解

employees 表左连接 dept_emp 表，如果是未分配部门的员工，那么他对应的 dept_no 是 NULL，否则就不是 NULL。

```sql
select e.last_name,e.first_name,d.dept_no 
from employees e left join dept_emp d on e.emp_no=d.emp_no
where d.dept_no is not NULL;

-- 使用内连接
SELECT e.last_name,e.first_name,d.dept_no
FROM employees AS e
INNER JOIN dept_emp AS d
ON e.emp_no=d.emp_no;
```

## 3、涉及内容

查询字段值为空的语法：where <字段名> is null

查询字段值不为空的语法：where <字段名> is not null

注意：null 不能用 '!='，'='，'<>' 来判断

```sql
mysql> select * from WINDOWFUNC_TEST where userid is not null;
+------+--------+------+
| dept | userid | sal  |
+------+--------+------+
| d1   | user1  | 1000 |
| d1   | user3  | 3000 |
| d1   | user2  | 2000 |
| d2   | user4  | 4000 |
| d2   | user4  | 6000 |
| d2   | user1  | 5000 |
+------+--------+------+
6 rows in set (0.01 sec)
```