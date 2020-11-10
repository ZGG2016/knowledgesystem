# Hadoop Archives Guide

[TOC]

## 一、Overview

Hadoop archives 是特殊的档案格式。**一个 Hadoop archive 对应一个文件系统目录**。其扩展名是 `*.har`。
一个 Hadoop archive 目录包含元数据 `形式是_index和 _masterindex` 和 数据 `part-*`文件。
`_index` 文件包含了档案中的文件的文件名和位置信息。

## 二、How to Create an Archive

用法: 

`hadoop archive -archiveName name -p <parent> [-r <replication factor>] <src>* <dest>`

- `-archiveName`：指定你要创建的 archive 的名字。比如foo.har。archive的名字的扩展名应该是 `*.har`。

- `parent` 参数：指定被归档(be archived)文件的相对路径，如 `-p /foo/bar a/b/c e/f/g`
Here `/foo/bar` is the parent path and `a/b/c, e/f/g` are relative paths to parent.

- `r`：副本因子。未指定的话，默认是3.

如果你想归档单个目录 `/foo/bar`，可以这么使用：

	hadoop archive -archiveName zoo.har -p /foo/bar -r 3 /outputdir

如果你指定了一个加密空间的源文件，那么它们会被解密后，再写入档案。
如果 har 文件不在加密空间，将会以解密后的形式存储。
如果 har 文件在加密空间，将会以加密的形式存储。

## 三、How to Look Up Files in Archives

archive 作为文件系统层暴露给外界。所以所有的 fs shell 命令都能在 archive 上运行，
但是要使用不同的 URI。另外，archive 是不可改变的。所以重命名，删除和创建
都会返回错误。Hadoop Archives 的URI是

	har://scheme-hostname:port/archivepath/fileinarchive

如果没提供scheme-hostname，它会使用底层文件系统。这种情况下URI是这种形式

	har:///archivepath/fileinarchive

## 四、How to Unarchive an Archive

解档：

	hdfs dfs -cp har:///user/zoo/foo.har/dir1 hdfs:/user/zoo/newdir

并行的解档：

	hadoop distcp har:///user/zoo/foo.har/dir1 hdfs:/user/zoo/newdir

## 五、Archives Examples

### 1、Creating an Archive

	hadoop archive -archiveName foo.har -p /user/hadoop -r 3 dir1 dir2 /user/zoo
	hadoop archive -archiveName foo.har -p /root/userr/hadoop -r 1 dir1 dir2 /in
在上面的例子中， 使用 `/user/hadoop` 作为相对路径目录。
`/user/hadoop/dir1` 和 `/user/hadoop/dir2` 将被归档到 `/user/zoo/foo.har`。
归档并不会自动删除输入文件。如果想在归档后删除，只能手动删。

### 2、Looking Up Files

归档后，可以通过如下命令查看档案中的文件：

	hdfs dfs -ls -R har:///user/zoo/foo.har/

如果你想列出档案里的文件：

	hdfs dfs -ls har:///user/zoo/foo.har

输出就是：

	har:///user/zoo/foo.har/dir1
	har:///user/zoo/foo.har/dir2
	
如果使用如下命令归档：

	hadoop archive -archiveName foo.har -p /user/ hadoop/dir1 hadoop/dir2 /user/zoo

`-ls` 查看后：

hdfs dfs -ls har:///user/zoo/foo.har

出现：

	har:///user/zoo/foo.har/hadoop/dir1
	har:///user/zoo/foo.har/hadoop/dir2

Notice that the archived files have been archived relative to /user/ 
rather than /user/hadoop.


## 六、Hadoop Archives and MapReduce

如果在 hdfs 中有一个归档文件 `/user/zoo/foo.har`，那么你就可以将其作为 MapReduce
的输入，所有你需要的数据均在这个目录下 `har:///user/zoo/foo.har`。Hadoop Archives
作为为一个文件系统，MapReduce将能够使用Hadoop Archives 中的所有逻辑输入文件作为输入。
