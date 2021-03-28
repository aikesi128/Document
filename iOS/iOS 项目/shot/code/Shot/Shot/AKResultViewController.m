//
//  AKResultViewController.m
//  Shot
//
//  Created by zhujunwu on 2020/11/20.
//

#import "AKResultViewController.h"
#import "AKInfoCell.h"

@interface AKResultViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation AKResultViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setup];
}

/*! setup  */
- (void)setup
{
    self.title = @"搜索结果";
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    tableView.rowHeight = 100;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // back btn
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回搜索页面" forState:UIControlStateNormal];
    [backButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    backButton.backgroundColor = [UIColor colorWithRed:0.01 green:0.4 blue:0.6 alpha:1];
    backButton.layer.cornerRadius = 8;
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@44);
        make.bottom.equalTo(tableView.mas_bottom).offset(-44);
    }];
    
    if (self.carNumber.length) {
        NSMutableArray *tem = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"1.txt" ofType:nil];
        NSString *content = [[NSString alloc]initWithContentsOfFile:path_local_file encoding:NSUTF8StringEncoding error:nil];
        if (content.length == 0) {
           content = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        NSArray *contactArr = [content componentsSeparatedByString:@"\n"];
        for (NSString *info in contactArr) {
            if (info.length == 0) {
              continue;
            }
            
            NSArray *infoArr = [info componentsSeparatedByString:@","];
            NSString *carNumber = infoArr[2];
            NSString *temCarNumber = carNumber;
            for (int i = 0; i < _carNumber.length; i++) {
                NSString *chars = [_carNumber substringWithRange:NSMakeRange(i, 1)];
                if (![temCarNumber containsString:chars]) {
                    // 不包含当前字母
                    continue;
                }
                NSRange range = [temCarNumber rangeOfString:chars];
                temCarNumber = [temCarNumber stringByReplacingCharactersInRange:range withString:@""];
            }
            if (temCarNumber.length != carNumber.length - _carNumber.length) {
                continue;
            }
            
            // 过完循环则符合条件
            AKInfoModel *model = [AKInfoModel new];
            model.carNumber = infoArr[2];
            model.otherInfo = [NSString stringWithFormat:@"车主信息: %@, 住户:%@, 缴费金额:%@,%@",infoArr[1],infoArr[0],infoArr[3],infoArr[4]];
            [tem addObject:model];
        }
        self.dataSource = [tem copy];
    }
}

#pragma mark -- button click

- (void)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AKInfoCell *cell = [AKInfoCell dequeueReusedCellWithTableView:tableView];
    cell.model = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",@(indexPath.row+1),cell.model.carNumber];
    return cell;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *tem = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"1.txt" ofType:nil];
        NSString *content = [[NSString alloc]initWithContentsOfFile:path_local_file encoding:NSUTF8StringEncoding error:nil];
        if (content.length == 0) {
           content = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        NSArray *contactArr = [content componentsSeparatedByString:@"\n"];
        for (NSString *info in contactArr) {
            if (info.length == 0) {
                continue;
            }
            NSArray *infoArr = [info componentsSeparatedByString:@","];
            AKInfoModel *model = [AKInfoModel new];
            model.carNumber = infoArr[2];
            model.otherInfo = [NSString stringWithFormat:@"车主信息: %@, 住户:%@, 缴费金额:%@,%@",infoArr[1],infoArr[0],infoArr[3],infoArr[4]];
            [tem addObject:model];
        }
        _dataSource = [tem copy];
    }
    return _dataSource;
}


@end
