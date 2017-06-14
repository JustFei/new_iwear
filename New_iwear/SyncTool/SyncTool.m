//
//  SyncTool.m
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SyncTool.h"
#import "FMDBManager.h"
#import "SedentaryReminderModel.h"
#import "SedentaryModel.h"
#import "InterfaceSelectionModel.h"
#import "UnitsSettingModel.h"
#import "TargetSettingModel.h"

@interface SyncTool ()
{
    /** 同步的数据量 */
    NSInteger _asynCount;
    //判断设置是否在同步中
    BOOL _syncSettingIng;
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
        //注册所有通知
        NSArray *observerArr = @[SET_TIME,
                                 SET_FIRMWARE,
                                 SET_WINDOW,
                                 GET_SEDENTARY_DATA,
                                 LOST_PERIPHERAL_SWITCH,
                                 SET_CLOCK,
                                 SET_UNITS_DATA,
                                 SET_TIME_FORMATTER,
                                 SET_MOTION_TARGET,
                                 SET_USER_INFO];
        for (NSString *keyWord in observerArr) {
            [[NSNotificationCenter defaultCenter]
             addObserver:self selector:@selector(setNotificationObserver:) name:keyWord object:nil];
        }
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
    _asynCount = 0;
    /** 同步时间 */
    [[BleManager shareInstance] writeTimeToPeripheral:[NSDate date]];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步硬件版本号 */
    [[BleManager shareInstance] writeRequestVersion];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步获取电量 */
    [[BleManager shareInstance] writeGetElectricity];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步界面选择 */
    [self writeUserInterface];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步久坐提醒 */
    [self writeSedentReminder];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步防丢提醒 */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]) {
        [[BleManager shareInstance] writePeripheralShakeWhenUnconnectWithOforOff:[[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]];
    }else {
        [[BleManager shareInstance] writePeripheralShakeWhenUnconnectWithOforOff:NO];
    }
    [NSThread sleepForTimeInterval:0.01];
    /** 同步闹钟提醒 */
    [self writeClockReminder];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步亮度调节 */
    [[BleManager shareInstance] writeDimmingToPeripheral:[[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] ? [[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] : 90];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步单位设置 */
    [self writeUnitsSetting];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步时间格式设置 */
    [self writeTimeFormatterSetting];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步计步目标 */
    [self writeStepTargetSetting];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步用户信息设置 */
    [self writeUserInfoSetting];
    [NSThread sleepForTimeInterval:0.01];
    /** 同步电话短信配对提醒（暂时不同步电话和短信的设置） */
    //        [self pairPhoneAndMessage];
}

#pragma mark -同步设置的数据
- (void)pairPhoneAndMessage
{
    //同步提醒设置
    Remind *rem = [[Remind alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING] && [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING]) {
        rem.phone = [[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING];
        rem.message = [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING];
        [[BleManager shareInstance] writePhoneAndMessageRemindToPeripheral:rem];
    }
}

- (void)writeSedentReminder
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            SedentaryReminderModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        SedentaryModel *sedModel = [[SedentaryModel alloc] init];
        //久坐是否开启
        sedModel.sedentaryAlert = ((SedentaryReminderModel *)mutArr[0]).switchIsOpen;
        //勿扰是否开启
        sedModel.unDisturb = ((SedentaryReminderModel *)mutArr[3]).switchIsOpen;
        //开始时间
        sedModel.sedentaryStartTime = ((SedentaryReminderModel *)mutArr[1]).time;
        //结束时间
        sedModel.sedentaryEndTime = ((SedentaryReminderModel *)mutArr[2]).time;
        //勿扰开始时间
        sedModel.disturbStartTime = @"12:00";
        //勿扰结束时间
        sedModel.disturbEndTime = @"14:00";
        //步数设置
        sedModel.stepInterval = 50;
        [[BleManager shareInstance] writeSedentaryAlertWithSedentaryModel:sedModel];
    }else {
        SedentaryModel *sedModel = [[SedentaryModel alloc] init];
        //勿扰是否开启
        sedModel.sedentaryAlert = NO;
        //勿扰是否开启
        sedModel.unDisturb = NO;
        [[BleManager shareInstance] writeSedentaryAlertWithSedentaryModel:sedModel];
    }
}

- (void)writeClockReminder
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CLOCK_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:CLOCK_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            ClockModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        [[BleManager shareInstance] writeClockToPeripheral:ClockDataSetClock withClockArr:[NSMutableArray arrayWithArray:mutArr]];
    }else {
        NSArray *timeArr = @[@"08:00", @"08:30", @"09:00", @"09:30", @"10:00"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int ind = 0; ind < timeArr.count; ind ++) {
            ClockModel *model = [[ClockModel alloc] init];
            model.time = timeArr[ind];
            model.isOpen = NO;
            [mutArr addObject:model];
        }
        
        [[BleManager shareInstance] writeClockToPeripheral:ClockDataSetClock withClockArr:[NSMutableArray arrayWithArray:mutArr]];
    }
}

- (void)writeUserInterface
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:WINDOW_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:WINDOW_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            InterfaceSelectionModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        [[BleManager shareInstance] writeWindowRequset:WindowRequestModeSetWindow withDataArr:mutArr];
    }else {
        NSArray *nameArr = @[@"待机",@"计步",@"运动",@"心率",@"睡眠",@"查找",@"闹钟",@"关于",@"关机"];
        NSArray *imageArr = @[@"selection_standby",@"selection_sport",@"selection_step",@"selection_heartrate",@"selection_sleep",@"selection_find",@"selection_alarmclock",@"selection_about",@"selection_turnoff"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int i = 0; i < nameArr.count; i ++) {
            InterfaceSelectionModel *model = [[InterfaceSelectionModel alloc] init];
            model.functionName = nameArr[i];
            model.functionImageName = imageArr[i];
            
            switch (i) {
                case 0:
                    model.windowID = 80;
                    break;
                case 1:
                    model.windowID = 81;
                    break;
                case 2:
                    model.windowID = 82;
                    break;
                case 3:
                    model.windowID = 83;
                    break;
                case 4:
                    model.windowID = 84;
                    break;
                case 5:
                    model.windowID = 87;
                    break;
                case 6:
                    model.windowID = 89;
                    break;
                case 7:
                    model.windowID = 86;
                    break;
                case 8:
                    model.windowID = 85;
                    break;
                    
                default:
                    break;
            }
            
            
            if (i == 0) {
                model.selectMode = SelectModeUnchoose;
            }else {
                model.selectMode = SelectModeSelected;
            }
            
            [mutArr addObject:model];
        }
        
        [[BleManager shareInstance] writeWindowRequset:WindowRequestModeSetWindow withDataArr:mutArr];
    }
}

- (void)writeUnitsSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UNITS_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:UNITS_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            UnitsSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        UnitsSettingModel *model = ((NSArray*)mutArr.firstObject).firstObject;
        [[BleManager shareInstance] writeUnitToPeripheral:model.isSelect];
    }else {
        [[BleManager shareInstance] writeUnitToPeripheral:NO];
    }
}

- (void)writeTimeFormatterSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            UnitsSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        UnitsSettingModel *model = ((NSArray*)mutArr.firstObject).firstObject;
        
        [[BleManager shareInstance] writeTimeFormatterToPeripheral:model.isSelect];
    }else {
        [[BleManager shareInstance] writeTimeFormatterToPeripheral:NO];
    }
}

- (void)writeStepTargetSetting
{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING];
    TargetSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:arr.firstObject];
    [[BleManager shareInstance] writeMotionTargetToPeripheral:model.target];
}

- (void)writeUserInfoSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING]) {
        NSData *infoData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING];
        UserInfoModel *infoModel = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
        [[BleManager shareInstance] writeUserInfoToPeripheralWeight:[NSString stringWithFormat:@"%ld",(long)infoModel.weight] andHeight:[NSString stringWithFormat:@"%ld", infoModel.height]];
    }else {
        [[BleManager shareInstance] writeUserInfoToPeripheralWeight:@"60" andHeight:@"170"];
    }
}

//- (void)synchronizeSettings
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        /** 同步时间 */
//        [[BleManager shareInstance] writeTimeToPeripheral:[NSDate date]];
//        /** 同步硬件版本号 */
//        [[BleManager shareInstance] writeRequestVersion];
//        /** 同步获取电量 */
//        [[BleManager shareInstance] writeGetElectricity];
//        /** 同步界面选择 */
//        [self writeUserInterface];
//        /** 同步久坐提醒 */
//        [self writeSedentReminder];
//        /** 同步防丢提醒 */
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]) {
//            [[BleManager shareInstance] writePeripheralShakeWhenUnconnectWithOforOff:[[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]];
//        }else {
//            [[BleManager shareInstance] writePeripheralShakeWhenUnconnectWithOforOff:NO];
//        }
//        
//        /** 同步闹钟提醒 */
//        [self writeClockReminder];
//        /** 同步亮度调节 */
//        [[BleManager shareInstance] writeDimmingToPeripheral:[[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] ? [[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] : 90];
//        /** 同步单位设置 */
//        [self writeUnitsSetting];
//        /** 同步时间格式设置 */
//        [self writeTimeFormatterSetting];
//        /** 同步计步目标 */
//        [self writeStepTargetSetting];
//        /** 同步用户信息设置 */
//        [self writeUserInfoSetting];
//        /** 同步电话短信配对提醒（暂时不同步电话和短信的设置） */
//        //        [self pairPhoneAndMessage];
//    });
//}

/**
 SET_TIME,
 SET_FIRMWARE,
 SET_WINDOW,
 GET_SEDENTARY_DATA,
 LOST_PERIPHERAL_SWITCH,
 SET_CLOCK,
 SET_UNITS_DATA,
 SET_TIME_FORMATTER,
 SET_MOTION_TARGET,
 SET_USER_INFO;
 */

- (void)setNotificationObserver:(NSNotification *)noti
{
    NSLog(@"asynCount == %ld noti.name == %@",_asynCount ,noti.name);
    
    if ([noti.name isEqualToString:SET_TIME] ||
        [noti.name isEqualToString:SET_WINDOW] ||
        [noti.name isEqualToString:GET_SEDENTARY_DATA] ||
        [noti.name isEqualToString:LOST_PERIPHERAL_SWITCH] ||
        [noti.name isEqualToString:SET_UNITS_DATA] ||
        [noti.name isEqualToString:SET_TIME_FORMATTER] ||
        [noti.name isEqualToString:SET_MOTION_TARGET] ||
        [noti.name isEqualToString:SET_USER_INFO]) {
        BOOL isFirst = noti.userInfo[@"success"];
        if (isFirst == 1)
        {
            _asynCount ++;
        }
        else [self asynFail];
    }else if ([noti.name isEqualToString:SET_FIRMWARE]) {
        // 版本号,电量,亮度
        manridyModel *model = [noti object];
        if (model.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            if (model.receiveDataType == ReturnModelTypeFirwmave) {
                switch (model.firmwareModel.mode) {
                    case FirmwareModeGetVersion:
                        //版本号
                        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.version forKey:HARDWARE_VERSION];
                        break;
                    case FirmwareModeGetElectricity:
                        //电量
                        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.PerElectricity forKey:ELECTRICITY_INFO_SETTING];
                        break;
                        
                    default:
                        break;
                }
            }
            _asynCount ++;
        }else [self asynFail];
    }else if ([noti.name isEqualToString:SET_CLOCK]) {
        manridyModel *model = [noti object];
        if (model.isReciveDataRight == ResponsEcorrectnessDataRgith) _asynCount ++;
        else [self asynFail];
    }
    if (_asynCount == 12) {
        if (self.syncSettingSuccessBlock) {
            self.syncSettingSuccessBlock(YES);
        }
    }
}

- (void)asynFail
{
    if (self.syncSettingSuccessBlock) {
        self.syncSettingSuccessBlock(NO);
    }
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
