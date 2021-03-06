//
//  SettingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/2.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingPeripheralTableViewCell.h"
#import "SettingTableViewCell.h"
#import "SettingHeaderView.h"
//#import <HealthKit/HealthKit.h>

static NSString *const periperlCellID = @"peripheralCell";
static NSString *const settingCellID = @"settingCell";
static NSString *const settingHeaderID = @"settingHeader";

@interface SettingViewController () < UITableViewDelegate, UITableViewDataSource >
{
    BOOL _isAuthorization;
}
//@property (nonatomic, strong) HKHealthStore *hkStore;
@property (nonatomic, strong) UITableView *tableView;
/** 第一组 cell 的数据源 */
@property (nonatomic, strong) NSArray *groupFirstDataSourceArr;
/** 第二组 cell 的数据源 */
@property (nonatomic, strong) NSArray *groupSecondDataSourceArr;
/** 跳转控制器的名字 */
@property (nonatomic, strong) NSArray *vcArray;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"setting", nil);
    
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    [[BleManager shareInstance] writeGetElectricity];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getElectricity:) name:SET_FIRMWARE object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self.navigationController.navigationBar setBackgroundColor:self.naviBarColor];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //移除 tableview，在 viewWillAppear 中重新创建
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    self.groupFirstDataSourceArr = nil;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getElectricity:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.firmwareModel.mode == FirmwareModeGetElectricity) {
        //电量
        [[NSUserDefaults standardUserDefaults] setObject:model.firmwareModel.PerElectricity forKey:ELECTRICITY_INFO_SETTING];
        self.groupFirstDataSourceArr = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.groupFirstDataSourceArr.count : self.groupSecondDataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SettingPeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:periperlCellID];
        cell.peripheralModel = self.groupFirstDataSourceArr[indexPath.row];
        return cell;
    }else {
        SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCellID];
        cell.model = self.groupSecondDataSourceArr[indexPath.row];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 72;
    }else {
        return 48;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        SettingHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:settingHeaderID];
        /** 这种方法可以改变 HeaderView 的背景颜色 */
        UIView *backgroundView = [[UIView alloc] initWithFrame:view.bounds];
        backgroundView.backgroundColor = SETTING_BACKGROUND_COLOR;
        view.userInfoButtonClickBlock = ^ {
            id pushVC = [[NSClassFromString(@"UserInfoViewController") alloc] init];
            [self.navigationController pushViewController:pushVC animated:YES];
        };
        view.backgroundView = backgroundView;
        return view;
    }else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = CLEAR_COLOR;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
        [view addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view.mas_top);
            make.left.equalTo(view.mas_left);
            make.right.equalTo(view.mas_right);
            make.bottom.equalTo(view.mas_top).offset(8);
        }];

        UILabel *functionChooseLabel = [[UILabel alloc] init];
        [functionChooseLabel setText:NSLocalizedString(@"funSetting", nil)];
        [functionChooseLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [functionChooseLabel setFont:[UIFont systemFontOfSize:14]];
        [view addSubview:functionChooseLabel];
        [functionChooseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(16);
            make.centerY.equalTo(view.mas_centerY).offset(4);
        }];
        
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 225;
    }else {
        return 56;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        id pushVC = [[NSClassFromString(@"BindPeripheralViewController") alloc] init];
        [self.navigationController pushViewController:pushVC animated:YES];
    }else if (indexPath.section == 1) {
        id pushVC = [[NSClassFromString(self.vcArray[indexPath.row]) alloc] init];
        [self.navigationController pushViewController:pushVC animated:YES];
    }
    
}

//- (void)healthKit
//{
//    self.hkStore = [[HKHealthStore alloc] init];
//    
//    // 查询是否设备是否支持HealthKit框架（官方暂不提供是否授权的接口）
//    
//    [HKHealthStore isHealthDataAvailable];
//    
//    // 查询是否支持写入授权（允许返回YES）
//    
//    switch ([self.hkStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]])
//    
//    {
//            
//        case 0:
//            
//            NSLog(@"用户尚未作出选择，关于是否该应用程序可以保存指定类型的对象");
//            
//            break;
//            
//        case 1:
//            
//            _isAuthorization = NO;
//            
//            NSLog(@"此应用程序不允许保存指定类型的对象");
//            
//            break;
//            
//        case 2:
//            
//            NSLog(@"此应用程序被授权保存指定类型的对象");
//            
//            break;
//            
//        default:
//            
//            break;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT - 64) style:UITableViewStyleGrouped];
        /** 注册 cell 和 headerView */
        [_tableView registerNib:[UINib nibWithNibName:@"SettingPeripheralTableViewCell" bundle:nil] forCellReuseIdentifier:periperlCellID];
        [_tableView registerNib:[UINib nibWithNibName:@"SettingTableViewCell" bundle:nil] forCellReuseIdentifier:settingCellID];
        [_tableView registerClass:NSClassFromString(@"SettingHeaderView") forHeaderFooterViewReuseIdentifier:settingHeaderID];
        
        /** 偏移掉表头的 64 个像素 */
        _tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
        _tableView.backgroundColor = CLEAR_COLOR;
        _tableView.backgroundColor = SETTING_BACKGROUND_COLOR;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsMultipleSelection = NO;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)groupFirstDataSourceArr
{
    if (!_groupFirstDataSourceArr) {
        PeripheralCellModel *model = [[PeripheralCellModel alloc] init];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"]) {
            model.isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
            model.peripheralName = [[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralName"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralName"] : NSLocalizedString(@"notBindPer", nil);
            model.isConnect = [BleManager shareInstance].connectState == kBLEstateDidConnected ? YES : NO;
            model.battery = [[NSUserDefaults standardUserDefaults] objectForKey:ELECTRICITY_INFO_SETTING] ? [[NSUserDefaults standardUserDefaults] objectForKey:ELECTRICITY_INFO_SETTING] : @"--";
        }else {
            model.isBind = NO;
        }
        
        _groupFirstDataSourceArr = @[model];
    }
    
    return _groupFirstDataSourceArr;
}

- (NSArray *)groupSecondDataSourceArr
{
    if (!_groupSecondDataSourceArr) {
        NSArray *fucName = @[NSLocalizedString(@"interfaceSelect", nil),NSLocalizedString(@"RemoteControlCamera", nil),NSLocalizedString(@"searchPer", nil),NSLocalizedString(@"remindFunc", nil),
//                             @"微信运动",
                             NSLocalizedString(@"wrist", nil),NSLocalizedString(@"dimmingSetting", nil),NSLocalizedString(@"unitSetting", nil),NSLocalizedString(@"timeFormatter", nil),NSLocalizedString(@"targetSetting", nil),NSLocalizedString(@"about", nil)];
        NSArray *imageName = @[@"set_interface",@"set_camera",@"set_find",@"set_phone",
//                               @"set_wechat",
                               @"set_wrist",@"set_dimming",@"set_unit",@"set_time",@"set_targetsetting",@"set_info"];
        NSMutableArray *dataArr = [NSMutableArray array];
        for (int i = 0; i < fucName.count; i ++) {
            SettingCellModel *model = [[SettingCellModel alloc] init];
            model.fucName = fucName[i];
            model.headImageName = imageName[i];
            [dataArr addObject:model];
        }
        _groupSecondDataSourceArr = [NSArray arrayWithArray:dataArr];
    }
    
    return _groupSecondDataSourceArr;
}

- (NSArray *)vcArray
{
    if (!_vcArray) {
        _vcArray = @[@"InterfaceSelectionViewController", @"TakePhotoViewController", @"FindMyPeriphearlViewController", @"RemindViewController",
//                     @"WeChatViewController",
                     @"WristViewController",@"DimmingViewController", @"UnitsSettingViewController", @"TimeFormatterViewController", @"TargetSettingViewController", @"AboutViewController"];
    }
    
    return _vcArray;
}


@end
