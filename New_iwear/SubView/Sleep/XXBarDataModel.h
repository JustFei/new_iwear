//
//  XXBarDataModel.h
//  New_iwear
//
//  Created by JustFei on 2017/6/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BarTypeDeep = 0,
    BarTypeLow,
    BarTypeClear
} BarType;

@interface XXBarDataModel : NSObject

@property (nonatomic, assign) float xValue;
@property (nonatomic, assign) float xWidth;
@property (nonatomic, assign) BarType barType;

@end
