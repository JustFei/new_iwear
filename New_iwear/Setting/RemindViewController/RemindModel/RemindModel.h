//
//  RemindModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindModel : NSObject < NSCoding >

@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, copy) NSString *headImageName;
@property (nonatomic, assign) BOOL isOpen;

@end
