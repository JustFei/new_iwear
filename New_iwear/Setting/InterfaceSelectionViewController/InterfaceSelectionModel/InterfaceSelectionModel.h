//
//  InterfaceSelectionModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SelectModeUnselected,
    SelectModeSelected,
    SelectModeUnchoose,
} SelectMode;

@interface InterfaceSelectionModel : NSObject

@property (nonatomic, copy) NSString *functionImageName;
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, assign) SelectMode selectMode;

@end
