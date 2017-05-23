//
//  LoseReminderViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "LoseReminderViewController.h"
#import "SedentaryReminderTableViewCell.h"

static NSString * const LoseReminderTableViewCellID = @"LoseReminderTableViewCell";

@interface LoseReminderViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation LoseReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"防丢提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveLoseAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveLoseAction
{
    [self.hud showAnimated:YES];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(setPairNoti:) name:GET_PAIR object:nil];
    [[BleManager shareInstance] writePeripheralShakeWhenUnconnectWithOforOff:((SedentaryReminderModel *)self.dataArr.firstObject).switchIsOpen];
}

- (void)setPairNoti:(NSNotification *)noti
{
    [self.hud hideAnimated:YES];
    manridyModel *model = [noti object];
    if (model.isReciveDataRight) {
        if (model.pairSuccess) {
            MDToast *sucToast = [[MDToast alloc] initWithText:@"配对成功" duration:1.5];
            [sucToast show];
        }else {
            MDToast *sucToast = [[MDToast alloc] initWithText:@"配对失败，请配对设备，否则无法使用该功能" duration:3];
            [sucToast show];
        }
    }else {
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存失败" duration:1.5];
        [sucToast show];
    }
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SedentaryReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoseReminderTableViewCellID];
    
    SedentaryReminderModel *model = self.dataArr[indexPath.row];
    cell.switchChangeBlock = ^{
        model.switchIsOpen = !model.switchIsOpen;
        [tableView reloadData];
    };
    
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *lineView = [UIView new];
//    lineView.backgroundColor = CLEAR_COLOR;
//    
//    return lineView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 8;
//}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(@"SedentaryReminderTableViewCell") forCellReuseIdentifier:LoseReminderTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = nil;
        /** 偏移掉表头的 64 个像素 */
        //_tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        SedentaryReminderModel *model = [[SedentaryReminderModel alloc] init];
        model.title = @"开启防丢提醒";
        model.switchIsOpen = YES;
        model.whetherHaveSwitch = YES;
        model.subTitle = @"连接断开时振动";
        _dataArr = @[model];
    }
    
    return _dataArr;
}

@end
