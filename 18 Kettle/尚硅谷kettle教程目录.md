# 尚硅谷kettle教程目录及重点内容


[TOC]


## 1 Kettle 概述

### 1.1 ETL 简介

### 1.2 Kettle 简介

#### 1.2.1 Kettle 是什么

#### 1.2.2 Kettle 的两种设计

#### 1.2.3 Kettle 的核心组件

#### 1.2.4 Kettle 特点

## 2、Kettle 安装部署

### 2.1 Kettle 下载

#### 2.1.1 下载地址

#### 2.1.2 Kettle 目录说明

#### 2.1.3 Kettle 文件说明

### 2.2 Kettle 安装部署

#### 2.2.1 概述

#### 2.2.2 安装

### 2.3 Kettle 界面简介

#### 2.3.1 首页

#### 2.3.2 转换

#### 2.3.3 作业

### 2.4 Kettle 转换初次体验

### 2.5 Kettle 核心概念

#### 2.5.1 可视化编程

#### 2.5.2 转换

#### 2.5.3 步骤（Step）

#### 2.5.4 跳（Hop）

#### 2.5.5 元数据

#### 2.5.6 数据类型

#### 2.5.7 并行

#### 2.5.8 作业

## Kettle 转换

### 3.1 Kettle 输入控件

#### 3.1.1 CSV 文件输入

#### 3.1.2 文本文件输入

#### 3.1.3 Excel 输入

#### 3.1.4 XML 输入

#### 3.1.5 JSON 输入

#### 3.1.6 表输入

### 3.2 Kettle 输出控件

#### 3.2.1 Excel 输出

#### 3.2.2 文本文件输出

#### 3.2.3 SQL 文件输出

#### 3.2.4 表输出

#### 3.2.5 更新&插入/更新

#### 3.2.6 删除

### 3.3 Kettle 转换控件

#### 3.3.1 Concat fields

#### 3.3.2 值映射

#### 3.3.3 增加常量&增加序列

#### 3.3.4 字段选择

#### 3.3.5 计算器

#### 3.3.6 字符串剪切&替换&操作

#### 3.3.7 排序记录&去除重复记录

#### 3.3.8 唯一行（哈希值）

#### 3.3.9 拆分字段

#### 3.3.10 列拆分为多行

#### 3.3.11 行扁平化

#### 3.3.12 列转行

#### 3.3.13 行转列

### 3.4 Kettle 应用控件

#### 3.4.1 替换 NULL 值

#### 3.4.2 写日志

### 3.5 Kettle 流程控件

#### 3.5.1 Switch/case

#### 3.5.2 过滤记录

#### 3.5.3 空操作

#### 3.5.4 中止

### 3.6 Kettle 查询控件

#### 3.6.1 数据库查询

#### 3.6.2 流查询

### 3.7 Kettle 连接控件

#### 3.7.1 合并记录

#### 3.7.2 记录集连接

### 3.8 Kettle 统计控件

#### 3.8.1 分组

### 3.9 Kettle 映射控件

#### 3.9.1 映射

### 3.10 Kettle 脚本控件

#### 3.10.1 执行 SQL 脚本

## 4 Kettle 作业

### 4.1 作业简介

#### 4.1.1 作业项

#### 4.1.2 作业跳

### 4.2 作业初体验

## 5 Kettle 使用案例

### 5.1 转换案例

把 stu1 的数据按 id 同步到 stu2，stu2 有相同 id 则更新数据。

### 5.2 作业案例

使用作业执行上述转换，并且额外在表 stu2 中添加一条数据，整个作业运行成功的话发邮件提醒。

### 5.3 Hive-HDFS 案例

### 5.4 HDFS-Hbase 案例

## 6 Kettle 资源库

### 6.1 数据库资源库 

### 6.2 文件资源库

## 7、Kettle 调优