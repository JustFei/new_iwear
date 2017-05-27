//
//  InterfaceSelectionModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 功能	窗口ID
 主页面	0
 记步界面	1
 运动界面	2
 心率界面	3
 睡眠界面	4
 关机界面	5
 设备信息界面	6
 查找界面	7
 血压界面	8
 闹钟界面	9
 MAC地址二维码界面	10
 APP下载二维码界面	11
 自定义二维码界面	12
 跑步运动界面	13
 登山运动界面	14
 羽毛球运动界面	15
 篮球运动界面	16
 */

//typedef enum : NSUInteger {
//    SelectModeUnselected,   //未选择的
//    SelectModeSelected,     //选择的
//    SelectModeUnchoose,     //不可选择的，即必须存在的
//} SelectMode;

typedef NS_ENUM(NSInteger, SelectMode) {
    SelectModeUnselected,   //未选择的
    SelectModeSelected,     //选择的
    SelectModeUnchoose,     //不可选择的，即必须存在的
};

@interface InterfaceSelectionModel : NSObject < NSCoding >

@property (nonatomic, assign) NSInteger windowID;
@property (nonatomic, copy) NSString *functionImageName;
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, assign) SelectMode selectMode;

@end
