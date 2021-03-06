//
//  FMDBManager.h
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class SportModel;
@class HeartRateModel;
@class UserInfoModel;
@class SleepModel;
@class ClockModel;
@class BloodModel;
@class BloodO2Model;
@class SedentaryModel;

typedef enum : NSUInteger {
    SQLTypeStep = 0,
    SQLTypeHeartRate,
    SQLTypeTemperature,
    SQLTypeSleep,
    SQLTypeBloodPressure,
    SQLTypeUserInfoModel,
} SQLType;

typedef enum : NSUInteger {
    QueryTypeAll = 0,
    QueryTypeWithDay,
    QueryTypeWithMonth,
    QueryTypeWithLastCount      //取出最后几条数据
} QueryType;

@interface FMDBManager : NSObject

- (instancetype)initWithPath:(NSString *)path;

//#pragma mark - ClockData
//- (BOOL)insertClockModel:(ClockModel *)model;
//
//- (NSMutableArray *)queryClockData;
//
//- (BOOL)deleteClockData:(NSInteger)deleteSql;
//
//- (BOOL)modifyClockModel:(ClockModel *)model withModifyID:(NSInteger)ID;

#pragma mark - StepData 
//插入模型数据
- (BOOL)insertStepModel:(SportModel *)model;

//查询数据,如果 传空 默认会查询表中所有数据
- (NSArray *)queryStepWithDate:(NSString *)date;

//删除数据,如果 传空 默认会删除表中所有数据
//- (BOOL)deleteData:(NSString *)deleteSql;

//修改数据
- (BOOL)modifyStepWithDate:(NSString *)date model:(SportModel *)model;

#pragma mark - SegmentStepData
//插入分段计步数据
- (BOOL)insertSegmentStepModel:(SegmentedStepModel *)model;

//查询分段计步数据
- (NSArray *)querySegmentedStepWithDate:(NSString *)date;

#pragma mark - SegmentRunData
//插入分段计步数据
- (BOOL)insertSegmentRunModel:(SegmentedRunModel *)model;

//查询分段计步数据
- (NSArray *)querySegmentedRunWithDate:(NSString *)date;

#pragma mark - HeartRateData
- (BOOL)insertHeartRateModel:(HeartRateModel *)model;

- (NSArray *)queryHeartRate:(NSString *)queryStr WithType:(QueryType)type;

- (BOOL)deleteHeartRateData:(NSString *)deleteSql;

#pragma mark - SleepData
- (BOOL)insertSleepModel:(SleepModel *)model;

- (NSArray *)querySleepWithDate:(NSString *)date;

- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model;

- (BOOL)deleteSleepData:(NSString *)deleteSql;

- (BOOL)deleteSleep;

#pragma mark - BloodPressureData
- (BOOL)insertBloodModel:(BloodModel *)model;

- (NSArray *)queryBlood:(NSString *)queryStr WithType:(QueryType)type;

//- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model;

//- (BOOL)deleteSleepData:(NSString *)deleteSql;

#pragma mark - BloodO2Data
- (BOOL)insertBloodO2Model:(BloodO2Model *)model;

- (NSArray *)queryBloodO2:(NSString *)queryStr WithType:(QueryType)type;

- (BOOL)deleteBloodData:(NSString *)deleteSql;

//#pragma mark - UserInfoData
//- (BOOL)insertUserInfoModel:(UserInfoModel *)model;
//
//- (NSArray *)queryAllUserInfo;
//
//- (BOOL)modifyUserInfoWithID:(NSInteger)ID model:(UserInfoModel *)model;
//
//- (BOOL)modifyStepTargetWithID:(NSInteger)ID model:(NSInteger)stepTarget;
//
//- (BOOL)modifySleepTargetWithID:(NSInteger)ID model:(NSInteger)sleepTarget;
//
//- (BOOL)deleteUserInfoData:(NSString *)deleteSql;

#pragma mark - CloseData
- (void)CloseDataBase;

//#pragma mark - SedentaryData
//- (BOOL)insertSedentaryData:(SedentaryModel *)model;
//
//- (BOOL)modifySedentaryData:(SedentaryModel *)model;
//
//- (NSArray *)querySedentary;
//
//- (BOOL)deleteSendentaryData:(SedentaryModel *)model;

@end
