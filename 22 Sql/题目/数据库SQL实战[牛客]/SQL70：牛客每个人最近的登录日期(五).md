# [SQL70：牛客每个人最近的登录日期(五)](https://www.nowcoder.com/practice/ea0c56cd700344b590182aad03cc61b8?tpId=82&&tqId=35088&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

牛客每天有很多人登录，请你统计一下牛客每个日期新用户的次日留存率。
有一个登录(login)记录表，简况如下:

![SQL70-1](./image/SQL70-1.png)

第1行表示id为2的用户在2020-10-12使用了客户端id为1的设备登录了牛客网，因为是第1次登录，所以是新用户

。。。

第4行表示id为2的用户在2020-10-13使用了客户端id为2的设备登录了牛客网，因为是第2次登录，所以是老用户

。。

最后1行表示id为4的用户在2020-10-15使用了客户端id为1的设备登录了牛客网，因为是第2次登录，所以是老用户



请你写出一个sql语句查询每个日期新用户的次日留存率，结果保留小数点后面3位数(3位之后的四舍五入)，并且查询结果按照日期升序排序，上面的例子查询结果如下:

![SQL70-2](./image/SQL70-2.png)

查询结果表明:

2020-10-12登录了3个(id为2，3，1)新用户，2020-10-13，只有2个(id为2,1)登录，故2020-10-12新用户次日留存率为2/3=0.667;

2020-10-13没有新用户登录，输出0.000;

2020-10-14登录了1个(id为4)新用户，2020-10-15，id为4的用户登录，故2020-10-14新用户次日留存率为1/1=1.000;

2020-10-15没有新用户登录，输出0.000;

(注意:sqlite里查找某一天的后一天的用法是:date(yyyy-mm-dd, '+1 day')，sqlite里1/2得到的不是0.5，得到的是0，只有`1*1.0/2`才会得到0.5)

## 2、题解

要求`每个日期新用户的次日留存率`。

先取出所有新用户，得到表b，和原表a左连接(注意关联条件)，就能得到`b.user_id,b.date,a.user_id,a.date`。

此时，如果新用户在第二天登录，`a.user_id,a.date`就不会为null。

由此可以算出在第二天登录的新用户数(每个分组下)，进而算出`每个日期新用户的次日留存率`。

但这个结果只是`存在新用户的次日留存的情况(或日期)`，题目还要求算不存在的情况，即留存率为0的情况。

所以，取出留存率为0的情况和原结果合并。

```sql
select a.date,
round(sum(case when b.user_id is not null then 1 else 0 end)/count(a.user_id),3) p
from (select user_id,min(date) date from login group by user_id) a
left join login b 
on a.user_id=b.user_id and date_add(a.date,interval 1 day)=b.date
group by a.date
union 
select date,0.000 p
from login 
where date not in (select min(date) date from login group by user_id)
order by date;


select a.date,round(ifnull(1.0*count(l.user_id)/count(b.user_id),0),3) p
from 
(select date from login group by date) a 
left join 
(select user_id,min(date) d from login group by user_id) b
on a.date=b.d
left join login l 
on b.user_id=l.user_id and l.date=date_add(a.date,interval 1 day)
group by a.date;

-- ---------------------------
mysql> select a.date,b.user_id,b.d,l.user_id,l.date
    -> from 
    -> (select date from login group by date) a 
    -> left join 
    -> (select user_id,min(date) d from login group by user_id) b
    -> on a.date=b.d
    -> left join login l 
    -> on b.user_id=l.user_id and l.date=date_add(a.date,interval 1 day);
+------------+---------+------------+---------+------------+
| date       | user_id | d          | user_id | date       |
+------------+---------+------------+---------+------------+
| 2020-10-12 |       2 | 2020-10-12 |       2 | 2020-10-13 |
| 2020-10-12 |       3 | 2020-10-12 |    NULL | NULL       |
| 2020-10-12 |       1 | 2020-10-12 |       1 | 2020-10-13 |
| 2020-10-13 |    NULL | NULL       |    NULL | NULL       |
| 2020-10-14 |       4 | 2020-10-14 |       4 | 2020-10-15 |
| 2020-10-15 |    NULL | NULL       |    NULL | NULL       |
+------------+---------+------------+---------+------------+
```

## 3、涉及内容
