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
@property (nonatomic, assign) NSInteger sumCount;

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
    //初始化计数器
    self.sumCount = 0;
    
    //计步历史条数
    [[BleManager shareInstance] writeMotionRequestToPeripheralWithMotionType:MotionTypeCountOfData];
    
    
    
    
    //计步历史
//    [[BleManager shareInstance] writeMotionRequestToPeripheralWithMotionType:MotionTypeDataInPeripheral];
//    //睡眠历史
//    [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryData];
//    //心率历史
//    [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
//    //血压历史
//    [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryData];
//    //血氧历史
//    [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryData];
}

- (void)getMotionCount:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.sportModel.motionType == MotionTypeCountOfData) {
        self.sumCount = self.sumCount + model.sportModel.sumDataCount;
        DLog(@"sumCount == %ld", self.sumCount);
        //睡眠历史条数
        [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryCount];
    }
}

- (void)getSleepCount:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.sleepModel.sleepState == SleepDataHistoryCount) {
        self.sumCount = self.sumCount + model.sleepModel.sumDataCount;
        DLog(@"sumCount == %ld", self.sumCount);
        //心率历史条数
        [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryCount];
    }
}

- (void)getHRCount:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.heartRateModel.heartRateState == HeartRateDataHistoryCount) {
        self.sumCount = self.sumCount + model.heartRateModel.sumDataCount.integerValue;
        DLog(@"sumCount == %ld", self.sumCount);
        //血压历史条数
        [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryCount];
    }
}

- (void)getBPCount:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodModel.bloodState == BloodDataHistoryCount) {
        self.sumCount = self.sumCount + model.bloodModel.sumCount.integerValue;
        DLog(@"sumCount == %ld", self.sumCount);
        //血氧历史条数
        [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryCount];
    }
}

- (void)getBOCount:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodO2Model.bloodO2State == BloodO2DataHistoryCount) {
        self.sumCount = self.sumCount + model.bloodO2Model.sumCount.integerValue;
        DLog(@"sumCount == %ld", self.sumCount);
    }
}


#pragma mark - 设置同步
- (void)syncSetting
{
    
}

@end
