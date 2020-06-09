# Git创建版本库与添加远程库

### 1 创建版本库

	(1) 选择一个合适的地方，创建一个空目录
	(2) 通过git init命令把这个目录变成Git可以管理的仓库
	(3) 编写一个readme.txt文件，放到learngit目录下
	(4) 用命令git add告诉Git，把文件添加到仓库
	(5) 用命令git commit告诉Git，把文件提交到仓库

![1](https://s1.ax1x.com/2020/05/31/t1HR91.png)

![2](https://s1.ax1x.com/2020/05/31/t1HW1x.png)


git add 的时候出现了fatal: unable to auto-detect email address (got 'ZGG@420-PC.(none)')，需要设置邮箱和用户名


### 2 添加远程库

	(1) 登陆GitHub，然后，在右上角找到“Create a new repo”按钮，创建一个新的仓库
	(2) 在Repository name填入Liunx，其他保持默认设置，点击“Create repository”按钮，就成功地创建了一个新的Git仓库
	(3) 在本地的learngit仓库下运行命令：

    `$ git remote add origin git@github.com:ZGG2016/Liunx.git`

请千万注意，把上面的ZGG2016替换成你自己的GitHub账户名

(4)把本地库的所有内容推送到远程库上：

    `$ git push -u origin master`

之后提交的时候，就可以通过命令：

    `$ git push origin master`

git push 的时候出现了fatal: Could not read from remote repository.

需要添加SSH密钥

	(1) 生存密钥
	(2) 将 id_rsa.pub的内容添加到github的setting/SSH项上

		cd ~/.ssh
		ssh-keygen -t rsa -C "sdut2012@163.com"
		cat id_rsa.pub

参考：
[廖雪峰官网GIT教程](https://www.liaoxuefeng.com/wiki/896043488029600)
[解决Github网页上图片显示失败的问题](https://blog.csdn.net/qq_38232598/article/details/91346392)
