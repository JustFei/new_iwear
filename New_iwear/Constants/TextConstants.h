//
//  TextConstants.h
//  New_iwear
//
//  Created by JustFei on 2017/5/19.
//  Copyright © 2017年 manridy. All rights reserved.
//

#ifndef TextConstants_h
#define TextConstants_h

#pragma mark - 通知中心的名字
//设置时间
#define SET_TIME @"SetTime"
//设置闹钟
#define SET_CLOCK @"SetClock"
//计步信息
#define GET_MOTION_DATA @"GetMotionData"
//计步清零
#define SET_MOTION_ZERO @"SetMotionZero"
//gps 数据
#define GET_GPS_DATA @"GetGPSData"
//用户信息
#define SET_USER_INFO @"SetUserInfo"
//运动目标
#define SET_MOTION_TARGET @"SetMotionTarget"
//查看是否配对
#define GET_PAIR @"GetPair"
//心率开关
#define SET_HR_STATE @"SetHRState"
//心率数据
#define GET_HR_DATA @"GetHRData"
//睡眠数据
#define GET_SLEEP_DATA @"GetSleepData"
//设置固件
#define SET_FIRMWARE @"SetFirmware"
//设备确认查找到时反馈
#define GET_SEARCH_FEEDBACK @"GetSearchFeedBack"
//设备查找手机(此处需要全局监听)
#define SET_FIND_PHONE @"SetFindPhone"
//血压
#define GET_BP_DATA @"GetBPData"
//血氧
#define GET_BO_DATA @"GetBOData"
//拍照
#define SET_TAKE_PHOTO @"SetTakePhoto"
//分段计步
#define GET_SEGEMENT_STEP @"GetSegementStep"
//分段跑步
#define GET_SEGEMENT_RUN @"GetSegementRun"
//久坐提醒
#define GET_SEDENTARY_DATA @"GetSedentaryData"
//单位设置
#define SET_UNITS_DATA @"SetUnitsData"
//时间格式设置
#define SET_TIME_FORMATTER @"SetTimeFormatter"
//窗口设置
#define SET_WINDOW @"SetWindow"


#pragma mark - NSUserDefault 保存的信息的名字
//长度单位
#define LONG_MEASURE @"LongMeasure"             //yes：英制，no：公制
//重量单位
#define HUNDRED_WEIGHT @"HundredWeight"         //yes：英制，no：公制
//时间制式
#define TIME_FORMATTER @"TimeFormatter"         //yes：12时，no：24时
//运动目标
#define MOTION_TARGET @"MotionTarget"
//睡眠目标
#define SLEEP_TARGET @"SleepTarget"
//硬件版本号
#define HARDWARE_VERSION @"HardwareVersion"  
//窗口设置保存
#define WINDOW_SETTING @"WindowSetting"
//久坐设置保存
#define SEDENTARY_SETTING @"SedentarySetting"

#endif /* TextConstants_h */
