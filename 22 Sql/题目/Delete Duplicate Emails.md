# Delete Duplicate Emails

## 1、题目

Write a SQL query to delete all duplicate email entries in a table named Person, keeping only unique emails based on its smallest Id.

	+----+------------------+
	| Id | Email            |
	+----+------------------+
	| 1  | john@example.com |
	| 2  | bob@example.com  |
	| 3  | john@example.com |
	+----+------------------+

Id is the primary key column for this table.

For example, after running your query, the above Person table should have the following rows:

	+----+------------------+
	| Id | Email            |
	+----+------------------+
	| 1  | john@example.com |
	| 2  | bob@example.com  |
	+----+------------------+

Note:

	Your output is the whole Person table after executing your sql. Use delete statement.

## 2、题解

```sql
delete from Person
    where Id not in (
        select Id from (
                select min(Id) Id,Email
                    from Person group by Email
                 ) a
    );
#Runtime: 1743 ms
#Memory Usage: 0B

delete p1 from Person p1 
    inner join Person p2 on p1.Email=p2.Email 
    where p1.Id>p2.Id;
#Runtime: 2002 ms
#Memory Usage: 0B
```

## 3

DELETE 语句用于删除表中的行。

	DELETE FROM table_name
	WHERE some_column=some_value;

请注意:

	WHERE 子句规定哪条记录或者哪些记录需要删除。如果您省略了 WHERE 子句，所有的记录都将被删除！