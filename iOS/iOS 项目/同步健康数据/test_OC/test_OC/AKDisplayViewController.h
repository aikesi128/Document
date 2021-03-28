//
//  AKDisplayViewController.h
//  test_OC
//
//  Created by zhujunwu on 2021/3/1.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface AKDisplayViewController : UIViewController

@property (nonatomic, strong) HKQuantitySample *sample;

@end

NS_ASSUME_NONNULL_END
