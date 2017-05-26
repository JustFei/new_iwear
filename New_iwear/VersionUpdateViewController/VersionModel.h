//
//  VersionModel.h
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *version;

+ (instancetype)modelWithTitle:(NSString *)title andVersion:(NSString *)version;

@end
