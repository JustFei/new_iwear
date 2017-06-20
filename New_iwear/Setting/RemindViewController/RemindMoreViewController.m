//
//  RemindMoreViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindMoreViewController.h"
#import "RemindMoreTableViewCell.h"

static NSString * const RemindMoreTableViewCellID = @"RemindMoreTableViewCell";

@interface RemindMoreViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation RemindMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"更多提醒";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = SETTING_BACKGROUND_COLOR;
}

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
    RemindMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RemindMoreTableViewCellID forIndexPath:indexPath];
    
    cell.model = self.dataArr[indexPath.row];
    
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

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(@"RemindMoreTableViewCell") forCellReuseIdentifier:RemindMoreTableViewCellID];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSMutableArray *mutArr = [NSMutableArray array];
        NSArray *imageNameArr = @[@"remind_sit02", @"remind_alarm02", @"remind_mgs02", @"remind_phone02", @"remind_antilost", @"remind_app"];
        NSArray *funcNameArr = @[@"久坐提醒", @"闹钟提醒", @"短信提醒", @"来电提醒", @"防丢提醒",@"应用提醒"];
        for (int index = 0; index < funcNameArr.count; index ++) {
            RemindModel *model = [[RemindModel alloc] init];
            model.functionName = funcNameArr[index];
            model.headImageName = imageNameArr[index];
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

- (NSArray *)vcArr
{
    if (!_vcArr) {
        _vcArr = @[@"SedentaryReminderViewController", @"ClockReminderViewController", @"MessageReminderViewController", @"PhoneReminderViewController", @"LoseReminderViewController", @"APPRemindViewController"];
    }
    
    return _vcArr;
}

@end
