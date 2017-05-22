//
//  UnitsSettingTableViewCell.h
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <MaterialControls/MaterialControls.h>
#import "UnitsSettingModel.h"

typedef void(^UnitsSettingSelectBlock)(void);

@interface UnitsSettingTableViewCell : MDTableViewCell

@property (nonatomic, strong) UnitsSettingModel *model;
@property (nonatomic, copy) UnitsSettingSelectBlock unitsSettingSelectBlock;

@end
