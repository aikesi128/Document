//
//  AKDisplayViewController.m
//  test_OC
//
//  Created by zhujunwu on 2021/3/1.
//

#import "AKDisplayViewController.h"

@interface AKDisplayViewController ()

@end

@implementation AKDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 350, 650)];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = UIColor.blackColor;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    
    // 开始拼串
    NSMutableString *str = [NSMutableString stringWithString:@"\n\n\n\n\n"];
    [str appendFormat:@"UUID:%@\n",_sample.UUID];
    [str appendFormat:@"开始时间:%@\n",_sample.startDate];
    [str appendFormat:@"结束时间:%@\n",_sample.endDate];
    [str appendFormat:@"metadata:%@\n",_sample.metadata];
    [str appendFormat:@"sourceRevision:%@\n",_sample.sourceRevision];
    [str appendFormat:@"device:%@\n",_sample.device];
    [str appendFormat:@"sampleType:%@\n",_sample.sampleType];
    label.text = str;
}

 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
