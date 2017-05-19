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
//#import "AllBleFmdb.h"
#import "AppDelegate.h"
#import "ClockModel.h"
#import <UserNotifications/UserNotifications.h>

#define kServiceUUID              @"F000EFE0-0000-4000-0000-00000000B000"
#define kWriteCharacteristicUUID  @"F000EFE1-0451-4000-0000-00000000B000"
#define kNotifyCharacteristicUUID @"F000EFE3-0451-4000-0000-00000000B000"

#define kCurrentVersion @"1.0"


@interface BleManager () <UNUserNotificationCenterDelegate>

@property (nonatomic ,strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic ,strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic ,strong) NSMutableArray *deviceArr;
//@property (nonatomic ,strong) AllBleFmdb *fmTool;
@property (nonatomic ,strong) UIAlertView *disConnectView;
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

#pragma mark - get sdk version -获取SDK版本号
- (NSString *)getManridyBleSDKVersion
{
    return kCurrentVersion;
}

#pragma mark - action of connecting layer -连接层操作
/** 判断有没有当前设备有没有连接的 */
- (BOOL)retrievePeripherals
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"]) {
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        NSArray *arr = [_myCentralManager retrievePeripheralsWithIdentifiers: @[uuid]];
        DLog(@"当前已连接的设备%@,有几个%ld",arr ,(unsigned long)arr.count);
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
            //NSLog(@"x == %ld", x);
            [NSThread sleepForTimeInterval:0.01];
            DLog(@"---%@", message);
            [self.currentDev.peripheral writeValue:message forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
#warning Resend Message Function
            //self.haveResendMessage = YES;
            //[self setResendTimerWithMessage:message];
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
    DLog(@"时间设置成功");
}

//set clock
- (void)writeClockToPeripheral:(ClockData)state withClockArr:(NSMutableArray *)clockArr
{
    if (state == ClockDataSetClock) {
        DLog(@"设置闹钟");
        
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
        DLog(@"设置闹钟数据成功");
    }else {
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"01"];
        
        //写入操作
        [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
        DLog(@"获取闹钟数据成功");
    }
}

//get motionInfo
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:[NSString stringWithFormat:@"%ld",(unsigned long)type] head:@"03"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    DLog(@"请求计步数据");
}

//set motionInfo zero
- (void)writeMotionZeroToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"04"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    DLog(@"清空计步数据");
}
//get GPS data
- (void)writeGPSToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"05"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    DLog(@"gps 请求成功");
}

//set userInfo
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height
{
    NSString *protocolStr = [weight stringByAppendingString:[NSString stringWithFormat:@",%@",height]];
    
    protocolStr = [NSStringTool protocolAddInfo:protocolStr head:@"06"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//set motion target
- (void)writeMotionTargetToPeripheral:(NSString *)target
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:target head:@"07"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//set heart rate test state
- (void)writeHeartRateTestStateToPeripheral:(HeartRateTestState)state
{
    NSString *protocolStr;
    protocolStr = state == HeartRateTestStateStop ? [NSStringTool protocolAddInfo:@"00" head:@"09"] : [NSStringTool protocolAddInfo:@"01" head:@"09"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get heart rate data
- (void)writeHeartRateRequestToPeripheral:(HeartRateData)heartRateData
{
    NSString *protocolStr;
    protocolStr = heartRateData == HeartRateDataLastData ? [NSStringTool protocolAddInfo:@"00" head:@"0A"] : [NSStringTool protocolAddInfo:@"01" head:@"0A"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get sleepInfo
- (void)writeSleepRequestToperipheral:(SleepData)sleepData
{
    NSString *protocolStr;
    protocolStr = sleepData == SleepDataLastData ? [NSStringTool protocolAddInfo:@"00" head:@"0C"] : [NSStringTool protocolAddInfo:@"01" head:@"0C"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//phone and message remind
- (void)writePhoneAndMessageRemindToPeripheral:(Remind *)remindModel
{
    NSString *protocolStr;
    protocolStr = [NSStringTool protocolForRemind:remindModel];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
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
    protocolStr = bloodData == BloodDataLastData ? [NSStringTool protocolAddInfo:@"00" head:@"11"] : [NSStringTool protocolAddInfo:@"01" head:@"11"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

//get blood O2 data
- (void)writeBloodO2ToPeripheral:(BloodO2Data)bloodO2Data
{
    NSString *protocolStr;
    protocolStr = bloodO2Data == BloodO2DataLastData ? [NSStringTool protocolAddInfo:@"00" head:@"12"] : [NSStringTool protocolAddInfo:@"01" head:@"12"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** get version from peripheral */
- (void)writeRequestVersion
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:@"" head:@"0f"];
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
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
        T2T1 = @"001e" ;    //30分钟提醒间隔
        //T2T1 = @"003c" ;    //60分钟提醒间隔
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
    DLog(@"久坐协议 = %@",protocolStr);
    
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
- (void)writeSegementStepWithHistoryMode:(HistoryMode)mode
{
    NSString *protocolStr;
    switch (mode) {
            /** 具体的历史数据 */
        case HistoryModeData:
            protocolStr = @"FC1A02";
            break;
            /** 历史数据条数 */
        case HistoryModeCount:
            protocolStr = @"FC1A04";
            break;
            
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** 分段跑步获取 */
- (void)writeSegementRunWithHistoryMode:(HistoryMode)mode
{
    NSString *protocolStr;
    switch (mode) {
        case HistoryModeData:
            protocolStr = @"FC1B02";
            break;
        case HistoryModeCount:
            protocolStr = @"FC1B04";
            break;
        case HistoryModeCurrent:
            protocolStr = @"FC1B08";
            break;
            
        default:
            break;
    }
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

/** 窗口协议 */
- (void)writeWindowRequset:(WindowRequestMode)mode
{
    NSString *protocolStr;
    switch (mode) {
        case WindowRequestModeWindowCount:
            protocolStr = @"FC1C01";
            break;
        case WindowRequestModeSearchWindow:
            protocolStr = @"FC1C0201";
            break;
        case WindowRequestModeSetWindow:
            protocolStr = @"FC1C0200";
            break;
        case WindowRequestModeWindowRelationship:
            protocolStr = @"FC1C04";
            break;
            
        default:
            break;
    }
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
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
            DLog(@"message == %@",message);
            AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:message style:UIAlertControllerStyleAlert];
            [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:nil]];
            [aTool show];
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
    }else {
        if ([device.uuidString isEqualToString:kServiceUUID]) {
            device.deviceName = @"X9Plus";
            if (![self.deviceArr containsObject:peripheral]) {
                DLog(@"+1");
                [self.deviceArr addObject:peripheral];
                
                //返回扫描到的设备实例
                if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                    
                    [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
                }
            }
        }
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    peripheral.delegate = self;
    //传入nil会返回所有服务;一般会传入你想要服务的UUID所组成的数组,就会返回指定的服务
    [peripheral discoverServices:nil];
    
    //AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate.mainVc showFunctionView];
    
    [self.disConnectView dismissWithClickedButtonIndex:0 animated:NO];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //    DLog(@"连接失败");
    
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidFailConnectDevice:)]) {
        [self.connectDelegate manridyBLEDidFailConnectDevice:self.currentDev];
    }
    
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectState = kBLEstateDisConnected;
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidDisconnectDevice:)]) {
        [self.connectDelegate manridyBLEDidDisconnectDevice:self.currentDev];
    }
    
    if (self.isReconnect) {
        DLog(@"需要断线重连");
        [self.myCentralManager connectPeripheral:self.currentDev.peripheral options:nil];
        
        self.disConnectView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"bleReConnect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"IKnow", nil) otherButtonTitles:nil, nil];
        self.disConnectView.tag = 103;
        [self.disConnectView show];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]) {
            BOOL isFindMyPeripheral = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"];
            
            /**TODO:这里的延迟操作会因为在后台的原因停止执行，目前测试在8秒钟左右可以实现稳定延迟。*/
            if (isFindMyPeripheral) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self delayMethod];
                });
                
            }
        }
        
        //AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        delegate.mainVc.haveNewStep = YES;
//        delegate.mainVc.haveNewHeartRate = YES;
//        delegate.mainVc.haveNewSleep = YES;
//        delegate.mainVc.haveNewBP = YES;
//        delegate.mainVc.haveNewBO = YES;
//        [delegate.mainVc hiddenFunctionView];
        
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
                DLog(@"已成功加推送%@",notificationRequest.identifier);
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
    
    //    DLog(@"Discovered characteristic %@", service.characteristics);
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
        DLog(@"Error changing notification state: %@",[error localizedDescription]);
    }else {
        DLog(@"Success changing notification state: %d;value = %@",characteristic.isNotifying ,characteristic.value);
    }
}

//订阅特征值发送变化的通知，所有获取到的值都将在这里进行处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"updateValue == %@",characteristic.value);
    
    [self analysisDataWithCharacteristic:characteristic.value];
    
}

//写入某特征值后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        //        DLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }else {
        //        DLog(@"Success writing chararcteristic value: %@",characteristic);
    }
}

#pragma mark - 数据解析
- (void)analysisDataWithCharacteristic:(NSData *)value
{
    if ([value bytes] != nil) {
        const unsigned char *hexBytes = [value bytes];
        
        //命令头字段
        NSString *headStr = [NSString stringWithFormat:@"%02x", hexBytes[0]];
        
        if ([headStr isEqualToString:@"00"] || [headStr isEqualToString:@"80"]) {
            //解析设置时间数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSetTimeData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_TIME object:model];
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
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisUserInfoData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_USER_INFO object:model];
        }else if ([headStr isEqualToString:@"07"] || [headStr isEqualToString:@"87"]) {
            //运动目标推送
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSportTargetData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_MOTION_TARGET object:model];
        }else if ([headStr isEqualToString:@"08"] || [headStr isEqualToString:@"88"]) {
            //询问设备是否配对成功
            manridyModel *model = [[AnalysisProcotolTool shareInstance]analysisPairData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_PAIR object:model];
        }else if ([headStr isEqualToString:@"09"] || [headStr isEqualToString:@"89"]) {
            //心率开关
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartStateData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_HR_STATE object:model];
        }else if([headStr isEqualToString:@"0a"] || [headStr isEqualToString:@"0A"] || [headStr isEqualToString:@"8a"] || [headStr isEqualToString:@"8A"]) {
            //获取心率数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_HR_DATA object:model];
        }else if ([headStr isEqualToString:@"0c"] || [headStr isEqualToString:@"0C"] || [headStr isEqualToString:@"8c"] || [headStr isEqualToString:@"8C"]) {
            //获取睡眠
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSleepData:value WithHeadStr: headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SLEEP_DATA object:model];
        }else if ([headStr isEqualToString:@"0d"] || [headStr isEqualToString:@"0D"] || [headStr isEqualToString:@"8d"] || [headStr isEqualToString:@"8D"]) {
            //上报GPS数据
            //            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisGPSData:value WithHeadStr: headStr];
            //if ([self.receiveDelegate respondsToSelector:@selector(receiveGPSWithModel:)]) {
                //                [self.receiveDelegate receiveGPSWithModel:model];
                //                [_fmTool saveGPSToDataBase:model];
            //}else {
                //                [_fmTool saveGPSToDataBase:model];
            //}
        }else if ([headStr isEqualToString:@"0f"] || [headStr isEqualToString:@"0F"]) {
            //设备维护指令
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisFirmwareData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_FIRMWARE object:model];
        }else if ([headStr isEqualToString:@"fc"] || [headStr isEqualToString:@"FC"]) {
            NSString *secondStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
            NSString *TTStr = [NSString stringWithFormat:@"%02x", hexBytes[3]];
            if ([secondStr isEqualToString:@"10"]) {
                if ([self.searchDelegate respondsToSelector:@selector(receivePeripheralRequestToRemindPhoneWithState:)]) {
                    if ([TTStr isEqualToString:@"00"]) {
                        [self.searchDelegate receivePeripheralRequestToRemindPhoneWithState:NO];
                    }else {
                        [self.searchDelegate receivePeripheralRequestToRemindPhoneWithState:YES];
                    }
                    
                }
            }
        }else if ([headStr isEqualToString:@"10"]) {
            //查找设备回调
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEARCH_FEEDBACK object:nil];
        }else if ([headStr isEqualToString:@"11"]) {
            //获取血压
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodData:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_BP_DATA object:model];
        }else if ([headStr isEqualToString:@"12"]) {
            //获取血氧
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodO2Data:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_BO_DATA object:model];
        }else if ([headStr isEqualToString:@"19"]) {
            //开始拍照
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:SET_TAKE_PHOTO object:model];
        }else if ([headStr isEqualToString:@"1A"] || [headStr isEqualToString:@"1a"]) {
            //分段计步数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEGEMENT_STEP object:model];
        }else if ([headStr isEqualToString:@"1B"] || [headStr isEqualToString:@"1b"]) {
            //分段跑步数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_SEGEMENT_RUN object:model];
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

