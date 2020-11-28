# [Combine Two Tables](https://leetcode.com/problems/combine-two-tables/)

## 1、题目描述

Table: Person

	+-------------+---------+
	| Column Name | Type    |
	+-------------+---------+
	| PersonId    | int     |
	| FirstName   | varchar |
	| LastName    | varchar |
	+-------------+---------+

PersonId is the primary key column for this table.
Table: Address

	+-------------+---------+
	| Column Name | Type    |
	+-------------+---------+
	| AddressId   | int     |
	| PersonId    | int     |
	| City        | varchar |
	| State       | varchar |
	+-------------+---------+

AddressId is the primary key column for this table.
 

Write a SQL query for a report that provides the following information for each person in the Person table, regardless if there is an address for each of those people:

	FirstName, LastName, City, State

## 2、题解

```sql
select p.FirstName, p.LastName,a.City, a.State
	from Person p 
	left join Address a on p.PersonId =a.PersonId;
```

## 3、涉及内容

(1)[join理解](https://github.com/ZGG2016/knowledgesystem/blob/master/22%20Sql/join%E7%90%86%E8%A7%A3.md)