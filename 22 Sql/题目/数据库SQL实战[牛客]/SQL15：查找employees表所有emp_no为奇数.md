# [查找employees表所有emp_no为奇数](https://www.nowcoder.com/practice/a32669eb1d1740e785f105fa22741d5c?tpId=82&&tqId=29767&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找employees表所有emp_no为奇数，且last_name不为Mary(注意大小写)的员工信息，并按照hire_date逆序排列(题目不能使用mod函数)

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

## 2、题解


```sql
select * from employees
where emp_no & 1 and last_name!='Mary'
order by hire_date desc;
```

```sql
select * from employees
where emp_no%2=1 and last_name!='Mary'
order by hire_date desc;
```

## 3、涉及内容

(1)运算符

	/ 或 DIV：	除法

	% 或 MOD	：  取余

	=		：  等于	

	<=>	    ：  严格比较两个NULL值是否相等	。两个操作码均为NULL时，其所得值为1；而当一个操作码为NULL时，其所得值为0

	<>, !=	：  不等于

	&       ：  按位与

	|       ：  按位或

	^       ：  按位异或

	!       ：  取反

	<<      ：  左移
	
	>>      ：  右移