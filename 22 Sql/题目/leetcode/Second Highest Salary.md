# [Second Highest Salary](https://leetcode.com/problems/second-highest-salary/)

## 1、题目描述

Write a SQL query to get the second highest salary from the Employee table.

	+----+--------+
	| Id | Salary |
	+----+--------+
	| 1  | 100    |
	| 2  | 200    |
	| 3  | 300    |
	+----+--------+

For example, given the above Employee table, the query should return 200 as the second highest salary. If there is no second highest salary, then the query should return null.

	+---------------------+
	| SecondHighestSalary |
	+---------------------+
	| 200                 |
	+---------------------+

## 2、题解

```sql
# mysql
# 先取最大值，再过滤调最大值，就是第二大值。
select max(Salary) SecondHighestSalary 
    from Employee 
    where Salary<(select max(Salary) from Employee);

-----------------------------------------------------------
# 取出最大值，取偏移
select 
    ifnull(
        (select distinct Salary 
         from Employee 
         order by Salary desc
         limit 1 offset 1),
    null) as  SecondHighestSalary;
```

## 3、涉及内容

(1)IFNULL() 函数

	IFNULL(expression, alt_value)

判断第一个表达式是否为 NULL，如果为 NULL 则返回第二个参数的值，如果不为 NULL 则返回第一个参数的值。

```sql
SELECT IFNULL(NULL, "RUNOOB");  #RUNOOB

SELECT IFNULL("Hello", "RUNOOB"); #Hello
```

类似函数：

	IF(expr1,expr2,expr3)，如果expr1的值为true，则返回expr2的值，如果expr1的值为false，则返回expr3的值。

	SELECT IF(TRUE,'A','B');    # A
	SELECT IF(FALSE,'A','B');   # B

	---------------------------------------------

	NULLIF(expr1,expr2)，如果expr1=expr2成立，那么返回值为null，否则返回值为expr1的值。

	SELECT NULLIF('A','A');     # null
	SELECT NULLIF('A','B');     # A

	---------------------------------------------

	ISNULL(expr)，如果expr的值为null，则返回1，如果expr1的值不为null，则返回0。

	SELECT ISNULL(NULL);        # 1
	SELECT ISNULL('HELLO');     # 0

(2)limit、offset

	limit y : 读 y 条数据

	limit x, y : 跳过 x 条数据，读 y 条数据
	【limit 0,1读第一条，limit 1,1跳过第一条读第二条】

	limit y offset x : 跳过 x 条数据，读 y 条数据

	select * from test limit 30; 
	select * from test limit 30, 30; 
	select * from test limit 30 offset 30;  

(3)ORDER BY 

用于根据指定的列对结果集进行排序。默认升序asc。降序是desc。

(4)[子句查询](https://blog.csdn.net/Noblelxl/article/details/90646648)