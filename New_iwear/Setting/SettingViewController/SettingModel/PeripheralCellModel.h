//
//  PeripheralCellModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/3.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralCellModel : NSObject

/** 设备名称 */
@property (nonatomic, copy) NSString *peripheralName;
/** 是否绑定 */
@property (nonatomic, assign) BOOL isBind;
/** 是否连接 */
@property (nonatomic, assign) BOOL isConnect;
/** 电量 */
@property (nonatomic, copy) NSString *battery;

@end
