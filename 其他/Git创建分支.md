# Git创建分支

[TOC]

## 1、创建分支

```sh
# 创建分支，并切换到新的分支，相当于git branch branch01 \ git checkout branch01
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git checkout -b branch01    
Switched to a new branch 'branch01'

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ ls
'IDLE 快捷键.jpg'   readme.txt   test.md

# 在新的分支branch01上，修改文件，添加一行文本 create branch test
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ vi readme.txt

# 添加、提交修改
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git commit -a -m "add one line"
[branch01 0ec0362] add one line
 1 file changed, 1 insertion(+), 2 deletions(-)

# 切换到master分支
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

# 分支有了独立内容，希望将它合并回到主分支
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git merge branch01
Updating 0126114..0ec0362
Fast-forward
 readme.txt | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

# push
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git push origin master
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 334 bytes | 167.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:ZGG2016/test.git
   0126114..0ec0362  master -> master

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ cat readme.txt
test
test
create branch test

# 删除分支branch01
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git branch -d branch01
Deleted branch branch01 (was 0126114).
```

## 2、合并冲突

```sh
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ cat readme.txt
bash: catreadme.txt: command not found

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ cat readme.txt
test
test
create branch test

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git checkout branch01
Switched to branch 'branch01'

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ ls
'IDLE 快捷键.jpg'   readme.txt   test.md

# 在分支branch01修改文件内容，追加一行文本 conflict test
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ echo "conflict test" >> readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ cat readme.txt
test
test
create branch test
conflict test

# 添加、提交
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git commit -a -m "add one line conflict"
warning: LF will be replaced by CRLF in readme.txt.
The file will have its original line endings in your working directory
[branch01 9207356] add one line conflict
 1 file changed, 1 insertion(+)

# 切换到master
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

# 在分支master修改文件内容，追加一行文本 conflict test 2
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ echo "conflict test 2" >> readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ cat readme.txt
test
test
create branch test
conflict test 2

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git diff
warning: LF will be replaced by CRLF in readme.txt.
The file will have its original line endings in your working directory
diff --git a/readme.txt b/readme.txt
index f1db05a..6b64027 100644
--- a/readme.txt
+++ b/readme.txt
@@ -1,3 +1,4 @@
 test
 test
 create branch test
+conflict test 2

# 添加、提交
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git commit -a -m "add one line conflict 2"
warning: LF will be replaced by CRLF in readme.txt.
The file will have its original line endings in your working directory
[master 30797ec] add one line conflict 2
 1 file changed, 1 insertion(+)

# branch01合并到master
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git merge branch01
Auto-merging readme.txt
CONFLICT (content): Merge conflict in readme.txt
Automatic merge failed; fix conflicts and then commit the result.

# 出现了冲突
# 为了解决冲突，你必须选择使用由 ======= 分割的两部分中的一个，或者你也可以自行合并这些内容。
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ cat readme.txt
test
test
create branch test
<<<<<<< HEAD
conflict test 2
=======
conflict test
>>>>>>> branch01

# 这里选择自行合并
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ vi readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git status -s
UU readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git add readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git status -s
M  readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git commit
hint: Waiting for your editor to close the file... "C:\\Program Files (x86)\\Notepad++\\notepad++.exe" -multiInst -notabbar -nosession -noPlugin: C:\Program Files (x86)\Notepad++\notepad++.exe: No such file or directory
error: There was a problem with the editor '"C:\\Program Files (x86)\\Notepad++\\notepad++.exe" -multiInst -notabbar -nosession -noPlugin'.
Please supply the message using either -m or -F option.

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git push origin master
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 354 bytes | 177.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:ZGG2016/test.git
   0ec0362..30797ec  master -> master

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ ls
'IDLE 快捷键.jpg'   readme.txt   test.md

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ cat readme.txt
test
test
create branch test
conflict test 2
conflict test

```

## 3、远程分支

```sh
# 现在在master分支上，工作目标是干净的，也没有需要commit的
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean

# 把新建的本地分支branch01 push到远程服务器，远程分支名为dev，本地分支名为branch01
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git push origin branch01:dev
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 350 bytes | 87.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
remote:
remote: Create a pull request for 'dev' on GitHub by visiting:
remote:      https://github.com/ZGG2016/test/pull/new/dev
remote:
To github.com:ZGG2016/test.git
 * [new branch]      branch01 -> dev

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git branch -a
  branch01
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/dev
  remotes/origin/master

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ echo "remote branch test" >> readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ cat readme.txt
test
test
create branch test
conflict test
remote branch test

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git add readme.txt
warning: LF will be replaced by CRLF in readme.txt.
The file will have its original line endings in your working directory

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git commit -m "add one line"
[branch01 d5982b4] add one line
 1 file changed, 1 insertion(+)


zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git pull origin dev
From github.com:ZGG2016/test
 * branch            dev        -> FETCH_HEAD
Already up to date.

# 合并到远程分支代码
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git push origin branch01:dev
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 347 bytes | 173.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:ZGG2016/test.git
   9207356..d5982b4  branch01 -> dev

# 合并到本地master
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (branch01)
$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git merge branch01
Auto-merging readme.txt
CONFLICT (content): Merge conflict in readme.txt
Automatic merge failed; fix conflicts and then commit the result.

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git status
On branch master
Your branch is up to date with 'origin/master'.

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   readme.txt

no changes added to commit (use "git add" and/or "git commit -a")

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ vi readme.txt

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master|MERGING)
$ git commit -a -m "update"
[master ebe3a34] update

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git merge branch01
Already up to date.

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git pull origin master
From github.com:ZGG2016/test
 * branch            master     -> FETCH_HEAD
Already up to date.

zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git push origin master
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 363 bytes | 181.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:ZGG2016/test.git
   b941c88..ebe3a34  master -> master

# 删除远程分支 ，或 git push origin :dev
zgg@DESKTOP-0AHQ4FT MINGW64 ~/Desktop/GitFiles/test (master)
$ git push origin --delete dev
To github.com:ZGG2016/test.git
 - [deleted]         dev
```

参考：[菜鸟教程](https://www.runoob.com/git/git-branch.html)、[带入场景](https://git-scm.com/book/zh/v2/Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%9A%84%E6%96%B0%E5%BB%BA%E4%B8%8E%E5%90%88%E5%B9%B6)