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
#import <HealthKit/HealthKit.h>

static NSString *const periperlCellID = @"peripheralCell";
static NSString *const settingCellID = @"settingCell";
static NSString *const settingHeaderID = @"settingHeader";

@interface SettingViewController () < UITableViewDelegate, UITableViewDataSource >
{
    BOOL _isAuthorization;
}
@property (nonatomic, strong) HKHealthStore *hkStore;
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
    
    self.title = @"设置";
    self.navigationController.navigationBar.barTintColor = NAVIGATION_BAR_COLOR;
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.navigationController.view.mas_centerY);
//        make.left.equalTo(self.navigationController.view.mas_left).offset(16);
//        make.width.equalTo(@48);
//        make.height.equalTo(@48);
//    }];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self healthKit];
    self.tableView.backgroundColor = SETTING_BACKGROUND_COLOR;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
        view.backgroundView = backgroundView;
        return view;
    }else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = CLEAR_COLOR;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = TEXT_COLOR_LEVEL1;
        [view addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view.mas_top);
            make.left.equalTo(view.mas_left);
            make.right.equalTo(view.mas_right);
            make.bottom.equalTo(view.mas_top).offset(8);
        }];

        UILabel *functionChooseLabel = [[UILabel alloc] init];
        [functionChooseLabel setText:@"功能设置"];
        [functionChooseLabel setTextColor:TEXT_COLOR_LEVEL3];
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
    
    id pushVC = [[NSClassFromString(self.vcArray[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:pushVC animated:YES];
}

/** 重载 ScrollView 代理方法来让 HeaderView 跟着 tableView 一起滑动 */
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    CGFloat sectionHeaderHeight = 225;
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y> 0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }else{
//        if(scrollView.contentOffset.y >= sectionHeaderHeight){
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}

- (void)healthKit
{
    self.hkStore = [[HKHealthStore alloc] init];
    
    // 查询是否设备是否支持HealthKit框架（官方暂不提供是否授权的接口）
    
    [HKHealthStore isHealthDataAvailable];
    
    // 查询是否支持写入授权（允许返回YES）
    
    switch ([self.hkStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]])
    
    {
            
        case 0:
            
            NSLog(@"用户尚未作出选择，关于是否该应用程序可以保存指定类型的对象");
            
            break;
            
        case 1:
            
            _isAuthorization = NO;
            
            NSLog(@"此应用程序不允许保存指定类型的对象");
            
            break;
            
        case 2:
            
            NSLog(@"此应用程序被授权保存指定类型的对象");
            
            break;
            
        default:
            
            break;
    }
}

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
        model.peripheralName = @"X9Plus";
        model.isBind = YES;
        model.isConnect = YES;
        model.battery = 90;
        _groupFirstDataSourceArr = @[model];
    }
    
    return _groupFirstDataSourceArr;
}

- (NSArray *)groupSecondDataSourceArr
{
    if (!_groupSecondDataSourceArr) {
        NSArray *fucName = @[@"界面选择",@"遥控拍照",@"查找手环",@"提醒功能",@"微信运动",@"亮度调节",@"单位设置",@"时间格式",@"目标设置",@"关于"];
        NSArray *imageName = @[@"set_interface",@"set_camera",@"set_find",@"set_remind",@"set_wechat",@"set_dimming",@"set_unit",@"set_time",@"",@"set_info"];
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
        _vcArray = @[@"InterfaceSelectionViewController", @"TakePhotoViewController", @"FindMyPeriphearlViewController", @"RemindViewController", @"WeChatViewController", @"DimmingViewController", @"UnitsSettingViewController", @"TimeFormatterViewController", @"TargetSettingViewController", @"AboutViewController"];
    }
    
    return _vcArray;
}


@end
