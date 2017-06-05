//
//  HeartRateContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@interface HeartRateContentView : UIView < PNChartDelegate >

- (void)updateHRUIWithDataArr:(NSArray *)dbArr;

@end
