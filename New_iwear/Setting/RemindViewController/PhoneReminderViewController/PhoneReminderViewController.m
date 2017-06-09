//
//  PhoneReminderViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "PhoneReminderViewController.h"
#import "SedentaryReminderTableViewCell.h"

static NSString * const PhoneReminderTableViewCellID = @"PhoneReminderTableViewCell";

@interface PhoneReminderViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation PhoneReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电话提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(savePhoneAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
    
    UIView *headView = [UIView new];
    headView.backgroundColor =  self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(64);
        make.bottom.equalTo(self.view.mas_bottom).offset(-250);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [headImageView setImage:[UIImage imageNamed:@"call-reminder_pic"]];
    [headView addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView.mas_centerX);
        make.centerY.equalTo(headView.mas_centerY);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    [tipLabel setText:@"请保持蓝牙开启，并且手环与手机保持连接"];
    [tipLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [headView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView.mas_centerX);
        make.bottom.equalTo(headView.mas_bottom).offset(-17);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(headView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
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

- (void)savePhoneAction
{
    [self.hud showAnimated:YES];
    BOOL message = [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING];
    BOOL phone = ((SedentaryReminderModel *)self.dataArr.firstObject).switchIsOpen;
    Remind *model = [[Remind alloc] init];
    model.phone = phone;
    model.message = message;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(setPairNoti:) name:GET_PAIR object:nil];
    [[BleManager shareInstance] writePhoneAndMessageRemindToPeripheral:model];
}

- (void)setPairNoti:(NSNotification *)noti
{
    [self.hud hideAnimated:YES];
    manridyModel *model = [noti object];
    if (model.isReciveDataRight) {
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
        [sucToast show];
        //保存选项至本地
        [[NSUserDefaults standardUserDefaults] setBool:((SedentaryReminderModel *)self.dataArr.firstObject).switchIsOpen forKey:PHONE_SWITCH_SETTING];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        if (model.pairSuccess) {
            MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
            [sucToast show];
            //保存选项至本地
            [[NSUserDefaults standardUserDefaults] setBool:((SedentaryReminderModel *)self.dataArr.firstObject).switchIsOpen forKey:PHONE_SWITCH_SETTING];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            MDToast *sucToast = [[MDToast alloc] initWithText:@"配对失败，请配对设备，否则无法使用该功能" duration:3];
            [sucToast show];
        }
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
    SedentaryReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PhoneReminderTableViewCellID];
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
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *lineView = [UIView new];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    
    return lineView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(@"SedentaryReminderTableViewCell") forCellReuseIdentifier:PhoneReminderTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = nil;
        /** 偏移掉表头的 64 个像素 */
        _tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
        
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
        model.title = @"开启来电提醒";
        model.switchIsOpen = NO;
        model.whetherHaveSwitch = YES;
        model.subTitle = @"手机来电时，手表会振动提醒";
        _dataArr = @[model];
    }
    
    return _dataArr;
}

- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    
    return _hud;
}

@end
