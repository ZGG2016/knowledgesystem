# [SQL27：给出每个员工每年薪水涨幅超过5000的员工编号emp_no](https://www.nowcoder.com/practice/eb9b13e5257744db8265aa73de04fd44?tpId=82&&tqId=29779&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)


## 1、题目

给出每个员工每年薪水涨幅超过5000的员工编号emp_no、薪水变更开始日期from_date以及薪水涨幅值salary_growth，并按照salary_growth逆序排列。

提示：在sqlite中获取datetime时间对应的年份函数为strftime('%Y', to_date)

(数据保证每个员工的每条薪水记录to_date-from_date=1年，而且同一员工的下一条薪水记录from_data=上一条薪水记录的to_data)

```sql
CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解

注意：同一员工的下一条薪水记录from_data=上一条薪水记录的to_data

```sql
select s1.emp_no,s2.from_date,(s2.salary-s1.salary) salary_growth
from salaries s1 
join salaries s2 on s1.emp_no=s2.emp_no and s1.to_date=s2.from_date
where s2.salary-s1.salary > 5000
order by salary_growth desc;
```

## 3、涉及内容