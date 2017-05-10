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
    NSMutableArray *_dataArr;
    NSInteger index;
    BOOL _isConnected;
}

@property (nonatomic ,weak) UIView *downView;
@property (nonatomic ,weak) UITableView *peripheralList;
@property (nonatomic ,weak) UIButton *bindButton;
@property (nonatomic ,weak) UIButton *disbindButton;
@property (nonatomic ,strong) UIImageView *lockImageView;
@property (nonatomic ,weak) UIImageView *connectImageView;
@property (nonatomic ,strong) UIImageView *refreshImageView;
@property (nonatomic ,strong) UILabel *bindStateLabel;
@property (nonatomic ,strong) UILabel *perNameLabel;
@property (nonatomic ,strong) BleManager *myBleTool;
@property (nonatomic ,strong) MBProgressHUD *hud;
@property (nonatomic ,copy) NSString *changeName;
//@property (nonatomic ,strong) FMDBManager *myFmdbTool;

@end

@implementation BindPeripheralViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view layoutIfNeeded];
    
    _dataArr = [NSMutableArray array];
    
    index = -1;
    
    self.myBleTool = [BleManager shareInstance];
    self.myBleTool.discoverDelegate = self;
    self.myBleTool.connectDelegate = self;
    self.myBleTool.receiveDelegate = self;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"搜索", nil) style:UIBarButtonItemStylePlain target:self action:@selector(searchPeripheral)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    BOOL isBinded = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    if (isBinded) {
        [self createBindView];
    }else {
       [self creatUnBindView];
    }
    
    self.title = @"设备绑定";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = NAVIGATION_BAR_COLOR;
    
    UIImageView *bluetoothImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 80, WIDTH * 120 / 320, 30, 46)];
    [self.view addSubview:bluetoothImageView];
    [bluetoothImageView setImage:[UIImage imageNamed:@"ble_icon"]];
    
    self.lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x + 50, WIDTH * 120 / 320, 30, 46)];
    [self.view addSubview:self.lockImageView];
    [self.lockImageView setImage:[UIImage imageNamed:@"ble_lock_oper"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, WIDTH * 261 / 320, WIDTH, 8 * WIDTH / 320)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBindView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.connectImageView setImage:[UIImage imageNamed:@"ble_connect"]];
    
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    [self.refreshImageView setHidden:YES];
    
    [self.bindStateLabel setText:NSLocalizedString(@"haveBindPer", nil)];
    
    [self.perNameLabel setHidden:NO];
    [self.perNameLabel setAlpha:0.5];
    [self.perNameLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralName"]];
    
    [self.disbindButton setHidden:NO];
    [self.disbindButton setAlpha:1];
}

- (void)creatUnBindView
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.connectImageView setImage: [UIImage imageNamed:@"ble_break_icon"]];
    
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    [self.refreshImageView setHidden:NO];
    
    [self.bindStateLabel setText:@"未绑定设备"];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchPeripheral
{
    index = -1;
    
    [self deletAllRowsAtTableView];
    
    [self.myBleTool scanDevice];
    
    [self.peripheralList setHidden:NO];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.refreshImageView.alpha = 0;
        [self.refreshImageView setHidden:YES];
        
        [self.bindButton setHidden:NO];
        self.bindButton.alpha = 1;
    }];
}

- (void)bindPeripheral
{
    if (index != -1) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        BleDevice *device = _dataArr[index];
        [self.myBleTool connectDevice:device];
        self.myBleTool.isReconnect = YES;
        _isConnected = YES;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        [self.hud.label setText:NSLocalizedString(@"bindingPer", nil)];
    }else {
        AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"choosePerToBind", nil) style:UIAlertControllerStyleAlert];
        [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"goToChoose", nil) style:AlertToolStyleDefault handler:nil]];
        [aTool show];

    }
}

- (void)disbindPeripheral
{
    _isConnected = NO;
    self.myBleTool.isReconnect = NO;
    [self.myBleTool unConnectDevice];
    index = -1;
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"peripheralUUID"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBind"];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"disbindPerSuccess", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"IKnow", nil) otherButtonTitles:nil, nil];
    view.tag = 102;
    [view show];
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

- (void)pairPhoneAndMessage
{
    //同步提醒设置
    Remind *rem = [[Remind alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"]) {
        rem.phone = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"];
        rem.message = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"];
        [self.myBleTool writePhoneAndMessageRemindToPeripheral:rem];
    }
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
    if (!_isConnected) {
        index = indexPath.row;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
        {
            [self deletAllRowsAtTableView];
            [self.peripheralList setHidden:YES];
            
            [UIView animateWithDuration:1 animations:^{
                [self.disbindButton setHidden:NO];
                self.disbindButton.alpha = 1;
               
                self.bindButton.alpha = 0;
                [self.bindButton setHidden:YES];
                
                [self.perNameLabel setHidden:NO];
                [self.perNameLabel setText:self.myBleTool.currentDev.deviceName];
                [self.perNameLabel setAlpha:1];
                
                [self.bindStateLabel setText:NSLocalizedString(@"haveBindPer", nil)];
                
                [self.connectImageView setImage:[UIImage imageNamed:@"ble_connect"]];
            }];
            
            
        }
            break;
        case 101:
        {
            [self deletAllRowsAtTableView];
            [self.peripheralList setHidden:YES];
            
            [UIView animateWithDuration:1 animations:^{
                [self.refreshImageView setHidden:NO];
                
                self.bindButton.alpha = 0;
                [self.bindButton setHidden:YES];
            }];
        }
            break;
        case 102:
        {
            if (!_isConnected) {
                [self deletAllRowsAtTableView];
                [self.peripheralList setHidden:YES];
                
                [UIView animateWithDuration:1 animations:^{
                    self.disbindButton.alpha = 0;
                    [self.disbindButton setHidden:YES];
                    
                    self.refreshImageView.alpha = 1;
                    [self.refreshImageView setHidden:NO];
                    
                    self.bindButton.alpha = 0;
                    [self.bindButton setHidden:YES];
                    
                    self.perNameLabel.alpha = 0;
                    [self.perNameLabel setHidden:YES];
                    
                    [self.bindStateLabel setText:NSLocalizedString(@"haveNoBindPer", nil)];
                    
                    [self.connectImageView setImage:[UIImage imageNamed:@"ble_break_icon"]];
                }];
            }else {
                [self.myBleTool connectDevice:self.myBleTool.currentDev];
            }
        }
            break;
        case 103:
        {
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                if ([alertView textFieldAtIndex:0].text.length != 0) {
                    //改名字
                    self.changeName = [alertView textFieldAtIndex:0].text;
                    NSString *name_utf_8 =  [[[alertView textFieldAtIndex:0].text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    if (name_utf_8.length >30) {
                        self.hud.mode = MBProgressHUDModeText;
                        self.hud.label.text = @"名字长度过长";
                        [self.hud showAnimated:YES];
                        [self.hud hideAnimated:YES afterDelay:2];
                    }else {
                        [self.myBleTool writePeripheralNameWithNameString:name_utf_8];
                    }
                }
            }
        }
        default:
            break;
    }
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
    
    [self.myBleTool stopScan];
    
    [[NSUserDefaults standardUserDefaults] setValue:device.peripheral.identifier.UUIDString forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:device.deviceName forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBind"];
    
    //写入电话短信配对提醒
    [self pairPhoneAndMessage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]) {
            //写入防丢提醒
            [self.myBleTool writePeripheralShakeWhenUnconnectWithOforOff:[[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]];
        }else {
            [self.myBleTool writePeripheralShakeWhenUnconnectWithOforOff:NO];   //防丢置为NO，类似初始化
        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//            SedentaryModel *model = [self.myFmdbTool querySedentary].firstObject;
//            if (model) {
//                //写入久坐提醒
//                [self.myBleTool writeSedentaryAlertWithSedentaryModel:model];
//            }else {
//                model.sedentaryAlert = NO;
//                model.unDisturb = NO;
//                model.disturbStartTime = @"12:00";
//                model.disturbEndTime = @"14:00";
//                model.sedentaryStartTime = @"09:00";
//                model.sedentaryEndTime = @"18:00";
//                model.stepInterval = 100;
//                //写入久坐提醒
//                [self.myBleTool writeSedentaryAlertWithSedentaryModel:model];
//            }
//            
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                NSMutableArray *clockArr = [self.myFmdbTool queryClockData];
//                if (clockArr.count != 0) {
//                    //写入闹钟数据
//                    [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:clockArr];
//                }else {
//                    ClockModel *model = [[ClockModel alloc] init];
//                    for (NSInteger i = 0; i < 3; i ++) {
//                        model.ID = i;
//                        model.time = @"08:00";
//                        model.isOpen = NO;
//                        [clockArr addObject:model];
//                    }
//                    //写入闹钟数据
//                    [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:clockArr];
//                }
//                
//            });
//        });
    });
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:[NSString stringWithFormat:NSLocalizedString(@"haveBindPerName", nil),device.deviceName] delegate:self cancelButtonTitle:NSLocalizedString(@"IKnow", nil) otherButtonTitles:nil, nil];
    view.tag = 100;
    [view show];
    
    [self.myBleTool writeTimeToPeripheral:[NSDate date]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.myBleTool writeRequestVersion];
    });
}


- (void)manridyBLEDidFailConnectDevice:(BleDevice *)device
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _isConnected = NO;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"bindErrorAndTryAgain", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
    view.tag = 101;
    [view show];
    
    [self deletAllRowsAtTableView];
    [self.myBleTool stopScan];
    
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
        BleDevice *current = self.myBleTool.currentDev;
        current.deviceName = self.changeName;
        _isConnected = NO;
        self.myBleTool.isReconnect = NO;
        [self.myBleTool unConnectDevice];
        index = -1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.myBleTool connectDevice:current];
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
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 25, WIDTH * 136.5 / 320, 50, 13)];
        [self.view addSubview:view];
        _connectImageView = view;
    }
    
    return _connectImageView;
}

- (UIImageView *)refreshImageView
{
    if (!_refreshImageView) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.downView.center.x - 44, 100, 88, 78.5)];
        [view setImage:[UIImage imageNamed:@"ble_refresh"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchPeripheral)];
        [view addGestureRecognizer:tap];
        view.userInteractionEnabled = YES;
        
        [self.downView addSubview:view];
        _refreshImageView = view;
    }
    
    return _refreshImageView;
}

- (UILabel *)bindStateLabel
{
    if (!_bindStateLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, WIDTH * 190 / 320, 200, 19)];
        [label setTextColor:[UIColor colorWithWhite:1 alpha:0.4]];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        _bindStateLabel = label;
    }
    
    return _bindStateLabel;
}

- (UILabel *)perNameLabel
{
    if (!_perNameLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, WIDTH * 220 / 320, 200, 19)];
        label.alpha = 0;
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changePeripheralName:)];
        lp.minimumPressDuration = 3.0;
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:lp];
        
        [label setTextColor:[UIColor colorWithWhite:1 alpha:0.4]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setHidden:YES];
        
        [self.view addSubview:label];
        _perNameLabel = label;
    }
    
    return _perNameLabel;
}

- (UIView *)downView
{
    if (!_downView) {
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, WIDTH * 269 / 320, WIDTH, self.view.frame.size.height - (WIDTH * 269 / 320))];
        downView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:downView];
        _downView = downView;
    }
    
    return _downView;
}

- (UITableView *)peripheralList
{
    if (!_peripheralList) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, self.downView.frame.size.height - 21 - 50) style:UITableViewStylePlain];
        view.backgroundColor = [UIColor whiteColor];
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.downView addSubview:view];
        _peripheralList = view;
    }
    
    return _peripheralList;
}

- (UIButton *)bindButton
{
    if (!_bindButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.downView.center.x - 90, self.downView.frame.size.height - 21 - 47, 180, 47)];
        [button setTitle:NSLocalizedString(@"bindPer", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bindPeripheral) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0;
        
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self.downView addSubview:button];
        _bindButton = button;
    }
    
    return _bindButton;
}

- (UIButton *)disbindButton
{
    if (!_disbindButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.downView.center.x - 90 * WIDTH / 320, self.downView.frame.size.width * 18 / 320, WIDTH * 180 / 320, WIDTH * 47 / 320)];
        [button setTitle:NSLocalizedString(@"disbindPer", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(disbindPeripheral) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0;
        
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self.downView addSubview:button];
        _disbindButton = button;
    }
    
    return _disbindButton;
}

//- (FMDBTool *)myFmdbTool
//{
//    if (!_myFmdbTool) {
//        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
//    }
//    return _myFmdbTool;
//}

@end