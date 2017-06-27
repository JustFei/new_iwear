//
//  NewfeatureViewController.h
//  New_iwear
//
//  Created by JustFei on 2017/6/27.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EnterMainVCBlock)(void);

@interface NewfeatureViewController : UIViewController

@property (nonatomic, copy) EnterMainVCBlock enterMainVCBlock;

@end
