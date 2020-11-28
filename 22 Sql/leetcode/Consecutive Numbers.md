# Consecutive Numbers

## 1、问题

Write a SQL query to find all numbers that appear at least three times consecutively.

	+----+-----+
	| Id | Num |
	+----+-----+
	| 1  |  1  |
	| 2  |  1  |
	| 3  |  1  |
	| 4  |  2  |
	| 5  |  1  |
	| 6  |  2  |
	| 7  |  2  |
	+----+-----+

For example, given the above Logs table, 1 is the only number that appears consecutively for at least three times.

	+-----------------+
	| ConsecutiveNums |
	+-----------------+
	| 1               |
	+-----------------+

## 2、题解

方法1：内连接自身两次，如果连续出现三次，那么结果表的三个num都相同。

```sql
select distinct a.num as ConsecutiveNums
    from Logs a
    inner join Logs b on b.id=a.id+1 and b.num=a.num
    inner join Logs c on c.id=a.id+2 and c.num=a.num;

```

帮助理解：

```sql
MariaDB [mysql]> select * from Logs a inner join Logs b on b.Id=a.Id+1; 
+------+------+------+------+
| Id   | Num  | Id   | Num  |
+------+------+------+------+
|    1 |    1 |    2 |    1 |
|    2 |    1 |    3 |    1 |
|    3 |    1 |    4 |    2 |
|    4 |    2 |    5 |    1 |
|    5 |    1 |    6 |    2 |
|    6 |    2 |    7 |    2 |
+------+------+------+------+
6 rows in set (0.00 sec)

MariaDB [mysql]> select * from Logs a inner join Logs b on b.Id=a.Id+1 and b.Num=a.Num;       
+------+------+------+------+
| Id   | Num  | Id   | Num  |
+------+------+------+------+
|    1 |    1 |    2 |    1 |
|    2 |    1 |    3 |    1 |
|    6 |    2 |    7 |    2 |
+------+------+------+------+
3 rows in set (0.00 sec)

MariaDB [mysql]> select * from Logs a inner join Logs b on b.Id=a.Id+1 and b.Num=a.Num inner join Logs c on c.Id=a.Id+2 and c.Num=a.Num;      
+------+------+------+------+------+------+
| Id   | Num  | Id   | Num  | Id   | Num  |
+------+------+------+------+------+------+
|    1 |    1 |    2 |    1 |    3 |    1 |
+------+------+------+------+------+------+
1 row in set (0.00 sec)
```

方法2：利用窗口函数

```sql
SELECT distinct num as "ConsecutiveNums"
FROM(
SELECT id,num,
	lag (num,1) over(order by id ASC) lag1,
  	lag (num,2) over(order by id ASC) lag2
FROM logs
order BY 1
  ) a
  where num=lag1 and lag1=lag2
```