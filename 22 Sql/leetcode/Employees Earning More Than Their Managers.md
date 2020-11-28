# Employees Earning More Than Their Managers

## 1、题目

The Employee table holds all employees including their managers. Every employee has an Id, and there is also a column for the manager Id.

	+----+-------+--------+-----------+
	| Id | Name  | Salary | ManagerId |
	+----+-------+--------+-----------+
	| 1  | Joe   | 70000  | 3         |
	| 2  | Henry | 80000  | 4         |
	| 3  | Sam   | 60000  | NULL      |
	| 4  | Max   | 90000  | NULL      |
	+----+-------+--------+-----------+

Given the Employee table, write a SQL query that finds out employees who earn more than their managers. For the above table, Joe is the only employee who earns more than his manager.

	+----------+
	| Employee |
	+----------+
	| Joe      |
	+----------+

## 2、题解

```sql
select a.Name Employee 
    from Employee a
    inner join Employee b on a.ManagerId=b.Id 
    where a.Salary > b.Salary;
    
#Runtime: 408 ms
#Memory Usage: 0B
```