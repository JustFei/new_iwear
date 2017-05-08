//
//  TargetSettingModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TargetSettingModel.h"

@implementation TargetSettingModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"title == %@ name == %@, target == %@", _title, _name, _target];
}

@end
