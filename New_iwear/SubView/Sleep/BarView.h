//
//  BarView.h
//  SleepCharts
//
//  Created by Faith on 2017/4/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BackColorDeep = 0,
    BackColorLow,
} BackColor;

@interface BarView : UIView

@property (nonatomic, assign) BackColor backColor;
@property (nonatomic, assign) BOOL isSelect;

- (void)setColor;

@end
