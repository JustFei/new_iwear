//
//  UserInfoModel.h
//  ManridyApp
//
//  Created by JustFei on 16/10/13.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Metric) {
    isMetric = 0,
    notIsMetric
};

typedef NS_ENUM(NSUInteger, Gender) {
    GenderMan = 0,
    GenderWoman
};

@interface UserInfoModel : NSObject < NSCoding >

@property (nonatomic ,copy) NSString *userName;
@property (nonatomic ,assign) Gender gender;
@property (nonatomic ,copy) NSString *age;
@property (nonatomic ,copy) NSString *height;
@property (nonatomic ,copy) NSString *weight;
@property (nonatomic ,assign) NSInteger stepLength;
@property (nonatomic ,assign) NSInteger stepTarget;
@property (nonatomic ,assign) NSInteger sleepTarget;
//@property (nonatomic, assign) Metric metric;

+ (instancetype)userInfoModelWithUserName:(NSString *)userName andGender:(NSInteger)gender andAge:(NSString *)age andHeight:(NSString *)height andWeight:(NSString *)weight andStepLength:(NSInteger)stepLength andStepTarget:(NSInteger)stepTarget andSleepTarget:(NSInteger)sleepTarget;

@end
