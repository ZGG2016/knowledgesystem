# [SQL25：获取员工其当前的薪水比其manager当前薪水还高的相关信息](https://www.nowcoder.com/practice/f858d74a030e48da8e0f69e21be63bef?tpId=82&&tqId=29777&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取员工其当前的薪水比其manager当前薪水还高的相关信息，当前表示to_date='9999-01-01',

结果第一列给出员工的emp_no，

第二列给出其manager的manager_no，

第三列给出该员工当前的薪水emp_salary,

第四列给该员工对应的manager当前的薪水manager_salary

```sql
CREATE TABLE `dept_emp` (
`emp_no` int(11) NOT NULL,
`dept_no` char(4) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `dept_manager` (
`dept_no` char(4) NOT NULL,
`emp_no` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`dept_no`));

CREATE TABLE `salaries` (
`emp_no` int(11) NOT NULL,
`salary` int(11) NOT NULL,
`from_date` date NOT NULL,
`to_date` date NOT NULL,
PRIMARY KEY (`emp_no`,`from_date`));
```

## 2、题解


```sql
select e.emp_no,m.emp_no manager_no,e.salary emp_salary,m.salary manager_salary
from (select de.emp_no,de.dept_no,s.salary from dept_emp de 
      join salaries s on de.emp_no=s.emp_no 
      where s.to_date='9999-01-01') e 
      join 
      (select dm.dept_no,dm.emp_no,s.salary from dept_manager dm
      join salaries s on dm.emp_no=s.emp_no 
      where s.to_date='9999-01-01') m 
      on e.dept_no=m.dept_no
      where e.salary >m.salary;
```

## 3、涉及内容