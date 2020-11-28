# Duplicate Emails

## 1、题目

Write a SQL query to find all duplicate emails in a table named Person.

	+----+---------+
	| Id | Email   |
	+----+---------+
	| 1  | a@b.com |
	| 2  | c@d.com |
	| 3  | a@b.com |
	+----+---------+

For example, your query should return the following for the above table:

	+---------+
	| Email   |
	+---------+
	| a@b.com |
	+---------+

Note: All emails are in lowercase.

## 2、题解

```sql
select distinct Email 
    from Person
    group by Email
    having count(*)>1;
------------------------------------
select distinct p1.Email 
	from Person p1 
	inner join Person p2 on p1.Email=p2.Email 
	where p1.Id != p2.Id;
```

```sql
mysql> select *  from Person p1  inner join Person p2 on p1.Email=p2.Email;                 
+------+---------+------+---------+
| Id   | Email   | Id   | Email   |
+------+---------+------+---------+
|    3 | a@b.com |    1 | a@b.com |
|    1 | a@b.com |    1 | a@b.com |
|    2 | c@d.com |    2 | c@d.com |
|    3 | a@b.com |    3 | a@b.com |
|    1 | a@b.com |    3 | a@b.com |
+------+---------+------+---------+
5 rows in set (0.00 sec)
```