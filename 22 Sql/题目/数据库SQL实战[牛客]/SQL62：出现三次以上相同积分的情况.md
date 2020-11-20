# [SQL62：出现三次以上相同积分的情况](https://www.nowcoder.com/practice/c69ac94335744480aa50646864b7f24d?tpId=82&&tqId=35079&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

积分(grade)表简化可以如下:

![SQL62-1](./image/SQL62-1.png)

id为用户主键id，number代表积分情况，让你写一个sql查询，积分表里面出现三次以及三次以上的积分，查询结果如下:

![SQL62-2](./image/SQL62-2.png)


## 2、题解


```sql
select number from grade group by number having count(number)>=3;
```

## 3、涉及内容