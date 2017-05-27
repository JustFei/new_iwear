//
//  RemindModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindModel.h"

@implementation RemindModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.functionName forKey:@"functionName"];
    [aCoder encodeObject:self.headImageName forKey:@"headImageName"];
    [aCoder encodeBool:self.isOpen forKey:@"isOpen"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.functionName = [aDecoder decodeObjectForKey:@"functionName"];
        self.headImageName = [aDecoder decodeObjectForKey:@"headImageName"];
        self.isOpen = [aDecoder decodeBoolForKey:@"isOpen"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"functionName == %@, headImageName == %@, isOpen == %d", _functionName, _headImageName, _isOpen];
}

@end
