//
//  ClockModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ClockDataSetClock = 0,
    ClockDataGetClock,
} ClockData;

@interface ClockModel : NSObject < NSCoding >

@property (assign, nonatomic) NSInteger ID;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) BOOL isOpen;

@end
