# 官网：Hive Architecture Overview

[TOC]

> Figure 1

![system_architecture](./system_architecture.png)

## 1、Hive Architecture

*Figure 1 shows the major components of Hive and its interactions with Hadoop. As shown in that figure, the main components of Hive are:*

Figure 1 展示了 Hive 的主要组件以及和 Hadoop 的交互。主要组件有:

- UI：**向系统提交查询和其他操作的用户界面**。在2011年，系统有一个命令行界面和一个基于 GUI 的 web 正在开发中。

*UI – The user interface for users to submit queries and other operations to the system. As of 2011 the system had a command line interface and a web based GUI was being developed.*

- Driver：**接受查询的组件**。该组件实现了会话句柄的概念，并提供了基于 JDBC/ODBC 接口的 api 执行和获取。

*Driver – The component which receives the queries. This component implements the notion of session handles and provides execute and fetch APIs modeled on JDBC/ODBC interfaces.*

- Compiler：**解析查询的组件**，对不同的查询块和查询表达式进行语义分析，最终利用从元数据存储中查找的表和分区元数据生成执行计划。

*Compiler – The component that parses the query, does semantic analysis on the different query blocks and query expressions and eventually generates an execution plan with the help of the table and partition metadata looked up from the metastore.*

- Metastore：

*Metastore – The component that stores all the structure information of the various tables and partitions in the warehouse including column and column type information, the serializers and deserializers necessary to read and write data and the corresponding HDFS files where the data is stored.*

*Execution Engine – The component which executes the execution plan created by the compiler. The plan is a DAG of stages. The execution engine manages the dependencies between these different stages of the plan and executes these stages on the appropriate system components.*

## 2、Hive Data Model

## 3、Metastore

### 3.1、Motivation

### 3.2、Metadata Objects

### 3.3、Metastore Architecture

### 3.4、Metastore Interface

## 4、Hive Query Language

## 5、Compiler

## 6、Optimizer

## 7、Hive APIs