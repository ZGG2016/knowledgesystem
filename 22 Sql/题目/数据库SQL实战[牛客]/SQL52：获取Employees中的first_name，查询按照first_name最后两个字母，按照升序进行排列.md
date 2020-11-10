# [SQL52：获取Employees中的first_name，查询按照first_name最后两个字母，按照升序进行排列](https://www.nowcoder.com/practice/74d90728827e44e2864cce8b26882105?tpId=82&&tqId=29820&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

获取Employees中的first_name，查询按照first_name最后两个字母，按照升序进行排列

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
select first_name from employees 
order by right(first_name,2);
```

## 3、涉及内容

(1)mysql截取字符串函数

- left(str,length) 

从左边截取length个

```sql
mysql> select left("text",0),left("text",1),left("text",2),left("text",-1),left("text",-2);
+----------------+----------------+----------------+-----------------+-----------------+
| left("text",0) | left("text",1) | left("text",2) | left("text",-1) | left("text",-2) |
+----------------+----------------+----------------+-----------------+-----------------+
|                | t              | te             |                 |                 |
+----------------+----------------+----------------+-----------------+-----------------+
1 row in set (0.00 sec)
```

- right(str,length) 

从右边截取length个

```sql
mysql> select right("text",0),right("text",1),right("text",2),right("text",-1),right("text",-2);                    
+-----------------+-----------------+-----------------+------------------+------------------+
| right("text",0) | right("text",1) | right("text",2) | right("text",-1) | right("text",-2) |
+-----------------+-----------------+-----------------+------------------+------------------+
|                 | t               | xt              |                  |                  |
+-----------------+-----------------+-----------------+------------------+------------------+
1 row in set (0.00 sec)
```

- substring(str,index) 

	当index>0：从左到右，从index处开始截取直到结束 

	当index<0：从左到右，从倒数第index处开始截取直到结束 

	当index=0：返回空

```sql
mysql> select substring("text",1),substring("text",-1),substring("text",0);
+---------------------+----------------------+---------------------+
| substring("text",1) | substring("text",-1) | substring("text",0) |
+---------------------+----------------------+---------------------+
| text                | t                    |                     |
+---------------------+----------------------+---------------------+
1 row in set (0.00 sec)
```

- substring(str,index,len) 

从index开始，截取len长度

```sql
mysql> select substring("text",1,3),substring("text",-3,2);
+-----------------------+------------------------+
| substring("text",1,3) | substring("text",-3,2) |
+-----------------------+------------------------+
| tex                   | ex                     |
+-----------------------+------------------------+
1 row in set (0.00 sec)
```

- substring_index(str,delim,count)

delim 分隔符

count 计数：

	  如果count是正数，那么就是从左往右数，第count个分隔符的左边的全部内容

      相反，如果是负数，那么就是从右边开始数，第count个分隔符右边的所有内容

```sql
mysql> select substring_index("www.baidu.com",'.',2);
+----------------------------------------+
| substring_index("www.baidu.com",'.',2) |
+----------------------------------------+
| www.baidu                              |
+----------------------------------------+
1 row in set (0.00 sec)

mysql> select substring_index("www.baidu.com",'.',-2);
+-----------------------------------------+
| substring_index("www.baidu.com",'.',-2) |
+-----------------------------------------+
| baidu.com                               |
+-----------------------------------------+
1 row in set (0.00 sec)

mysql> select substring_index("www.baidu.com",'.',0);
+----------------------------------------+
| substring_index("www.baidu.com",'.',0) |
+----------------------------------------+
|                                        |
+----------------------------------------+
1 row in set (0.00 sec)
```

- subdate(date,day)

时间减去后面的day

```sql
mysql> select subdate("2020-11-10",1),subdate("2020-11-10",-1),subdate("2020-11-10",0);
+-------------------------+--------------------------+-------------------------+
| subdate("2020-11-10",1) | subdate("2020-11-10",-1) | subdate("2020-11-10",0) |
+-------------------------+--------------------------+-------------------------+
| 2020-11-09              | 2020-11-11               | 2020-11-10              |
+-------------------------+--------------------------+-------------------------+
1 row in set (0.00 sec)
```

- subtime(expr1,expr2)  

时间相减 expr1-expr2

```sql
mysql> SELECT SUBTIME('1997-12-31 23:59:59.999999','1 1:1:1.000002');
+--------------------------------------------------------+
| SUBTIME('1997-12-31 23:59:59.999999','1 1:1:1.000002') |
+--------------------------------------------------------+
| 1997-12-30 22:58:58.999997                             |
+--------------------------------------------------------+
1 row in set (0.00 sec)
```