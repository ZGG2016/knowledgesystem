# [SQL69：牛客每个人最近的登录日期(四)](https://www.nowcoder.com/practice/e524dc7450234395aa21c75303a42b0a?tpId=82&&tqId=35087&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

牛客每天有很多人登录，请你统计一下牛客每个日期登录新用户个数，
有一个登录(login)记录表，简况如下:

![SQL69-1](./image/SQL69-1.png)


第1行表示id为2的用户在2020-10-12使用了客户端id为1的设备登录了牛客网，因为是第1次登录，所以是新用户

。。。

第4行表示id为2的用户在2020-10-13使用了客户端id为2的设备登录了牛客网，因为是第2次登录，所以是老用户

。。

最后1行表示id为4的用户在2020-10-15使用了客户端id为1的设备登录了牛客网，因为是第2次登录，所以是老用户


请你写出一个sql语句查询每个日期登录新用户个数，并且查询结果按照日期升序排序，上面的例子查询结果如下:

![SQL69-2](./image/SQL69-2.png)


查询结果表明:

2020-10-12，有3个新用户(id为2，3，1)登录

2020-10-13，没有新用户登录

2020-10-14，有1个新用户(id为4)登录

2020-10-15，没有新用户登录

## 2、题解

用原表left join第一次登录表，再过滤。

```sql
select a.date,sum(case when b.user_id is null then 0 else 1 end) new
from login a
left join (select user_id,min(date) date from login group by user_id) b
on a.user_id=b.user_id and a.date=b.date
group by a.date
order by a.date;

-- 用窗口函数
select a.date,
sum(case when rank=1 then 1 else 0 end) new
from 
(select date, row_number() over(partition by user_id order by date) rank
from login) a
group by date;
```

## 3、涉及内容