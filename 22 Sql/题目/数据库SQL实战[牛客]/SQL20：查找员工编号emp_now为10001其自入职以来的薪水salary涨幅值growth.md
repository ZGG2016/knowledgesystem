# [SQL20：查找员工编号emp_now为10001其自入职以来的薪水salary涨幅值growth](https://www.nowcoder.com/practice/c727647886004942a89848e2b5130dc2?tpId=82&&tqId=29772&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找员工编号emp_no为10001其自入职以来的薪水salary涨幅(总共涨了多少)growth(可能有多次涨薪，没有降薪)

```sql
CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

```sql
-- 薪水有涨，有降的情况，用当前薪水减入职时薪水
select (
    (select salary from salaries
    where emp_no=10001
    order by from_date desc limit 1)
    -(
    select salary from salaries
    where emp_no=10001
    order by from_date asc limit 1)
) as growth;

-- 他的薪水一直都在涨的情况，用最大值见最小值
select max(salary)-min(salary) as growth
from salaries
where emp_no=10001;
```

## 3、涉及内容