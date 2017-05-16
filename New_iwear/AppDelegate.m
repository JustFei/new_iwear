//
//  AppDelegate.m
//  New_iwear
//
//  Created by Faith on 2017/4/26.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BindPeripheralViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MDSnackbar *stateBar;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = WHITE_COLOR;
    
    //初始化一个tabBar控制器
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
    
    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    self.window.rootViewController = nc;
    
    self.stateBar = [[MDSnackbar alloc] init];
    [self.stateBar setText:@"尚未绑定设备，请前往绑定设备"];
    [self.stateBar setActionTitle:@"绑定"];
    [self.stateBar setActionTitleColor:NAVIGATION_BAR_COLOR];
    //这里100秒是让bar长驻在底部
    [self.stateBar setDuration:100];
    [self.stateBar addTarget:self action:@selector(bindAction)];
    [self.stateBar show];
    
    return YES;
}

- (void)bindAction
{
    [self.stateBar dismiss];
    BindPeripheralViewController *vc = [[BindPeripheralViewController alloc] init];
    [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
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
