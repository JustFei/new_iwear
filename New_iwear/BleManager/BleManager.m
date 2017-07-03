//
//  BleManager.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "BleManager.h"
#import "BleDevice.h"
#import "manridyModel.h"
#import "NSStringTool.h"
#import "AnalysisProcotolTool.h"
#import "AppDelegate.h"
#import "ClockModel.h"
#import <UserNotifications/UserNotifications.h>
#import "InterfaceSelectionModel.h"
#import "SedentaryReminderModel.h"

#define kServiceUUID              @"F000EFE0-0000-4000-0000-00000000B000"
#define kWriteCharacteristicUUID  @"F000EFE1-0451-4000-0000-00000000B000"
#define kNotifyCharacteristicUUID @"F000EFE3-0451-4000-0000-00000000B000"

@interface BleManager () <UNUserNotificationCenterDelegate>

@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) NSMutableArray *deviceArr;
//@property (nonatomic, strong) AllBleFmdb *fmTool;
//@property (nonatomic, strong) UIAlertView *disConnectView;
@property (nonatomic, strong) UNMutableNotificationContent *notiContent;
/** 控制同步发送消息的信号量 */
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t sendMessageQueue;
@property (nonatomic, strong) NSTimer *resendTimer;
@property (nonatomic, assign) BOOL haveResendMessage;

@end

@implementation BleManager


#pragma mark - Singleton
static BleManager *bleManager = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
//        _fmTool = [[AllBleFmdb alloc] init];
        self.notiContent = [[UNMutableNotificationContent alloc] init];
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
        bleManager = [[self alloc] init];
    });
    
    return bleManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleManager = [super allocWithZone:zone];
    });
    
    return bleManager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - action of connecting layer -连接层操作
/** 判断有没有当前设备有没有连接的 */
- (BOOL)retrievePeripherals
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"]) {
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        NSArray *arr = [_myCentralManager retrievePeripheralsWithIdentifiers: @[uuid]];
        NSLog(@"当前已连接的设备%@,有%ld个",arr.firstObject ,(unsigned long)arr.count);
        if (arr.count != 0) {
            CBPeripheral *per = (CBPeripheral *)arr.firstObject;
            per.delegate = self;
            BleDevice *device = [[BleDevice alloc] initWith:per andAdvertisementData:nil andRSSI:nil];
            
            [self connectDevice:device];
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

/** 扫描设备 */
- (void)scanDevice
{
    [self.deviceArr removeAllObjects];
    self.connectState = kBLEstateDisConnected;
    [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

/** 停止扫描 */
- (void)stopScan
{
    [_myCentralManager stopScan];
}

/** 连接设备 */
- (void)connectDevice:(BleDevice *)device
{
    if (!device) {
        return;
    }
    self.isReconnect = YES;
    self.currentDev = device;
    [_myCentralManager connectPeripheral:device.peripheral options:nil];
}

/** 断开设备连接 */
- (void)unConnectDevice
{
    if (self.currentDev.peripheral) {
        [self.myCentralManager cancelPeripheralConnection:self.currentDev.peripheral];
    }
}

/** 检索已连接的外接设备 */
- (NSArray *)retrieveConnectedPeripherals
{
    return [_myCentralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}

#pragma mark - data of write -写入数据操作
#pragma mark - 统一做消息队列处理，发送
- (void)addMessageToQueue:(NSData *)message
{
    //1.写入数据
    dispatch_async(self.sendMessageQueue, ^{
        if (self.currentDev.peripheral && self.writeCharacteristic) {
            // wait操作-1，当别的消息进来就会阻塞，知道这条消息收到回调，signal+1后，才会继续执行。保证了消息的队列发送，保证稳定性。
            __block long x = 0;
            x = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"---%@---", message);
            [self.currentDev.peripheral writeValue:message forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    });
}

//set time
- (void)writeTimeToPeripheral:(NSDate *)currentDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSString *currentStr = [NSString stringWithFormat:@"%02ld%02ld%02ld%02ld%02ld%02ld%02ld",[comps year] % 100 ,[comps month] ,[comps day] ,[comps hour] ,[comps minute] ,[comps second] ,[comps weekday] - 1];
    //    NSLog(@"-----------weekday is %ld",(long)[comps weekday]);//在这里需要注意的是：星期日是数字1，星期一时数字2，以此类推。。。
    
    //传入时间和头，返回协议字符串
    NSString *protocolStr = [NSStringTool protocolAddInfo:currentStr head:@"00"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步时间");
}

//set clock
- (void)writeClockToPeripheral:(ClockData)state withClockArr:(NSMutableArray *)clockArr
{
    if (state == ClockDataSetClock) {
        
        NSString *clockStateStr = [[NSString alloc] init];
        NSString *clockDataStr = [[NSString alloc] init];
        
        for (int index = 0; index < 5; index ++) {
            
            if (index < clockArr.count) {
                ClockModel *clockModel = clockArr[index];
                NSString *state;
                if (clockModel.isOpen) {
                    state = @"01";
                }else {
                    state = @"02";
                }
                
                NSString *clock = [clockModel.time stringByReplacingOccurrencesOfString:@":" withString:@""];
                
                clockStateStr = [clockStateStr stringByAppendingString:state];
                clockDataStr = [clockDataStr stringByAppendingString:clock];
            }else {
                clockStateStr = [clockStateStr stringByAppendingString:@"00"];
                clockDataStr = [clockDataStr stringByAppendingString:@"0000"];
            }
        }
        
        clockStateStr = [clockStateStr stringByAppendingString:clockDataStr];
        
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSString stringWithFormat:@"FC0100%@",clockStateStr];
        
        //写入操作
        [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
        NSLog(@"同步闹钟");
    }else {
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"01"];
        
        //写入操作
        [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
        NSLog(@"获取闹钟数据成功");
    }
}

//get motionInfo
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:[NSString stringWithFormat:@"%ld",(unsigned long)type] head:@"03"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"请求计步数据");
}

//set motionInfo zero
- (void)writeMotionZeroToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"04"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"清空计步数据");
}
//get GPS data
- (void)writeGPSToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"05"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"gps 请求成功");
}

//set userInfo
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height
{
    NSString *protocolStr = [weight stringByAppendingString:[NSString stringWithFormat:@",%@",height]];
    
    protocolStr = [NSStringTool protocolAddInfo:protocolStr head:@"06"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步用户信息");
}

//set motion target
- (void)writeMotionTargetToPeripheral:(NSString *)target
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:target head:@"07"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步计步目标");
}

//set heart rate test state
- (void)writeHeartRateTestStateToPeripheral:(HeartRateTestState)state
{
    NSString *protocolStr;
    switch (state) {
        case HeartRateTestStateStop:
            protocolStr = [NSStringTool protocolAddInfo:@"00" head:@"09"];
            break;
        case HeartRateTestStateStart:
            protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"09"];
            break;
        case HeartRateDataStateSingle:
            protocolStr = [NSStringTool protocolAddInfo:@"02" head:@"09"];
            break;
            
        default:
            break;
    }
//    protocolStr = state == HeartRateTestStateStop ?  : [NSStringTool protocolAddInfo:@"01" head:@"09"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get heart rate data
- (void)writeHeartRateRequestToPeripheral:(HeartRateData)heartRateData
{
    NSString *protocolStr;
    switch (heartRateData) {
        case HeartRateDataLastData:
            protocolStr = [NSStringTool protocolAddInfo:@"00" head:@"0A"];
            break;
        case HeartRateDataHistoryData:
            protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"0A"];
            break;
        case HeartRateDataHistoryCount:
            protocolStr = [NSStringTool protocolAddInfo:@"02" head:@"0A"];
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get sleepInfo
- (void)writeSleepRequestToperipheral:(SleepData)sleepData
{
    NSString *protocolStr;
    switch (sleepData) {
        case SleepDataLastData:
            protocolStr = [NSStringTool protocolAddInfo:@"00" head:@"0C"];
            break;
        case SleepDataHistoryData:
            protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"0C"];
            break;
        case SleepDataHistoryCount:
            protocolStr = [NSStringTool protocolAddInfo:@"02" head:@"0C"];
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//phone and message remind
- (void)writePhoneAndMessageRemindToPeripheral:(Remind *)remindModel
{
    NSString *protocolStr;
    protocolStr = [NSStringTool protocolForRemind:remindModel];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"设置同步电话短信");
}

//search my peripheral
- (void)writeSearchPeripheralWithONorOFF:(BOOL)state
{
    NSString *protocolStr;
    protocolStr = state ? @"FC100003" : @"FC100000";

    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//设备断开后震动提醒
- (void)writePeripheralShakeWhenUnconnectWithOforOff:(BOOL)state
{
    NSString *protocolStr;
    protocolStr = state ? @"FC100201" : @"FC100200";
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步防丢");
}

//翻腕亮屏设置
- (void)writeWristFunWithOff:(BOOL)state
{
    NSString *protocolStr;
    protocolStr = state ? @"FC1501" : @"FC1500";
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"翻腕亮屏设置");
}

//stop peripheral
- (void)writeStopPeripheralRemind
{
    NSString *protocolStr = @"1001";
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get blood data
- (void)writeBloodToPeripheral:(BloodData)bloodData
{
    NSString *protocolStr;
    switch (bloodData) {
        case BloodDataLastData:
            protocolStr = [NSStringTool protocolAddInfo:@"00" head:@"11"];
            break;
        case BloodDataHistoryData:
            protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"11"];
            break;
        case BloodDataHistoryCount:
            protocolStr = [NSStringTool protocolAddInfo:@"02" head:@"11"];
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get blood O2 data
- (void)writeBloodO2ToPeripheral:(BloodO2Data)bloodO2Data
{
    NSString *protocolStr;
    switch (bloodO2Data) {
        case BloodO2DataLastData:
            protocolStr = [NSStringTool protocolAddInfo:@"00" head:@"12"];
            break;
        case BloodO2DataHistoryData:
            protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"12"];
            break;
        case BloodO2DataHistoryCount:
            protocolStr = [NSStringTool protocolAddInfo:@"02" head:@"12"];
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** get version from peripheral */
- (void)writeRequestVersion
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:@"" head:@"0f"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步版本号");
}

/** 设置设备亮度 */
- (void)writeDimmingToPeripheral:(float)value
{
    NSString *dim = [NSStringTool ToHex:value];
    if (dim.length < 2) {
        dim = [NSString stringWithFormat:@"0%@", dim];
    }
    NSString *protocolStr = [NSString stringWithFormat:@"fc0f04%@", dim];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步亮度");
}

/** 获取电量 */
- (void)writeGetElectricity
{
    NSString *protocolStr = @"fc0f06";
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步电量");
}

//set sedentary alert
- (void)writeSedentaryAlertWithSedentaryModel:(SedentaryModel *)sedentaryModel
{
    NSString *ss;
    NSString *T2T1 = @"0000";
    NSString *SHSM = @"0000";   //免打扰时段开始时间
    NSString *EHEM = @"0000";   //免打扰时段结束时间
    NSString *IHIM = @"0000";   //设定开始提醒时间
    NSString *IhIm = @"0000";   //设定提醒结束时间
    
    if (!sedentaryModel.sedentaryAlert) {
        if (!sedentaryModel.unDisturb) {
            ss = @"00";     //久坐和勿扰都没开启
        }else {
            ss = @"02";     //久坐关闭，勿扰开启
        }
    }else {
#warning change T2T1 time
        //001e
        //T2T1 = @"001e" ;    //30分钟提醒间隔
        T2T1 = @"003c" ;    //60分钟提醒间隔
        IHIM = [sedentaryModel.sedentaryStartTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        IhIm = [sedentaryModel.sedentaryEndTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        SHSM = [sedentaryModel.disturbStartTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        EHEM = [sedentaryModel.disturbEndTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        if (!sedentaryModel.unDisturb) {
            ss = @"01";     //久坐开启，勿扰关闭 SS BIT[0]=1
        }else {
            ss = @"03";     //久坐和勿扰都开启  SS BIT[0]=1 ;SS BIT[1]=1
        }
    }
    NSString *stepInterval = [NSStringTool ToHex:sedentaryModel.stepInterval];
    if (stepInterval.length < 4) {
        while (1) {
            stepInterval = [@"0" stringByAppendingString:stepInterval];
            if (stepInterval.length >= 4) {
                break;
            }
        }
    }
    NSString *info = [[[[[[ss stringByAppendingString:T2T1] stringByAppendingString:SHSM] stringByAppendingString:EHEM] stringByAppendingString:IHIM] stringByAppendingString:IhIm] stringByAppendingString:stepInterval];
    
    
    NSString *protocolStr = [NSStringTool protocolAddInfo:info head:@"16"];
    NSLog(@"同步久坐");
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//写入名称
- (void)writePeripheralNameWithNameString:(NSString *)name
{
    NSString *lengthInterval = [NSStringTool ToHex:name.length / 2];
    if (lengthInterval.length < 2) {
        while (1) {
            lengthInterval = [@"0" stringByAppendingString:lengthInterval];
            if (lengthInterval.length >= 2) {
                break;
            }
        }
    }
    NSString *protocolStr = [[@"FC0F07" stringByAppendingString:lengthInterval]stringByAppendingString:name];
    
    while (1) {
        if (protocolStr.length < 40) {
            protocolStr = [protocolStr stringByAppendingString:@"00"];
        }else {
            break;
        }
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/*推送公制和英制单位
 ImperialSystem  YES = 英制
 NO  = 公制
 */
- (void)writeUnitToPeripheral:(BOOL)ImperialSystem
{
    NSString *protocolStr;
    protocolStr = ImperialSystem ? @"FC170001" : @"FC170000";
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步单位");
}

/** 拍照部分 */
- (void)writeCameraMode:(kCameraMode)mode
{
    NSString *protocolStr;
        switch (mode) {
                /** 打开设备的拍照模式 */
            case kCameraModeOpenCamera:
                protocolStr = @"FC1981";
                break;
                /** 完成拍照 */
            case kCameraModePhotoFinish:
                protocolStr = @"FC190080";
                break;
                /** 关闭设备的拍照模式 */
            case kCameraModeCloseCamera:
                protocolStr = @"FC1980";
                break;
                
            default:
                break;
        }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** 分段计步获取 */
- (void)writeSegementStepWithHistoryMode:(SegmentedStepData)mode
{
    NSString *protocolStr;
    switch (mode) {
            /** 具体的历史数据 */
        case SegmentedStepDataHistoryCount:
            protocolStr = @"FC1A02";
            break;
            /** 历史数据条数 */
        case SegmentedStepDataHistoryData:
            protocolStr = @"FC1A04";
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** 分段跑步获取 */
- (void)writeSegementRunWithHistoryMode:(SegmentedRunData)mode
{
    NSString *protocolStr;
    switch (mode) {
        case SegmentedRunDataHistoryData:
            protocolStr = @"FC1B04";
            break;
        case SegmentedRunDataHistoryCount:
            protocolStr = @"FC1B02";
            break;
        case SegmentedRunDataCurrentData:
            protocolStr = @"FC1B08";
            break;
            
        default:
            break;
    }
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** 窗口协议 */
- (void)writeWindowRequset:(WindowRequestMode)mode withDataArr:(NSArray *)dataArr
{
    NSString *protocolStr;
    switch (mode) {
        case WindowRequestModeWindowCount:              //查询窗口数量
            protocolStr = @"FC1C01";
            break;
        case WindowRequestModeSearchWindow:             //查询窗口
            protocolStr = @"FC1C02000000818283848586878889";
            break;
        case WindowRequestModeSetWindow:                //设置窗口
        {
            protocolStr = @"FC1C0201";
            NSString *EHEL = @"";
            NSString *winID = @"";
            for (int index = 1; index <= dataArr.count; index ++) {
                InterfaceSelectionModel *model = dataArr[dataArr.count - index];
                EHEL = [EHEL stringByAppendingString:model.selectMode == SelectModeUnselected ? @"0" : @"1"];
                InterfaceSelectionModel *model1 = dataArr[index - 1];
                winID = [winID stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)model1.windowID]];
            }
            if (EHEL.length % 4 != 0) {
                int count = 4 - EHEL.length % 4;
                for (int i = 0; i < count; i ++) {
                    EHEL = [@"0" stringByAppendingString:EHEL];
                }
            }
            //二进制转换为16进制
            EHEL = [NSStringTool getBinaryByhex:nil binary:EHEL];
            if (EHEL.length == 4) {
                protocolStr = [protocolStr stringByAppendingString:EHEL];
            }else if (EHEL.length > 4) {
                NSLog(@"出错了");
                return;
            }else if (EHEL.length < 4) {
                NSInteger count = 4 - EHEL.length;
                for (int i = 0; i < count; i ++) {
                    EHEL = [@"0" stringByAppendingString:EHEL];
                }
                protocolStr = [protocolStr stringByAppendingString:EHEL];
            }
            protocolStr = [protocolStr stringByAppendingString:winID];
        }
            break;
        case WindowRequestModeWindowRelationship:       //获取窗口关系
            protocolStr = @"FC1C04";
            break;
            
        default:
            break;
    }
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步界面选择");
}

/**
 时间格式设置
 YES = 12 时
 NO = 24 时
 */
- (void)writeTimeFormatterToPeripheral:(BOOL)twelveFormatter
{
    NSString *protocolStr = [NSString stringWithFormat:@"fc1800%@", twelveFormatter ? @"01" : @"00"];
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步时间格式");
}

/** 添加睡眠的测试协议 */
- (void)writeSleepTest
{
    NSString *protocolStr = @"fc0c03";
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"添加睡眠测试数据");
}

#pragma mark - CBCentralManagerDelegate
//检查设备蓝牙开关的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message = nil;
    switch (central.state) {
        case 0:
            self.systemBLEstate = 0;
            break;
        case 1:
            //            message = @"该设备不支持蓝牙功能，请检查系统设置";
            self.systemBLEstate = 1;
            break;
        case 2:
        {
            self.systemBLEstate = 2;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 3:
        {
            self.systemBLEstate = 3;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 4:
        {
            message = NSLocalizedString(@"phoneNotOpenBLE", nil);
            self.systemBLEstate = 4;
            NSLog(@"message == %@",message);
        }
            break;
        case 5:
        {
            self.systemBLEstate = 5;
            message = NSLocalizedString(@"bleHaveOpen", nil);
        }
            break;
            
        default:
            break;
    }
    
    //[_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

//查找到正在广播的指定外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    BleDevice *device = [[BleDevice alloc] initWith:peripheral andAdvertisementData:advertisementData andRSSI:RSSI];
    //当你发现你感兴趣的连接外围设备，停止扫描其他设备，以节省电能。
    if (device.deviceName != nil ) {
        if (![self.deviceArr containsObject:peripheral]) {
            [self.deviceArr addObject:peripheral];
            
            //返回扫描到的设备实例
            if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                
                [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
            }
        }
    }
//    }else {
//        if ([device.uuidString isEqualToString:kServiceUUID]) {
//            device.deviceName = @"X9Plus";
//            if (![self.deviceArr containsObject:peripheral]) {
//                NSLog(@"+1");
//                [self.deviceArr addObject:peripheral];
//                
//                //返回扫描到的设备实例
//                if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
//                    
//                    [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
//                }
//            }
//        }
//    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    peripheral.delegate = self;
    //传入nil会返回所有服务;一般会传入你想要服务的UUID所组成的数组,就会返回指定的服务
    [peripheral discoverServices:nil];
    
    //AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate.mainVc showFunctionView];
    
//    [self.disConnectView dismissWithClickedButtonIndex:0 animated:NO];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //    NSLog(@"连接失败");
    
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidFailConnectDevice:)]) {
        [self.connectDelegate manridyBLEDidFailConnectDevice:self.currentDev];
    }
    
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectState = kBLEstateDisConnected;
    [SyncTool shareInstance].syncDataIng = NO;
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidDisconnectDevice:)]) {
        [self.connectDelegate manridyBLEDidDisconnectDevice:self.currentDev];
    }
    [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    if (self.isReconnect) {
        NSLog(@"需要断线重连");
        [self.myCentralManager connectPeripheral:self.currentDev.peripheral options:nil];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:LOST_SETTING]) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LOST_SETTING];
            SedentaryReminderModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            /**TODO:这里的延迟操作会因为在后台的原因停止执行，目前测试在8秒钟左右可以实现稳定延迟。*/
            if (model.switchIsOpen) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self delayMethod];
                });
            }
        }
    }else {
        self.currentDev = nil;
    }
    
}

- (void)delayMethod
{
    if (self.connectState == kBLEstateDisConnected) {
        // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = NSLocalizedString(@"perDismissNodify", nil);
        // 次标题
        //content.subtitle = NSLocalizedString(@"PerDismissNodifySubtitle", nil);
        // 内容
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSString *dateStr = [formatter stringFromDate:date];
        content.body = [NSString stringWithFormat:NSLocalizedString(@"PerDismissNodifyContent", nil),dateStr];
        // 通知的提示声音，这里用的默认的声音
        content.sound = [UNNotificationSound soundNamed:@"alert.wav"];
        
        // 标识符
        content.categoryIdentifier = @"categoryIndentifier";
        
        // 2、创建通知触发
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        // 3、创建通知请求
        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification" content:content trigger:trigger];
        
        // 4、将请求加入通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"已成功加推送%@",notificationRequest.identifier);
            }
        }];
    }
}

#pragma mark - CBPeripheralDelegate
//发现到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        
        //返回特定的写入，订阅的特征即可
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kWriteCharacteristicUUID],[CBUUID UUIDWithString:kNotifyCharacteristicUUID]] forService:service];
    }
}

//获得某服务的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    //    NSLog(@"Discovered characteristic %@", service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        //保存写入特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
            
            self.writeCharacteristic = characteristic;
        }
        
        //保存订阅特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotifyCharacteristicUUID]]) {
            self.notifyCharacteristic = characteristic;
            self.connectState = kBLEstateDidConnected;
            if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidConnectDevice:)]) {
                if (self.currentDev.peripheral == peripheral) {
                    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:@"peripheralUUID"];
                    [self.connectDelegate manridyBLEDidConnectDevice:self.currentDev];
                }
            }
            
            //订阅该特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    
}

//获得某特征值变化的通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error changing notification state: %@",[error localizedDescription]);
    }else {
        NSLog(@"Success changing notification state: %d;value = %@",characteristic.isNotifying ,characteristic.value);
    }
}

//订阅特征值发送变化的通知，所有获取到的值都将在这里进行处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"updateValue == %@",characteristic.value);
    
    [self analysisDataWithCharacteristic:characteristic.value];
    
}

//写入某特征值后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        //        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }else {
        //        NSLog(@"Success writing chararcteristic value: %@",characteristic);
    }
}

#pragma mark - 数据解析
- (void)analysisDataWithCharacteristic:(NSData *)value
{
    if ([value bytes] != nil) {
        const unsigned char *hexBytes = [value bytes];
        // signal操作+1
        dispatch_semaphore_signal(self.semaphore);
        //命令头字段
        NSString *headStr = [[NSString stringWithFormat:@"%02x", hexBytes[0]] localizedLowercaseString];
        
        if ([headStr isEqualToString:@"00"] || [headStr isEqualToString:@"80"]) {
            //解析设置时间数据
//            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSetTimeData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_TIME object:nil userInfo:@{@"success":[headStr isEqualToString:@"00"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"01"] || [headStr isEqualToString:@"81"]) {
            //解析闹钟数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisClockData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_CLOCK object:model];
        }else if ([headStr isEqualToString:@"03"] || [headStr isEqualToString:@"83"]) {
            //解析获取的步数数据
            manridyModel *model =  [[AnalysisProcotolTool shareInstance] analysisGetSportData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_MOTION_DATA object:model];
        }else if ([headStr isEqualToString:@"04"] || [headStr isEqualToString:@"84"]) {
            //运动清零
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSportZeroData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_MOTION_ZERO object:model];
        }else if ([headStr isEqualToString:@"05"] || [headStr isEqualToString:@"85"]) {
            //获取到历史的GPS数据信息
            //            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHistoryGPSData:value WithHeadStr:headStr];
            //[[NSNotificationCenter defaultCenter] postNotificationName:GET_GPS_DATA object:model];
            
        }else if ([headStr isEqualToString:@"06"] || [headStr isEqualToString:@"86"]) {
            //用户信息推送
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_USER_INFO object:nil userInfo:@{@"success":[headStr isEqualToString:@"06"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"07"] || [headStr isEqualToString:@"87"]) {
            //运动目标推送
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_MOTION_TARGET object:nil userInfo:@{@"success":[headStr isEqualToString:@"07"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"08"] || [headStr isEqualToString:@"88"]) {
            //询问设备是否配对成功
            manridyModel *model = [[AnalysisProcotolTool shareInstance]analysisPairData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_PAIR object:model];
        }else if ([headStr isEqualToString:@"09"] || [headStr isEqualToString:@"89"]) {
            //心率开关
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartStateData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_HR_STATE object:model];
        }else if([headStr isEqualToString:@"0a"] || [headStr isEqualToString:@"8a"]) {
            //获取心率数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_HR_DATA object:model];
        }else if ([headStr isEqualToString:@"0c"] || [headStr isEqualToString:@"8c"]) {
            //获取睡眠
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSleepData:value WithHeadStr: headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SLEEP_DATA object:model];
        }else if ([headStr isEqualToString:@"0d"] || [headStr isEqualToString:@"8d"]) {
            //上报GPS数据

        }else if ([headStr isEqualToString:@"0f"] || [headStr isEqualToString:@"8f"]) {
            //设备维护指令
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisFirmwareData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_FIRMWARE object:model];
        }else if ([headStr isEqualToString:@"10"] || [headStr isEqualToString:@"90"]) {
            //查找设备回调
            NSString *DDStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
//            NSString *SZStr = [NSString stringWithFormat:@"%02x", hexBytes[2]];
            if ([DDStr isEqualToString:@"00"]) {    //设备确认查找到的返回
                [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEARCH_FEEDBACK object:nil userInfo:@{@"success" : @YES}];
            }else if ([DDStr isEqualToString:@"02"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LOST_PERIPHERAL_SWITCH object:nil userInfo:@{@"success": @YES}];
            }
        }else if ([headStr isEqualToString:@"11"] || [headStr isEqualToString:@"91"]) {
            //获取血压
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_BP_DATA object:model];
        }else if ([headStr isEqualToString:@"12"] || [headStr isEqualToString:@"92"]) {
            //获取血氧
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodO2Data:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_BO_DATA object:model];
        }else if ([headStr isEqualToString:@"15"] || [headStr isEqualToString:@"95"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WRIST_SETTING_NOTI object:nil userInfo:@{@"success": @YES}];
        }else if ([headStr isEqualToString:@"16"] || [headStr isEqualToString:@"96"]) {
            //久坐提醒设置是否成功
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEDENTARY_DATA object:nil userInfo:@{@"success":[headStr isEqualToString:@"16"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"17"] || [headStr isEqualToString:@"97"]) {
            //单位设置是否成功
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_UNITS_DATA object:nil userInfo:@{@"success":[headStr isEqualToString:@"17"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"18"] || [headStr isEqualToString:@"98"]) {
            //单位设置是否成功
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_TIME_FORMATTER object:nil userInfo:@{@"success":[headStr isEqualToString:@"18"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"19"] || [headStr isEqualToString:@"99"]) {
            //开始拍照
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_TAKE_PHOTO object:model];
        }else if ([headStr isEqualToString:@"1a"] || [headStr isEqualToString:@"9a"]) {
            //分段计步数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSegmentedStep:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEGEMENT_STEP object:model];
        }else if ([headStr isEqualToString:@"1b"] || [headStr isEqualToString:@"9b"]) {
            //分段跑步数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSegmentedRun:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEGEMENT_RUN object:model];
        }else if ([headStr isEqualToString:@"1c"] || [headStr isEqualToString:@"9c"]) {
            //设置窗口成功
            NSString *ENStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
            NSString *SZStr = [NSString stringWithFormat:@"%02x", hexBytes[2]];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_WINDOW object:nil userInfo:@{@"success":[ENStr isEqualToString:@"02"] && [SZStr isEqualToString:@"01"]? @YES : @NO}];
        }else if ([headStr isEqualToString:@"fc"]) {
            NSString *secondStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
            NSString *TTStr = [NSString stringWithFormat:@"%02x", hexBytes[3]];
            if ([secondStr isEqualToString:@"09"]) {
                //心率开关
                manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartStateData:value WithHeadStr:headStr];
                [[NSNotificationCenter defaultCenter] postNotificationName:SET_HR_STATE object:model];
            }else if ([secondStr isEqualToString:@"10"]) {
                //设备查找手机，需要全局监听。有 yes 和 no 两种状态
//                if () {
                [[NSNotificationCenter defaultCenter] postNotification:[[NSNotification alloc] initWithName:SET_FIND_PHONE object:nil userInfo:@{@"success":[TTStr isEqualToString:@"00"] ? @"NO" : @"YES"}]];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:SET_FIND_PHONE object:nil userInfo:@{@"success": @(NO)}];
//                }else if ([TTStr isEqualToString:@"01"]) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:SET_FIND_PHONE object:nil userInfo:@{@"success": @(YES)}];
//                }
            }else if ([secondStr isEqualToString:@"19"]) {
                manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
                [[NSNotificationCenter defaultCenter] postNotificationName:SET_TAKE_PHOTO object:model];
            }
        }
    }
}

#pragma mark - 通知

#pragma mark - 懒加载
- (NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}


@end

