# 子查询与join的区别

**mysql 8.0.21**

## 1、从语句执行顺序来看

- FROM t1 join t2 on t1.=t2.
- where
- group by
- avg,sum.... 
- having 
- select 
- distinct 
- order by
- limit 

所以：

直接join的话，后面处理是基于两表的笛卡尔积后的数据量。

而子查询的话，是先在一个表的数据量的基础上执行，然后在另一个表的数据量的基础上执行。