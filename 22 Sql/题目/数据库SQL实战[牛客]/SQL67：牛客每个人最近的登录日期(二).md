# [SQL67：牛客每个人最近的登录日期(二)](https://www.nowcoder.com/practice/7cc3c814329546e89e71bb45c805c9ad?tpId=82&&tqId=35085&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)


## 1、题目

牛客每天有很多人登录，请你统计一下牛客每个用户最近登录是哪一天，用的是什么设备。

有一个登录(login)记录表，简况如下:

![SQL66-1](./image/SQL66-1.png)

第1行表示id为2的用户在2020-10-12使用了客户端id为1的设备登录了牛客网

。。。

第4行表示id为3的用户在2020-10-13使用了客户端id为2的设备登录了牛客网

还有一个用户(user)表，简况如下:

![SQL67-1](./image/SQL67-1.png)


还有一个客户端(client)表，简况如下:

![SQL67-2](./image/SQL67-2.png)


请你写出一个sql语句查询每个用户最近一天登录的日子，用户的名字，以及用户用的设备的名字，并且查询结果按照user的name升序排序，上面的例子查询结果如下:

![SQL67-3](./image/SQL67-3.png)

查询结果表明:

fh最近的登录日期在2020-10-13，而且是使用pc登录的

wangchao最近的登录日期也是2020-10-13，而且是使用ios登录的


## 2、题解


```sql
# sqlite
select u.name u_n,c.name c_n,max(l.date) d
from login l 
join user u on l.user_id=u.id
join client c on l.client_id=c.id
group by u_n
order by u_n;

select u.name u_n,c.name c_n,lg.date d
from (
    select user_id,client_id,max(date) date
    from login group by user_id) lg
    join user u on lg.user_id=u.id
    join client c on lg.client_id=c.id
order by u_n;

select user.name as u_n, client.name as c_n,
login.date
from login 
join user on login.user_id=user.id
join client on login.client_id=client.id
where (login.user_id,login.date) in
(select user_id,max(date) from login group by login.user_id )
order by user.name;
```

## 3、涉及内容