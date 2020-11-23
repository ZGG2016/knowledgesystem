# [SQL66：牛客每个人最近的登录日期(一)](https://www.nowcoder.com/practice/ca274ebe6eac40ab9c33ced3f2223bb2?tpId=82&&tqId=35084&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

牛客每天有很多人登录，请你统计一下牛客每个用户最近登录是哪一天。

有一个登录(login)记录表，简况如下:

![SQL66-1](./image/SQL66-1.png)

第1行表示id为2的用户在2020-10-12使用了客户端id为1的设备登录了牛客网

。。。

第4行表示id为3的用户在2020-10-13使用了客户端id为2的设备登录了牛客网


请你写出一个sql语句查询每个用户最近一天登录的日子，并且按照user_id升序排序，上面的例子查询结果如下:

![SQL66-2](./image/SQL66-2.png)

查询结果表明:

user_id为2的最近的登录日期在2020-10-13

user_id为3的最近的登录日期也是2020-10-13

## 2、题解


```sql
# sqlite

select user_id,max(date) d
from login
group by user_id
order by user_id;
```

## 3、涉及内容