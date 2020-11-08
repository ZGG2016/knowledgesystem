# [SQL26：汇总各个部门当前员工的title类型的分配数目](https://www.nowcoder.com/practice/4bcb6a7d3e39423291d2f7bdbbff87f8?tpId=82&&tqId=29778&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)


## 1、题目

汇总各个部门当前员工的title类型的分配数目，即结果给出部门编号dept_no、dept_name、其部门下所有的当前(dept_emp.to_date = '9999-01-01')员工的当前(titles.to_date = '9999-01-01')title以及该类型title对应的数目count，结果按照dept_no升序排序

(注：因为员工可能有离职，所有dept_emp里面to_date不为'9999-01-01'就已经离职了，不计入统计，而且员工可能有晋升，所以如果titles.to_date 不为 '9999-01-01'，那么这个可能是员工之前的职位信息，也不计入统计)

```sql
CREATE TABLE `departments` (
`dept_no` char(4) NOT NULL,
`dept_name` varchar(40) NOT NULL,
PRIMARY KEY (`dept_no`));

CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE IF NOT EXISTS `titles` (
`emp_no` int(11) NOT NULL,
`title` varchar(50) NOT NULL,
`from_date` date NOT NULL,
`to_date` date DEFAULT NULL);
```

## 2、题解

注意这里的"以及该类型title对应的数目count"，是指某一title的数量。

```sql
select de.dept_no,dp.dept_name,t.title,count(t.title) count
from dept_emp de join titles t on de.emp_no=t.emp_no
join departments dp on de.dept_no=dp.dept_no  
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
group by de.dept_no,dp.dept_name,t.title
order by de.dept_no;
```

## 3、涉及内容