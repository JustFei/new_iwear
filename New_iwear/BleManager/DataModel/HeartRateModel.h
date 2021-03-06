//
//  HeartRateModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HeartRateDataLastData = 0,
    HeartRateDataHistoryData,
    HeartRateDataHistoryCount,
    HeartRateDataSingleTestSuccess, //单次测量是否成功
    HeartRateDataContinuous,     //持续测量
    HeartRateDataUpload         //测量完成时实时上报的数据
} HeartRateData;

@interface HeartRateModel : NSObject
/**
 *  关于心率数据有两种情况：
 *  1.获取最后一条数据的情况下，sumDataCount和currentDataCount将为空值，没有意义；
 *  2.获取历史数据的情况下，currentDataCount为当前数据编号，sumDataCount为总的数据条数；
 */

//判断是最后一次心率还是历史心率
@property (nonatomic ,assign) HeartRateData heartRateState;
//总的数据条数
@property (nonatomic ,copy) NSString *sumDataCount;
//当前的数据条数
@property (nonatomic ,copy) NSString *currentDataCount;
//心率数据的时间值：类型为YYMMDDhhmmss
@property (nonatomic ,copy) NSString *time;
//心率数据
@property (nonatomic ,copy) NSString *heartRate;
//用来按天查询
@property (nonatomic ,copy) NSString *date;
//用来按月查询
@property (nonatomic, copy) NSString *month;
//用来判断但是测量是否成功
@property (nonatomic, assign) BOOL singleTestSuccess;

@end
