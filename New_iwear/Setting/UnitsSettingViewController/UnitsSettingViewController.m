//
//  UnitsSettingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "UnitsSettingViewController.h"
#import "UnitsSettingTableViewCell.h"

static NSString * const UnitsSettingTableViewCellID = @"UnitsSettingTableViewCell";

@interface UnitsSettingViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation UnitsSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"单位设置";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)self.dataArr[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitsSettingTableViewCellID forIndexPath:indexPath];
    NSArray *sectionArr = self.dataArr[indexPath.section];
    cell.model = sectionArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = CLEAR_COLOR;
    UILabel *sectionTitleLabel = [[UILabel alloc] init];
    [sectionTitleLabel setText:section == 0 ? @"长度单位设置" : @"重量单位设置"];
    [sectionTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [sectionTitleLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [headerView addSubview:sectionTitleLabel];
    [sectionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView.mas_left).offset(16);
        make.centerY.equalTo(headerView.mas_centerY).offset(4);
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(UnitsSettingTableViewCellID) forCellReuseIdentifier:UnitsSettingTableViewCellID];
        UIView *footview = [[UIView alloc] init];
        _tableView.tableFooterView = footview;
        _tableView.scrollEnabled = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *sec1 = @[@"公制(米/公里)", @"英制(英寸/英尺/英里)"];
        NSArray *sec2 = @[@"公制(公斤/千克)",@"英制(磅)"];
        NSMutableArray *mutArr1 = [NSMutableArray array];
        NSMutableArray *mutArr2 = [NSMutableArray array];
        for (int index = 0; index < sec1.count; index ++) {
            UnitsSettingModel *model = [[UnitsSettingModel alloc] init];
            model.name = sec1[index];
            model.isSelect = index == 0 ? YES : NO;
            [mutArr1 addObject:model];
        }
        for (int index = 0; index < sec2.count; index ++) {
            UnitsSettingModel *model = [[UnitsSettingModel alloc] init];
            model.name = sec2[index];
            model.isSelect = index == 0 ? YES : NO;
            [mutArr2 addObject:model];
        }
        _dataArr = @[mutArr1, mutArr2];
    }
    
    return _dataArr;
}
@end
