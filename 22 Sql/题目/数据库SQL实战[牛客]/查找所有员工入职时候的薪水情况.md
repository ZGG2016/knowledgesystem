# [查找所有员工入职时候的薪水情况](https://www.nowcoder.com/practice/23142e7a23e4480781a3b978b5e0f33a?tpId=82&&tqId=29758&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找所有员工入职时候的薪水情况，给出emp_no以及salary， 并按照emp_no进行逆序(请注意，一个员工可能有多次涨薪的情况)

```sql
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

方法1：使用内连接，连接emp_no相同，且hire_date和from_date相同的记录(第一次发工资的日期)。

```sql
select e.emp_no,s.salary 
from employees e 
join salaries s on e.emp_no=s.emp_no and e.hire_date=s.from_date
order by emp_no desc;
```

方法2：思路类似方法1，只是使用from并列两个表

```sql
select e.emp_no,s.salary 
from employees e,salaries s
where e.emp_no=s.emp_no and e.hire_date=s.from_date
order by emp_no desc;
```

方法3：子查询

```sql
select s.emp_no,s.salary 
from salaries s
where from_date = (select hire_date from employees e where e.emp_no = s.emp_no)
order by s.emp_no desc;
```

方法4:获取 salaries 中 from_data 中最小的对应的 salary 和 emp_no ，因为 salaries 可能涨薪，所以这张表一个员工可能有多条记录。

```sql
SELECT emp_no,salary FROM salaries 
GROUP BY emp_no 
HAVING min( from_date ) 
ORDER BY emp_no DESC;
```

## 3、涉及内容

select * from a, b where a.id = 1 and a.id = b.id

隐式内连接，只有匹配的行