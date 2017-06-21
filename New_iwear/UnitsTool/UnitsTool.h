//
//  UnitsTool.h
//  ManridyApp
//
//  Created by Faith on 2017/3/31.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MetricToImperial,
    ImperialToMetric
} Mode;

@interface UnitsTool : NSObject

/** 厘米转英寸 */
+ (float)cmAndInch:(NSInteger)param withMode:(Mode)mode;
/** 千克转磅 */
+ (float)kgAndLb:(NSInteger)param withMode:(Mode)mode;
/** 千米转英里 */
+ (float)kmAndMi:(NSInteger)param withMode:(Mode)mode;
//判断是否是公制单位
+ (BOOL)isMetricOrImperialSystem;
@end
