//
//  VersionUpdateTableViewCell.h
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <MaterialControls/MaterialControls.h>
#import "VersionModel.h"

typedef void(^UpdateActionBlock)(void);

@interface VersionUpdateTableViewCell : MDTableViewCell

@property (nonatomic, strong) VersionModel *model;
@property (nonatomic, copy) UpdateActionBlock updateActionBlock;

@end
