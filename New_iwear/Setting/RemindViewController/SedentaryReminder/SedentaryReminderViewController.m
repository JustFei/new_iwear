//
//  SedentaryReminderViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SedentaryReminderViewController.h"
#import "SedentaryReminderTableViewCell.h"

static NSString *const SedentaryReminderTableViewCellID = @"SedentaryReminderTableViewCell";

@interface SedentaryReminderViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation SedentaryReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"久坐提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
    
    UIView *headView = [UIView new];
    headView.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(64);
        make.bottom.equalTo(self.view.mas_bottom).offset(-250);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [headImageView setImage:[UIImage imageNamed:@""]];
    [headView addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView.mas_centerX);
        make.centerY.equalTo(headView.mas_centerY);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    [tipLabel setText:@"持续一小时静坐，手环会振动提醒"];
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
    SedentaryReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SedentaryReminderTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 3 ? 72 : 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        //do some thing
    }
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
        [_tableView registerClass:NSClassFromString(SedentaryReminderTableViewCellID) forCellReuseIdentifier:SedentaryReminderTableViewCellID];
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
        NSArray *titleArr = @[@"开始久坐提醒", @"开始时间", @"结束时间", @"午休时间"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < titleArr.count; index ++) {
            SedentaryReminderModel *model = [[SedentaryReminderModel alloc] init];
            model.title = titleArr[index];
            if (index == 0 || index == 3) {
                model.switchIsOpen = YES;
                model.whetherHaveSwitch = YES;
                model.subTitle = index == 3 ? @"12:00~14:00不进行提醒" : @"";
            }else {
                model.time = index == 1 ? @"08:30" : @"19:30";
                model.timeState = index == 1 ? @"上午" : @"下午";
                model.whetherHaveSwitch = NO;
            }
            [mutArr addObject:model];
        }
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}
@end
