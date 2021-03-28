### 3.1.0 Git 常用命令

拉取远程分支到本地: **git checkout -b develop origin/develop**

从指定分支创建新的分支: **git checkout -b some-feature develop**

删除分支: **git branch -d branchName**

将目标分支合并到当前分支: **git merge branchName**

### 3.1.1  Feature Branch Workflow

	**Feature Branch Workflow 的核心理念**是：master 分支用于部署，功能开发应该在专门的分支而非 master 分支上，任何推向 master 分支的 feature-branch 都应该经过代码审核。即，团队成员共用一个私有项目仓库进行管理协作，开发者在各自的 feature-branch 中进行开发，开发完成后通过提交 Merge Request 进行代码评审，通过代码评审后 merge 进入 master 分支（即可部署到生产环境）。
	
		**Merge Request** 是一个请其他项目成员对代码进行 review 并 merge 的 request。类似 GitHub 的 Pull Request, 两者都是实现对两个 repo 或 branch 的合并。Coding.net 提供了一个友好的 Merge Request 界面，在合并提交的变更到正式项目前可以对其代码进行评审



### 3.1.2 Gitflow

 [参考地址](https://www.cnblogs.com/lcngu/p/5770288.html)

与Feature Branch Workflow比起来，Gitflow流程并没有增加任何新的概念或命令。其特色在于，**给不同的分支分配了非常明确的角色**，并且定义了使用场景和用法。除了用于功能开发的分支，它还使用独立的分支进行发布前的准备、记录以及后期维护。当然，你还是能充分利用Feature Branch Workflow的好处：拉拽请求（Pull Request）、隔离的试验以及更高效率的合作。

原理: 流程仍然使用一个中央代码仓库，它是所有开发者的信息交流中心。跟其他的工作流程一样，开发者在本地完成开发，然后再将分支代码推送到中央仓库。**唯一不同的是项目中分支的结构。**

**其中最为重要的两个分支: master只是用于保存官方的发布历史，而develop分支才是用于集成各种功能开发的分支, 所有从**



**git flow 命令说明:**

```
git flow init : 此命令会进行一些默认配置,终端会询问分支名称和前缀等信息, 完成后当前分支为develop分支
```

```
git flow feature start newFeatureName  开始开发一个新功能的时候, 此命令会自动从develop创建名称为newFeatureBranch的分支, 并切换到该分支
```

```
git flow feature finish newFeatureName  完成功能分支开发, 次分支会将newFeatureName合并到develop分支, 并且在完成后删除newFeatureName分支,切换到develop分支
```

```
git flow feature publish some_awesome_feature 或者 git push origin feature/some_awesome_feature  将一个feature分支推向远程服务器
```

```
git flow release start v0.1.0  基于develop创建一个发布(release)分支
```

```
git flow release finish v0.1.0 会把所作的修改合并到master分支，同时合并回develop分支
```

```
git flow hotfix start v0.1.0  当你在完成（finish)一个维护分支时，它会把你所作的修改合并到master分支，同时合并回develop分支
```

```
git flow feature publish MYFEATURE  (也就是push到远程)
```

 ```
git flow feature pull origin MYFEATURE  获取Publish的Feature
 ```

```
git flow hotfix start VERSION 开始一个hotfix
```

```
git flow hotfix finish VERSION  发布一个hotfix
```



![例图](https://images.cnblogs.com/cnblogs_com/cnblogsfans/771108/o_git-flow-commands.png)