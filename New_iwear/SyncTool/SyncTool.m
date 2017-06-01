//
//  SyncTool.m
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SyncTool.h"

@interface SyncTool ()
{
    BOOL _syncDataIng;      //判断数据是否在同步中
    BOOL _syncSettingIng;   //判断设置是否在同步中
}


@end

@implementation SyncTool

#pragma mark - Singleton
static SyncTool *_syncTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMotionCount:) name:GET_MOTION_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSleepCount:) name:GET_SLEEP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHRCount:) name:GET_HR_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBPCount:) name:GET_BP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBOCount:) name:GET_BO_DATA object:nil];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _syncTool = [[self alloc] init];
    });
    
    return _syncTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _syncTool = [super allocWithZone:zone];
    });
    
    return _syncTool;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 数据同步
- (void)syncData
{
    //如果在同步中，直接返回
    if (_syncDataIng) {
        return;
    }
    
    _syncDataIng = YES;
    
    //计步历史条数
    [[BleManager shareInstance] writeMotionRequestToPeripheralWithMotionType:MotionTypeCountOfData];
    //睡眠历史条数
    [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryCount];
    //心率历史条数
    [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryCount];
    //血压历史条数
    [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryCount];
    //血氧历史条数
    [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryCount];
    //计步历史
    [[BleManager shareInstance] writeMotionRequestToPeripheralWithMotionType:MotionTypeDataInPeripheral];
    //睡眠历史
    [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryData];
    //心率历史
    [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
    //血压历史
    [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryData];
    //血氧历史
    [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryData];
}

- (void)getMotionCount:(NSNotification *)noti
{
    
}

- (void)getSleepCount:(NSNotification *)noti
{
    
}

- (void)getHRCount:(NSNotification *)noti
{
    
}

- (void)getBPCount:(NSNotification *)noti
{
    
}

- (void)getBOCount:(NSNotification *)noti
{
    
}


#pragma mark - 设置同步
- (void)syncSetting
{
    
}

@end
