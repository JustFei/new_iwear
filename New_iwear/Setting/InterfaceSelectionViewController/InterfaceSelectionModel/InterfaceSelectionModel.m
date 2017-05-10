//
//  InterfaceSelectionModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "InterfaceSelectionModel.h"

@implementation InterfaceSelectionModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"functionImageName == %@, functionName == %@, selectMode == %ld", _functionImageName, _functionName, (unsigned long)_selectMode];
}

@end
