# 面试准备之Liunx

### 1、Linux查看CPU和内存使用情况（网易）

（1）通过 top 命令来查看 CPU 使用状况，实时显示系统中各个进程的资源占用状况.

[https://www.linuxidc.com/Linux/2016-08/133871.htm](https://www.linuxidc.com/Linux/2016-08/133871.htm)

（2）使用vmstat(virtual memory statistics)进行内存负载分析；也可以使用free 来标识内存的负载情况；也可以通过查看虚拟文件 /proc/meminfo 来查看内存的负载情况。

[https://www.linuxidc.com/Linux/2016-12/138599.htm](https://www.linuxidc.com/Linux/2016-12/138599.htm)

### 2、重定向

[http://www.runoob.com/linux/linux-shell-io-redirections.html](http://www.runoob.com/linux/linux-shell-io-redirections.html)

输出重定向：

	command1 > file1
 	//将执行command1的结果存入file

输入重定向：

	command1 < file1
	//从键盘写数据到文件

如果希望执行某个命令，但又不希望在屏幕上显示输出结果：

	command > /dev/null 2>&1
	//0 是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）
	============================
	command > file	将输出重定向到 file。
	command < file	将输入重定向到 file。
	command >> file	将输出以追加的方式重定向到 file。

## 3、两数相加

	v1=1
	v2=2
	let v3=$v1+$v2
	
	v3=`expr $v1 + $v2` # +左右加空格
	echo $v1+$v2 | bc
	echo $[$v1+$v2]
	echo $(($v1+$v2))
	awk 'BEGIN{print '"$v1"'+'"$v2"'}'

## 4、如何检查文件系统中是否存在某个文件 ?

	if [ -e /var/log/messages.sh ]
	then
		echo "File exists"
	fi

## 5、shell 脚本中所有循环语法

	#for
	for i in `a b c`;do
		echo $i
	done
	for((i=0;i<3;i++));do
		echo $i
	done
	=================================
	#while
	i=1
	while [ $i -lt 5 ] #注意空格
	do
	  echo $i
	  let "i++"
	done
	=================================
	#until
	a=0
	until [ ! $a -lt 10 ];do
		echo $a
		let "a++"
	done
	



