# 搭建Python-Storm环境

## 1、搭建Storm环境

	[root@zgg ~]# storm version
	Running: /opt/jdk/bin/java -client -Ddaemon.name= -Dstorm.options= -Dstorm.home=/opt/storm -Dstorm.log.dir=/opt/storm/logs -Djava.library.path=/usr/local/lib:/opt/local/lib:/usr/lib -Dstorm.conf.file= -cp /opt/storm/lib/storm-core-1.1.0.jar:/opt/storm/lib/kryo-3.0.3.jar:/opt/storm/lib/reflectasm-1.10.1.jar:/opt/storm/lib/asm-5.0.3.jar:/opt/storm/lib/minlog-1.3.0.jar:/opt/storm/lib/objenesis-2.1.jar:/opt/storm/lib/clojure-1.7.0.jar:/opt/storm/lib/ring-cors-0.1.5.jar:/opt/storm/lib/disruptor-3.3.2.jar:/opt/storm/lib/log4j-api-2.8.jar:/opt/storm/lib/log4j-core-2.8.jar:/opt/storm/lib/log4j-slf4j-impl-2.8.jar:/opt/storm/lib/slf4j-api-1.7.21.jar:/opt/storm/lib/log4j-over-slf4j-1.6.6.jar:/opt/storm/lib/servlet-api-2.5.jar:/opt/storm/lib/storm-rename-hack-1.1.0.jar:/opt/storm/conf org.apache.storm.utils.VersionInfo
	Storm 1.1.0
	URL https://git-wip-us.apache.org/repos/asf/storm.git -r e40d213de7067f7d3aa4d4992b81890d8ed6ff31
	Branch (no branch)
	Compiled by ptgoetz on 2017-03-21T17:04Z
	From source with checksum 4ddc442e8b804654454ab26fbec6348

## 2、安装lein

(1)  `wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein`

(2)  将其放到$PATH目录下。(`~/bin`)

(3)  `chmod a+x ~/bin/lein`

(4)  Run it (lein) and it will download the self-install package。如下图：

	[root@zgg ~]# lein
	Downloading Leiningen to /root/.lein/self-installs/leiningen-2.8.1-standalone.jar now...
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
	                                 Dload  Upload   Total   Spent    Left  Speed
	100   618    0   618    0     0    872      0 --:--:-- --:--:-- --:--:--   874
	100 12.9M  100 12.9M    0     0  41250      0  0:05:28  0:05:28 --:--:-- 33281
	Leiningen is a tool for working with Clojure projects.

## 3、安装streamparser

(1)如果没有安装pip（python包的管理工具），先安装pip。

	wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
	python get-pip.py

(2)这时pip就安装好了，执行 pip -h 能看到帮助信息

(3)安装virtualenv命令

	pip install virtualenv

(4)安装python-dev，执行(系统默认安装的是python2)

	yum install python-devel

	（安装python3：https://www.cnblogs.com/rookie404/p/6142151.html）

(5)安装streamparser，执行

	pip install streamparse

	注意：如果你是在直接使用root账户，那么需要在~/.bash_profile中添加
	export LEIN_ROOT=1

(6)执行wc工程

	sparse quickstart wordcount

		Creating your wordcount streamparse project...
		    create    wordcount
		    create    wordcount/.gitignore
		    create    wordcount/config.json
		    create    wordcount/fabfile.py
		    create    wordcount/project.clj
		    create    wordcount/README.md
		    create    wordcount/src
		    create    wordcount/src/bolts/
		    create    wordcount/src/bolts/__init__.py
		    create    wordcount/src/bolts/wordcount.py
		    create    wordcount/src/spouts/
		    create    wordcount/src/spouts/__init__.py
		    create    wordcount/src/spouts/words.py
		    create    wordcount/topologies
		    create    wordcount/topologies/wordcount.py
		    create    wordcount/virtualenvs
		    create    wordcount/virtualenvs/wordcount.txt
		Done.

	运行
		cd wordcount
		配置config.json
			{
			    "serializer": "json",
			    "topology_specs": "topologies/",
			    "virtualenv_specs": "virtualenvs/",
			    "envs": {
			        "prod": {
			            "user": "root",
			            "ssh_password": "root",
			            "nimbus": "zgg",
			            "workers": ["zgg"],
			            "log": {
			                "path": "/var/log/storm/streamparse",
			                "max_bytes": 1000000,
			                "backup_count": 10,
			                "level": "info"
			            },
			            "virtualenv_root": "/wordcount/virtualenvs/"
			        }
			    }
			}
	  	sparse run
	之后可以在日志文件中看到结果。

================================================================================

出现的问题：

	1.执行lein,或者lein install,报错如下：
		[root@zgg ~]# lein version
		Downloading Leiningen to /root/.lein/self-installs/leiningen-2.8.1-standalone.jar now...
		  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
		                                 Dload  Upload   Total   Spent    Left  Speed
		100   618    0   618    0     0    215      0 --:--:--  0:00:02 --:--:--   215
		  0     0    0     0    0     0      0      0 --:--:--  0:00:22 --:--:--     0curl: (7) Failed connect to github-production-release-asset-2e65be.s3.amazonaws.com:443; 拒绝连接
		Failed to download https://github.com/technomancy/leiningen/releases/download/2.8.1/leiningen-2.8.1-standalone.zip (exit code 7)
		It's possible your HTTP client's certificate store does not have the
		correct certificate authority needed. This is often caused by an
		out-of-date version of libssl. It's also possible that you're behind a
		firewall and haven't set HTTP_PROXY and HTTPS_PROXY.

	解决方法：
		先export HTTP_CLIENT="wget --no-check-certificate -O"
		然后再此执行，下载成功
	https://github.com/technomancy/leiningen/issues/1634
