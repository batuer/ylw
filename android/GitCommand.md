title:  Git命令
date: 2018年3月13日22:50:00
categories: Git
tags: 

	 - Git
cover_picture: /images/GitCommand.png
---

### Githug 安装及命令

1. [Githug]: https://github.com/Gazler/githug

2. 安装Ruby 1.8.7 or higher

3. gem install githug

4. 如果遇到权限问题，请加上`sudo`：sudo gem install githug

5. Commands
   - play 
   - hint 
   - reset 
   - levels

### 开始游戏

  GitLevels

![Markdown](https://upload-images.jianshu.io/upload_images/2088926-5abcaf67c2944559.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

使用githug hint命令根据提示完成，用githug play验证完成结果。

### 命令

1. 初始化：git init

2. 添加所有：git add .

3. 本地提交信息：git commit -m'***'

4. 远程仓库添加：git remote add origin git@gitee.com:****

5. 远程仓库更换：git remote set-url origin git@gitee.com:****

6. 远程提交：git push origin master

7. 查看本地分支：git branch 

8. 查看所有分支 ：git  branch  -a

9. 查看远程分支：git branch -r

10. 删除本地分支：git branch -D xxx

11. 删除远程分支： git push origin delete xxx

12. 提交所有远程分支：git push --all origin

13. 拉取远程分支并在本地创建：git  checkout  -b  xxx  origin/xxx

14. 切换本地分支：git  checkout  xxx 

15. 移除暂存区：git reset HEAD file

16. 丢弃工作区的修改：git checkout -- file

17. 查看本地Log：git log

18. 查看远程Log：git log origin/master

19. 指定默认分支：git branch --set-upstream-to=origin/<branch> develop 或者git push --set-upstream origin develop

20. Log信息一行：
    - git log --pretty=oneline
    - git log --oneline

21. cherry-pick
    - 单个：git cherry-pick commit-id
    - 多个：git cherry-pick commit-id**..**commit-id

22. 合并
    1. git merge xxx  :将xxx分支合并到当前分支:
    2. Rebase 实际上就是取出一系列的提交记录，“复制”它们，然后在另外一个地方逐个的放下去。 
       1. git rebase xxx :将xxx分支合并到当前分支。
       2. git rebase -i xxx1   xxx2: 合并xxx1到xxx2。

23. 回退：
    1. git checkout HEAD^：回退前一个
    2. git checkout HEAD~n：回退n个 提交

24. 撤销
    1. git reset ：本地撤销。

       |  选型   | HEAD | Index | Working copy |
       | :-----: | :--: | :---: | :----------: |
       | --soft  |  是  |  否   |      否      |
       | --mixed |  是  |  是   |      否      |
       | --hard  |  是  |  是   |      是      |

       - Head：当前分支的最近一个提交。
       - Index：暂存区。
       - WorKing Copy：工作文件集。

    2. git revert：提交一个新的版本，将需要revert的版本的内容再反向修改回去 

    3. git revert 和 git reset的区别 
       1. git revert是用一次新的commit来回滚之前的commit，git reset是直接删除指定的commit。
       2. 在回滚这一操作上看，效果差不多。但是在日后继续merge以前的老版本时有区别。因为git revert是用一次逆向的commit“中和”之前的提交，因此日后合并老的branch时，导致这部分改变不会再次出现，但是git reset是之间把某些commit在某个branch上删除，因而和老的branch再次merge时，这些被回滚的commit应该还会被引入。 
       3. git reset 是把HEAD向后移动了一下，而git revert是HEAD继续前进，只是新的commit的内容和要revert的内容正好相反，能够抵消要被revert的内容。 

25. Log
    1. git log：HEAD及以前
    2. git reflog：所有Log



### 错误

1. fatal: refusing to merge unrelated histories
   - git pull origin master --allow-unrelated-histories 
2. error:src refspec xxx does not match any
   - git checkout -b xxx

