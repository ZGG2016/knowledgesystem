# [SQL54：查找排除当前最大、最小salary之后的员工的平均工资avg_salary](https://www.nowcoder.com/practice/95078e5e1fba4438b85d9f11240bc591?tpId=82&&tqId=29822&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找排除最大、最小salary之后的当前(to_date = '9999-01-01' )员工的平均工资avg_salary。

```sql
CREATE TABLE `salaries` ( `emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解


```sql
select avg(salary) avg_salary
from salaries
where to_date = '9999-01-01' 
and salary not in (
    select max(salary) from salaries where to_date = '9999-01-01'
    union 
    select min(salary) from salaries where to_date = '9999-01-01');
```

## 3、涉及内容