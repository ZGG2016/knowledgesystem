# [SQL50：将employees表中的所有员工的last_name和first_name通过(')连接起来](https://www.nowcoder.com/practice/810bf4ee3ac64949b08983aa66ec7bee?tpId=82&&tqId=29818&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

将employees表中的所有员工的last_name和first_name通过(')连接起来。(sqlite不支持concat，请用||实现，mysql支持concat)

```sql
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
select concat_ws("'",last_name,first_name) name
from employees;
```

## 3、涉及内容