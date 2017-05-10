//
//  SedentaryReminderModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SedentaryReminderModel.h"

@implementation SedentaryReminderModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"_title == %@ _subTitle == %@, _time == %@, _timeState == %@, _whetherHaveSwitch == %d, _switchIsOpen == %d", _title, _subTitle, _time, _timeState, _whetherHaveSwitch, _switchIsOpen];
}

@end
