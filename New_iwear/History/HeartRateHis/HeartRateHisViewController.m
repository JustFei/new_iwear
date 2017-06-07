//
//  HeartRateHisViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "HeartRateHisViewController.h"
#import "HRTableViewCell.h"
#import "FMDBManager.h"
#import "HooDatePicker.h"

static NSString * const HRTableViewCellID = @"HRTableViewCell";

@interface HeartRateHisViewController () < UITableViewDelegate, UITableViewDataSource , HooDatePickerDelegate>
{
    NSString *_todayStr;
}
@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) UILabel *view1StepLabel;
@property (nonatomic, strong) UILabel *view2MileageLabel;
@property (nonatomic, strong) UILabel *view3kCalLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) HooDatePicker *datePicker;
@property (nonatomic, strong) MDButton *hisBtn;

@end

@implementation HeartRateHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = WHITE_COLOR;
    self.leftButton.backgroundColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self initUI];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger iCurYear = [components year] % 100;  //当前的年份
    NSInteger iCurMonth = [components month];  //当前的月份
    NSString *monthStr = [NSString stringWithFormat:@"20%ld/%02ld", iCurYear, iCurMonth];
    _todayStr = monthStr;
    [self getDataFromDBWithMonthStr:monthStr];
}

- (void)initUI
{
    UILabel *todayLabel = [[UILabel alloc] init];
    [todayLabel setText:@"上次测量结果"];
    [todayLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [todayLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:todayLabel];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(86 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    [self.stepLabel setText:@"--"];
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(todayLabel.mas_bottom).offset(6 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [self.view addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.stepLabel.mas_left).offset(-8 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.bottom.equalTo(self.stepLabel.mas_bottom);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(150 * VIEW_CONTROLLER_FRAME_WIDTH / 360));
        make.height.equalTo(@1);
    }];
    
    [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_bottom).offset(5 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    self.hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    [self.hisBtn setTitle:@"本月" forState:UIControlStateNormal];
    [self.hisBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.hisBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
    self.hisBtn.backgroundColor = CLEAR_COLOR;
    [self.hisBtn addTarget:self action:@selector(showTheCalender:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hisBtn];
    [self.hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.view.mas_top).offset(201 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    UIView *view1 = [[UIView alloc] init];
    view1.layer.borderWidth = 1;
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hisBtn.mas_bottom).offset(25 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.left.equalTo(self.view.mas_left).offset(-1);
        make.height.equalTo(@72);
        make.width.equalTo(@((VIEW_CONTROLLER_FRAME_WIDTH + 4) / 3));
    }];
    
    UILabel *view1Title = [[UILabel alloc] init];
    [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view1Title setFont:[UIFont systemFontOfSize:12]];
    [view1 addSubview:view1Title];
    [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view1StepLabel = [[UILabel alloc] init];
    [_view1StepLabel setText:@"--"];
    [_view1StepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view1StepLabel setFont:[UIFont systemFontOfSize:14]];
    [view1 addSubview:_view1StepLabel];
    [_view1StepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.borderWidth = 1;
    view2.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top);
        make.left.equalTo(view1.mas_right).offset(-1);
        make.height.equalTo(view1);
        make.width.equalTo(view1.mas_width);
    }];
    
    UILabel *view2Title = [[UILabel alloc] init];
    [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view2Title setFont:[UIFont systemFontOfSize:12]];
    [view2 addSubview:view2Title];
    [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view2.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view2MileageLabel = [[UILabel alloc] init];
    [_view2MileageLabel setText:@"--"];
    [_view2MileageLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view2MileageLabel setFont:[UIFont systemFontOfSize:14]];
    [view2 addSubview:_view2MileageLabel];
    [_view2MileageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view2.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view3 = [[UIView alloc] init];
    view3.layer.borderWidth = 1;
    view3.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
    [self.view addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top);
        make.left.equalTo(view2.mas_right).offset(-1);
        make.height.equalTo(view1);
        make.width.equalTo(view1.mas_width);
    }];
    
    UILabel *view3Title = [[UILabel alloc] init];
    [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view3Title setFont:[UIFont systemFontOfSize:12]];
    [view3 addSubview:view3Title];
    [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view3.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view3kCalLabel = [[UILabel alloc] init];
    [_view3kCalLabel setText:@"--"];
    [_view3kCalLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view3kCalLabel setFont:[UIFont systemFontOfSize:14]];
    [view3 addSubview:_view3kCalLabel];
    [_view3kCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view3.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(view1.mas_bottom);
    }];
    
    UILabel *unitLabel = [[UILabel alloc] init];
    [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel setFont:[UIFont systemFontOfSize:8]];
    [view1 addSubview:unitLabel];
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view1StepLabel.mas_right).offset(8);
        make.top.equalTo(_view1StepLabel.mas_bottom);
    }];
    UILabel *unitLabel2 = [[UILabel alloc] init];
    [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
    [view1 addSubview:unitLabel2];
    [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view2MileageLabel.mas_right).offset(8);
        make.top.equalTo(_view2MileageLabel.mas_bottom);
    }];
    UILabel *unitLabel3 = [[UILabel alloc] init];
    [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
    [view1 addSubview:unitLabel3];
    [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view3kCalLabel.mas_right).offset(8);
        make.top.equalTo(_view3kCalLabel.mas_bottom);
    }];
    
    switch (self.vcType) {
        case ViewControllerTypeHR:
        {
            self.title = @"心率记录";
            [self.navigationController.navigationBar setBackgroundColor:HR_CURRENT_BACKGROUND_COLOR];
            view1.layer.borderColor = HR_CURRENT_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = HR_CURRENT_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = HR_CURRENT_BACKGROUND_COLOR.CGColor;
            [headImageView setImage:[UIImage imageNamed:@"heart_heart-icon"]];
            [self.datePicker setHighlightColor:HR_CURRENT_BACKGROUND_COLOR];//设置高亮颜色
            [unitLabel setText:@"次/分钟"];
            [unitLabel2 setText:@"次/分钟"];
            [unitLabel3 setText:@"次/分钟"];
            [view1Title setText:@"平均心率"];
            [view2Title setText:@"最低心率"];
            [view3Title setText:@"最高心率"];
        }
            break;
        case ViewControllerTypeBP:
        {
            self.title = @"血压记录";
            [self.navigationController.navigationBar setBackgroundColor:BP_HISTORY_BACKGROUND_COLOR];
            view1.layer.borderColor = BP_HISTORY_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = BP_HISTORY_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = BP_HISTORY_BACKGROUND_COLOR.CGColor;
            [headImageView setImage:[UIImage imageNamed:@"bloodpressure_ic02"]];
            [self.datePicker setHighlightColor:BP_HISTORY_BACKGROUND_COLOR];//设置高亮颜色
            [unitLabel setText:@""];
            [unitLabel2 setText:@"mmHg"];
            [unitLabel3 setText:@"mmHg"];
            [view1Title setText:@"时间"];
            [view2Title setText:@"平均收缩压"];
            [view3Title setText:@"平均舒张压"];
        }
            break;
        case ViewControllerTypeBO:
        {
            self.title = @"血氧记录";
            [self.navigationController.navigationBar setBackgroundColor:BO_HISTORY_BACKGROUND_COLOR];
            view1.layer.borderColor = BO_HISTORY_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = BO_HISTORY_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = BO_HISTORY_BACKGROUND_COLOR.CGColor;
            [headImageView setImage:[UIImage imageNamed:@"bloodoxygen_ic02"]];
            [self.datePicker setHighlightColor:BO_HISTORY_BACKGROUND_COLOR];//设置高亮颜色
            [unitLabel setText:@"%"];
            [unitLabel2 setText:@"%"];
            [unitLabel3 setText:@"%"];
            [view1Title setText:@"平均血氧"];
            [view2Title setText:@"最低血氧"];
            [view3Title setText:@"最高血氧"];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - DB
- (void)getDataFromDBWithMonthStr:(NSString *)monthStr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        switch (self.vcType) {
            case ViewControllerTypeHR:
            {
                NSArray *hrArr = [self.myFmdbManager queryHeartRate:monthStr WithType:QueryTypeWithMonth];
                [self showHrDataWithArr:hrArr];
            }
                break;
            case ViewControllerTypeBP:
            {
                NSArray *bpArr = [self.myFmdbManager queryBlood:monthStr WithType:QueryTypeWithMonth];
                [self showBpDataWithArr:bpArr];
                NSString *year = [monthStr substringWithRange:NSMakeRange(0, 4)];
                NSString *month = [monthStr substringWithRange:NSMakeRange(5, 2)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.view1StepLabel.text = [NSString stringWithFormat:@"%@年%@月", year, month];
                });
            }
                break;
            case ViewControllerTypeBO:
            {
                NSArray *boArr = [self.myFmdbManager queryBloodO2:monthStr WithType:QueryTypeWithMonth];
                [self showBoDataWithArr:boArr];
            }
                break;
                
            default:
                break;
        }
        
    });
}

//展示心率数据
- (void)showHrDataWithArr:(NSArray *)hrArr
{
    NSMutableArray *mutArr = [NSMutableArray array];
    NSInteger sumHr = 0;
    NSInteger minHr = 10000;
    NSInteger maxHr = 0;
    for (HeartRateModel *model in hrArr) {
        HRTableModel *tableModel = [[HRTableModel alloc] init];
        NSString *monthStr = [model.time substringWithRange:NSMakeRange(0, 2)];
        NSString *dayStr = [model.time substringWithRange:NSMakeRange(3, 2)];
        tableModel.dateStr = [NSString stringWithFormat:@"%@月%@日", monthStr, dayStr];
        tableModel.timeStr = [model.time substringWithRange:NSMakeRange(6, 5)];
        tableModel.dataStr = model.heartRate;
        tableModel.unitStr = @"次/分钟";
        
        //获取最大值
        if (model.heartRate.integerValue > maxHr) {
            maxHr = model.heartRate.integerValue;
        }
        //获取最小值
        if (model.heartRate.integerValue < minHr) {
            minHr = model.heartRate.integerValue;
        }
        //获取总数
        sumHr = sumHr + model.heartRate.integerValue;
        
        [mutArr addObject:tableModel];
    }
    
    self.dataArr = mutArr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        HRTableModel *lastTestModel = self.dataArr.lastObject;
        self.stepLabel.text = lastTestModel.dataStr;
        self.mileageAndkCalLabel.text = [NSString stringWithFormat:@"%@ %@", lastTestModel.dateStr, lastTestModel.timeStr];
        float aveHr = (float)sumHr / hrArr.count;
        self.view1StepLabel.text = [NSString stringWithFormat:@"%.0f", aveHr];
        self.view2MileageLabel.text = [NSString stringWithFormat:@"%ld", minHr];
        self.view3kCalLabel.text = [NSString stringWithFormat:@"%ld", maxHr];
    });
}

//展示血压数据
- (void)showBpDataWithArr:(NSArray *)bpArr
{
    NSMutableArray *mutArr = [NSMutableArray array];
    NSInteger sumHighBp = 0;
    NSInteger sumLowBp = 0;
    for (BloodModel *model in bpArr) {
        HRTableModel *tableModel = [[HRTableModel alloc] init];
        NSString *monthStr = [model.dayString substringWithRange:NSMakeRange(5, 2)];
        NSString *dayStr = [model.dayString substringWithRange:NSMakeRange(8, 2)];
        tableModel.dateStr = [NSString stringWithFormat:@"%@月%@日", monthStr, dayStr];
        tableModel.timeStr = [model.highBloodString stringByAppendingString:@"mmHg"];
        tableModel.dataStr = model.lowBloodString;
        tableModel.unitStr = @"mmHg";
        
        //获取总数
        sumHighBp = sumHighBp + model.highBloodString.integerValue;
        sumLowBp = sumLowBp + model.lowBloodString.integerValue;
        
        [mutArr addObject:tableModel];
    }
    self.dataArr = mutArr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        BloodModel *lastTestModel = bpArr.lastObject;
        self.stepLabel.text = [NSString stringWithFormat:@"%@/%@", lastTestModel.lowBloodString, lastTestModel.highBloodString];
        self.mileageAndkCalLabel.text = [NSString stringWithFormat:@"%@ %@", lastTestModel.dayString, lastTestModel.timeString];
        float aveHighBp = (float)sumHighBp / bpArr.count;
        float aveLowBp = (float)sumLowBp / bpArr.count;
        self.view2MileageLabel.text = [NSString stringWithFormat:@"%.0f", aveHighBp];
        self.view3kCalLabel.text = [NSString stringWithFormat:@"%.0f", aveLowBp];
    });
}

//展示血氧数据
- (void)showBoDataWithArr:(NSArray *)boArr
{
    NSMutableArray *mutArr = [NSMutableArray array];
    float sumBo = 0;
    float minBo = 10000;
    float maxBo = 0;
    for (BloodO2Model *model in boArr) {
        HRTableModel *tableModel = [[HRTableModel alloc] init];
        NSString *monthStr = [model.dayString substringWithRange:NSMakeRange(5, 2)];
        NSString *dayStr = [model.dayString substringWithRange:NSMakeRange(8, 2)];
        tableModel.dateStr = [NSString stringWithFormat:@"%@月%@日", monthStr, dayStr];
        tableModel.timeStr = [model.timeString substringWithRange:NSMakeRange(0, 5)];
        tableModel.dataStr = [NSString stringWithFormat:@"%@.%@", model.integerString, model.floatString];
        tableModel.unitStr = @"%";
        float progressValue = [NSString stringWithFormat:@"%@.%@", model.integerString, model.floatString].floatValue;
        //获取最大值
        if (progressValue > maxBo) {
            maxBo = progressValue;
        }
        //获取最小值
        if (progressValue < minBo) {
            minBo = progressValue;
        }
        //获取总数
        sumBo = sumBo + progressValue;
        
        [mutArr addObject:tableModel];
    }
    self.dataArr = mutArr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        BloodO2Model *lastTestModel = boArr.lastObject;
        self.stepLabel.text = [NSString stringWithFormat:@"%@.%@%%", lastTestModel.integerString, lastTestModel.floatString];
        self.mileageAndkCalLabel.text = [NSString stringWithFormat:@"%@ %@", lastTestModel.dayString, lastTestModel.timeString];
        float aveBo = sumBo / boArr.count;
        self.view1StepLabel.text = [NSString stringWithFormat:@"%.1f", aveBo];
        self.view2MileageLabel.text = [NSString stringWithFormat:@"%.1f", minBo];
        self.view3kCalLabel.text = [NSString stringWithFormat:@"%.1f", maxBo];
    });
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)showHisVC:(MDButton *)sender
//{
//    
//}

- (void)showTheCalender:(MDButton *)sender
{
    [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];   //让时区正确
    NSDate *maxDate = [NSDate date];
    //self.datePicker.minimumDate = minDate;//设置显示的最小日期
    self.datePicker.maximumDate = maxDate;//设置显示的最大日期
    [self.datePicker setTintColor:TEXT_BLACK_COLOR_LEVEL3];//设置主色
    //默认日期一定要最后设置，否在会被覆盖成当天的日期(貌似没什么效果)
    [self.datePicker setDate:[sender.titleLabel.text isEqualToString:@"本月"] ? [NSDate date] : [dateFormatter dateFromString:sender.titleLabel.text]];
    
    [self.datePicker show];
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
    HRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HRTableViewCellID];
    
    cell.model = self.dataArr[self.dataArr.count - indexPath.row - 1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark - HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date
{
    DLog(@"%@",datePicker.date);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *currentDateString = [formatter stringFromDate:datePicker.date];
    
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender
{
    [datePicker dismiss];
}

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8 * 3600]];
    NSString *currentDateString = [formatter stringFromDate:date];
    
    [self.hisBtn setTitle:[currentDateString isEqualToString:_todayStr] ? @"本月" : currentDateString forState:UIControlStateNormal];
    [self getDataFromDBWithMonthStr:currentDateString];
}

#pragma mark - 懒加载
- (MDButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [_leftButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    return _leftButton;
}

- (UILabel *)stepLabel
{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        [_stepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_stepLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self.view addSubview:_stepLabel];
    }
    
    return _stepLabel;
}

- (UILabel *)mileageAndkCalLabel
{
    if (!_mileageAndkCalLabel) {
        _mileageAndkCalLabel = [[UILabel alloc] init];
        [_mileageAndkCalLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_mileageAndkCalLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self.view addSubview:_mileageAndkCalLabel];
    }
    
    return _mileageAndkCalLabel;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = CLEAR_COLOR;
        [_tableView registerClass:NSClassFromString(HRTableViewCellID) forCellReuseIdentifier:HRTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}

- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:DB_NAME];
    }
    
    return _myFmdbManager;
}

- (HooDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    
    return _datePicker;
}

@end
