//
//  ViewController.m
//  test_OC
//
//  Created by zhujunwu on 2021/2/25.
//

#import "ViewController.h"
#import "AKDisplayViewController.h"
#import <HealthKit/HealthKit.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *
 *  用户希望用move x记录骑自行车的数据能自动同步到apple health。
 *  apple health 如果要记录骑车，就得点一下记录。
 *  但是用户说他用human记录的骑车，可以同步到apple health。
 *  是不是apple health只能同步过去那种导航模式主动记录的骑车？
 *  方案: 深入理解HealthKit, 了解具体哪些数据可以存取?
 *  可能的方式: 步行, 跑步, 骑车.
 *
 *
 *
 *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
@interface ViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSStreamDelegate,NSURLSessionDownloadDelegate>
@property (nonatomic, strong) HKHealthStore *store;
@property(nonatomic,weak)UITextField *field;
@property(nonatomic,weak)UITableView *table;
@property(nonatomic,weak)UIButton *currentButton;
@property(nonatomic,weak)UILabel *label;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSStream *stream; //!<
@property (nonatomic, strong) NSMutableData *data; //!<
@property (nonatomic, strong) NSURLSessionDownloadTask *task; //!< <#des#>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    [self setup_stream];
    [self setup];
}

/*! setup  */
- (void)setup
{
    [self.navigationController.navigationBar setTranslucent:NO];
    UILabel *prompt = [[UILabel alloc]init];
    prompt.frame = CGRectMake(60, 100, 310, 30);
    prompt.font = [UIFont boldSystemFontOfSize:14];
    prompt.textColor = UIColor.redColor;
    prompt.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(3, 15, 3, 15);// = UIEdgeInsetsMake(3, 20, 3, 0);
    [self.view addSubview:prompt];
    self.label = prompt;
    
    // 步数, 走路距离, 骑车距离
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(60, 140, 275, 40)];
    field.placeholder = @"input number";
    field.returnKeyType = UIReturnKeyDone;
    field.delegate = self;
    field.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:field];
    self.field = field;
    
    
    
    float width = 100, height = 40, paddingLeft = 20;
    NSArray *titles = @[@"增加步数", @"增加走路距离",@"增加骑车距离", @"删除步数", @"删除走路距离", @"删除骑车距离"];
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.tag = i;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.layer.borderWidth = 2;
        [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [button setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        button.layer.borderColor = UIColor.orangeColor.CGColor;
        button.frame = CGRectMake( 30 + (i%3) * (width + paddingLeft), 200 + (i/3)*(height + 30), width, height);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    UITableView *table = [[UITableView alloc]init];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    table.frame = CGRectMake(0, 350, self.view.bounds.size.width, self.view.bounds.size.height - 350);
    [self.view addSubview:table];
    self.table = table;
    
    self.label.text = @"开始查询步数";
    // 默认应该是查询到今天的步数
    self.store = [[HKHealthStore alloc]init];
    if (HKHealthStore.isHealthDataAvailable) {
        // 申请授权
        NSSet *set = [NSSet setWithObjects:[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling], nil];
        [self.store requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.label.text = @"已经弹框提示用户";
            });
        }];
        
    }else {
        self.label.text = @"不支持HealthKit";
    }
    
    // 监听进入
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidActivity:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)appDidActivity:(id)sender
{
    // App 不知道用户对数据类型的授权状态
//    NSSet *set = [NSSet setWithObjects:[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling], nil];
   
}
  


#pragma mark -- button click

- (void)buttonClick:(UIButton *)sender
{
    if (self.field.text.length == 0) {
        // 查询
        HKQuantityTypeIdentifier identifier;
        if(sender.tag % 3 == 0){
            // 查询步数
            identifier = HKQuantityTypeIdentifierStepCount;
        }else if(sender.tag % 3 == 1){
            // 查询跑步距离
            identifier = HKQuantityTypeIdentifierDistanceWalkingRunning;
        }else{
            // 查询骑车距离
            identifier = HKQuantityTypeIdentifierDistanceCycling;
        }
        HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:[HKSampleType quantityTypeForIdentifier:identifier] predicate:nil limit:10 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            self.dataSource = [results copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
        }];
        [self.store executeQuery:query];
    }else{
        // 给HealthKit写数据
        if ([self.field.text floatValue] == 0) {
            self.label.text = @"请录入有效数据";
            return;
        }
//        HKQuantityTypeIdentifier identifier;
        switch (sender.tag) {
            case 0:
                // 增加步数
            {
                HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] quantity:[HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:[self.field.text floatValue]] startDate:NSDate.date endDate:NSDate.date];
                [self.store saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.label.text = @"StepCount添加成功";
                            
                        });
                    }
                }];
            }
                break;
            case 1:
                // 增加跑步距离
            {
                HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning] quantity:[HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:[self.field.text floatValue]] startDate:NSDate.date endDate:NSDate.date];
                [self.store saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.label.text = @"WalkingRunning添加成功";
                            
                        });
                    }
                }];
            }
                break;
            case 2:
                // 增加骑车
            {
                HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling] quantity:[HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:[self.field.text floatValue]] startDate:NSDate.date endDate:NSDate.date];
                [self.store saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.label.text = @"Cycling添加成功";
                            
                        });
                    }
                }];
            }
                break;
            case 3:
            {
                // 减少步数
                HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] predicate:nil limit:10 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
                    for (HKQuantitySample *sample in results) {
                        NSLog(@"aikesi--%f",[sample.quantity doubleValueForUnit:[HKUnit countUnit]]);
                    }
                    [self.store deleteObject:results.firstObject withCompletion:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.label.text = @"StepCount删除成功";
                                
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.label.text = [NSString stringWithFormat:@"%@",error.description];
                                
                            });
                            
                        }
                    }];
                }];
                [self.store executeQuery:query];
            }
                break;
            case 4:
                // 减少走路
            {
                HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning] predicate:nil limit:10 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
                    [self.store deleteObject:results.firstObject withCompletion:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.label.text = @"WalkingRunning删除成功";
                            });
                        }
                    }];
                   
                }];
                [self.store executeQuery:query];
            }
                break;
            case 5:
                // 减少骑车
            {
                HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling] predicate:nil limit:10 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
                    [self.store deleteObject:results.firstObject withCompletion:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.label.text = @"DistanceCycling删除成功";
                                
                            });
                        }
                    }];
                   
                }];
                [self.store executeQuery:query];
            }
                break;
                
            default:
                break;
        }
        self.field.text = nil;
        HKQuantityTypeIdentifier identifier;
        if(sender.tag % 3 == 0){
            // 查询步数
            identifier = HKQuantityTypeIdentifierStepCount;
        }else if(sender.tag % 3 == 1){
            // 查询跑步距离
            identifier = HKQuantityTypeIdentifierDistanceWalkingRunning;
        }else{
            // 查询骑车距离
            identifier = HKQuantityTypeIdentifierDistanceCycling;
        }
        HKSampleQuery *query = [[HKSampleQuery alloc]initWithSampleType:[HKSampleType quantityTypeForIdentifier:identifier] predicate:nil limit:10 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            self.dataSource = [results copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
        }];
        [self.store executeQuery:query];
        
    }
    
}

#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.dataSource) {
        return 1;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.dataSource) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"直接点击第一排按钮为查询功能";
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aikesi"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aikesi"];
        }
        HKQuantitySample *quantity = self.dataSource[indexPath.row];
        HKUnit *unit = nil;
        if (quantity.sampleType.identifier == HKQuantityTypeIdentifierStepCount) {
            unit = [HKUnit countUnit];
        }else {
            unit = [HKUnit meterUnit];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%.0f   %@",[quantity.quantity doubleValueForUnit:unit], quantity.startDate];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AKDisplayViewController *controller = [AKDisplayViewController new];
    HKQuantitySample *quantity = self.dataSource[indexPath.row];
    controller.sample = quantity;
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 刷新列表,
    [self.view endEditing:YES];
//    self.field.text = nil;
    return YES;
}


//----------------------------- 测试 stream -------------------------


 
- (void)setup_stream
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m801.music.126.net/20210303144331/a4d7b3b69b104aa9fd5474491a1e55c9/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/5678834389/f9c7/a240/c9b1/f1b9def3b4fc8a84134d87234d09049a.mp3"]]];
    [task resume];
    self.task = task;
//    NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:[NSURL URLWithString:@"http://m801.music.126.net/20210303144331/a4d7b3b69b104aa9fd5474491a1e55c9/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/5678834389/f9c7/a240/c9b1/f1b9def3b4fc8a84134d87234d09049a.mp3"]];
//    inputStream.delegate = self;
//    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [inputStream open];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"aikesi--下载完后曾");
}
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"aikesi--正在下载");
     
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone: {
            NSLog(@"NSStreamEventNone");
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            if (!_data) {
                _data = [NSMutableData data];
            }
            uint8_t buf[1024];
            NSInteger len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:1024];  // 读取数据
            if (len) {
                [_data appendBytes:(const void *)buf length:len];
            }
        }
            break;
         
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"aikesi--NSStreamEventHasSpaceAvailable");
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSLog(@"erroe happend");
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog(@"aikesi--finished");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            break;
        }
    }
}


@end
