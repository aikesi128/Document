# Universal link 原理

        在安装某个app的时候，iOS系统会检查App bundle中的Info.plist文件。如果发现有associated domain字段，会读取**applinks**的地址，比如open.mycompany.com，然后系统会去该域名根目录下寻找一个名为***apple-app-site-association***的文件。如果有，那么下载到本地，然后解析这个文件。根据path建立与appid的映射关系，保存在系统的数据库中。如果有访问https://open.mycompany.com/path/ 的链接，系统会根据映射关系找到的appid，启动该app，实现universal link。

> 客户端和服务端的任务

根据上述原理，客户端的首要任务就是要告诉系统去哪个域名下找关联文件。这个在associated domain中设置。

剩下的就是在app delegate文件里写处理的方法了。

服务端的任务就是部署这个文件，文件位置可以随便放，但是访问的地址一定要是域名的根目录下。

关联文件的格式，可以参考几个链接：

https://www.douban.com/apple-app-site-association

https://open.cmbchina.com/apple-app-site-association

虽然是json格式的，但是文件名不能有后缀名哦。

> 几个点

       通过抓包看，的确是安装时候就会去下载关联文件。如果此时网络不通，iOS有重试的机制，但具体的策略不太清楚。
    
        iOS9+，不要拿着iOS8系统的手机过来说，为什么ul不起作用。。。
    
        有时候不是跳转到app，而是直接跳转到浏览器打开。其实这是正常的，本来就是应该跳转到safari的，只是我们多了一个跳转到app的选择。第一次链接跳转，会给你一个选择，safari还是app，系统会记住并作为下一次默认的选择。
    
        如果想让url直接跳转到我们的app，可以访问一下域名+path的地址，在safari中下拉页面，会看到一个从app打开的选择，又可以重新选择了。  