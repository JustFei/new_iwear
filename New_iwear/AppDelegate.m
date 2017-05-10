//
//  AppDelegate.m
//  New_iwear
//
//  Created by Faith on 2017/4/26.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = WHITE_COLOR;
    
    //初始化一个tabBar控制器
    SettingViewController *tb = [[SettingViewController alloc]init];
    //设置UIWindow的rootViewController为UITabBarController
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:tb];
    
//    UIView *alertView = [[UIView alloc] init];
//    alertView.backgroundColor = RED_COLOR;
//    [self.window addSubview:alertView];
//    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.window.mas_left);
//        make.right.equalTo(self.window.mas_right);
//        make.bottom.equalTo(self.window.mas_bottom);
//        make.height.equalTo(@44);
//    }];
//    
//    UILabel *disconnectLabel = [[UILabel alloc] init];
//    [disconnectLabel setText:@"连接已断开"];
//    [disconnectLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
//    [disconnectLabel setFont:[UIFont systemFontOfSize:14]];
//    [alertView addSubview:disconnectLabel];
//    [disconnectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(alertView.mas_centerY);
//        make.left.equalTo(alertView.mas_left).offset(16);
//    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
