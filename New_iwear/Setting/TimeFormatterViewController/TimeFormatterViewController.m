//
//  TimeFormatterViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TimeFormatterViewController.h"
#import "UnitsSettingTableViewCell.h"
//#import "InterfaceSelectionCollectionViewCell.h"

static NSString * const TimeFormatterSettingTableViewCellID = @"TimeFormatterSettingTableViewCell";

@interface TimeFormatterViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation TimeFormatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"timeFormatter", nil);
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveTimeFormatterAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTimeFormatterWeatherSuccess:) name:SET_TIME_FORMATTER object:nil];
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

- (void)saveTimeFormatterAction
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UnitsSettingModel *model = ((NSArray*)self.dataArr.firstObject).firstObject;
        
        [[BleManager shareInstance] writeTimeFormatterToPeripheral:model.isSelect];
    }
}

- (void)setTimeFormatterWeatherSuccess:(NSNotification *)noti
{
    BOOL isFirst = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"isFirst:%d",isFirst);
    //这里不能直接写 if (isFirst),必须如下写法
    if (isFirst == 1) {
        //保存设置到本地
        NSMutableArray *saveMutArr = [NSMutableArray array];
        for (UnitsSettingModel *model in self.dataArr) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
            [saveMutArr addObject:data];
        }
        //这里只能保存不可变数组，所以要转换
        NSArray *saveArr = [NSArray arrayWithArray:saveMutArr];
        [[NSUserDefaults standardUserDefaults] setObject:saveArr forKey:TIME_FORMATTER_SETTING];
        
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:NSLocalizedString(@"saveSuccess", nil) duration:1.5];
        [sucToast show];
        UnitsSettingModel *model = ((NSArray *)self.dataArr.firstObject).firstObject;//12小时制
        //保存设置到本地
        //长度单位
        [[NSUserDefaults standardUserDefaults] setBool:model.isSelect forKey:TIME_FORMATTER];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        //做失败处理
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:NSLocalizedString(@"saveFail", nil) duration:1.5];
        [sucToast show];
    }
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
    UnitsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TimeFormatterSettingTableViewCellID forIndexPath:indexPath];
    NSArray *sectionArr = self.dataArr[indexPath.section];
    
    //将数据源中的选择项改变
    cell.unitsSettingSelectBlock = ^{
        for (int index = 0; index < sectionArr.count; index ++) {
            UnitsSettingModel *mod = sectionArr[index];
            mod.isSelect = index == indexPath.row ? YES : NO ;
        }
        [self.tableView reloadData];
    };
    
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
    [sectionTitleLabel setText:NSLocalizedString(@"timeForSet", nil)];
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
    
    //点击 cell 同样实现点击按钮的功能
    NSArray *sectionArr = self.dataArr[indexPath.section];
    for (int index = 0; index < sectionArr.count; index ++) {
        UnitsSettingModel *mod = sectionArr[index];
        mod.isSelect = index == indexPath.row ? YES : NO ;
    }
    [self.tableView reloadData];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(@"UnitsSettingTableViewCell") forCellReuseIdentifier:TimeFormatterSettingTableViewCellID];
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
        if ([[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING]) {
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TIME_FORMATTER_SETTING];
            NSMutableArray *mutArr = [NSMutableArray array];
            for (NSData *data in arr) {
                UnitsSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [mutArr addObject:model];
            }
            _dataArr = mutArr;
        }else {
            NSArray *sec1 = @[[NSString stringWithFormat:@"12%@", NSLocalizedString(@"hour", nil)], [NSString stringWithFormat:@"24%@", NSLocalizedString(@"hour", nil)]];
            NSMutableArray *mutArr1 = [NSMutableArray array];
            for (int index = 0; index < sec1.count; index ++) {
                UnitsSettingModel *model = [[UnitsSettingModel alloc] init];
                model.name = sec1[index];
                model.isSelect = index == 0 ? YES : NO;
                [mutArr1 addObject:model];
            }
            _dataArr = @[mutArr1];
        }
    }
    
    return _dataArr;
}

@end
