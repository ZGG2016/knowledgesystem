# Getting Started

[TOC]

## 1、Installation and Configuration

You can install a stable release of Hive by downloading a tarball, or you can download the source code and build Hive from that.

**Running HiveServer2 and Beeline**

### 1.1、Requirements

- **Java 1.7**

Note:  Hive versions 1.2 onward require Java 1.7 or newer. Hive versions 0.14 to 1.1 work with Java 1.6 as well. Users are strongly advised to start moving to Java 1.8 (see HIVE-8607).  

- **Hadoop 2.x (preferred)**, 1.x (not supported by Hive 2.0.0 onward).

Hive versions up to 0.13 also supported Hadoop 0.20.x, 0.23.x.

- **Hive is commonly used in production Linux and Windows environment. Mac is a commonly used development environment**. The instructions in this document are applicable to Linux and Mac. Using it on Windows would require slightly different steps.  

本文安装是应用于 Linux and Mac

### 1.2、Installing Hive from a Stable Release

### 1.3、Building Hive from Source

#### 1.3.1、Compile Hive on master

#### 1.3.2、Compile Hive on branch-1

#### 1.3.3、Compile Hive Prior to 0.13 on Hadoop 0.20

#### 1.3.4、Compile Hive Prior to 0.13 on Hadoop 0.23

### 1.4、Running Hive

#### 1.4.1、Running Hive CLI

#### 1.4.2、Running HiveServer2 and Beeline

#### 1.4.3、Running HCatalog

#### 1.4.4、Running WebHCat (Templeton)

### 1.5、Configuration Management Overview

### 1.6、Runtime Configuration

### 1.7、Hive, Map-Reduce and Local-Mode

### 1.8、Hive Logging

#### 1.8.1、HiveServer2 Logs

#### 1.8.2、Audit Logs

#### 1.8.3、Perf Logger

## 2、DDL Operations

### 2.1、Creating Hive Tables

### 2.2、Browsing through Tables

### 2.3、Altering and Dropping Tables

### 2.4、Metadata Store

## 3、DML Operations

## 4、SQL Operations

### 4.1、Example Queries

#### 4.1.1、SELECTS and FILTERS

#### 4.1.2、GROUP BY

#### 4.1.3、JOIN

#### 4.1.4、MULTITABLE INSERT

#### 4.1.5、STREAMING

## 5、Simple Example Use Cases

### 5.1、MovieLens User Ratings

### 5.2、Apache Weblog Data