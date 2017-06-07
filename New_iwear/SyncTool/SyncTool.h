//
//  SyncTool.h
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void(^SyncDataCurrentCountBlock)(NSInteger progress);

@interface SyncTool : NSObject
@property (nonatomic, assign) BOOL syncDataIng;      //判断数据是否在同步中
//@property (nonatomic, copy) SyncDataCurrentCountBlock syncDataCurrentCountBlock;

+ (instancetype)shareInstance;
//同步数据
- (void)syncAllData;

@end
