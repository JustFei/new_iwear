//
//  VersionModel.m
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "VersionModel.h"

@implementation VersionModel

+ (instancetype)modelWithTitle:(NSString *)title andVersion:(NSString *)version
{
    VersionModel *model = [[VersionModel alloc] init];
    model.title = title;
    model.version = version;
    
    return model;
}

@end
