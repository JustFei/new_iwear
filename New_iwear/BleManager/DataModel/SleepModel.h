//
//  SleepModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SleepDataLastData = 0,
    SleepDataHistoryData,
    SleepDataHistoryCount
} SleepData;

typedef enum : NSUInteger {
    SleepTypeDeep = 0,
    SleepTypeLow,
    SleepTypeClear,
} SleepType;

@interface SleepModel : NSObject
//关于睡眠数据的情况同心率数据的情况

//判断睡眠数据的状态未历史还是最后一次
@property (nonatomic, assign) SleepData sleepState;
//总的数据条数
@property (nonatomic, assign) NSInteger sumDataCount;
//当前的数据条数
@property (nonatomic, assign) NSInteger currentDataCount;
//开始睡眠时间值：类型为YYMMDDhhmm
@property (nonatomic, copy) NSString *startTime;
//结束睡眠的时间
@property (nonatomic, copy) NSString *endTime;
//深度睡眠时间
@property (nonatomic, copy) NSString *deepSleep;
//浅度睡眠时间
@property (nonatomic, copy) NSString *lowSleep;
//总睡眠时间
@property (nonatomic, copy) NSString *sumSleep;
//清醒时间
@property (nonatomic, copy) NSString *clearTime;
//数据类型
@property (nonatomic, assign) SleepType type;
//日期：用于查询
@property (nonatomic, copy) NSString *date;

@end
