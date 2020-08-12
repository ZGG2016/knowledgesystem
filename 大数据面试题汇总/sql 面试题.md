# sql 面试题

## 判断sql语句的效率

[explain命令](https://www.cnblogs.com/deverz/p/11066043.html)

## Sql语句  一个表的数据复制到另一个表

表a的数据复制到表b

两表结构相同： (b已存在)

```sql
insert into b select * from a (where...);
```

两表结构不相同：(b已存在)

```sql
insert into b(col1,col2) select col1,col2 from a;
```

表a的数据和结构复制到表b (b不存在)，不会复制表的默认值

```sql
create table b select * from a;
```

只复制表a的结构，不复制数据

```sql
create table b like a;
```

MySQL 数据库不支持 SELECT ... INTO 语句，但支持 INSERT INTO ... SELECT 。

```sql
MariaDB [mysql]> select * from apps;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
+----+------------+-------------------------+---------+
3 rows in set (0.00 sec)

--表结构
MariaDB [mysql]> desc apps;
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| id       | int(11)      | NO   | PRI | NULL    | auto_increment |
| app_name | char(20)     | NO   |     |         |                |
| url      | varchar(255) | NO   |     |         |                |
| country  | char(10)     | NO   |     |         |                |
+----------+--------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

--create table ... as select...
MariaDB [mysql]> create table apps_bkp2 as  select * from apps;
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

--表结构
MariaDB [mysql]> desc apps_bkp2;
+----------+--------------+------+-----+---------+-------+
| Field    | Type         | Null | Key | Default | Extra |
+----------+--------------+------+-----+---------+-------+
| id       | int(11)      | NO   |     | 0       |       |
| app_name | char(20)     | NO   |     |         |       |
| url      | varchar(255) | NO   |     |         |       |
| country  | char(10)     | NO   |     |         |       |
+----------+--------------+------+-----+---------+-------+
4 rows in set (0.00 sec)

--create table ... like ...
MariaDB [mysql]> create table apps_bkp3 like apps;
Query OK, 0 rows affected (0.01 sec)

--表结构
MariaDB [mysql]> desc apps_bkp3;
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| id       | int(11)      | NO   | PRI | NULL    | auto_increment |
| app_name | char(20)     | NO   |     |         |                |
| url      | varchar(255) | NO   |     |         |                |
| country  | char(10)     | NO   |     |         |                |
+----------+--------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)


MariaDB [mysql]> insert into apps_bkp select * from apps_bkp2 where id='1';
Query OK, 1 row affected (0.00 sec)
Records: 1  Duplicates: 0  Warnings: 0


MariaDB [mysql]> select * from apps_bkp;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
|  1 | QQ APP     | http://im.qq.com/       | CN      |
+----+------------+-------------------------+---------+
4 rows in set (0.00 sec)
```
[Oracle中复制表的方法（create as select、insert into select、select into）](https://blog.csdn.net/weixin_39750084/article/details/81292774)

## Innodb和MyISAM区别

事务
    
    InnoDB支持事务，MyISAM不支持，对于InnoDB每一条SQL语言都默认封装成事务，自动提交，这样会影响速度，所以最好把多条SQL语言放在begin和commit之间，组成一个事务；

外键

    InnoDB支持外键，而MyISAM不支持。对一个包含外键的InnoDB表转为MYISAM会失败； 

索引
    
    InnoDB是聚集索引，使用B+Tree作为索引结构，数据文件是和（主键）索引绑在一起的（表数据文件本身就是按B+Tree组织的一个索引结构），必须要有主键，通过主键索引效率很高。但是辅助索引需要两次查询，先查询到主键，然后再通过主键查询到数据。因此，主键不应该过大，因为主键太大，其他索引也都会很大。

    MyISAM是非聚集索引，也是使用B+Tree作为索引结构，索引和数据文件是分离的，索引保存的是数据文件的指针。主键索引和辅助索引是独立的。

    也就是说：InnoDB的B+树主键索引的叶子节点就是数据文件，辅助索引的叶子节点是主键的值；而MyISAM的B+树主键索引和辅助索引的叶子节点都是数据文件的地址指针

表的具体行数

    InnoDB不保存表的具体行数，执行select count(*) from table时需要全表扫描。而MyISAM用一个变量保存了整个表的行数，执行上述语句时只需要读出该变量即可，速度很快（注意不能加有任何WHERE条件）；

主键

    InnoDB表必须有主键（用户没有指定的话会自己找或生产一个主键），而Myisam可以没有

更多：[InnoDB和MyISAM的区别(超详细)](https://www.cnblogs.com/timor0101/p/12883649.html)


## join ##

inner join

    内连接，只连接匹配的行（CROSS JOIN、INNER JOIN与JOIN是相同）

left join

    返回左表的全部行和右表满足ON条件的行，如果左表的行在右表中没有匹配，那么这一行右表中对应数据用NULL代替。

right join

    返回右表的全部行和左表满足ON条件的行，如果右表的行在左表中没有匹配，那么这一行左表中对应数据用NULL代替。
    
full join

    从左表 和右表 那里返回所有的行。如果其中一个表的数据行在另一个表中没有匹配的行，那么对面的数据用NULL代替
    

## union ##

合并两个或多个 SELECT 语句的结果集。

注意：

    UNION 内部的 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。
    同时，每条 SELECT 语句中的列的顺序必须相同。

UNION 和 UNION ALL 的区别：

对重复结果的处理：

    UNION 在进行表链接后会筛选掉重复的记录
    UNION ALL 不会去除重复记录。

对排序的处理：

    UNION 交换两个SELECT语句的顺序后结果仍然是一样的；会对结果排序
    UNION ALL 在交换了SELECT语句的顺序后结果则不相同；不会对结果排序

```sql
MariaDB [mysql]> select * from apps union select * from apps_bkp;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
+----+------------+-------------------------+---------+
3 rows in set (0.00 sec)

MariaDB [mysql]> select * from apps union all select * from apps_bkp;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
|  1 | QQ APP     | http://im.qq.com/       | CN      |
+----+------------+-------------------------+---------+
7 rows in set (0.01 sec)

MariaDB [mysql]> select * from apps_bkp union select * from apps;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
+----+------------+-------------------------+---------+
3 rows in set (0.00 sec)

MariaDB [mysql]> select * from apps_bkp union all select * from apps;
+----+------------+-------------------------+---------+
| id | app_name   | url                     | country |
+----+------------+-------------------------+---------+
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  1 | QQ APP     | http://im.qq.com/       | CN      |
|  2 | 微博 APP   | http://weibo.com/       | CN      |
|  3 | 淘宝 APP   | https://www.taobao.com/ | CN      |
+----+------------+-------------------------+---------+
7 rows in set (0.00 sec)
```

join 和 union 的区别：

    join 是两张表根据条件相同的部分合并生成一个记录集。
    union是两个记录集(字段要一样的)合并在一起，成为一个新的记录集 。

## 提高查询效率的方式 ##

1、in 和 not in 要慎用，否则会导致全表扫描，如：

    select id from t where num in(1,2,3)
    对于连续的数值，能用 between 就不要用 in 了：
    select id from t where num between 1 and 3

2、应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如：

    select id from t where num/2=100
    应改为:
    select id from t where num=100*2

3、应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如：

    select id from t where num=10 or num=20
    可以这样查询：
    select id from t where num=10
    union all
    select id from t where num=20

4、当索引列有大量数据重复时，SQL查询可能不会去利用索引，如一表中有字段sex，male、female几乎各一半，那么即使在sex上建了索引也对查询效率起不了作用。

5、索引并不是越多越好，会降低了 insert 及 update 的效率，因为 insert 或 update 时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有必要。

原文链接：

[提高SQL查询效率方法总结](https://zhuanlan.zhihu.com/p/93319347)

[提高SQL查询效率的23种方法](https://www.cnblogs.com/coder-wf/p/13371122.html)

## case when ... then ... else ... end

MySQL 的 case when 的语法有两种：

简单函数 

    CASE [col_name] WHEN [value1] THEN [result1]…ELSE [default] END
    枚举这个字段所有可能的值

搜索函数 

    CASE WHEN [expr] THEN [result1]…ELSE [default] END
    搜索函数可以写判断，并且搜索函数只会返回第一个符合条件的值，其他case被忽略


```sql
MariaDB [mysql]> select * from websites;
+----+--------------+---------------------------+-------+---------+
| id | name         | url                       | alexa | country |
+----+--------------+---------------------------+-------+---------+
|  1 | Google       | https://www.google.cm/    |     1 | USA     |
|  2 | 淘宝         | https://www.taobao.com/   |    13 | CN      |
|  3 | 菜鸟教程     | http://www.runoob.com/    |  4689 | CN      |
|  4 | 微博         | http://weibo.com/         |    20 | CN      |
|  5 | Facebook     | https://www.facebook.com/ |     3 | USA     |
+----+--------------+---------------------------+-------+---------+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case when alexa<=20 THEN 'a' ELSE 'b' end rlt from websites;
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | a   |
|  3 | b   |
|  4 | a   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case country when 'USA' THEN 'a' else 'b' end rlt from websites; 
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | b   |
|  3 | b   |
|  4 | b   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)


MariaDB [mysql]> select id,case when alexa>0 and alexa<=10 THEN 'a'  when alexa>10 and alexa<=20 then 'b' ELSE 'c' end rlt from websites;
+----+-----+
| id | rlt |
+----+-----+
|  1 | a   |
|  2 | b   |
|  3 | c   |
|  4 | b   |
|  5 | a   |
+----+-----+
5 rows in set (0.00 sec)

```

## coalesce

mysql的coalesce:

    coalesce()解释：返回参数中的第一个非空表达式（从左向右依次类推）；

```sql
-- Return 2
select coalesce(null,2,3); 
```