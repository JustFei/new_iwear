//
//  TrainingViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TrainingViewController.h"
#import "TrainingTableCell.h"
#import "FMDBManager.h"
#import "PNChart.h"
#import "HooDatePicker.h"

static NSString * const TrainingTableCellID = @"TrainingTableCell";

@interface TrainingViewController () <UITableViewDelegate, UITableViewDataSource, PNChartDelegate , HooDatePickerDelegate>
{
    CGFloat offsetH;
    CGFloat turnOffsetH;
    CGFloat slideH;
    CGFloat kScreenW;
    BOOL isSlideMax;
}

@property (nonatomic, strong) MDButton *leftBtn;
@property (nonatomic, strong) MDButton *rightBtn;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) MDButton *calBtn;
@property (nonatomic, strong) UILabel *clickInfoLabel;
@property (nonatomic, strong) UIView *headTopView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *tableDataArr;
@property (nonatomic, strong) NSMutableArray *barChartDataArr;
@property (nonatomic, strong) NSMutableArray *xArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) PNBarChart *runBarChart;
@property (nonatomic, strong) HooDatePicker *datePicker;


@end

@implementation TrainingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"train", nil);
    
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [self initUI];
    
    [self getDataFromDBWithDate:[NSDate date]];
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.headTopView.backgroundColor = TRAINING_BACKGROUND_COLOR;
    self.dataTableView.backgroundColor = CLEAR_COLOR;
    self.runBarChart.backgroundColor = CLEAR_COLOR;
    [self.runBarChart strokeChart];
    
    self.leftLabel.backgroundColor = CLEAR_COLOR;
    self.rightLabel.backgroundColor = CLEAR_COLOR;
    [self.hud showAnimated:YES];
    
    _dateLabel = [[UILabel alloc] init];
    [_dateLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
    [_dateLabel setFont:[UIFont systemFontOfSize:12]];
    [self.headTopView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headTopView.mas_centerX);
        make.top.equalTo(self.headTopView.mas_top).offset(82);
    }];
    
    _clickInfoLabel = [[UILabel alloc] init];
    [_clickInfoLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
    [_clickInfoLabel setFont:[UIFont systemFontOfSize:12]];
    [self.headTopView addSubview:_clickInfoLabel];
    [_clickInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headTopView.mas_centerX);
        make.top.equalTo(_dateLabel.mas_bottom).offset(28);
    }];
    
    _leftBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [_leftBtn setImage:[UIImage imageNamed:@"train_chevron_left"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(beforeDateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headTopView addSubview:_leftBtn];
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.right.equalTo(_dateLabel.mas_left).offset(-8);
    }];
    
    _rightBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [_rightBtn setImage:[UIImage imageNamed:@"train_chevron_right"] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(afterDateAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn.enabled = NO;
    [self.headTopView addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.left.equalTo(_dateLabel.mas_right).offset(8);
    }];
    
    _calBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [_calBtn setImage:[UIImage imageNamed:@"all_calendar"] forState:UIControlStateNormal];
    [_calBtn addTarget:self action:@selector(calAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headTopView addSubview:_calBtn];
    [_calBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.left.equalTo(_rightBtn.mas_right).offset(8);
    }];
    
    [self.datePicker setHighlightColor:TRAINING_BACKGROUND_COLOR];
}

- (void)getDataFromDBWithDate:(NSDate *)queryDate
{
    self.noDataLabel.hidden = YES;
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    NSString *currentDateStr = [formatter1 stringFromDate:queryDate];
    if ([currentDateStr isEqualToString:[formatter1 stringFromDate:[NSDate date]]]) {
        [self.dateLabel setText:NSLocalizedString(@"today", nil)];
        self.rightBtn.enabled = NO;
    }else{
        [self.dateLabel setText:currentDateStr];
        self.rightBtn.enabled = YES;
    }
//    [self.dateLabel setText:currentDateStr];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *runDataArr = [self.myFmdbManager querySegmentedRunWithDate:currentDateStr];
        if (runDataArr.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableDataArr removeAllObjects];
                [self.barChartDataArr removeAllObjects];
                [self.xArr removeAllObjects];
                [self.runBarChart strokeChart];
                [self.dataTableView reloadData];
                [self.hud hideAnimated:YES];
                self.noDataLabel.hidden = NO;
            });
            return ;
        }else {
            [self.tableDataArr removeAllObjects];
            [self.barChartDataArr removeAllObjects];
            [self.xArr removeAllObjects];
            self.noDataLabel.hidden = YES;
            
            for (SegmentedRunModel *model in runDataArr) {
                //获取列表数据源
                TrainingTableModel *tableModel = [[TrainingTableModel alloc] init];
                tableModel.periodStr = model.startTime;
                tableModel.sportTypeStr = NSLocalizedString(@"running", nil);
                tableModel.timeCountStr = [NSString stringWithFormat:@"%ld", model.timeInterval];
                tableModel.stepStr = model.stepNumber;
                tableModel.kcalStr = model.kCalNumber;
                [self.tableDataArr addObject:tableModel];
                
                //获取 barChart 的数据源
                [self.barChartDataArr addObject:@(model.stepNumber.integerValue)];
                
                //设置数据源的最大值为 barChart 的最大值的2/3
                if (model.stepNumber.integerValue > self.runBarChart.yMaxValue * 0.7) {
                    self.runBarChart.yMaxValue = model.stepNumber.integerValue * 1.3;
                }
            }
            NSMutableArray *indexArr = [NSMutableArray array];
            for (int index = 0; index < self.barChartDataArr.count; index ++) {
                [indexArr addObject:[NSString stringWithFormat:@"%02d", index]];
                [self.xArr addObject:[NSString stringWithFormat:@"%d", index]];
            }
            
            SegmentedRunModel *firModel = runDataArr.firstObject;
            SegmentedRunModel *lasModel = runDataArr.lastObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回主线程更新 UI
                [self.hud hideAnimated:YES];
                [self.runBarChart setXLabels:self.xArr];
                [self.runBarChart setYValues:self.barChartDataArr];
                [self.runBarChart strokeChart];
                [self.dataTableView reloadData];
                [self.leftLabel setText:[firModel.startTime substringWithRange:NSMakeRange(11, 5)]];
                 [self.rightLabel setText:[lasModel.startTime substringWithRange:NSMakeRange(11, 5)]];
            });
        }
    });
}

#pragma mark - HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date
{
    
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender
{
    [datePicker dismiss];
}

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    
//    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8 * 3600]];
//    NSString *currentDateString = [formatter stringFromDate:date];
    
    if (date) {
        [self getDataFromDBWithDate:date];
    }
    
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"点击了 RunBarChart 的%ld", barIndex);
    TrainingTableModel *model = self.tableDataArr[barIndex];
    [self.clickInfoLabel setText:[NSString stringWithFormat:@"%@ %@%@", [model.periodStr substringWithRange:NSMakeRange(11, 5)], self.barChartDataArr[barIndex], NSLocalizedString(@"step1", nil)]];
    self.clickInfoLabel.hidden = NO;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//前一天
- (void)beforeDateAction:(MDButton *)sender
{
    NSDateFormatter *forMat = [[NSDateFormatter alloc] init];
    [forMat setDateFormat:@"yyyy-MM-dd"];
    NSDate *beforeDate;
    if ([self.dateLabel.text isEqualToString:NSLocalizedString(@"today", nil)]) {
        beforeDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]];
    }else {
        beforeDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[forMat dateFromString:self.dateLabel.text]];
    }
    [self getDataFromDBWithDate:beforeDate];
}

//后一天
- (void)afterDateAction:(MDButton *)sender
{
    NSDateFormatter *forMat = [[NSDateFormatter alloc] init];
    [forMat setDateFormat:@"yyyy-MM-dd"];
    NSDate *nextDat = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[forMat dateFromString:self.dateLabel.text]];
    [self getDataFromDBWithDate:nextDat];
}

- (void)calAction:(MDButton *)sender
{
    [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];   //让时区正确
    NSDate *maxDate = [NSDate date];
    //self.datePicker.minimumDate = minDate;//设置显示的最小日期
    self.datePicker.maximumDate = maxDate;//设置显示的最大日期
    [self.datePicker setTintColor:TEXT_BLACK_COLOR_LEVEL3];//设置主色
    //默认日期一定要最后设置，否在会被覆盖成当天的日期(貌似没什么效果)
    NSString *curStr = [dateFormatter stringFromDate:[NSDate date]];
    [self.datePicker setDate:[self.dateLabel.text isEqualToString:curStr] ? [NSDate date] : [dateFormatter dateFromString:self.dateLabel.text]];
    
    [self.datePicker show];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TrainingTableCellID];
    if (cell == nil) {
        cell = [[TrainingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TrainingTableCellID];
    }
    
    cell.model = self.tableDataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

#pragma mark - lazy
- (UIView *)headTopView
{
    if (!_headTopView) {
        _headTopView = [[UIView alloc] initWithFrame:CGRectZero];
        _headTopView.backgroundColor = CLEAR_COLOR;
        
        [self.view addSubview:_headTopView];
        [_headTopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@262);
            make.top.equalTo(self.view.mas_top);
        }];
    }
    
    return _headTopView;
}

- (UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        [_leftLabel setText:@"00:00"];
        [_leftLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_leftLabel setFont:[UIFont systemFontOfSize:11]];
        [self.view addSubview:_leftLabel];
        
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(16);
            make.top.equalTo(self.headTopView.mas_bottom).offset(12);
        }];
    }
    
    return _leftLabel;
}

- (UILabel *)rightLabel
{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        [_rightLabel setText:@"23:59"];
        [_rightLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_rightLabel setFont:[UIFont systemFontOfSize:11]];
        [self.view addSubview:_rightLabel];
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right).offset(-16);
            make.top.equalTo(self.headTopView.mas_bottom).offset(12);
        }];
    }
    
    return _rightLabel;
}

- (UITableView *)dataTableView
{
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_dataTableView registerClass:NSClassFromString(TrainingTableCellID) forCellReuseIdentifier:TrainingTableCellID];
        _dataTableView.bounces = NO;
//        _dataTableView.contentInset = UIEdgeInsetsMake(offsetH - 64, 0, 0, 0);
//        _dataTableView.scrollIndicatorInsets = _dataTableView.contentInset;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dataTableView.showsVerticalScrollIndicator = NO;
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        
        [self.view addSubview:_dataTableView];
        [_dataTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
            make.top.equalTo(self.leftLabel.mas_bottom).offset(12);
        }];
    }
    
    return _dataTableView;
}

/** 列表数据源 */
- (NSMutableArray *)tableDataArr
{
    if (!_tableDataArr) {
        _tableDataArr = [NSMutableArray array];
    }
    
    return _tableDataArr;
}

/** 图表数据源 */
- (NSMutableArray *)barChartDataArr
{
    if (!_barChartDataArr) {
        _barChartDataArr = [NSMutableArray array];
    }
    
    return _barChartDataArr;
}

- (NSMutableArray *)xArr
{
    if (!_xArr) {
        _xArr = [NSMutableArray array];
    }
    
    return _xArr;
}

- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:DB_NAME];
    }
    
    return _myFmdbManager;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        _noDataLabel.text = NSLocalizedString(@"noData", nil);
        
        [self.dataTableView addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.dataTableView.mas_centerX);
            make.centerY.equalTo(self.dataTableView.mas_centerY);
        }];
    }
    
    return _noDataLabel;
}

- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    
    return _hud;
}

- (PNBarChart *)runBarChart
{
    if (!_runBarChart) {
        _runBarChart = [[PNBarChart alloc] init];
        [_runBarChart setStrokeColor:STEP_CURRENT_CIRCLE_COLOR];
        _runBarChart.barBackgroundColor = [UIColor clearColor];
        _runBarChart.yChartLabelWidth = 20.0;
        _runBarChart.chartMarginLeft = 16;
        _runBarChart.chartMarginRight = 16;
        _runBarChart.chartMarginTop = 0;
        _runBarChart.chartMarginBottom = 0;
        _runBarChart.yMinValue = 0;
        _runBarChart.yMaxValue = 200;
        _runBarChart.barWidth = 11;
        _runBarChart.barRadius = 0;
        _runBarChart.showLabel = NO;
        _runBarChart.showChartBorder = NO;
        _runBarChart.isShowNumbers = NO;
        _runBarChart.isGradientShow = NO;
        _runBarChart.delegate = self;
        
        [self.headTopView addSubview:_runBarChart];
        [_runBarChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headTopView.mas_left);
            make.right.equalTo(self.headTopView.mas_right);
            make.bottom.equalTo(self.headTopView.mas_bottom);
            make.height.equalTo(@150);
        }];
    }
    
    return _runBarChart;
}

- (HooDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeDate;
    }
    
    return _datePicker;
}

@end
