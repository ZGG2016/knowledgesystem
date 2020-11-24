# [SQL68：牛客每个人最近的登录日期(三)]()

## 1、题目

牛客每天有很多人登录，请你统计一下牛客新登录用户的次日成功的留存率，
有一个登录(login)记录表，简况如下:

![SQL68-1](./image/SQL68-1.png)

第1行表示id为2的用户在2020-10-12使用了客户端id为1的设备第一次新登录了牛客网

。。。

第4行表示id为3的用户在2020-10-12使用了客户端id为2的设备登录了牛客网

。。。

最后1行表示id为1的用户在2020-10-14使用了客户端id为2的设备登录了牛客网

请你写出一个sql语句查询新登录用户次日成功的留存率，即第1天登陆之后，第2天再次登陆的概率,保存小数点后面3位(3位之后的四舍五入)，上面的例子查询结果如下:

![SQL68-2](./image/SQL68-2.png)

查询结果表明:

id为1的用户在2020-10-12第一次新登录了，在2020-10-13又登录了，算是成功的留存

id为2的用户在2020-10-12第一次新登录了，在2020-10-13又登录了，算是成功的留存

id为3的用户在2020-10-12第一次新登录了，在2020-10-13没登录了，算是失败的留存

id为4的用户在2020-10-13第一次新登录了，在2020-10-14没登录了，算是失败的留存

固次日成功的留存率为 2/4=0.5

(sqlite里查找某一天的后一天的用法是:date(yyyy-mm-dd, '+1 day')，四舍五入的函数为round，sqlite 1/2得到的不是0.5，得到的是0，只有`1*1.0/2`才会得到0.5
mysql里查找某一天的后一天的用法是:DATE_ADD(yyyy-mm-dd,INTERVAL 1 DAY)，四舍五入的函数为round)

## 2、题解

先取出用户及第一次登录的日期，通过join，得到第二次登录的日期，最后取概率。

```sql
select round((count(b.user_id)*1.0/count(a.user_id)),3) p
from (select user_id,min(date) d from login group by user_id) a
left join login b on a.user_id=b.user_id and b.date=DATE_ADD(a.d,INTERVAL 1 DAY);
```

## 3、涉及内容

DATE_ADD() 函数向日期添加指定的时间间隔。

语法：

	DATE_ADD(date,INTERVAL expr type)

date 参数是合法的日期表达式。

expr 参数是您希望添加的时间间隔。

type 参数可以是下列值：

	MICROSECOND
	SECOND
	MINUTE
	HOUR
	DAY
	WEEK
	MONTH
	QUARTER
	YEAR