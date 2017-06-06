//
//  BarChartView.m
//  SleepCharts
//
//  Created by Faith on 2017/4/14.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "XXBarChartView.h"

@implementation XXBarChartView

#pragma - init
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setupDefaultValues];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupDefaultValues];
    }
    
    return self;
}

//设置默认值
- (void)setupDefaultValues
{
//    [super setupDefaultValues];
    self.backgroundColor = [UIColor whiteColor];
}

//设置X的值
- (void)setXValues:(NSArray *)xValues
{
    _xValues = xValues;
}

- (void)updateBar
{
    
}

@end
