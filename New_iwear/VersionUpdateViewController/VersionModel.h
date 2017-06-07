//
//  VersionModel.h
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    VersionTypeSoftware = 0,
    VersionTypeHardware
} VersionType;

@interface VersionModel : NSObject

@property (nonatomic, assign) VersionType versionType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *version;

+ (instancetype)modelWithTitle:(NSString *)title andVersion:(NSString *)version;

@end
