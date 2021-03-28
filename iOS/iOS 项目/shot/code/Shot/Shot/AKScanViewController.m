//
//  AKScanViewController.m
//  Shot
//
//  Created by zhujunwu on 2020/11/20.
//

#import "AKScanViewController.h"

@interface AKScanViewController ()

@property (nonatomic, strong) UIButton *addButton; //!<  scan
@property (nonatomic, strong) UITextField *carNumberTextField; //!<  车牌号码
@property (nonatomic, strong) UITextField *homeTextField; //!<  门牌号
@property (nonatomic, strong) UITextField *moneyTextField; //!<  缴费进而
@property (nonatomic, strong) UITextField *nameTextField; //!<  车主姓名

@end

@implementation AKScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

/*! setup  */
- (void)setup
{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.carNumberTextField];
    [_carNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.top.equalTo(self.view).offset(100);
    }];
    [self.view addSubview:self.homeTextField];
    [_homeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.top.equalTo(self.carNumberTextField.mas_bottom).offset(18);
    }];
    [self.view addSubview:self.moneyTextField];
    [_moneyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.top.equalTo(self.homeTextField.mas_bottom).offset(18);
    }];
    [self.view addSubview:self.nameTextField];
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.top.equalTo(self.moneyTextField.mas_bottom).offset(18);
    }];
    [self.view addSubview:self.addButton];
    [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@30);
        make.top.equalTo(self.nameTextField.mas_bottom).offset(18);
    }];
    
}

#pragma mark -- button click

- (void)addButtonClick:(id)sender
{
    if (_carNumberTextField.text.length == 0 || _homeTextField.text.length == 0 || _moneyTextField.text.length == 0 || _nameTextField.text.length == 0) {
            MBProgressHUD *hud =  [MBProgressHUD new];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"信息不完整";
            [self.view addSubview:hud];
            [hud showAnimated:YES];
            [hud hideAnimated:YES afterDelay:1];
            return;
        }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1.txt" ofType:nil];
    NSString *content = [[NSString alloc]initWithContentsOfFile:path_local_file encoding:NSUTF8StringEncoding error:nil];
    if (content.length == 0) {
       content = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    content = [content stringByAppendingFormat:@"\n%@,%@,%@,%@,程序统计时间:%@",_homeTextField.text,_nameTextField.text,_carNumberTextField.text,_moneyTextField.text,[df stringFromDate:NSDate.date]];
    [content writeToFile:path_local_file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"aikesi--%@",path_local_file);
    [self.navigationController popViewControllerAnimated:YES];
     
}


#pragma mark -- lazy

- (UITextField *)carNumberTextField {
    
    if (!_carNumberTextField) {
        _carNumberTextField = [[UITextField alloc]init];
        _carNumberTextField.placeholder = @"请输入车牌号码";
        _carNumberTextField.font = [UIFont systemFontOfSize:16];
        _carNumberTextField.textColor = UIColor.purpleColor;
        _carNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
        _carNumberTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _carNumberTextField;;
}

- (UITextField *)homeTextField {
    
    if (!_homeTextField) {
        _homeTextField = [[UITextField alloc]init];
        _homeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _homeTextField.placeholder = @"请输入门牌号";
        _homeTextField.font = [UIFont systemFontOfSize:16];
        _homeTextField.textColor = UIColor.purpleColor;
        _homeTextField.borderStyle = UITextBorderStyleRoundedRect;
        _homeTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _homeTextField;;
}

- (UITextField *)moneyTextField {
    
    if (!_moneyTextField) {
        _moneyTextField = [[UITextField alloc]init];
        _moneyTextField.keyboardType = UIKeyboardTypeNumberPad;
        _moneyTextField.placeholder = @"请输入缴费金额";
        _moneyTextField.font = [UIFont systemFontOfSize:16];
        _moneyTextField.textColor = UIColor.purpleColor;
        _moneyTextField.borderStyle = UITextBorderStyleRoundedRect;
        _moneyTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _moneyTextField;;
}

- (UITextField *)nameTextField {
    
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc]init];
        _nameTextField.placeholder = @"请输入车主姓名";
        _nameTextField.font = [UIFont systemFontOfSize:16];
        _nameTextField.textColor = UIColor.purpleColor;
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _nameTextField;;
}


- (UIButton *)addButton {
    
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:@"添加" forState:UIControlStateNormal];
        [_addButton setTitleColor:UIColor.purpleColor forState:UIControlStateNormal];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}


@end
