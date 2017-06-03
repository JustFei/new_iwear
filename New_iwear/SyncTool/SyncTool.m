//
//  SyncTool.m
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SyncTool.h"
#import "FMDBManager.h"

@interface SyncTool ()
{
    
    BOOL _syncSettingIng;   //判断设置是否在同步中
    //用来判断每个数据是否有数据
    BOOL _haveMotion;
    BOOL _haveSleep;
    BOOL _haveHR;
    BOOL _haveBP;
    BOOL _haveBO;
}

@property (nonatomic, assign) NSInteger sumCount;
@property (nonatomic, assign) NSInteger progressCount;
/** 控制同步发送消息的信号量 */
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t sendMessageQueue;
@property (nonatomic, strong) FMDBManager *myFmdbManager;

@end

@implementation SyncTool

#pragma mark - Singleton
static SyncTool *_syncTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSegmentStep:) name:GET_SEGEMENT_STEP object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSleep:) name:GET_SLEEP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHR:) name:GET_HR_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBP:) name:GET_BP_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBO:) name:GET_BO_DATA object:nil];
        // 信号量初始化为1
        self.semaphore = dispatch_semaphore_create(1);
        self.sendMessageQueue = dispatch_get_global_queue(0, 0);
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
    if (self.syncDataIng) {
        DLog(@"正在同步中。。。");
        return;
    }
    
    self.syncDataIng = YES;
    //初始化计数器
    self.sumCount = 0;
    
    //同步时间
    [[BleManager shareInstance] writeTimeToPeripheral:[NSDate date]];
    //当前计步数据
    [[BleManager shareInstance] writeMotionRequestToPeripheralWithMotionType:MotionTypeStepAndkCal];
    [self writeHistoryData];
}

- (void)writeHistoryData
{
    //后台线程
    dispatch_async(self.sendMessageQueue, ^{
        __block long x = 0;
        
        
        //分段计步历史条数
        [[BleManager shareInstance] writeSegementStepWithHistoryMode:SegmentedStepDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        DLog(@"1 ------ %ld", x);
        
        //睡眠历史条数
        [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        DLog(@"1 ------ %ld", x);
        
        //心率历史条数
        [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        DLog(@"1 ------ %ld", x);
        
        //血压历史条数
        [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        DLog(@"1 ------ %ld", x);
        
        //血氧历史条数
        [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        DLog(@"1 ------ %ld", x);
        
        //如果都没有数据的话，就直接模拟同步成功的进度条
        if (!_haveMotion && !_haveSleep && !_haveHR && !_haveBP && !_haveBO) {
            if (self.syncDataCurrentCountBlock) {
                for (int i = 0; i <= 100; i ++) {
                    self.syncDataCurrentCountBlock(i);
                    [NSThread sleepForTimeInterval:0.05];
                }
            }
            return ;
        }
        
        //分段计步历史
        if (_haveMotion)
        {
            [[BleManager shareInstance] writeSegementStepWithHistoryMode:SegmentedStepDataHistoryData];
            // wait操作-1，当别的消息进来就会阻塞，知道这条消息收到回调，signal+1后，才会继续执行。保证了消息的队列发送，保证稳定性。
            
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            DLog(@"1 ------ %ld", x);
        }
        //睡眠历史
        if (_haveSleep) {
            [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            DLog(@"1 ------ %ld", x);
        }
        //心率历史
        if (_haveHR) {
            [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            DLog(@"1 ------ %ld", x);
        }
        //血压历史
        if (_haveBP) {
            [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            DLog(@"1 ------ %ld", x);
        }
        //血氧历史
        if (_haveBO) [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryData];
    });
}

#pragma mark -DataNoti处理
/** 分段计步数据 */
- (void)getSegmentStep:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.segmentStepModel.segmentedStepState == SegmentedStepDataHistoryCount) {
        self.sumCount = self.sumCount + model.segmentStepModel.AHCount;
        _haveMotion = model.segmentStepModel.AHCount != 0;
        DLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.segmentStepModel.segmentedStepState == SegmentedStepDataHistoryData) {
        //当数据接受完毕，发送睡眠
        if (model.segmentStepModel.AHCount == model.segmentStepModel.CHCount + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        DLog(@"progress == %.2f", progress);
        if (self.syncDataCurrentCountBlock) {
            self.syncDataCurrentCountBlock(progress * 100);
        }
        //插入数据库
        [self.myFmdbManager insertSegmentStepModel:model.segmentStepModel];
    }
}

/** 睡眠数据 */
- (void)getSleep:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.sleepModel.sleepState == SleepDataHistoryCount) {
        self.sumCount = self.sumCount + model.sleepModel.sumDataCount;
        _haveSleep = model.sleepModel.sumDataCount != 0;
        DLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.sleepModel.sleepState == SleepDataHistoryData) {
        //当数据接受完毕，发送心率
        if (model.sleepModel.sumDataCount == model.sleepModel.currentDataCount + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        DLog(@"progress == %.2f", progress);
        if (self.syncDataCurrentCountBlock) {
            self.syncDataCurrentCountBlock(progress * 100);
        }
        
        //插入数据库
        [self.myFmdbManager insertSleepModel:model.sleepModel];
    }
}

/** 心率数据 */
- (void)getHR:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.heartRateModel.heartRateState == HeartRateDataHistoryCount) {
        self.sumCount = self.sumCount + model.heartRateModel.sumDataCount.integerValue;
        _haveHR = model.heartRateModel.sumDataCount.integerValue != 0;
        DLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.heartRateModel.heartRateState == HeartRateDataHistoryData) {
        //当数据接受完毕，发送血压
        if (model.heartRateModel.sumDataCount.integerValue == model.heartRateModel.currentDataCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        DLog(@"progress == %.2f", progress);
        if (self.syncDataCurrentCountBlock) {
            self.syncDataCurrentCountBlock(progress * 100);
        }
        
        //插入数据库
        [self.myFmdbManager insertHeartRateModel:model.heartRateModel];
    }
}

/** 血压数据 */
- (void)getBP:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodModel.bloodState == BloodDataHistoryCount) {
        self.sumCount = self.sumCount + model.bloodModel.sumCount.integerValue;
        _haveBP = model.bloodModel.sumCount.integerValue != 0;
        DLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.bloodModel.bloodState == BloodDataHistoryData) {
        //当数据接受完毕，发送血氧
        if (model.bloodModel.sumCount.integerValue == model.bloodModel.currentCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        DLog(@"progress == %.2f", progress);
        if (self.syncDataCurrentCountBlock) {
            self.syncDataCurrentCountBlock(progress * 100);
        }
        
        //插入数据库
        [self.myFmdbManager insertBloodModel:model.bloodModel];
    }
}

/** 血氧数据 */
- (void)getBO:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodO2Model.bloodO2State == BloodO2DataHistoryCount) {
        self.progressCount = self.sumCount = self.sumCount + model.bloodO2Model.sumCount.integerValue;
        _haveBO = model.bloodO2Model.sumCount.integerValue != 0;
        DLog(@"sumCount == %ld", self.sumCount);
        if (self.sumCount == 0) {
            self.syncDataIng = NO;
        }
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.bloodO2Model.bloodO2State == BloodO2DataHistoryData) {
        //当数据接受完毕，发送血氧
        if (model.bloodModel.sumCount.integerValue == model.bloodModel.currentCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
            self.syncDataIng = NO;
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        DLog(@"progress == %.2f", progress);
        if (self.syncDataCurrentCountBlock) {
            self.syncDataCurrentCountBlock(progress * 100);
        }
        
        //插入数据库
        [self.myFmdbManager insertBloodO2Model:model.bloodO2Model];
    }
}

#pragma mark - 设置同步
- (void)syncSetting
{
    
}

#pragma mark - lazy
- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbManager;
}



@end
