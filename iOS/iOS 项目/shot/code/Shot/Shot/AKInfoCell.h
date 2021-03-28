//
//  AKInfoCell.h
//  Shot
//
//  Created by zhujunwu on 2020/11/20.
//

#import <UIKit/UIKit.h>
#import "AKInfoModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface AKInfoCell : UITableViewCell

@property (nonatomic, strong) AKInfoModel *model;

+ (instancetype)dequeueReusedCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
