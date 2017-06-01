//
//  SyncTool.h
//  New_iwear
//
//  Created by JustFei on 2017/6/1.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncTool : NSObject

+ (instancetype)shareInstance;
//数据同步
- (void)syncData;
//设置同步
- (void)syncSetting;

@end
