//
//  XXBarDataModel.m
//  New_iwear
//
//  Created by JustFei on 2017/6/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "XXBarDataModel.h"

@implementation XXBarDataModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"xValue == %.1f xWidth == %.1f barType == %ld", _xValue, _xWidth, _barType];
}

@end
