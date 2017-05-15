//
//  TrainingTableModel.m
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TrainingTableModel.h"

@implementation TrainingTableModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"_periodStr == %@, _sportTypeStr == %@, _timeCountStr == %@, _stepStr == %@, _kcalStr == %@", _periodStr, _sportTypeStr, _timeCountStr, _stepStr, _kcalStr];
}

@end
