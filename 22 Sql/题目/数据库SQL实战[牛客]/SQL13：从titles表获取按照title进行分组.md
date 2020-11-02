# [从titles表获取按照title进行分组](https://www.nowcoder.com/practice/72ca694734294dc78f513e147da7821e?tpId=82&&tqId=29765&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

从titles表获取按照title进行分组，每组个数大于等于2，给出title以及对应的数目t。

```sql
CREATE TABLE IF NOT EXISTS "titles" (
`emp_no` int(11) NOT NULL,
`title` varchar(50) NOT NULL,
`from_date` date NOT NULL,
`to_date` date DEFAULT NULL);
```

## 2、题解

```sql
select title,count(*) t
from titles
group by title
having t>=2;
```

## 3、涉及内容

注意where和having的区别

(1)HAVING 子句

在 SQL 中增加 HAVING 子句原因是，**WHERE 关键字无法与聚合函数一起使用**。

HAVING 子句可以让我们**筛选分组后的各组数据**。

```sql
SELECT column_name, aggregate_function(column_name)
FROM table_name
WHERE column_name operator value
GROUP BY column_name
HAVING aggregate_function(column_name) operator value;
```

(2)where 和 having 的区别

where 子句的作用是在对查询结果进行分组前，将不符合where条件的行去掉，也就是**在分组之前过滤数据**，条件中不能包含聚和函数，使用where条件限制特定的行。 

having 子句的作用是筛选满足条件的组，即**在分组之后过滤数据**，条件中经常包含聚合函数，使用having 条件过滤特定的组，也可以使用多个分组标准进行分组。

总之一条sql中有where having group by的时候，顺序是 where  group by having

```sql

mysql> SELECT sal from WINDOWFUNC_TEST WHERE sal>3000;
+------+
| sal  |
+------+
| 4000 |
| 6000 |
| 5000 |
+------+
3 rows in set (0.00 sec)

mysql> SELECT sal from WINDOWFUNC_TEST having sal>3000;     
+------+
| sal  |
+------+
| 4000 |
| 6000 |
| 5000 |
+------+
3 rows in set (0.00 sec)

mysql> SELECT dept from WINDOWFUNC_TEST having sal>3000;     
ERROR 1054 (42S22): Unknown column 'sal' in 'having clause'

mysql> SELECT dept from WINDOWFUNC_TEST where sal>3000;      
+------+
| dept |
+------+
| d2   |
| d2   |
| d2   |
+------+
3 rows in set (0.00 sec)

mysql> SELECT DEPT,AVG(SAL) A FROM WINDOWFUNC_TEST GROUP BY DEPT HAVING A>1000;
+------+-----------+
| DEPT | A         |
+------+-----------+
| d1   | 2000.0000 |
| d2   | 5000.0000 |
+------+-----------+
2 rows in set (0.00 sec)

mysql> SELECT DEPT,AVG(SAL) A FROM WINDOWFUNC_TEST WHERE A>1000 GROUP BY DEPT; 
ERROR 1054 (42S22): Unknown column 'A' in 'where clause'
```