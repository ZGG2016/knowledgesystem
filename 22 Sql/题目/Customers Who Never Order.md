# Customers Who Never Order

## 1、题目

Suppose that a website contains two tables, the Customers table and the Orders table. Write a SQL query to find all customers who never order anything.

Table: Customers.

	+----+-------+
	| Id | Name  |
	+----+-------+
	| 1  | Joe   |
	| 2  | Henry |
	| 3  | Sam   |
	| 4  | Max   |
	+----+-------+

Table: Orders.

	+----+------------+
	| Id | CustomerId |
	+----+------------+
	| 1  | 3          |
	| 2  | 1          |
	+----+------------+

Using the above tables as example, return the following:

	+-----------+
	| Customers |
	+-----------+
	| Henry     |
	| Max       |
	+-----------+

## 2、题解

```sql
select a.Name Customers
    from Customers a
    left join Orders b on a.Id=b.CustomerId 
    where b.CustomerId is null;

# Runtime: 404 ms
# Memory Usage: 0B

select c.Name as Customers 
    from Customers c 
    where c.Id NOT IN (
        select o.CustomerId from Orders o
    );

#Runtime: 405 ms
#Memory Usage: 0B
```
## 3

MySQL 中处理 NULL 使用 IS NULL 和 IS NOT NULL 运算符:

	IS NULL: 当列的值是 NULL,此运算符返回 true。
	IS NOT NULL: 当列的值不为 NULL, 运算符返回 true。
	<=>: 比较操作符（不同于 = 运算符），当比较的的两个值相等或者都为 NULL 时返回 true。

IN 操作符允许您在 WHERE 子句中规定多个值:

	SELECT column_name(s)
	FROM table_name
	WHERE column_name IN (value1,value2,...);