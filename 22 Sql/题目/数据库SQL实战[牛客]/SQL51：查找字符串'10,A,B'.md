# [SQL51：查找字符串'10,A,B'](https://www.nowcoder.com/practice/e3870bd5d6744109a902db43c105bd50?tpId=82&&tqId=29819&rp=1&ru=/ta/sql&qru=/ta/sql/question-ranking)

## 1、题目

查找字符串'10,A,B' 中逗号','出现的次数cnt。

## 2、题解

原来串的长度 - 替换之后的串的长度 就是 被替换的 逗号的个数

```sql
select length("10,A,B")-length(replace("10,A,B",",","")) cnt;
```

## 3、涉及内容