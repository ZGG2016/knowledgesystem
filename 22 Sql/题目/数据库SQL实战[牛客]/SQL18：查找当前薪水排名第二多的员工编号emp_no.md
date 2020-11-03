# [SQL18：查找当前薪水排名第二多的员工编号emp_no](https://www.nowcoder.com/practice/c1472daba75d4635b7f8540b837cc719?tpId=82&&tqId=29770&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找当前薪水(to_date='9999-01-01')排名第二多的员工编号emp_no、薪水salary、last_name以及first_name，你可以不使用order by完成吗

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


```sql
--先求salaries表里的最大值，再求出第二大的值，再将join后的表过滤这个条件。
select e.emp_no,s.salary,e.last_name,e.first_name
from employees e 
join salaries s on e.emp_no=s.emp_no
where s.to_date='9999-01-01'
and s.salary == (
    select max(salary) from salaries 
    where salary != (
        select max(salary) from salaries where to_date='9999-01-01'
    ) and to_date='9999-01-01'
);

-- 详细讲解见：https://blog.nowcoder.net/n/f35b41269fd84707a748724827510e23?f=comment
-- 如果是第二大，那么s1.salary <= s2.salary连接、分组、去重后，里面的元素只有两个。
select s.emp_no, s.salary, e.last_name, e.first_name
from salaries s join employees e
on s.emp_no = e.emp_no
where s.salary =
    (
    select s1.salary
    from salaries s1 join salaries s2      -- 自连接查询
    on s1.salary <= s2.salary
    group by s1.salary                     -- 当s1<=s2链接并以s1.salary分组时一个s1会对应多个s2
    having count(distinct s2.salary) = 2   -- (去重之后的数量就是对应的名次)
    and s1.to_date = '9999-01-01'
    and s2.to_date = '9999-01-01'
    )
and s.to_date = '9999-01-01'
```



## 3、涉及内容