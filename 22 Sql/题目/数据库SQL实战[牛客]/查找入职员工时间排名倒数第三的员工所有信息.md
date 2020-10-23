# [查找入职员工时间排名倒数第三的员工所有信息](https://www.nowcoder.com/practice/ec1ca44c62c14ceb990c3c40def1ec6c?tpId=82&&tqId=29754&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找入职员工时间排名倒数第三的员工所有信息，为了减轻入门难度，目前所有的数据里员工入职的日期都不是同一天

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

输入描述:

无

输出描述:

	emp_no	birth_date	first_name	last_name	gender	hire_date

	10005   1955-01-21   Kyoichi     Maliniak     M    1989-09-12


## 2、题解

当所有的数据里员工入职的日期都不是同一天：

```sql
select emp_no,birth_date,first_name,last_name,gender,hire_date from employees 
	order by hire_date desc limit 2,1;  # 注意这里是2
```

当所有的数据里员工入职的日期存在是同一天：

```sql
select emp_no,birth_date,first_name,last_name,gender,hire_date from employees 
    where hire_date = (select distinct hire_date from employees order by hire_date desc limit 2,1);
-- group by 比 distinct 效率更高
select emp_no,birth_date,first_name,last_name,gender,hire_date from employees where hire_date = 
(select hire_date from employees group by hire_date order by hire_date desc limit 2,1)

-- 窗口函数
select emp_no,birth_date,first_name,last_name,gender,hire_date from 
(select emp_no,birth_date,first_name,last_name,gender,hire_date,
dense_rank() over (order by hire_date desc) rank
from employees) e
where rank=3;
```