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
#import "BleManager.h"

@interface AppDelegate () < BleConnectDelegate, BleDiscoverDelegate, BleReceiveSearchResquset >
{
    BOOL _isBind;
}
@property (nonatomic, strong) MDSnackbar *stateBar;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) MainViewController *mainVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = WHITE_COLOR;
    
    //初始化一个tabBar控制器
    self.mainVC = [[MainViewController alloc]init];
    //取出 bar 底部线条
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
//    [nc.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
////    nc.navigationBar.barStyle = UIBarStyleBlack;
//    nc.navigationBar.translucent = NO;
//    [nc.navigationBar setShadowImage:[UIImage new]];

    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    self.window.rootViewController = nc;
    
    self.myBleManager = [BleManager shareInstance];
    self.myBleManager.discoverDelegate = self;
    self.myBleManager.connectDelegate = self;
    self.myBleManager.searchDelegate = self;
    //监听state变化的状态
    [self.myBleManager addObserver:self forKeyPath:@"systemBLEstate" options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
//    [self.myBleManager addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    return YES;
}

/** 跳转到蓝牙设置界面 */
- (void)pushToBleSet
{
//    NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
//    if ([[UIApplication sharedApplication]canOpenURL:url]) {
//        [[UIApplication sharedApplication]openURL:url];
//    }
}

/** 跳转到 bindPeripheral 界面 */
- (void)bindAction
{
    [self.stateBar dismiss];
    BindPeripheralViewController *vc = [[BindPeripheralViewController alloc] init];
    switch (self.mainVC.pageControl.currentPage) {
        case 0:
            vc.naviBarColor = STEP_CURRENT_BACKGROUND_COLOR;
            break;
        case 1:
            vc.naviBarColor = SLEEP_CURRENT_BACKGROUND_COLOR;
            break;
        case 2:
            vc.naviBarColor = HR_CURRENT_BACKGROUND_COLOR;
            break;
        case 3:
            vc.naviBarColor = BP_HISTORY_BACKGROUND_COLOR;
            break;
        case 4:
            vc.naviBarColor = BO_HISTORY_BACKGROUND_COLOR;
            break;
        default:
            break;
    }
    [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
}

/** 取消通知栏 */
- (void)cancelStateBarAction:(MDButton *)sender
{
    if (self.stateBar.isShowing) {
        [self.stateBar dismiss];
    }
}

#pragma mark - 监听系统蓝牙状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change[@"new"]);
    if ([keyPath isEqualToString:@"systemBLEstate"]) {
        NSString *new = change[@"new"];
        switch (new.integerValue) {
            case 4:
            {
                self.stateBar.text = NSLocalizedString(@"手机蓝牙未打开", nil);
//                [self.stateBar setActionTitle:@"设置"];
//                [self.stateBar addTarget:self action:@selector(pushToBleSet)];
                [self.stateBar show];
            }
                break;
            case 5:
            {
                if (self.myBleManager.connectState == kBLEstateDisConnected) {
                    [self isBindPeripheral];
                }
            }
                
                break;
                
            default:
                break;
        }
    }
//    else if ([keyPath isEqualToString:@"connectState"]) {
//        NSString *new = change[@"new"];
//        
//    }
}

/** 用来判断是否显示状态栏 */
- (void)showTheStateBar
{
    if (self.myBleManager.systemBLEstate == 4) {
        self.stateBar.text = NSLocalizedString(@"手机蓝牙未打开", nil);
        [self.stateBar show];
    }else if (self.myBleManager.systemBLEstate == 5) {
        [self isBindPeripheral];
    }
}

/** 判断是否绑定 */
- (void)isBindPeripheral
{
    _isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    DLog(@"有没有绑定设备 == %d",_isBind);
    if (_isBind) {
        if (self.stateBar.isShowing) {
            [self.stateBar dismiss];
            self.stateBar = nil;
        }
        self.stateBar.text = @"正在连接中";
        [self.stateBar show];
        [self connectBLE];
    }else {
        if (self.stateBar.isShowing) {
            [self.stateBar dismiss];
            self.stateBar = nil;
        }
        self.stateBar.text = @"未绑定设备";
        self.stateBar.actionTitle = @"绑定";
        [self.stateBar addTarget:self action:@selector(bindAction)];
        [self.stateBar show];
    }
}

/** 连接已绑定的设备 */
- (void)connectBLE
{
    BOOL systemConnect = [self.myBleManager retrievePeripherals];
    if (!systemConnect) {
        [self.myBleManager scanDevice];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.myBleManager stopScan];
            
            if (self.myBleManager.connectState == kBLEstateDisConnected) {
                //[self.mainVc.stepView.stepLabel setText:@"未连接上设备，点击重试"];
            }
        });
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self.myBleManager removeObserver:self forKeyPath:@"systemBLEstate"];
}

#pragma mark - bleConnectDelegate
- (void)manridyBLEDidConnectDevice:(BleDevice *)device
{
    //    [self.mainVc showFunctionView];
    self.stateBar.text = @"连接成功";
    
//    self 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.stateBar.text = @"正在同步数据";
        [[SyncTool shareInstance] syncAllData];
    });
}

#pragma mark - lazy
- (MDSnackbar *)stateBar
{
    if (!_stateBar) {
        _stateBar = [[MDSnackbar alloc] init];
        [_stateBar setActionTitleColor:NAVIGATION_BAR_COLOR];
        
        //这里1000000秒是让bar长驻在底部
        [_stateBar setDuration:1000000];
        _stateBar.multiline = YES;
        
        MDButton *cancelButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
        [cancelButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelStateBarAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = RED_COLOR;
        [_stateBar addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_stateBar.mas_left).offset(16);
            //        make.top.equalTo(self.stateBar.mas_top).offset(10);
            make.centerY.equalTo(_stateBar.mas_centerY);
        }];
    }
    
    return _stateBar;
}

@end
