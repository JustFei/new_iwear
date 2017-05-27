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
@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, copy) NSString *selectTime;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SedentaryReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"久坐提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    [headImageView setImage:[UIImage imageNamed:@"sit_alarm"]];
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

/**
 @property (nonatomic ,assign) BOOL sedentaryAlert;
 @property (nonatomic ,assign) BOOL unDisturb;
 @property (nonatomic ,assign) int timeInterval;
 @property (nonatomic ,copy) NSString *disturbStartTime;
 @property (nonatomic ,copy) NSString *disturbEndTime;
 @property (nonatomic ,copy) NSString *sedentaryStartTime;
 @property (nonatomic ,copy) NSString *sedentaryEndTime;
 @property (nonatomic ,assign) int stepInterval;
 */
- (void)saveAction
{
    [self.hud showAnimated:YES];
    SedentaryModel *sedModel = [[SedentaryModel alloc] init];
    //久坐是否开启
    sedModel.sedentaryAlert = ((SedentaryReminderModel *)self.dataArr[0]).switchIsOpen;
    //勿扰是否开启
    sedModel.unDisturb = ((SedentaryReminderModel *)self.dataArr[3]).switchIsOpen;
    //开始时间
    sedModel.sedentaryStartTime = ((SedentaryReminderModel *)self.dataArr[1]).time;
    //结束时间
    sedModel.sedentaryEndTime = ((SedentaryReminderModel *)self.dataArr[2]).time;
    //勿扰开始时间
    sedModel.disturbStartTime = @"12:00";
    //勿扰结束时间
    sedModel.disturbEndTime = @"14:00";
    //步数设置
    sedModel.stepInterval = 50;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(weatheSuccess:) name:GET_SEDENTARY_DATA object:nil];
    [[BleManager shareInstance] writeSedentaryAlertWithSedentaryModel:sedModel];
}

- (void)weatheSuccess:(NSNotification *)noti
{
    BOOL isFirst = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"isFirst:%d",isFirst);
    //这里不能直接写 if (isFirst),必须如下写法
    if (isFirst == 1) {
        NSMutableArray *saveMutArr = [NSMutableArray array];
        for (SedentaryModel *model in self.dataArr) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
            [saveMutArr addObject:data];
        }
        //这里只能保存不可变数组，所以要转换
        NSArray *saveArr = [NSArray arrayWithArray:saveMutArr];
        [[NSUserDefaults standardUserDefaults] setObject:saveArr forKey:SEDENTARY_SETTING];
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
        [sucToast show];
    }else {
        //做失败处理
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存失败，稍后再试" duration:1.5];
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
    SedentaryReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SedentaryReminderTableViewCellID];
    SedentaryReminderModel *rowModel = self.dataArr[indexPath.row];
    cell.switchChangeBlock = ^{
        rowModel.switchIsOpen = !rowModel.switchIsOpen;
        [tableView reloadData];
    };
    
    cell.model = rowModel;
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
        if (indexPath.row == 1 || indexPath.row == 2) {
            [self showTimePickerViewWith:indexPath];
        }
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
    SedentaryReminderModel *model = self.dataArr[indexPath.row];
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
    
    //    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    //    [currentFormatter setDateFormat:@"hh:mm"];
    //    self.title = [currentFormatter stringFromDate:[NSDate date]];
    
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
        if ([[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING]) {
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING];
            NSMutableArray *mutArr = [NSMutableArray array];
            for (NSData *data in arr) {
                SedentaryModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [mutArr addObject:model];
            }
            _dataArr = mutArr;
        }else {
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
                    model.whetherHaveSwitch = NO;
                }
                [mutArr addObject:model];
            }
            _dataArr = [NSArray arrayWithArray:mutArr];
        }
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
