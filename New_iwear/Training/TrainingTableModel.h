//
//  TrainingTableModel.h
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainingTableModel : NSObject

/** 时间段的文本 */
@property (nonatomic, strong) NSString *periodStr;
@property (nonatomic, strong) NSString *sportTypeStr;
@property (nonatomic, strong) NSString *timeCountStr;
@property (nonatomic, strong) NSString *stepStr;
@property (nonatomic, strong) NSString *kcalStr;

@end
