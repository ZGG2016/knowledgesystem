# [获取所有非manager的员工emp_no](https://www.nowcoder.com/practice/32c53d06443346f4a2f2ca733c19660c?tpId=82&&tqId=29762&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目


获取所有非manager的员工emp_no

```sql
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
```

## 2、题解


```sql
-- not in
select emp_no from employees
where emp_no not in (
    select emp_no from dept_manager
);

-- LEFT JOIN左连接+IS NULL
SELECT e.emp_no
FROM employees AS e
LEFT JOIN dept_manager AS d
ON e.emp_no=d.emp_no
WHERE dept_no IS NULL;

```