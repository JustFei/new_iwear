//
//  RootViewController.m
//  New_iwear
//
//  Created by Faith on 2017/4/26.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "BaseNavigationViewController.h"

@interface RootViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.barTintColor = WHITE_COLOR;
    self.tabBar.translucent= NO;
    
    NSArray  *classNameArray =[NSArray arrayWithObjects:@"FirstViewController",@"SecondViewController",@"ThirdViewController", nil];
    NSArray *titleArray =[NSArray arrayWithObjects:@"状态",@"相机",@"我的", nil];
    NSArray *normalImageArray =[NSArray arrayWithObjects:@"main_normal",@"camera_normal",@"setting_normal",nil];
    NSArray *selectImageArray =[NSArray arrayWithObjects:@"main_select",@"camera_select",@"setting_normal", nil];
    
    NSMutableArray  *navigationArray =[[NSMutableArray alloc]init];
    for (int i=0; i<classNameArray.count; i++) {
        UIViewController  *vc =(UIViewController *)[[NSClassFromString(classNameArray[i]) alloc] init];
        vc.title=titleArray[i];
        UIImage  *normalImage =[UIImage imageNamed:normalImageArray[i]];
        UIImage  *selectImage =[UIImage imageNamed:selectImageArray[i]];
        vc.tabBarItem.image =[normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage=[selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        BaseNavigationViewController *na =[[BaseNavigationViewController alloc]initWithRootViewController:vc];
        [navigationArray addObject:na];
    }
    self.viewControllers = navigationArray;
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:BLACK_COLOR, NSFontAttributeName:[UIFont systemFontOfSize:10]} forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:CONNECT_BACKGROUND_COLOR, NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
