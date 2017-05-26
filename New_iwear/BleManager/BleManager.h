//
//  BleManager.h
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "manridyModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"

@class manridyModel;

/**
 心率测试开关
 HeartRateTestStateStop：停止心率测量
 HeartRateTestStateStart：开始心率测量
 */
typedef enum : NSUInteger {
    HeartRateTestStateStop = 0,
    HeartRateTestStateStart,
} HeartRateTestState;

/**
 当前设备的连接状态
 kBLEstateDisConnected：未连接
 kBLEstateDidConnected：已连接
 */
typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected,
}kBLEstate;

/**
 系统蓝牙的状态
 SystemBLEStateUnknown：蓝牙装填未知
 SystemBLEStateResetting：与系统服务的连接暂时丢失，即将更新。
 SystemBLEStateUnsupported：该平台不支持蓝牙低功耗中央/客户端角色。
 SystemBLEStateUnauthorized：该应用程序未被授权使用蓝牙低功耗角色。
 SystemBLEStatePoweredOff：蓝牙当前已关机。
 SystemBLEStatePoweredOn：蓝牙目前已打开并可用。
 */
typedef enum{
    SystemBLEStateUnknown = 0,
    SystemBLEStateResetting,
    SystemBLEStateUnsupported,
    SystemBLEStateUnauthorized,
    SystemBLEStatePoweredOff,
    SystemBLEStatePoweredOn,
} SystemBLEState;

/**
 拍照模式
 kCameraModeOpenCamera：打开相机
 kCameraModePhotoFinish：拍照已完成
 kCameraModeCloseCamera：关闭相机
 */
typedef enum : NSUInteger {
    kCameraModeOpenCamera = 0,
    kCameraModePhotoFinish,
    kCameraModeCloseCamera,
} kCameraMode;

/**
 历史数据模式
 HistoryModeData：具体的历史数据
 HistoryModeCount：历史数据条数
 HistoryModeCurrent：获取当前跑步情况，此条仅仅针对跑步数据有用！！！！
 */
typedef enum : NSUInteger {
    HistoryModeData = 0,
    HistoryModeCount,
    HistoryModeCurrent,
} HistoryMode;

/**
 历史数据模式
 WindowRequestModeWindowCount：查询窗口数量
 WindowRequestModeSearchWindow：查询窗口
 WindowRequestModeSetWindow：设置窗口
 WindowRequestModeWindowRelationship：获取窗口关系
 */
typedef enum : NSUInteger {
    WindowRequestModeWindowCount = 0,
    WindowRequestModeSearchWindow,
    WindowRequestModeSetWindow,
    WindowRequestModeWindowRelationship
} WindowRequestMode;

#pragma mark - 扫描设备协议
@protocol BleDiscoverDelegate <NSObject>

@optional
- (void)manridyBLEDidDiscoverDeviceWithMAC:(BleDevice *)device;

@end

#pragma mark - 连接协议
@protocol BleConnectDelegate <NSObject>

@optional
/**
 *  invoked when the device did connected by the centeral
 *
 *  @param device the device did connected
 */
- (void)manridyBLEDidConnectDevice:(BleDevice *)device;

/**
 *  invoked when the device did fail connected
 *
 *  @param device fail
 */
- (void)manridyBLEDidFailConnectDevice:(BleDevice *)device;

/**
 *  invoked when the device did disconnected
 *
 *  @param device the device did disconnected
 */
- (void)manridyBLEDidDisconnectDevice:(BleDevice *)device;

@end

#pragma mark - 设备请求查找手机
@protocol BleReceiveSearchResquset <NSObject>

@optional
- (void)receivePeripheralRequestToRemindPhoneWithState:(BOOL)OnorOFF;

@end

@interface BleManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

+ (instancetype)shareInstance;

/** 当前连接的设备 */
@property (nonatomic ,strong) BleDevice *currentDev;
@property (nonatomic ,weak) id <BleDiscoverDelegate>discoverDelegate;
@property (nonatomic ,weak) id <BleConnectDelegate>connectDelegate;
@property (nonatomic ,weak) id <BleReceiveSearchResquset>searchDelegate;
@property (nonatomic ,assign) BOOL isReconnect;
@property (nonatomic ,assign) kBLEstate connectState; //support add observer ,abandon @readonly ,don't change it anyway.
@property(nonatomic, assign,) SystemBLEState systemBLEstate;
@property (nonatomic ,strong) CBCentralManager *myCentralManager;

#pragma mark - action of connecting layer -连接层操作
/** 判断有没有当前设备有没有连接的 */
- (BOOL)retrievePeripherals;

/** 扫描设备 */
- (void)scanDevice;

/** 停止扫描 */
- (void)stopScan;

/** 连接设备 */
- (void)connectDevice:(BleDevice *)device;

/** 断开设备连接 */
- (void)unConnectDevice;

/** 重连设备 */
//- (void)reConnectDevice:(BOOL)isConnect;

/** 检索已连接的外接设备 */
- (NSArray *)retrieveConnectedPeripherals;

#pragma mark - 获取SDK版本号
//- (NSString *)getManridyBleSDKVersion;

#pragma mark - 写入/请求相关数据
/** 设置时间 */
- (void)writeTimeToPeripheral:(NSDate *)currentDate;

/** 设置闹钟 */
- (void)writeClockToPeripheral:(ClockData)state withClockArr:(NSMutableArray *)clockArr;

/** 计步信息 */
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type;

/** 清空计步 */
- (void)writeMotionZeroToPeripheral;

/** GPS 数据 */
- (void)writeGPSToPeripheral;

/** 设置用户信息：身高体重 */
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height;

/** 设置运动目标 */
- (void)writeMotionTargetToPeripheral:(NSString *)target;

/** 心率开关 */
- (void)writeHeartRateTestStateToPeripheral:(HeartRateTestState)state;

/** 心率数据 */
- (void)writeHeartRateRequestToPeripheral:(HeartRateData)heartRateData;

/** 睡眠数据 */
- (void)writeSleepRequestToperipheral:(SleepData)sleepData;

/** 电话短信提醒 */
- (void)writePhoneAndMessageRemindToPeripheral:(Remind *)remindModel;

/** 查找我的设备 */
- (void)writeSearchPeripheralWithONorOFF:(BOOL)state;

/** 防丢提醒 */
- (void)writePeripheralShakeWhenUnconnectWithOforOff:(BOOL)state;

/** 停止设备提醒 */
- (void)writeStopPeripheralRemind;

/** 血压数据 */
- (void)writeBloodToPeripheral:(BloodData)bloodData;

/** 血氧数据 */
- (void)writeBloodO2ToPeripheral:(BloodO2Data)bloodO2Data;

/** 获取设备版本号 */
- (void)writeRequestVersion;

/** 设置设备亮度 */
- (void)writeDimmingToPeripheral:(float)value;

/** 设置久坐提醒 */
- (void)writeSedentaryAlertWithSedentaryModel:(SedentaryModel *)sedentaryModel;

/** 写入名称 */
- (void)writePeripheralNameWithNameString:(NSString *)name;

/** 推送公制和英制单位
 ImperialSystem   YES = 英制
                  NO  = 公制
 */
- (void)writeUnitToPeripheral:(BOOL)ImperialSystem;

/** 拍照 */
- (void)writeCameraMode:(kCameraMode)mode;

/** 分段计步获取 */
- (void)writeSegementStepWithHistoryMode:(HistoryMode)mode;

/** 分段跑步获取 */
- (void)writeSegementRunWithHistoryMode:(HistoryMode)mode;

/** 窗口协议 */
- (void)writeWindowRequset:(WindowRequestMode)mode withDataArr:(NSArray *)dataArr;

/** 
 时间格式设置
 YES = 12 时
 NO = 24 时
 */
- (void)writeTimeFormatterToPeripheral:(BOOL)twelveFormatter;

@end
