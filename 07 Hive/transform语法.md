# transform语法


1.数据集

格式：

	user id | item id | rating | timestamp. 

数据样例：

	196		242     3       881250949
	186     302     3       891717742
	22      377     1       878887116
	244     51      2       880606923
	166     346     1       886397596
	298     474     4       884182806
	115     265     2       881171488
	253     465     5       891628467
	305     451     3       886324817
	6       86      3       883603013
	62      257     2       879372434

2.建表，并导入数据

```sql
-- 建表
create table movies_data(
    user_id int,
    item_id int,
    rating int,
    rate_time string
)row format delimited
fields terminated by "\t";

-- 导入数据
load data local inpath '/root/data/u.data' into table movies_data;
```

3.编写脚本

在 mapper 中，将 rating 字段的值追加一个 `point` 字符串，形式为：`1point`

```python
# mapper_test.py
import sys

for line in sys.stdin:
    user_id,item_id,rating,rate_time = line.strip().split("\t")
    print("\t".join([user_id,item_id,rating+'point',rate_time]))
```

在 reducer 中，将 rating 字段的值再追加一个 `point` 字符串，形式为：`1pointpoint`

```python
# reducer_test.py
import sys
import datetime

for line in sys.stdin:
  user_id,item_id,rating,rate_time = line.strip().split("\t")

  weekday = datetime.datetime.fromtimestamp(float(rate_time)).isoweekday()
  print("\t".join([userid, item_id, rating, str(weekday)]))
```


4.添加 hive 的 classpath

```sql
hive> add file /root/python_script/mapper_test.py;
Added resources: [/root/python_script/mapper_test.py]

hive> add file /root/python_script/reducer_test.py;
Added resources: [/root/python_script/reducer_test.py]
```

5.创建一个存储最终结果的表

```sql
-- 建表
create table movies_data_res(
    user_id int,
    item_id int,
    rating string,
    rate_time string
)row format delimited
fields terminated by "\t";
```

6.编写sql语句

```sql
FROM (
  FROM movies_data
  SELECT TRANSFORM(movies_data.user_id,movies_data.item_id,movies_data.rating,movies_data.rate_time)
  USING 'python mapper_test.py'
  AS (user_id,item_id,rating,rate_time)
  ) map_output
INSERT OVERWRITE TABLE movies_data_res
  SELECT TRANSFORM(map_output.user_id,map_output.item_id,map_output.rating,map_output.rate_time)
  USING 'python reducer_test.py'
  AS (user_id int,item_id int,rating string,rate_time string);
```

7.查看结果

```sql
hive> select * from movies_data_res;
OK
196     242     3pointpoint     881250949
186     302     3pointpoint     891717742
22      377     1pointpoint     878887116
244     51      2pointpoint     880606923
166     346     1pointpoint     886397596
298     474     4pointpoint     884182806
115     265     2pointpoint     881171488
253     465     5pointpoint     891628467
305     451     3pointpoint     886324817
6       86      3pointpoint     883603013
62      257     2pointpoint     879372434
```