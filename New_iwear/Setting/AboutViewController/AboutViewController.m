//
//  AboutViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableViewCell.h"

static NSString * const AboutTableViewCellID = @"AboutTableViewCell";

@interface AboutViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"about", nil);
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    self.tableView.backgroundColor = SETTING_BACKGROUND_COLOR;
    
    UIView *headView = [UIView new];
    headView.backgroundColor = WHITE_COLOR;
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(64);
        make.height.equalTo(@(232 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [nameLabel setText:@"iband"];
    [headView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headView.mas_bottom).offset(-16);
        make.centerX.equalTo(headView.mas_centerX);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_pic01"]];
    [headView addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView.mas_centerX);
        make.bottom.equalTo(nameLabel.mas_top).offset(-16);
    }];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [headView addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(headView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
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
    AboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AboutTableViewCellID];
    
    cell.nameLabel.text = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id pushVC = [[NSClassFromString(self.vcArr[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:pushVC animated:YES];
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
        [_tableView registerClass:NSClassFromString(AboutTableViewCellID) forCellReuseIdentifier:AboutTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
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
        _dataArr = @[NSLocalizedString(@"checkUpdate", nil)
//                     @"使用帮助",
//                     @"关于我们"
                     ];
    }
    
    return _dataArr;
}

- (NSArray *)vcArr
{
    if (!_vcArr) {
        _vcArr = @[@"VersionUpdateViewController",@"",@""];
    }
    
    return _vcArr;
}

@end
