//
//  SyncTool.h
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SyncDataCurrentCountBlock)(NSInteger progress);

@interface SyncTool : NSObject
@property (nonatomic, assign) BOOL syncDataIng;      //判断数据是否在同步中
@property (nonatomic, copy) SyncDataCurrentCountBlock syncDataCurrentCountBlock;

+ (instancetype)shareInstance;
//数据同步
- (void)syncData;
//设置同步
- (void)syncSetting;

@end
