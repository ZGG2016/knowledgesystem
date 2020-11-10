# [SQL33：创建一个actor表，包含如下列信息](https://www.nowcoder.com/practice/ac233de508ef4849b0eeb4f38dcf09cf?tpId=82&&tqId=29801&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

创建一个actor表，包含如下列信息

	  列表	           类型	       是否为NULL	含义
	actor_id	     smallint(5)	not null	主键id
	first_name	     varchar(45)	not null	名字
	last_name	     varchar(45)	not null	姓氏
	last_update	     date	        not null	日期

## 2、题解


```sql
create table if not exists actor(
actor_id smallint(5) not null primary key,
first_name varchar(45) not null,
last_name varchar(45) not null,
last_update date not null 
);
```

## 3、涉及内容