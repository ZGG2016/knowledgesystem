# [SQL72：考试分数(一)](https://www.nowcoder.com/practice/f41b94b4efce4b76b27dd36433abe398?tpId=82&&tqId=35492&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

牛客每次考试完，都会有一个成绩表(grade)，如下:

![SQL72-1](./image/SQL72-1.png)

第1行表示用户id为1的用户选择了C++岗位并且考了11001分

。。。

第8行表示用户id为8的用户选择了前端岗位并且考了9999分

请你写一个sql语句查询各个岗位分数的平均数，并且按照分数降序排序，结果保留小数点后面3位(3位之后四舍五入):

![SQL72-2](./image/SQL72-2.png)

(注意: sqlite 1/2得到的不是0.5，得到的是0，只有`1*1.0/2`才会得到0.5，sqlite四舍五入的函数为round)

## 2、题解


```sql
select job,round(avg(score),3) avg
from grade 
group by job
order by avg desc;
```

## 3、涉及内容