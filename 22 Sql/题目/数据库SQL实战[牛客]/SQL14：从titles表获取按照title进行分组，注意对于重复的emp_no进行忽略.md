# [从titles表获取按照title进行分组，注意对于重复的emp_no进行忽略](https://www.nowcoder.com/practice/c59b452f420c47f48d9c86d69efdff20?tpId=82&&tqId=29766&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

从titles表获取按照title进行分组，每组个数大于等于2，给出title以及对应的数目t。
注意对于重复的emp_no进行忽略(即emp_no重复的title不计算，title对应的数目t不增加)。

```sql
CREATE TABLE IF NOT EXISTS `titles` (
`emp_no` int(11) NOT NULL,
`title` varchar(50) NOT NULL,
`from_date` date NOT NULL,
`to_date` date DEFAULT NULL);
```

## 2、题解


```sql
select title,count(distinct emp_no) t
from titles 
group by title
having t>=2;
```

```sql
select title,count(*) t
from (select distinct emp_no,title from titles) a
group by title
having t>=2;
```

## 3、涉及内容

(1)[distinct:用来去除查询结果中的重复记录的](https://blog.csdn.net/u010003835/article/details/79154457)

	只能在SELECT 语句中使用，不能在 INSERT, DELETE, UPDATE 中使用。

对一列操作:`SELECT DISTINCT city FROM test_distinct;`

对多列操作:把 SELECT 表达式的项 拼接起来选唯一值。 `SELECT DISTINCT province, city FROM test_distinct;`

