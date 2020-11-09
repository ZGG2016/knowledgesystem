# [SQL28：查找描述信息中包括robot的电影对应的分类名称以及电影数目](https://www.nowcoder.com/practice/3a303a39cc40489b99a7e1867e6507c5?tpId=82&&tqId=29780&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找描述信息(film.description)中包含robot的电影对应的分类名称(category.name)以及电影数目(count(film.film_id))，而且还需要该分类包含电影总数量(count(film_category.category_id))>=5部

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

注意这句话的理解：`还需要该分类包含电影总数量(count(film_category.category_id))>=5部`

只取 包含的电影总数量大于等于5 的分类。

```sql
select c.name,count(f.film_id)
from film_category fc join film f on fc.film_id=f.film_id 
join category c on fc.category_id=c.category_id
where f.description like '%robot%' 
and c.category_id in (select category_id from film_category 
                       group by category_id 
                       having count(film_id)>=5);
```

## 3、涉及内容

(1)like

SQL LIKE 子句中使用百分号 %字符来表示任意字符。如果没有使用百分号 %, LIKE 子句与等号 = 的效果是一样的。

通用语法：

	SELECT field1, field2,...fieldN 
	FROM table_name
	WHERE field1 LIKE condition1 [AND [OR]] filed2 = 'somevalue'

在 where like 的条件查询中，SQL 提供了四种匹配方式。

- %：表示任意 0 
个或多个字符。可匹配任意类型和长度的字符，有些情况下若是中文，请使用两个百分号（%%）表示。

- `_`：表示任意单个字符。匹配单个任意字符，它常用来限制表达式的字符长度语句。

- []：表示括号内所列字符中的一个（类似正则表达式）。指定一个字符、字符串或范围，要求所匹配对象为它们中的任一个。

- [^] ：表示不在括号所列之内的单个字符。其取值和 [] 相同，但它要求所匹配对象为指定字符以外的任一个字符。

-  查询内容包含通配符时,由于通配符的缘故，导致我们查询特殊字符 `“%”、“_”、“[”` 的语句无法正常实现，而把特殊字符用 “[ ]” 括起便可正常查询。

		'%a'     //以a结尾的数据
		'a%'     //以a开头的数据
		'%a%'    //含有a的数据
		'_a_'    //三位且中间字母是a的
		'_a'     //两位且结尾字母是a的
		'a_'     //两位且开头字母是a的