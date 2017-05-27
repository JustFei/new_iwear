//
//  TargetSettingModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TargetSettingModel.h"

@implementation TargetSettingModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.mode forKey:@"mode"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.target forKey:@"target"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.mode = [aDecoder decodeIntegerForKey:@"mode"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.target = [aDecoder decodeObjectForKey:@"target"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"title == %@ name == %@, target == %@", _title, _name, _target];
}

@end
