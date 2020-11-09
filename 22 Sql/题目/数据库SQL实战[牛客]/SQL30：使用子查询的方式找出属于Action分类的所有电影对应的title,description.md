# [SQL30：使用子查询的方式找出属于Action分类的所有电影对应的title,description](https://www.nowcoder.com/practice/2f2e556d335d469f96b91b212c4c203e?tpId=82&&tqId=29782&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

使用子查询的方式找出属于Action分类的所有电影对应的title,description

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
select f.title,f.description
from film_category fc join film f on fc.film_id=f.film_id
where fc.category_id in (select category_id from category where name like '%Action%');
```

## 3、涉及内容