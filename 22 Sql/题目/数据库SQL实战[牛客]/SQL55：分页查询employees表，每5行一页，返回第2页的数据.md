# [SQL55：分页查询employees表，每5行一页，返回第2页的数据](https://www.nowcoder.com/practice/f24966e0cb8a49c192b5e65339bc8c03?tpId=82&&tqId=29823&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

分页查询employees表，每5行一页，返回第2页的数据

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
SELECT * FROM employees LIMIT 5,5;
```

## 3、涉及内容

(1)limit、offset

	limit y : 读 y 条数据

	limit x, y : 跳过 x 条数据，读 y 条数据
	【limit 0,1读第一条，limit 1,1跳过第一条读第二条】

	limit y offset x : 跳过 x 条数据，读 y 条数据

	select * from test limit 30; 
	select * from test limit 30, 30; 
	select * from test limit 30 offset 30; 