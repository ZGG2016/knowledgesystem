# [SQL29：使用join查询方式找出没有分类的电影id以及名称](https://www.nowcoder.com/practice/a158fa6e79274ac497832697b4b83658?tpId=82&&tqId=29781&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

使用join查询方式找出没有分类的电影id以及名称

```sql
CREATE TABLE IF NOT EXISTS film (
film_id smallint(5)  NOT NULL DEFAULT '0',  -- 电影id
title varchar(255) NOT NULL,   -- 电影名称
description text,  -- 电影描述信息
PRIMARY KEY (film_id));

CREATE TABLE category  (
category_id  tinyint(3)  NOT NULL ,   -- 电影分类id
name  varchar(25) NOT NULL,  -- 电影分类名称
`last_update` timestamp,  -- 电影分类最后更新时间
PRIMARY KEY ( category_id ));

CREATE TABLE film_category  (
film_id  smallint(5)  NOT NULL,  -- 电影id
category_id  tinyint(3)  NOT NULL,  -- 电影分类id
`last_update` timestamp); -- 电影id和分类id对应关系的最后更新时间
```

## 2、题解


```sql
select f.film_id,f.title
from film f left join film_category fc on f.film_id=fc.film_id
where fc.category_id  is null;
```

## 3、涉及内容