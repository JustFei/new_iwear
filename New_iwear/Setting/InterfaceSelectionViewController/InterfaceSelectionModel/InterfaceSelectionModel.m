//
//  InterfaceSelectionModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "InterfaceSelectionModel.h"

@implementation InterfaceSelectionModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.windowID forKey:@"windowID"];
    [aCoder encodeObject:self.functionName forKey:@"functionName"];
    [aCoder encodeObject:self.functionImageName forKey:@"functionImageName"];
    [aCoder encodeInteger:self.selectMode forKey:@"selectMode"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.windowID = [aDecoder decodeIntegerForKey:@"windowID"];
        self.functionName = [aDecoder decodeObjectForKey:@"functionName"];
        self.functionImageName = [aDecoder decodeObjectForKey:@"functionImageName"];
        self.selectMode = [aDecoder decodeIntegerForKey:@"selectMode"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"functionImageName == %@, functionName == %@, selectMode == %ld", _functionImageName, _functionName, (unsigned long)_selectMode];
}

@end
