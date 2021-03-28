//
//  AKInfoCell.m
//  Shot
//
//  Created by zhujunwu on 2020/11/20.
//

#import "AKInfoCell.h"

@implementation AKInfoCell

+ (instancetype)dequeueReusedCellWithTableView:(UITableView *)tableView
{
    AKInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AKCell"];
    if (cell == nil) {
        cell = [[AKInfoCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AKCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setModel:(AKInfoModel *)model {
    _model = model;
    self.textLabel.text = model.carNumber;
    self.textLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.numberOfLines = MAXFRAG;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:model.otherInfo];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.lineSpacing = 3;
    style.minimumLineHeight = 17;
    [str addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, model.otherInfo.length)];
    self.detailTextLabel.attributedText = str;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float width = UIScreen.mainScreen.bounds.size.width;
    self.textLabel.frame = CGRectMake(30, 10, (width - 60), 30);
    self.detailTextLabel.frame = CGRectMake(30, 35, (width - 60), 50);
}


@end
