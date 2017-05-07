//
//  RemindModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindModel.h"

@implementation RemindModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"functionName == %@, headImageName == %@, isOpen == %d", _functionName, _headImageName, _isOpen];
}

@end
