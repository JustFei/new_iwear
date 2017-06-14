//
//  SyncTool.h
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

//同步设置的回调
typedef void(^SyncSettingSuccessBlock)(BOOL success);

@interface SyncTool : NSObject
@property (nonatomic, assign) BOOL syncDataIng;      //判断数据是否在同步中
@property (nonatomic, copy) SyncSettingSuccessBlock syncSettingSuccessBlock;

+ (instancetype)shareInstance;
//同步数据
- (void)syncAllData;
//同步设置
- (void)syncSetting;

@end
