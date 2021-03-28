//
//  ViewController.m
//  Shot
//
//  Created by zhujunwu on 2020/11/20.
//

#import "ViewController.h"
#import "AKScanViewController.h"
#import "AKResultViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *scanButton; //!<  scan
@property (nonatomic, strong) UITextField *searchTextField; //!<  search TF

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setup];
}

/*! setup  */
- (void)setup
{
    
    // search TF
    [self.view addSubview:self.searchTextField];
    [_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.centerY.equalTo(self.view);
    }];
    [self.searchTextField becomeFirstResponder];
    
    // !!!: 暂时不用扫描功能, 没时间弄  scan btn
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.scanButton];
    
    // search btn
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [searchButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [searchButton addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.backgroundColor = [UIColor colorWithRed:0.01 green:0.4 blue:0.6 alpha:1];
    searchButton.layer.cornerRadius = 8;
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@44);
        make.top.equalTo(self.searchTextField.mas_bottom).offset(20);
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [_searchTextField resignFirstResponder];
}

#pragma mark -- button click

- (void)scanButtonClick:(id)sender {

    AKScanViewController *controller = [[AKScanViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)searchButtonClick:(id)sender {
    
//    if(_searchTextField.text.length == 0) {
//        MBProgressHUD *hud =  [MBProgressHUD new];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = @"未输入车牌信息";
//        [self.view addSubview:hud];
//        [hud showAnimated:YES];
//        [hud hideAnimated:YES afterDelay:1];
//        return;
//    }
    AKResultViewController *controller = [AKResultViewController new];
    controller.carNumber = self.searchTextField.text;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -- UITextFieldDelegate

// 超过5个数字则放弃输入
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 4 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

#pragma mark -- lazy

- (UITextField *)searchTextField {
    
    if (!_searchTextField) {
        _searchTextField = [[UITextField alloc]init];
        _searchTextField.keyboardType = UIKeyboardTypeNumberPad;
        _searchTextField.placeholder = @"请输入车牌号码中的数字";
        _searchTextField.font = [UIFont systemFontOfSize:16];
        _searchTextField.textColor = UIColor.purpleColor;
        _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
        _searchTextField.clearButtonMode = UITextFieldViewModeAlways;
        _searchTextField.delegate = self;
    }
    return _searchTextField;;
}


- (UIButton *)scanButton {
    
    if (!_scanButton) {
        _scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanButton setTitle:@"添加车辆信息" forState:UIControlStateNormal];
        [_scanButton setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
        _scanButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_scanButton addTarget:self action:@selector(scanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanButton;
}

@end
