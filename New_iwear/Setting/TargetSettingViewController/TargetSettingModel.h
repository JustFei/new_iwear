//
//  TargetSettingModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TargetModeMotion = 0,
    TargetModeSleep
} TargetMode;

@interface TargetSettingModel : NSObject

@property (nonatomic, assign) TargetMode mode;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *target;

@end
