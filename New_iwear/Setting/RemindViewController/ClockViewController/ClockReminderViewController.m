//
//  ClockViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "ClockReminderViewController.h"
#import "ClockTableViewCell.h"

static NSString *const ClockTableViewCellID = @"ClockTableViewCell";

@interface ClockReminderViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, copy) NSString *selectTime;
@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ClockReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"闹钟提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveClockAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = SETTING_BACKGROUND_COLOR;
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

- (void)saveClockAction
{
    [self.hud showAnimated:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(setClockNoti:) name:SET_CLOCK object:nil];
    [[BleManager shareInstance] writeClockToPeripheral:ClockDataSetClock withClockArr:[NSMutableArray arrayWithArray:self.dataArr]];
}

- (void)setClockNoti:(NSNotification *)noti
{
    [self.hud hideAnimated:YES];
    manridyModel *model = [noti object];
    if (model.isReciveDataRight) {
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
        [sucToast show];
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
    ClockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ClockTableViewCellID];
    
    cell.timeButtonActionBlock = ^{
        [self showTimePickerViewWith:indexPath];
    };
    
    cell.timeSwitchActionBlock = ^{
        [self changeSwitchState:indexPath];
    };
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    UILabel *tipLabel = [[UILabel alloc] init];
    [tipLabel setText:@"你可以设置最多三个闹钟"];
    [tipLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView.mas_left).offset(16);
        make.centerY.equalTo(headerView.mas_centerY).offset(4);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView.mas_left);
        make.right.equalTo(headerView.mas_right);
        make.bottom.equalTo(headerView.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 开关
- (void)changeSwitchState:(NSIndexPath *)indexPath
{
    ClockModel *model = self.dataArr[indexPath.row];
    model.isOpen = !model.isOpen;
    [self.tableView reloadData];
}

#pragma mark - 时间选择器
- (void)showTimePickerViewWith:(NSIndexPath *)indexPath
{
    //    self.title = sender.titleLabel.text;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //初始化 selectTime
        self.selectTime = @"";
    }];
    //修改数据源的数据
    ClockModel *model = self.dataArr[indexPath.row];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        model.time = self.selectTime;
        [self.tableView reloadData];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    //这一步的目的：如果用户没有改变 picker 的值，就直接初始化为 model.time
    self.selectTime = model.time;
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    [self.datePickerView setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    // 设置时区
    [self.datePickerView setTimeZone:[NSTimeZone localTimeZone]];
    // 设置当前显示时间为数据库中的时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [self.datePickerView setDate:[formatter dateFromString:model.time]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [self.datePickerView setLocale:locale];
    // 当值发生改变的时候调用的方法
    [self.datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [alert.view addSubview:self.datePickerView];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    DLog(@"%@",datePicker.date);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.selectTime = [formatter stringFromDate:datePicker.date];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(ClockTableViewCellID) forCellReuseIdentifier:ClockTableViewCellID];
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *timeArr = @[@"08:00", @"08:30", @"09:00", @"09:30", @"10:00"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < timeArr.count; index ++) {
            ClockModel *model = [[ClockModel alloc] init];
            model.time = timeArr[index];
            model.isOpen = NO;
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
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
