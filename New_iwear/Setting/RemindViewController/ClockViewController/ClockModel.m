//
//  ClockModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "ClockModel.h"

@implementation ClockModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeBool:self.isOpen forKey:@"isOpen"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.ID = [aDecoder decodeIntegerForKey:@"ID"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.isOpen = [aDecoder decodeBoolForKey:@"isOpen"];
    }
    return self;
}

@end
