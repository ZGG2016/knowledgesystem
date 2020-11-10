# Hadoop Cluster Setup

[TOC]

## 1、Purpose

<font color="grey">This document describes how to install and configure Hadoop clusters ranging from a few nodes to extremely large clusters with thousands of nodes. To play with Hadoop, you may first want to install it on a single machine (see [Single Node Setup](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)).</font>

<font color="grey">This document does not cover advanced topics such as [Security](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html) or High Availability.</font>

本文档介绍如何安装配置hadoop集群，但不涉及安全和高可用相关的高阶内容。

## 2、Prerequisites

- Install Java. See the [Hadoop Wiki](https://cwiki.apache.org/confluence/display/HADOOP2/HadoopJavaVersions) for known good versions.
- Download a stable version of Hadoop from Apache mirrors.

## 3、Installation

<font color="grey">Installing a Hadoop cluster typically involves unpacking the software on all the machines in the cluster or installing it via a packaging system as appropriate for your operating system. It is important to divide up the hardware into functions.</font>

<font color="grey">Typically one machine in the cluster is designated as the NameNode and another machine as the ResourceManager, exclusively. These are the masters. Other services (such as Web App Proxy Server and MapReduce Job History server) are usually run either on dedicated hardware or on shared infrastructure, depending upon the load.</font>

<font color="grey">The rest of the machines in the cluster act as both DataNode and NodeManager. These are the workers.</font>

将硬件划分为不同的功能是很重要的。

通常，**集群中的一台机器被指定为 NameNode ，另一台机器被指定为 ResourceManager**。这些是 masters 。**其他服务(如 Web App Proxy Server 和 MapReduce Job History Server)通常运行在专用硬件或共享基础设施上，具体取决于负载**。

**集群中的其他机器同时充当 DataNode 和 NodeManager**。这些是 workers。

## 4、Configuring Hadoop in Non-Secure Mode

<font color="grey">Hadoop’s Java configuration is driven by two types of important configuration files:</font>

<font color="grey">Read-only default configuration - core-default.xml, hdfs-default.xml, yarn-default.xml and mapred-default.xml.</font>

<font color="grey">Site-specific configuration - etc/hadoop/core-site.xml, etc/hadoop/hdfs-site.xml, etc/hadoop/yarn-site.xml and etc/hadoop/mapred-site.xml.</font>

<font color="grey">Additionally, you can control the Hadoop scripts found in the bin/ directory of the distribution, by setting site-specific values via the etc/hadoop/hadoop-env.sh and etc/hadoop/yarn-env.sh.</font>

Hadoop 的 Java 配置是由如下两类文件驱动的：

- 仅读的默认配置文件：`core-default.xml, hdfs-default.xml, yarn-default.xml and mapred-default.xml`

- 特定的配置文件：`etc/hadoop/core-site.xml, etc/hadoop/hdfs-site.xml, etc/hadoop/yarn-site.xml and etc/hadoop/mapred-site.xml.`

还可以**通过设置 `etc/hadoop/hadoop-env.sh` 和`etc/hadoop/yarn-env.sh` 中的特定值，来控制`bin/` 目录下的 Hadoop 脚本**。

<font color="grey">To configure the Hadoop cluster you will need to configure the environment in which the Hadoop daemons execute as well as the configuration parameters for the Hadoop daemons.</font>

<font color="grey">HDFS daemons are NameNode, SecondaryNameNode, and DataNode. YARN daemons are ResourceManager, NodeManager, and WebAppProxy. If MapReduce is to be used, then the MapReduce Job History Server will also be running. For large installations, these are generally running on separate hosts.</font>

要配置 Hadoop 集群，需要配置执行 Hadoop 守护进程的环境以及配置参数。

- **HDFS 守护进程是 NameNode、SecondaryNameNode 和 DataNode。**

- **YARN 守护进程是 ResourceManager、NodeManager 和 WebAppProxy。**

- **如果要使用 MapReduce ，那么 MapReduce Job History Server 也将运行。**

对于大型集群安装，它们通常运行在不同的主机上。

### 4.1、Configuring Environment of Hadoop Daemons

### 4.2、Configuring the Hadoop Daemons

## 5、Monitoring Health of NodeManagers

## 6、Slaves File

## 7、Hadoop Rack Awareness

## 8、Logging

## 9、Operating the Hadoop Cluster

### 9.1、Hadoop Startup

### 9.2、Hadoop Shutdown

## 10、Web Interfaces