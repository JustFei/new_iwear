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
//#import "FMDBManager.h"

#define WIDTH self.view.frame.size.width

@interface BindPeripheralViewController () <UITableViewDelegate ,UITableViewDataSource ,BleDiscoverDelegate ,BleConnectDelegate ,BleReceiveDelegate ,UIAlertViewDelegate, UITextFieldDelegate>
{
    /** 设备信息数据源 */
    NSMutableArray *_dataArr;
    /** 点击的索引 */
    NSInteger index;
    /** 是否连接 */
//    BOOL _isConnected;
}

@property (nonatomic ,weak) UIView *downView;
@property (nonatomic ,weak) UITableView *peripheralList;
@property (nonatomic ,weak) MDButton *bindButton;
@property (nonatomic ,weak) UIImageView *connectImageView;
@property (nonatomic ,strong) UIImageView *refreshImageView;
@property (nonatomic ,strong) UILabel *bindStateLabel;
@property (nonatomic, strong) MDButton *qrCodeButton;
@property (nonatomic ,strong) BleManager *myBleMananger;
@property (nonatomic ,strong) MBProgressHUD *hud;
@property (nonatomic ,copy) NSString *changeName;
//@property (nonatomic ,strong) FMDBManager *myFmdbTool;

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
    [helpBtn setTitle:@"使用帮助" forState:UIControlStateNormal];
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
    _myBleMananger.receiveDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.naviBarColor) {
        [self.navigationController.navigationBar setBackgroundColor:self.naviBarColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            /** 解除绑定的UI */
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//            [self.bindStateLabel setText:@"未绑定设备"];
//            self.qrCodeButton.hidden = NO;
//            self.refreshImageView.hidden = NO;
//            [sender setTitle:@"绑定设备" forState:UIControlStateNormal];
//            sender.hidden = YES;
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

- (void)qrAction:(MDButton *)sender
{
    
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"]) {
        rem.phone = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"];
        rem.message = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"];
        [self.myBleMananger writePhoneAndMessageRemindToPeripheral:rem];
    }
}

- (void)synchronizeSettings
{
    //写入电话短信配对提醒
    [self pairPhoneAndMessage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]) {
            //写入防丢提醒
            [self.myBleMananger writePeripheralShakeWhenUnconnectWithOforOff:[[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]];
        }else {
            [self.myBleMananger writePeripheralShakeWhenUnconnectWithOforOff:NO];   //防丢置为NO，类似初始化
        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//            SedentaryModel *model = [self.myFmdbTool querySedentary].firstObject;
//            if (model) {
//                //写入久坐提醒
//                [self.myBleMananger writeSedentaryAlertWithSedentaryModel:model];
//            }else {
//                model.sedentaryAlert = NO;
//                model.unDisturb = NO;
//                model.disturbStartTime = @"12:00";
//                model.disturbEndTime = @"14:00";
//                model.sedentaryStartTime = @"09:00";
//                model.sedentaryEndTime = @"18:00";
//                model.stepInterval = 100;
//                //写入久坐提醒
//                [self.myBleMananger writeSedentaryAlertWithSedentaryModel:model];
//            }
//            
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                NSMutableArray *clockArr = [self.myFmdbTool queryClockData];
//                if (clockArr.count != 0) {
//                    //写入闹钟数据
//                    [self.myBleMananger writeClockToPeripheral:ClockDataSetClock withClockArr:clockArr];
//                }else {
//                    ClockModel *model = [[ClockModel alloc] init];
//                    for (NSInteger i = 0; i < 3; i ++) {
//                        model.ID = i;
//                        model.time = @"08:00";
//                        model.isOpen = NO;
//                        [clockArr addObject:model];
//                    }
//                    //写入闹钟数据
//                    [self.myBleMananger writeClockToPeripheral:ClockDataSetClock withClockArr:clockArr];
//                }
//                
//            });
//        });
    });
    
    [self.myBleMananger writeTimeToPeripheral:[NSDate date]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.myBleMananger writeRequestVersion];
    });
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
    [self.hud hideAnimated:YES];
    [self.myBleMananger stopScan];
    
    [[NSUserDefaults standardUserDefaults] setValue:device.peripheral.identifier.UUIDString forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:device.deviceName forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBind"];
    
    /** 修改状态栏的文本,隐藏二维码扫描,修改连接状态图,隐藏设备列表 */
//    [self.bindStateLabel setText:device.deviceName];
//    self.qrCodeButton.hidden = YES;
//    self.peripheralList.hidden = YES;
//    [self.bindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
//    [self.connectImageView setImage:[UIImage imageNamed:@"devicebinding_pic01_connect"]];
    [self setBindView];
    MDToast *connectToast = [[MDToast alloc] initWithText:[NSString stringWithFormat:@"已绑定设备:%@", device.deviceName] duration:1];
    [connectToast show];
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

#pragma mark - BleReceiveDelegate
- (void)receiveVersionWithVersionStr:(NSString *)versionStr
{
    DLog(@"固件版本号 == %@",versionStr);
    [[NSUserDefaults standardUserDefaults] setObject:versionStr forKey:@"version"];
}

- (void)receiveChangePerNameSuccess:(BOOL)success
{
    if (success) {
        BleDevice *current = self.myBleMananger.currentDev;
        current.deviceName = self.changeName;
//        _isConnected = NO;
        self.myBleMananger.isReconnect = NO;
        [self.myBleMananger unConnectDevice];
        index = -1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.myBleMananger connectDevice:current];
        });
    }
}

- (void)receivePairWitheModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypePairSuccess) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataFail) {
            if (manridyModel.pairSuccess == NO) {
                AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:@"配对失败，请重试。" style:UIAlertControllerStyleAlert];
                [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
                    //失败了就继续配对
                    [self pairPhoneAndMessage];
                }]];
                [aTool show];
            }
        }
    }
}

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
        [_qrCodeButton addTarget:self action:@selector(qrAction:) forControlEvents:UIControlEventTouchUpInside];
        
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

//- (FMDBTool *)myFmdbTool
//{
//    if (!_myFmdbTool) {
//        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
//    }
//    return _myFmdbTool;
//}

@end
