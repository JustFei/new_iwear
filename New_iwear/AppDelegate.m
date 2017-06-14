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
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Bugly/Bugly.h>

@interface AppDelegate () < BleConnectDelegate, BleDiscoverDelegate, BleReceiveSearchResquset, UNUserNotificationCenterDelegate >
{
    SystemSoundID soundID;
    BOOL _isBind;
}
@property (nonatomic, strong) MDSnackbar *stateBar;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) MainViewController *mainVC;
@property (nonatomic ,strong) AlertTool *searchVC;

@end

@implementation AppDelegate

static void completionCallback(SystemSoundID mySSID)
{
    // 播放完毕之后，再次播放
    AudioServicesPlayAlertSound(mySSID);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Bugly startWithAppId:@"bbb928d22b"];
    //保存 log
    [self redirectNSLogToDocumentFolder];
    
    //监听查找手机通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchPhoneNoti:) name:SET_FIND_PHONE object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = WHITE_COLOR;
    
    //初始化一个tabBar控制器
    self.mainVC = [[MainViewController alloc]init];
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
    
    //注册通知
    // 申请通知权限
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    }];
    
    return YES;
}

- (void)resetDelegate
{
    self.myBleManager = [BleManager shareInstance];
    self.myBleManager.discoverDelegate = self;
    self.myBleManager.connectDelegate = self;
    self.myBleManager.searchDelegate = self;
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
    NSLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change[@"new"]);
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
    NSLog(@"有没有绑定设备 == %d",_isBind);
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

/** 处理查找手机的通知 */
- (void)getSearchPhoneNoti:(NSNotification *)noti
{
    NSString *success = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"success:%@", success);
    //这里不能直接写 if (isFirst),必须如下写法
    if ([success isEqualToString:@"YES"]) {
        if (self.searchVC != nil) {
            [self.searchVC dismissFromSuperview];
            self.searchVC = nil;
        }
        [self.searchVC show];
        [self requestNotify];
        
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
        //提示音 带震动
        AudioServicesPlayAlertSound(soundID);
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL,(void*)completionCallback ,NULL);
    }else {
        [self.searchVC dismissFromSuperview];
        AudioServicesDisposeSystemSoundID(soundID);
    }
}

- (void)requestNotify
{
    // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    // 标题
    content.title = @"手环查找中。。。";
    // body     Tips:之前忘记设置body，导致通知只有声音而没有通知内容 ╥﹏╥...
    content.body = [NSString stringWithFormat:@"您的手环正在查找您。。。"];
    content.sound = [UNNotificationSound soundNamed:@"alert.wav"];
    // 标识符
    content.categoryIdentifier = @"categoryIndentifier1";
    
    // 2、创建通知触发
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    // 3、创建通知请求
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"categoryIndentifier1" content:content trigger:trigger];
    
    // 4、将请求加入通知中心
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            DLog(@"已成功加推送%@",notificationRequest.identifier);
        }
    }];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SyncTool shareInstance] syncAllData];
    });
}

#pragma mark - Log
- (void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
    //把错误日志发送到邮箱
    //    NSString *urlStr = [NSString stringWithFormat:@"mailto://test@163.com?subject=bug报告&body=感谢您的配合!<br><br><br>错误详情:<br>%@",crashString ];
    //    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    [[UIApplication sharedApplication] openURL:url];
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
            make.centerY.equalTo(_stateBar.mas_centerY);
        }];
    }
    
    return _stateBar;
}

- (AlertTool *)searchVC
{
    if (!_searchVC) {
        _searchVC = [AlertTool alertWithTitle:@"提示" message:@"设备正在查找手机" style:UIAlertControllerStyleAlert];
        [_searchVC addAction:[AlertAction actionWithTitle:@"取消" style:AlertToolStyleDefault handler:^(AlertAction *action) {
            if ([BleManager shareInstance].connectState == kBLEstateDidConnected) {
                [[BleManager shareInstance] writeStopPeripheralRemind];
                AudioServicesDisposeSystemSoundID(soundID);
            }
        }]];
    }
    
    return _searchVC;
}

@end
