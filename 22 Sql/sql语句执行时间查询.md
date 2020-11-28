# sql语句执行时间查询

**mysql 8.0.21**

## 1、show profiles 查看

确定 profiles 是不是打开了，默认是不打开的。

```sql
mysql> show profiles; 
Empty set (0.02 sec) 

mysql> show variables like "%pro%"; 
+---------------------------+-------+ 
| Variable_name | Value | 
+---------------------------+-------+ 
| profiling | OFF | 
| profiling_history_size | 15 | 
| protocol_version | 10 | 
| slave_compressed_protocol | OFF | 
+---------------------------+-------+ 
```

开启profile，测试

```sql
mysql> set profiling=1;
Query OK, 0 rows affected (0.00 sec)

mysql> show profiles;
mysql> show profiles;
+----------+------------+-----------------------------+
| Query_ID | Duration   | Query                       |
+----------+------------+-----------------------------+
|        1 | 0.00049175 | select * from actor limit 3 |
+----------+------------+-----------------------------+
```

## 2、通过时间差查看

```sql
delimiter // set @d=now();
select * from comment;
select timestampdiff(second,@d,now());
delimiter ;

Query OK, 0 rows affected (1 min 55.58 sec)

+----------------------------------+
| timestampdiff(second, @d, now()) |
+----------------------------------+
|                                2 |
+----------------------------------+
1 row in set (1 min 55.58 sec)
```