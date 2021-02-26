# hive 实现 wordcount

数据存储在hdfs

```sh
[root@zgg hive-3.1.2]# hadoop fs -cat /in/wc.txt
hello hadoop spark hello flink hadoop hadoop
```

1、建表

```sql
hive> create table wc(word string) row format delimited fields terminated by "\t";
OK
```

2、导入数据

```sql
hive> load data inpath '/in/wc.txt' overwrite into table wc;
Loading data to table default.wc
OK
```

3、统计

```sql
hive> select newword,count(*) c
    > from (select explode(split(word,' ')) newword from wc) a 
    > group by newword
    > order by c desc;
...
OK
hadoop  3
hello   2
spark   1
flink   1
```