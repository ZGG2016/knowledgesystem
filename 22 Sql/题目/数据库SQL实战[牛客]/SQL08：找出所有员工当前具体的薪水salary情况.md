# [找出所有员工当前具体的薪水salary情况](https://www.nowcoder.com/practice/ae51e6d057c94f6d891735a48d1c2397?tpId=82&&tqId=29760&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

找出所有员工当前(to_date='9999-01-01')具体的薪水salary情况，对于相同的薪水只显示一次,并按照逆序显示。

CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));

输出描述:

	salary

	94692

	94409

	88958

	88070


## 2、题解


```sql
-- distinct
select distinct salary 
from salaries
where to_date='9999-01-01'
order by salary desc;

-- group by ，相比distinct性能更好
select salary
from salaries
where to_date='9999-01-01'
group by salary
order by salary desc;
```

