//
//  BarView.m
//  SleepCharts
//
//  Created by Faith on 2017/4/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "BarView.h"

@implementation BarView

- (void)setColor
{
    if (self.isSelect) {
        DLog(@"+++++++++++%ld", self.backColor);
        switch (self.backColor) {
            case BackColorDeep:
                [self setBackgroundColor:SLEEP_CURRENT_DEEP_SLEEEP_SELECT_BAR];
                break;
            case BackColorLow:
                [self setBackgroundColor:SLEEP_CURRENT_LOW_SLEEEP_SELECT_BAR];
                break;
            case BackColorClear:
                [self setBackgroundColor:SLEEP_CURRENT_CLEAR_SLEEEP_BAR];
                break;
                
            default:
                break;
        }
    }else {
        switch (self.backColor) {
            case BackColorDeep:
                [self setBackgroundColor:SLEEP_CURRENT_DEEP_SLEEEP_BAR];
                break;
            case BackColorLow:
                [self setBackgroundColor:SLEEP_CURRENT_LOW_SLEEEP_BAR];
                break;
            case BackColorClear:
                [self setBackgroundColor:SLEEP_CURRENT_CLEAR_SLEEEP_BAR];
                break;
                
            default:
                break;
        }

    }
}

@end
