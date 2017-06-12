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
    BOOL _haveSegStep;
    BOOL _haveSegRun;
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
@property (nonatomic, strong) MDSnackbar *stateBar;

@end

@implementation SyncTool

#pragma mark - Singleton
static SyncTool *_syncTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSegmentStep:) name:GET_SEGEMENT_STEP object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSegmentRun:) name:GET_SEGEMENT_RUN object:nil];
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
- (void)syncAllData
{
    //如果在同步中，直接返回
    if (self.syncDataIng) {
        NSLog(@"正在同步中。。。");
        return;
    }
    if (![SyncTool shareInstance].syncDataIng && [BleManager shareInstance].connectState == kBLEstateDidConnected) {
        [self syncData];
        [self.stateBar setText:@"正在同步数据"];
        [self.stateBar show];
    }
}

- (void)syncData
{
    self.syncDataIng = YES;
    NSLog(@"syncDataIng == %d", self.syncDataIng);
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
        NSLog(@"1 ------ %ld", x);
        
        //分段运动历史条数
        [[BleManager shareInstance] writeSegementRunWithHistoryMode:SegmentedRunDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 ------ %ld", x);
        
        //睡眠历史条数
        [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 ------ %ld", x);
        
        //心率历史条数
        [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 ------ %ld", x);
        
        //血压历史条数
        [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 ------ %ld", x);
        
        //血氧历史条数
        [[BleManager shareInstance] writeBloodO2ToPeripheral:BloodO2DataHistoryCount];
        x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"1 ------ %ld", x);
        
        //如果都没有数据的话，就直接模拟同步成功的进度条
        if (!_haveSegStep && !_haveSleep && !_haveHR && !_haveBP && !_haveBO && !_haveSegRun) {
            for (int i = 0; i <= 100; i ++) {
                [self updateProgress:i];
                [NSThread sleepForTimeInterval:0.01];
            }
            return ;
        }
        
        //分段计步历史
        if (_haveSegStep)
        {
            [[BleManager shareInstance] writeSegementStepWithHistoryMode:SegmentedStepDataHistoryData];
            // wait操作-1，当别的消息进来就会阻塞，知道这条消息收到回调，signal+1后，才会继续执行。保证了消息的队列发送，保证稳定性。
            
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"1 ------ %ld", x);
        }
        //分段运动历史
        if (_haveSegRun)
        {
            [[BleManager shareInstance] writeSegementRunWithHistoryMode:SegmentedRunDataHistoryData];
            // wait操作-1，当别的消息进来就会阻塞，知道这条消息收到回调，signal+1后，才会继续执行。保证了消息的队列发送，保证稳定性。
            
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"1 ------ %ld", x);
        }
        
        //睡眠历史
        if (_haveSleep) {
            [[BleManager shareInstance] writeSleepRequestToperipheral:SleepDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"1 ------ %ld", x);
        }
        //心率历史
        if (_haveHR) {
            [[BleManager shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"1 ------ %ld", x);
        }
        //血压历史
        if (_haveBP) {
            [[BleManager shareInstance] writeBloodToPeripheral:BloodDataHistoryData];
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"1 ------ %ld", x);
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
    if (model.segmentStepModel.segmentedStepState == SegmentedStepDataUpdateData) {
        //当有数据上报时，获取新数据
        if (!_syncDataIng) {
            [self syncAllData];
        }
    }else if (model.segmentStepModel.segmentedStepState == SegmentedStepDataHistoryCount) {
        self.sumCount = self.sumCount + model.segmentStepModel.AHCount;
        _haveSegStep = model.segmentStepModel.AHCount != 0;
        NSLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.segmentStepModel.segmentedStepState == SegmentedStepDataHistoryData) {
        if (model.segmentStepModel.AHCount == 0) {
            return;
        }
        //当数据接受完毕，发送睡眠
        if (model.segmentStepModel.AHCount == model.segmentStepModel.CHCount + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        //插入数据库
        [self.myFmdbManager insertSegmentStepModel:model.segmentStepModel];
    }
}

/** 分段运动数据 */
- (void)getSegmentRun:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.segmentRunModel.segmentedRunState == SegmentedRunDataUpdateData) {
        //当有数据上报时，获取新数据
        if (!_syncDataIng) {
            [self syncAllData];
        }
    }else if (model.segmentRunModel.segmentedRunState == SegmentedRunDataHistoryCount) {
        self.sumCount = self.sumCount + model.segmentRunModel.AHCount;
        _haveSegRun = model.segmentRunModel.AHCount != 0;
        NSLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.segmentRunModel.segmentedRunState == SegmentedRunDataHistoryData) {
        if (model.segmentRunModel.AHCount == 0) {
            return;
        }
        //当数据接受完毕，发送睡眠
        if (model.segmentRunModel.AHCount == model.segmentRunModel.CHCount + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        //插入数据库
        [self.myFmdbManager insertSegmentRunModel:model.segmentRunModel];
    }
}

/** 睡眠数据 */
- (void)getSleep:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.sleepModel.sleepState == SleepDataHistoryCount) {
        self.sumCount = self.sumCount + model.sleepModel.sumDataCount;
        _haveSleep = model.sleepModel.sumDataCount != 0;
        NSLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.sleepModel.sleepState == SleepDataHistoryData) {
        if (model.sleepModel.sumDataCount == 0) {
            return;
        }
        //当数据接受完毕，发送心率
        if (model.sleepModel.sumDataCount == model.sleepModel.currentDataCount + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        
        //插入数据库
        [self.myFmdbManager insertSleepModel:model.sleepModel];
    }
}

/** 心率数据 */
- (void)getHR:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.heartRateModel.heartRateState == HeartRateDataUpload) {
        //收到上报数据时，同步数据
//        if (!_syncDataIng) {
//            [self syncData];
//        }
    }else if (model.heartRateModel.heartRateState == HeartRateDataHistoryCount) {
        self.sumCount = self.sumCount + model.heartRateModel.sumDataCount.integerValue;
        _haveHR = model.heartRateModel.sumDataCount.integerValue != 0;
        NSLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.heartRateModel.heartRateState == HeartRateDataHistoryData) {
        if (model.heartRateModel.sumDataCount.integerValue == 0) {
            return;
        }
        //当数据接受完毕，发送血压
        if (model.heartRateModel.sumDataCount.integerValue == model.heartRateModel.currentDataCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        
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
        NSLog(@"sum == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.bloodModel.bloodState == BloodDataHistoryData) {
        if (model.bloodModel.sumCount.integerValue == 0) {
            return;
        }
        //当数据接受完毕，发送血氧
        if (model.bloodModel.sumCount.integerValue == model.bloodModel.currentCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        
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
        NSLog(@"sumCount == %ld", self.sumCount);
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
    }else if (model.bloodO2Model.bloodO2State == BloodO2DataHistoryData) {
        if (model.bloodO2Model.sumCount.integerValue == 0) {
            return;
        }
        //当数据接受完毕，发送血氧
        NSLog(@"boSum == %ld;boCur + 1 == %ld",model.bloodO2Model.sumCount.integerValue, model.bloodO2Model.currentCount.integerValue + 1);
        if (model.bloodO2Model.sumCount.integerValue == model.bloodO2Model.currentCount.integerValue + 1) {
            // signal操作+1
            dispatch_semaphore_signal(self.semaphore);
        }
        
        //传递进度值
        self.progressCount --;
        float progress = (self.sumCount - self.progressCount) / (float)self.sumCount;
        NSLog(@"progress == %.2f", progress);
        [self updateProgress:(progress *100)];
        
        //插入数据库
        [self.myFmdbManager insertBloodO2Model:model.bloodO2Model];
    }
}

#pragma mark - 设置同步
- (void)syncSetting
{
    
}

#pragma mark - Action
/** 取消通知栏 */
- (void)cancelStateBarAction:(MDButton *)sender
{
    if (self.stateBar.isShowing) {
        [self.stateBar dismiss];
    }
}

- (void)updateProgress:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stateBar setText:[NSString stringWithFormat:@"正在同步数据 %.0f%%", progress]];
        if (progress >= 100) {
            self.syncDataIng = NO;
            NSLog(@"syncDataIngEnd == %d", self.syncDataIng);
            self.stateBar.text = @"同步完成";
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_ALL_UI object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.stateBar dismiss];
            });
        }
    });
}

#pragma mark - lazy
- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:DB_NAME];
    }
    
    return _myFmdbManager;
}

- (MDSnackbar *)stateBar
{
    if (!_stateBar) {
        _stateBar = [[MDSnackbar alloc] init];
        [_stateBar setActionTitleColor:NAVIGATION_BAR_COLOR];
        
        //这里1000000秒是让bar长驻在底部
        [_stateBar setDuration:1000000];
        _stateBar.multiline = YES;
        
        MDButton *cancelButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
        [cancelButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelStateBarAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = RED_COLOR;
        [_stateBar addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_stateBar.mas_left).offset(16);
            //        make.top.equalTo(self.stateBar.mas_top).offset(10);
            make.centerY.equalTo(_stateBar.mas_centerY);
        }];
    }
    
    return _stateBar;
}

@end
