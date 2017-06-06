//
//  BarView.m
//  SleepCharts
//
//  Created by Faith on 2017/4/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "BarView.h"

/** 浅睡正常颜色 */
#define LOW_DEFAULT_COLOR [UIColor colorWithRed:99.0 / 255.0 green:105.0  / 255.0 blue:189.0 / 255.0 alpha:1]
/** 深睡正常颜色 */
#define DEEP_DEFAULT_COLOR [UIColor colorWithRed:55.0 / 255.0 green:61.0 / 255.0 blue:142.0 / 255.0 alpha:1]
/** 浅睡选中颜色 */
#define LOW_SELECT_COLOR [UIColor colorWithRed:153.0 / 255.0 green:158.0 / 255.0 blue:213.0 / 255.0 alpha:1]
/** 深睡选中颜色 */
#define DEEP_SELECT_COLOR [UIColor colorWithRed:44.0 / 255.0 green:48.0 / 255.0 blue:111.0 / 255.0 alpha:1]

@implementation BarView

- (void)setColor
{
    if (self.isSelect) {
        [self setBackgroundColor:self.backColor == BackColorDeep ? SLEEP_CURRENT_DEEP_SLEEEP_SELECT_BAR : SLEEP_CURRENT_LOW_SLEEEP_SELECT_BAR];
    }else {
        [self setBackgroundColor:self.backColor == BackColorDeep ? SLEEP_CURRENT_DEEP_SLEEEP_BAR : SLEEP_CURRENT_LOW_SLEEEP_BAR];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
