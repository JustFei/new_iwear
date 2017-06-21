//
//  UnitsTool.m
//  ManridyApp
//
//  Created by Faith on 2017/3/31.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UnitsTool.h"

@implementation UnitsTool

/** 厘米转英寸 */
+ (float)cmAndInch:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 0.3937 : param / 0.3937;
}

/** 千克转磅 */
+ (float)kgAndLb:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 2.205 : param / 2.205;
}

/** 千米转英里 */
+ (float)kmAndMi:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 0.62137 : param / 0.62137;
}

//判断是否是公制单位
+ (BOOL)isMetricOrImperialSystem
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LONG_MEASURE]) {
        BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:LONG_MEASURE];
        return isMetric;
    }else {
        return YES;
    }
}

@end
