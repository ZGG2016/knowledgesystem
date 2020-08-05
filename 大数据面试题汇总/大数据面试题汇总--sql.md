# 大数据面试题汇总--sql

## 判断sql语句的效率

[explain命令](https://www.cnblogs.com/deverz/p/11066043.html)

## Sql语句  一个表的数据复制到另一个表

表a的数据复制到表b

两表结构相同：

```sql
insert into b select * from a (where...);
```

两表结构不相同：

```sql
insert into b(col1,col2) select col1,col2 from a;
```

表a的数据和结构复制到表b

```sql
create table b select * from a;
```

只复制表a的结构，不复制数据

```sql
create table b like a;
```

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

    UNION 交换两个SELECT语句的顺序后结果仍然是一样的
    UNION ALL 在交换了SELECT语句的顺序后结果则不相同

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
