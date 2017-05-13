//
//  HRTableModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "HRTableModel.h"

@implementation HRTableModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"_dateStr == %@, _timeStr == %@, _dataStr == %@, _unitStr == %@", _dateStr, _timeStr, _dataStr, _unitStr];
}

@end
