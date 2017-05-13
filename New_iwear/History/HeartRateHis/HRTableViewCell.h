//
//  HRTableViewCell.h
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <MaterialControls/MaterialControls.h>
#import "HRTableModel.h"

@interface HRTableViewCell : MDTableViewCell

@property (nonatomic, strong) HRTableModel *model;

@end
