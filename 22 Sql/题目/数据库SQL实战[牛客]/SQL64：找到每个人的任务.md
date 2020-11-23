# [SQL64：找到每个人的任务]()


## 1、题目

有一个person表，主键是id，如下:

![SQL64-1](./image/SQL64-1.png)

有一个任务(task)表如下，主键也是id，如下:

![SQL64-2](./image/SQL64-2.png)

请你找到每个人的任务情况，并且输出出来，没有任务的也要输出，而且输出结果按照person的id升序排序，输出情况如下:

![SQL64-3](./image/SQL64-3.png)

## 2、题解


```sql
select p.id,p.name,t.content 
from person as p 
left join task as t on p.id=t.person_id 
order by p.id asc;
```

## 3、涉及内容