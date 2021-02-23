# 组内取最值的示例

牛客SQL题目：

[SQL66：牛客每个人最近的登录日期(一)](https://github.com/ZGG2016/sql-practice-niuke/blob/master/SQL66%EF%BC%9A%E7%89%9B%E5%AE%A2%E6%AF%8F%E4%B8%AA%E4%BA%BA%E6%9C%80%E8%BF%91%E7%9A%84%E7%99%BB%E5%BD%95%E6%97%A5%E6%9C%9F(%E4%B8%80).md)

```sql
select user_id,max(date) as d
from login
group by user_id  -- 要在组内取最大值，不能使用排序和limit
order by user_id; -- 结果输出是升序

-- 组内取最大值使用窗口函数

-- 窗口函数 dense_rank
select user_id,date as d
from (
select user_id,date,
    dense_rank() over(partition by user_id order by date desc ) dr
from login
) t
where dr =1
order by user_id

-- 窗口函数 last_value
select distinct  -- 注意这里使用了distinct
    user_id,
    -- between unbounded preceding and unbounded following 也可以
    last_value(date) over(partition by user_id order by date rows between current row and unbounded following) as d
from login;

-- 窗口函数 first_value
select distinct
    user_id,
    first_value(date) over(partition by user_id order by date desc rows between unbounded preceding and unbounded following) as d
from login;

-- 窗口函数 nth_value
select distinct
    user_id,
    nth_value(date,1) over(partition by user_id order by date desc rows between unbounded preceding and unbounded following) as d
from login;
```