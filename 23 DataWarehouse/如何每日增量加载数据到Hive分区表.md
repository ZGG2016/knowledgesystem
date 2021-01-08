# 如何每日增量加载数据到Hive分区表


## 1、加载数据

数据加载到 Hive 分区表（两个分区，日期（20160316）和小时（10））中，每日加载前一天的日志文件数据到表 db_track.track_log

### 1.1、数据存储

每天生成的日志文件放入同一个目录 eg: 20160316 - 目录名称

日志文件是每个小时生成一个，一天总共有二十四个文件 eg: 2016031820


### 1.2、shell脚本编写

负责调度的 shell 脚本 load_tracklogs.sh

注：这里涉及到了三个点：

1) for循环 

2) linux下字符串的截取${line:0:4} 

3) 传递参数到hive的sql脚本

```sh
#!/bin/sh

## 环境变量生效
. /etc/profile

## HIVE HOME
HIVE_HOME=/opt/cdh5.3.6/hive-0.13.1-cdh5.3.6

## 日志目录
LOG_DIR=/data/tracklogs

## 目录名称, 依据日期date获取
yesterday=`date -d -1days '+%Y%m%d'`

### 
for line in `ls $LOG_DIR/${yesterday}`
do
  echo "loading $line .............."
  #从文件名称中解析出日期和小时
  daily=${line:0:4}${line:4:2}${line:6:2}
  hour=${line:8:2}
  LOAD_FILE=${LOG_DIR}/${yesterday}/${line}
  ###  echo $daily + $hour
  ###  ${HIVE_HOME}/bin/hive -e "LOAD DATA LOCAL INPATH '${LOAD_FILE}' OVERWRITE INTO TABLE db_track.track_log PARTITION(date = '${daily}', hour = '${hour}') ;"
  ${HIVE_HOME}/bin/hive --hiveconf LOAD_FILE_PARAM=${LOAD_FILE} --hiveconf daily_param=${daily} --hiveconf hour_param=${hour} -f /home/hadoop/load_data.sql
done
```

负责加载数据的sql脚本

```sql
LOAD DATA LOCAL INPATH '${hiveconf:LOAD_FILE_PARAM}' 
	OVERWRITE INTO TABLE db_track.track_log 
	PARTITION(date = '${hiveconf:daily_param}', hour = '${hiveconf:hour_param}') ;

```

### 1.3、制定每天定时执行

可以在当前用户下直接创建：crontab -e

下面的例子就是每天晚上1点30运行任务的例子，注意sh命令前一般需要加上绝对路径

```sh
# LODAD DATA INTO TRACK_LOG
30 1 * * * /bin/sh /home/hadoop/load_tracklogs.sh
```

原文地址：[https://www.cnblogs.com/raymoc/p/5321851.html](https://www.cnblogs.com/raymoc/p/5321851.html)