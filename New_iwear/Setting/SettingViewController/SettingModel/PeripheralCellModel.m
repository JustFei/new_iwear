//
//  PeripheralCellModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/3.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "PeripheralCellModel.h"

@implementation PeripheralCellModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"peripheralName == %@, isBind == %d, isConnect == %d, battery == %@", _peripheralName, _isBind, _isConnect, _battery];
}

@end
