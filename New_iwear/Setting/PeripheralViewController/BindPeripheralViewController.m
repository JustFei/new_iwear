//
//  BindPeripheralViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BindPeripheralViewController.h"
#import "BleManager.h"
#import "BleDevice.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeScanningVC.h"
#import "SedentaryReminderModel.h"
#import "SedentaryModel.h"
#import "InterfaceSelectionModel.h"
#import "UnitsSettingModel.h"
#import "TargetSettingModel.h"
//#import "FMDBManager.h"

#define WIDTH self.view.frame.size.width

@interface BindPeripheralViewController () <UITableViewDelegate ,UITableViewDataSource ,BleDiscoverDelegate ,BleConnectDelegate ,UIAlertViewDelegate, UITextFieldDelegate>
{
    /** 设备信息数据源 */
    NSMutableArray *_dataArr;
    /** 点击的索引 */
    NSInteger index;
    /** 扫描到的 mac 地址 */
    NSString *QRMacAddress;
    /** 同步的数据量 */
    NSInteger _asynCount;
}

@property (nonatomic ,weak) UIView *downView;
@property (nonatomic ,weak) UITableView *peripheralList;
@property (nonatomic ,weak) MDButton *bindButton;
@property (nonatomic ,weak) UIImageView *connectImageView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *bindStateLabel;
@property (nonatomic, strong) MDButton *qrCodeButton;
@property (nonatomic, strong) BleManager *myBleMananger;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic ,copy) NSString *changeName;
@property (nonatomic, strong) MDToast *connectToast;

@end

@implementation BindPeripheralViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [NSMutableArray array];
    
    index = -1;
    
    //navigationbar
    self.title = @"设备绑定";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"搜索", nil) style:UIBarButtonItemStylePlain target:self action:@selector(searchPeripheral)];
    self.navigationItem.rightBarButtonItem = rightItem;
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    if (self.naviBarColor) {
        [self.navigationController.navigationBar setBackgroundColor:self.naviBarColor];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.qrCodeButton setBackgroundColor:CLEAR_COLOR];
    BOOL isBinded = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    if (isBinded) {
        [self setBindView];
    }else {
       [self setUnBindView];
    }
    
    MDButton *helpBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    //[helpBtn setTitle:@"使用帮助" forState:UIControlStateNormal];
    [helpBtn setTitleColor:TEXT_WHITE_COLOR_LEVEL3 forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(helpAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];
    [helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bindStateLabel.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-16);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.downView.mas_top);
        make.height.equalTo(@8);
    }];
    
    _myBleMananger = [BleManager shareInstance];
    _myBleMananger.connectDelegate = self;
    _myBleMananger.discoverDelegate = self;
    
    //注册所有通知
    NSArray *observerArr = @[SET_TIME,
                             SET_FIRMWARE,
                             SET_WINDOW,
                             GET_SEDENTARY_DATA,
                             LOST_PERIPHERAL_SWITCH,
                             SET_CLOCK,
                             SET_UNITS_DATA,
                             SET_TIME_FORMATTER,
                             SET_MOTION_TARGET,
                             SET_USER_INFO];
    for (NSString *keyWord in observerArr) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(setNotificationObserver:) name:keyWord object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBindView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.bindButton.hidden = NO;
    [self.connectImageView setImage:[UIImage imageNamed:@"devicebinding_pic01_connect"]];
    [self.bindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    [self.peripheralList setHidden:YES];
    [self.refreshImageView setHidden:YES];
    [self.bindStateLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralName"]];
    [self.qrCodeButton setHidden:YES];
}

- (void)setUnBindView
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.bindButton.hidden = YES;
    [self.connectImageView setImage: [UIImage imageNamed:@"devicebinding_pic01_disconnect"]];
    [self.bindButton setTitle:@"绑定设备" forState:UIControlStateNormal];
    [self.peripheralList setHidden:YES];
    [self.refreshImageView setHidden:NO];
    [self.bindStateLabel setText:@"未绑定设备"];
    [self.qrCodeButton setHidden:NO];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)helpAction:(MDButton *)sender
{
    
}

- (void)searchPeripheral
{
    index = -1;
    
    [self deletAllRowsAtTableView];
    
    [self.myBleMananger scanDevice];
    
    [self.peripheralList setHidden:NO];
    [self.refreshImageView setHidden:YES];
    [self.bindButton setHidden:NO];
}

/** 绑定/接触绑定设备 */
- (void)bindPeripheral:(MDButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"绑定设备"]) {
        if (index != -1) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            BleDevice *device = _dataArr[index];
            [self.myBleMananger connectDevice:device];
            self.myBleMananger.isReconnect = YES;
            self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            [self.hud.label setText:NSLocalizedString(@"绑定中", nil)];
        }else {
            MDToast *toast = [[MDToast alloc] initWithText:@"请选择设备以绑定" duration:0.5];
            [toast show];
        }
    }else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定解除绑定？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.myBleMananger.isReconnect = NO;
            [self.myBleMananger unConnectDevice];
            index = -1;
            
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralID"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralName"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"peripheralUUID"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBind"];
            [[NSUserDefaults standardUserDefaults] setObject:@"--" forKey:ELECTRICITY_INFO_SETTING];
            
            [self setUnBindView];
            MDToast *disconnectToast = [[MDToast alloc] initWithText:@"解绑成功" duration:1];
            [disconnectToast show];
        }];
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alertC addAction:cancelAc];
        [alertC addAction:okAc];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)scanQR:(UIButton *)sender
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        QRCodeScanningVC *vc = [[QRCodeScanningVC alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    });
                    
                    SGQRCodeLog(@"当前线程 - - %@", [NSThread currentThread]);
                    // 用户第一次同意了访问相机权限
                    SGQRCodeLog(@"用户第一次同意了访问相机权限");
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    SGQRCodeLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            QRCodeScanningVC *vc = [[QRCodeScanningVC alloc] init];
            vc.scanResult = ^(NSString *result) {
                NSLog(@"macAddress == %@", result);
                result = [result lowercaseString];
                QRMacAddress = result;
                [self.myBleMananger scanDevice];
                self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                self.hud.mode = MBProgressHUDModeIndeterminate;
                [self.hud.label setText:NSLocalizedString(@"绑定中", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.myBleMananger.connectState == kBLEstateDisConnected) {
                        [self.myBleMananger stopScan];
                        [self.hud.label setText:@"绑定失败，请重试"];
                        [self.hud hideAnimated:YES afterDelay:1.5];
                    }
                });
            };
            [self.navigationController pushViewController:vc animated:YES];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"⚠️ 警告" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)deletAllRowsAtTableView
{
    //移除cell
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int row = 0; row < _dataArr.count; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    [_dataArr removeAllObjects];
    [self.peripheralList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)changePeripheralName:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([BleManager shareInstance].connectState == kBLEstateDidConnected) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改名称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 103;
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *nameField = [alertView textFieldAtIndex:0];
            nameField.delegate = self;
            nameField.placeholder = @"请输入修改的名称";
            [alertView show];
        }
    }
}

#pragma mark - 同步设置的数据
- (void)pairPhoneAndMessage
{
    //同步提醒设置
    Remind *rem = [[Remind alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING] && [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING]) {
        rem.phone = [[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING];
        rem.message = [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING];
        [self.myBleMananger writePhoneAndMessageRemindToPeripheral:rem];
    }
}

- (void)writeSedentReminder
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            SedentaryReminderModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        SedentaryModel *sedModel = [[SedentaryModel alloc] init];
        //久坐是否开启
        sedModel.sedentaryAlert = ((SedentaryReminderModel *)mutArr[0]).switchIsOpen;
        //勿扰是否开启
        sedModel.unDisturb = ((SedentaryReminderModel *)mutArr[3]).switchIsOpen;
        //开始时间
        sedModel.sedentaryStartTime = ((SedentaryReminderModel *)mutArr[1]).time;
        //结束时间
        sedModel.sedentaryEndTime = ((SedentaryReminderModel *)mutArr[2]).time;
        //勿扰开始时间
        sedModel.disturbStartTime = @"12:00";
        //勿扰结束时间
        sedModel.disturbEndTime = @"14:00";
        //步数设置
        sedModel.stepInterval = 50;
        [self.myBleMananger writeSedentaryAlertWithSedentaryModel:sedModel];
    }else {
        SedentaryModel *sedModel = [[SedentaryModel alloc] init];
        //勿扰是否开启
        sedModel.sedentaryAlert = NO;
        //勿扰是否开启
        sedModel.unDisturb = NO;
        [self.myBleMananger writeSedentaryAlertWithSedentaryModel:sedModel];
    }
}

- (void)writeClockReminder
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CLOCK_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:CLOCK_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            ClockModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        [self.myBleMananger writeClockToPeripheral:ClockDataSetClock withClockArr:[NSMutableArray arrayWithArray:mutArr]];
    }else {
        NSArray *timeArr = @[@"08:00", @"08:30", @"09:00", @"09:30", @"10:00"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int ind = 0; ind < timeArr.count; ind ++) {
            ClockModel *model = [[ClockModel alloc] init];
            model.time = timeArr[ind];
            model.isOpen = NO;
            [mutArr addObject:model];
        }
        
        [self.myBleMananger writeClockToPeripheral:ClockDataSetClock withClockArr:[NSMutableArray arrayWithArray:mutArr]];
    }
}

- (void)writeUserInterface
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:WINDOW_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:WINDOW_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            InterfaceSelectionModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        [self.myBleMananger writeWindowRequset:WindowRequestModeSetWindow withDataArr:mutArr];
    }else {
        NSArray *nameArr = @[@"待机",@"计步",@"运动",@"心率",@"睡眠",@"查找",@"闹钟",@"关于",@"关机"];
        NSArray *imageArr = @[@"selection_standby",@"selection_sport",@"selection_step",@"selection_heartrate",@"selection_sleep",@"selection_find",@"selection_alarmclock",@"selection_about",@"selection_turnoff"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int i = 0; i < nameArr.count; i ++) {
            InterfaceSelectionModel *model = [[InterfaceSelectionModel alloc] init];
            model.functionName = nameArr[i];
            model.functionImageName = imageArr[i];
            
            switch (i) {
                case 0:
                    model.windowID = 80;
                    break;
                case 1:
                    model.windowID = 81;
                    break;
                case 2:
                    model.windowID = 82;
                    break;
                case 3:
                    model.windowID = 83;
                    break;
                case 4:
                    model.windowID = 84;
                    break;
                case 5:
                    model.windowID = 87;
                    break;
                case 6:
                    model.windowID = 89;
                    break;
                case 7:
                    model.windowID = 86;
                    break;
                case 8:
                    model.windowID = 85;
                    break;
                    
                default:
                    break;
            }
            
            
            if (i == 0) {
                model.selectMode = SelectModeUnchoose;
            }else {
                model.selectMode = SelectModeSelected;
            }
            
            [mutArr addObject:model];
        }
        
        [self.myBleMananger writeWindowRequset:WindowRequestModeSetWindow withDataArr:mutArr];
    }
}

- (void)writeUnitsSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UNITS_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:UNITS_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            UnitsSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        UnitsSettingModel *model = ((NSArray*)mutArr.firstObject).firstObject;
        [self.myBleMananger writeUnitToPeripheral:model.isSelect];
    }else {
        [self.myBleMananger writeUnitToPeripheral:NO];
    }
}

- (void)writeTimeFormatterSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSData *data in arr) {
            UnitsSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [mutArr addObject:model];
        }
        UnitsSettingModel *model = ((NSArray*)mutArr.firstObject).firstObject;
        
        [self.myBleMananger writeTimeFormatterToPeripheral:model.isSelect];
    }else {
        [self.myBleMananger writeTimeFormatterToPeripheral:NO];
    }
}

- (void)writeStepTargetSetting
{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING];
    TargetSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:arr.firstObject];
    [self.myBleMananger writeMotionTargetToPeripheral:model.target];
}

- (void)writeUserInfoSetting
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING]) {
        NSData *infoData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING];
        UserInfoModel *infoModel = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
        [self.myBleMananger writeUserInfoToPeripheralWeight:[NSString stringWithFormat:@"%ld",(long)infoModel.weight] andHeight:[NSString stringWithFormat:@"%ld", infoModel.height]];
    }else {
        [self.myBleMananger writeUserInfoToPeripheralWeight:@"60" andHeight:@"170"];
    }
}

- (void)synchronizeSettings
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /** 同步时间 */
        [self.myBleMananger writeTimeToPeripheral:[NSDate date]];
        /** 同步硬件版本号 */
        [self.myBleMananger writeRequestVersion];
        /** 同步获取电量 */
        [self.myBleMananger writeGetElectricity];
        /** 同步界面选择 */
        [self writeUserInterface];
        /** 同步久坐提醒 */
        [self writeSedentReminder];
        /** 同步防丢提醒 */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]) {
            [self.myBleMananger writePeripheralShakeWhenUnconnectWithOforOff:[[NSUserDefaults standardUserDefaults] boolForKey:LOST_SETTING]];
        }else {
            [self.myBleMananger writePeripheralShakeWhenUnconnectWithOforOff:NO];
        }
        
        /** 同步闹钟提醒 */
        [self writeClockReminder];
        /** 同步亮度调节 */
        [self.myBleMananger writeDimmingToPeripheral:[[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] ? [[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING] : 90];
        /** 同步单位设置 */
        [self writeUnitsSetting];
        /** 同步时间格式设置 */
        [self writeTimeFormatterSetting];
        /** 同步计步目标 */
        [self writeStepTargetSetting];
        /** 同步用户信息设置 */
        [self writeUserInfoSetting];
        /** 同步电话短信配对提醒（暂时不同步电话和短信的设置） */
//        [self pairPhoneAndMessage];
    });
}

/**
 SET_TIME,
 SET_FIRMWARE,
 SET_WINDOW,
 GET_SEDENTARY_DATA,
 LOST_PERIPHERAL_SWITCH,
 SET_CLOCK,
 SET_UNITS_DATA,
 SET_TIME_FORMATTER,
 SET_MOTION_TARGET,
 SET_USER_INFO;
 */

- (void)setNotificationObserver:(NSNotification *)noti
{
    NSLog(@"asynCount == %ld noti.name == %@",_asynCount ,noti.name);
    
    if ([noti.name isEqualToString:SET_TIME] ||
        [noti.name isEqualToString:SET_WINDOW] ||
        [noti.name isEqualToString:GET_SEDENTARY_DATA] ||
        [noti.name isEqualToString:LOST_PERIPHERAL_SWITCH] ||
        [noti.name isEqualToString:SET_UNITS_DATA] ||
        [noti.name isEqualToString:SET_TIME_FORMATTER] ||
        [noti.name isEqualToString:SET_MOTION_TARGET] ||
        [noti.name isEqualToString:SET_USER_INFO]) {
        BOOL isFirst = noti.userInfo[@"success"];
        if (isFirst == 1)
        {
            _asynCount ++;
        }
            else [self asynFail];
    }else if ([noti.name isEqualToString:SET_FIRMWARE]) {
        // 版本号,电量,亮度
        manridyModel *model = [noti object];
        if (model.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            if (model.receiveDataType == ReturnModelTypeFirwmave) {
                switch (model.firmwareModel.mode) {
                    case FirmwareModeGetVersion:
                        //版本号
                        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.version forKey:HARDWARE_VERSION];
                        break;
                    case FirmwareModeGetElectricity:
                        //电量
                        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.PerElectricity forKey:ELECTRICITY_INFO_SETTING];
                        break;
                        
                    default:
                        break;
                }
            }
            _asynCount ++;
        }else [self asynFail];
    }else if ([noti.name isEqualToString:SET_CLOCK]) {
        manridyModel *model = [noti object];
        if (model.isReciveDataRight == ResponsEcorrectnessDataRgith) _asynCount ++;
        else [self asynFail];
    }
    if (_asynCount == 12) {
        self.hud.label.text = @"同步完成";
        [self.hud hideAnimated:YES afterDelay:1.5];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)asynFail
{
    self.hud.label.text = @"同步失败";
    [self.hud hideAnimated:YES afterDelay:1.5];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bindcell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bindcell"];
    }
    BleDevice *device = _dataArr[indexPath.row];
    
    cell.textLabel.text = device.deviceName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!_isConnected) {
        index = indexPath.row;
//    }
}

#pragma mark - BleDiscoverDelegate
- (void)manridyBLEDidDiscoverDeviceWithMAC:(BleDevice *)device
{
    if (![_dataArr containsObject:device]) {
        [_dataArr addObject:device];
        
        if (QRMacAddress.length > 0) {
            [QRMacAddress isEqualToString:device.macAddress] ? [self.myBleMananger connectDevice:device] : NSLog(@"不匹配");
        }
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count - 1 inSection:0];
        [indexPaths addObject: indexPath];
        [self.peripheralList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - BleConnectDelegate
//这里我使用peripheral.identifier作为设备的唯一标识，没有使用mac地址，如果出现id变化导致无法连接的情况，请转成用mac地址作为唯一标识。
- (void)manridyBLEDidConnectDevice:(BleDevice *)device
{
    //同步设置条数初始化为0
    _asynCount = 0;
    self.hud.label.text = @"正在同步设置";
    [self synchronizeSettings];
    [self.myBleMananger stopScan];
    
    [[NSUserDefaults standardUserDefaults] setValue:device.peripheral.identifier.UUIDString forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:device.deviceName forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBind"];
    
    /** 修改状态栏的文本,隐藏二维码扫描,修改连接状态图,隐藏设备列表 */
    [self setBindView];
    self.connectToast = [[MDToast alloc] initWithText:[NSString stringWithFormat:@"已绑定设备:%@", device.deviceName] duration:1];
    [self.connectToast show];
}


- (void)manridyBLEDidFailConnectDevice:(BleDevice *)device
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
//    _isConnected = NO;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"bindErrorAndTryAgain", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
    view.tag = 101;
    [view show];
    
    [self deletAllRowsAtTableView];
    [self.myBleMananger stopScan];
    
    [self.refreshImageView setHidden:NO];
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    index = 0;
}

//#pragma mark - BleReceiveDelegate
//- (void)receiveVersionWithVersionStr:(NSString *)versionStr
//{
//    NSLog(@"固件版本号 == %@",versionStr);
//    [[NSUserDefaults standardUserDefaults] setObject:versionStr forKey:@"version"];
//}
//
//- (void)receiveChangePerNameSuccess:(BOOL)success
//{
//    if (success) {
//        BleDevice *current = self.myBleMananger.currentDev;
//        current.deviceName = self.changeName;
////        _isConnected = NO;
//        self.myBleMananger.isReconnect = NO;
//        [self.myBleMananger unConnectDevice];
//        index = -1;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.myBleMananger connectDevice:current];
//        });
//    }
//}
//
//- (void)receivePairWitheModel:(manridyModel *)manridyModel
//{
//    if (manridyModel.receiveDataType == ReturnModelTypePairSuccess) {
//        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataFail) {
//            if (manridyModel.pairSuccess == NO) {
//                AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:@"配对失败，请重试。" style:UIAlertControllerStyleAlert];
//                [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
//                    //失败了就继续配对
//                    [self pairPhoneAndMessage];
//                }]];
//                [aTool show];
//            }
//        }
//    }
//}

#pragma mark - 懒加载
- (UIImageView *)connectImageView
{
    if (!_connectImageView) {
        UIImageView *view = [[UIImageView alloc] init];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(131);
        }];
        _connectImageView = view;
    }
    
    return _connectImageView;
}

- (UIImageView *)refreshImageView
{
    if (!_refreshImageView) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"devicebinding_refresh"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchPeripheral)];
        [view addGestureRecognizer:tap];
        view.userInteractionEnabled = YES;
        
        [self.downView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.downView.mas_centerX);
            make.centerY.equalTo(self.downView.mas_centerY);
        }];
        _refreshImageView = view;
    }
    
    return _refreshImageView;
}

- (UILabel *)bindStateLabel
{
    if (!_bindStateLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.downView.mas_top).offset(-24);
        }];
        _bindStateLabel = label;
    }
    
    return _bindStateLabel;
}

- (MDButton *)qrCodeButton
{
    if (!_qrCodeButton) {
        _qrCodeButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [_qrCodeButton setImage:[UIImage imageNamed:@"devicebinding_scan"] forState:UIControlStateNormal];
        [_qrCodeButton addTarget:self action:@selector(scanQR:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_qrCodeButton];
        [_qrCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bindStateLabel.mas_centerY);
            make.left.equalTo(self.bindStateLabel.mas_right).offset(8);
        }];
    }
    
    return _qrCodeButton;
}

- (UIView *)downView
{
    if (!_downView) {
        UIView *downView = [[UIView alloc] init];
        downView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:downView];
        [downView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
            make.height.equalTo(@(328 * VIEW_CONTROLLER_FRAME_WIDTH / 360));
        }];
        _downView = downView;
    }
    
    return _downView;
}

- (UITableView *)peripheralList
{
    if (!_peripheralList) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        view.backgroundColor = [UIColor whiteColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.downView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.downView.mas_top);
            make.left.equalTo(self.downView.mas_left);
            make.right.equalTo(self.downView.mas_right);
            make.bottom.equalTo(self.bindButton.mas_top);
        }];
        _peripheralList = view;
    }
    
    return _peripheralList;
}

- (MDButton *)bindButton
{
    if (!_bindButton) {
        MDButton *button = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [button setTitle:NSLocalizedString(@"绑定设备", nil) forState:UIControlStateNormal];
        [button setTitleColor:NAVIGATION_BAR_COLOR forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bindPeripheral:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1;
        button.layer.borderColor = TEXT_BLACK_COLOR_LEVEL1.CGColor;
        [button setBackgroundColor:CLEAR_COLOR];
        button.hidden = YES;
        
        [self.downView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(1);
            make.left.equalTo(self.view.mas_left).offset(-1);
            make.right.equalTo(self.view.mas_right).offset(1);
            make.height.equalTo(@48);
        }];
        _bindButton = button;
    }
    
    return _bindButton;
}

@end
