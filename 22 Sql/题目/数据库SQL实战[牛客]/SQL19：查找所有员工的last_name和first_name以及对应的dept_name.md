# [SQL19：查找所有员工的last_name和first_name以及对应的dept_name](https://www.nowcoder.com/practice/5a7975fabe1146329cee4f670c27ad55?tpId=82&&tqId=29771&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找所有员工的last_name和first_name以及对应的dept_name，也包括暂时没有分配部门的员工

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

三表join

```sql
SELECT em.last_name, em.first_name, dp.dept_name
FROM (employees AS em LEFT JOIN dept_emp AS de ON em.emp_no = de.emp_no)
LEFT JOIN departments AS dp ON de.dept_no = dp.dept_no;
```

## 3、涉及内容

(1)多表join:

INNER JOIN 连接两个数据表的用法： 

	SELECT * FROM 表1 INNER JOIN 表2 ON 表1.字段号=表2.字段号 

INNER JOIN 连接三个数据表的用法： 

	SELECT * FROM (表1 INNER JOIN 表2 ON 表1.字段号=表2.字段号) INNER JOIN 表3 ON 表1.字段号=表3.字段号 

INNER JOIN 连接四个数据表的用法： 

	SELECT * FROM ((表1 INNER JOIN 表2 ON 表1.字段号=表2.字段号) INNER JOIN 表3 ON 表1.字段号=表3.字段号) INNER JOIN 表4 ON Member.字段号=表4.字段号 

INNER JOIN 连接五个数据表的用法： 

	SELECT * FROM (((表1 INNER JOIN 表2 ON 表1.字段号=表2.字段号) INNER JOIN 表3 ON 表1.字段号=表3.字段号) INNER JOIN 表4 ON Member.字段号=表4.字段号) INNER JOIN 表5 ON Member.字段号=表5.字段号