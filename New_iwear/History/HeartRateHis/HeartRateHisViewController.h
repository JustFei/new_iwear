//
//  HeartRateHisViewController.h
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ViewControllerTypeHR = 0,
    ViewControllerTypeBP,
    ViewControllerTypeBO
} ViewControllerType;

@interface HeartRateHisViewController : UIViewController

@property (nonatomic, assign) ViewControllerType vcType;

@end
