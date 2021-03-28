# iOS 小组件widget

	widget可以让用户快速访问他们认为重要的信息, 如今天的天气, 股价, 日程表, 或者快速的执行一个任务
	
	如果用户允许, 小组件可以出现在锁屏界面: 

```
They do so in the “Allow Access When Locked” area by going to Settings > Touch ID & Passcode > Notifications View.
```

  用户和widget交互是快速的并且受限制的, 应该设计一个简单的, 流线型的UI,高亮用户感兴趣的东西, 限制和用户交互的item的数量是个好主意.



### 3.2.1 注意事项

1. 确保小组件与你想要提供的功能相适应, 最好的widget是可以让用户快速刷新或者允许简单的任务
2. 确保内容总是最新的
3. 合适的相应用户交互
4. 表现良好( 必须合理的使用内存, 否则系统可能会干掉它 )
5. widget 不支持键盘输入
6. 避免( 最好不要 )再widget中放scrollview, 用户很难在widget中滑动它



### 3.2.2 高度 & 宽度

	在today widget 页面中, widget的默认总高度经测量为**134** 个点,  系统占用了39个点的高度, 默认的Y的0点就是39.  左右边距各有8个点



### 3.2.3 使用

1 在xcode中 new -> file -> target -> today Extension

2 模板会创建好需要的文件,  如果不需要使用storyboard开发, 则在info.plist文件中删除 NSExtension下的 `NSExtensionMainStoryboard`  字段,     添加 `NSExtensionPrincipalClass` 字段, 值为对应的控制器. 运行后应该开始会有效果了, 可以继续在对应的控制器中进行开发

3 widget 默认显示的是折叠后的效果( 高度134 ), 必须设置displayModel才会显示展开的按钮

```
self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
```

4 设置控件的点击事件跳转到主应用

```
 [self.extensionContext openURL:[NSURL URLWithString:@"footprint://aikesi-widget"] completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"aikesi--success");
        }
    }];
```

5 widget 更新数据的时候 会在这个方法中取新数据

```
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    ///!!!: 每次滑到today widget的时候会调用一次 <test code>
    static int index = 0;
    self.label.text = [self.label.text stringByAppendingFormat:@"__%d",index];
    completionHandler(NCUpdateResultNewData);
    index++;
    
}
```

6 可以在模式切换的时候, 对子控件重新布局

```
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    ///!!!:  最小高度为134, 并且顶部系统占用了39个点.  最大高度好像拿不到是多少,应该够用   默认左右有8个点的缩进
    CGRect frame;
    if(activeDisplayMode == NCWidgetDisplayModeCompact)
    {
        self.preferredContentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 150); // 默认为134
        frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - 16 - 85), 10, 75, 75);
    }else
    {
        // 当widget展开的时候, 图片需要展示位方形的,
        float width = UIScreen.mainScreen.bounds.size.width - 16;
        float imageWidth = width - 20;
        float imageHeight = imageWidth;
        float widgetHeight = imageHeight + 20;
        frame = CGRectMake(10, 10, imageWidth, imageHeight);
        self.preferredContentSize = CGSizeMake(width, widgetHeight);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.frame = frame;
    }];
}
```

7 可以展示动画

```
//// display & resize 时候展现动画
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        }];
}
```

8 最后, widget与主应用的数据是不互通的, 如果要互通的话, 需要处在同一个groupid

中,  所以widget和主应用都要开启groupid功能, 并且在开发者账号下配置groupid. 才能共享数据

方式1: NSUserDefaults  需要传groupid进去

```
 //FIXME: 测试widget共享数据
    NSUserDefaults *shareDefault = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.csdigit.moves"];
    [shareDefault setObject:@"test message" forKey:@"test-widget"];
    [shareDefault synchronize];
```

方式2: 利用NSFileManager共享数据

```
// 在主应用中存储数据 
// NSFileManager 存储数据
- (void)saveFile {
    NSError *error = nil;
    NSURL *containUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.rs.testGroup"];
   containUrl = [containUrl URLByAppendingPathComponent:@"group.data"];
    NSString *text = @"打开app";
    BOOL result = [text writeToURL:containUrl atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (result){
        NSLog(@"save success");
    }else {
        NSLog(@"error:%@", error);
    }
}

// NSFileManager  在widget中读取数据 
- (NSString *)readByFileManager {
    NSError *error = nil;
    NSURL *containUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.rs.testGroup"];
    containUrl = [containUrl URLByAppendingPathComponent:@"group.data"];
    NSString *text = [NSString stringWithContentsOfURL:containUrl encoding:NSUTF8StringEncoding error:&error];
    return text;

```

### 3.2.4  参考

[widget开发](https://www.jianshu.com/p/d328c29cb811)