//
//  ClockTableViewCell.h
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockModel.h"

//时间按钮的 block
typedef void(^TimeButtonActionBlock)(void);
//开关按钮的 block
typedef void(^TimeSwitchActionBlock)(void);

@interface ClockTableViewCell : MDTableViewCell

@property (nonatomic, strong) ClockModel *model;

@property (nonatomic, copy) TimeButtonActionBlock timeButtonActionBlock;
@property (nonatomic, copy) TimeSwitchActionBlock timeSwitchActionBlock;

@end
