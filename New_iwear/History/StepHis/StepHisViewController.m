//
//  StepHisViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "StepHisViewController.h"
#import "PNChart.h"
#import "UnitsTool.h"
#import "BleManager.h"
#import "FMDBManager.h"
#import "TargetSettingModel.h"
#import "HooDatePicker.h"

@interface StepHisViewController ()< PNChartDelegate , HooDatePickerDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    NSInteger haveDataDays;
    BOOL _isMetric;
    NSString *_todayStr;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UILabel *view1StepLabel;
@property (nonatomic, strong) UILabel *view2MileageLabel;
@property (nonatomic, strong) UILabel *view3kCalLabel;
@property (nonatomic, strong) PNCircleChart *stepCircleChart;
@property (nonatomic, strong) PNBarChart *stepBarChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) HooDatePicker *datePicker;
@property (nonatomic, strong) MDButton *hisBtn;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;

@end

@implementation StepHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITE_COLOR;
    self.leftButton.backgroundColor = CLEAR_COLOR;
    self.title = @"历史记录";
    [self initUI];
    
    [self updateDBWithDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self.navigationController.navigationBar setBackgroundColor:STEP_CURRENT_BACKGROUND_COLOR];
}

- (void)initUI
{
    _upView = [[UIView alloc] init];
    _upView.backgroundColor = CLEAR_COLOR;
    [self.view addSubview:_upView];
    [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(self.view.mas_width);
    }];
    
    [self.stepCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_upView.mas_centerX);
        make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.width.equalTo(@(220 * VIEW_CONTROLLER_FRAME_WIDTH / 360));
        make.height.equalTo(@(220 * VIEW_CONTROLLER_FRAME_WIDTH / 360));
    }];
    [self.stepCircleChart strokeChart];
//    [self.stepCircleChart updateChartByCurrent:@(0.75)];
    
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.centerY.equalTo(self.stepCircleChart.mas_centerY);
    }];
    [self.stepLabel setText:@"0"];
    
    UILabel *todayLabel = [[UILabel alloc] init];
    [todayLabel setText:@"每日平均"];
    [todayLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [todayLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:todayLabel];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.bottom.equalTo(self.stepLabel.mas_top).offset(-18 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [headImageView setImage:[UIImage imageNamed:@"walk_walkic02"]];
    [self.view addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.bottom.equalTo(todayLabel.mas_top);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.width.equalTo(self.stepLabel.mas_width).offset(-6 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.height.equalTo(@1);
    }];
    
    [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.top.equalTo(lineView.mas_bottom).offset(2 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    [self.mileageAndkCalLabel setText:@""];
    
    self.hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    [self.hisBtn setTitle:@"本月" forState:UIControlStateNormal];
    [self.hisBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.hisBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
    self.hisBtn.backgroundColor = CLEAR_COLOR;
    [self.hisBtn addTarget:self action:@selector(showTheCalender:) forControlEvents:UIControlEventTouchUpInside];
    [_upView addSubview:self.hisBtn];
    [self.hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_upView.mas_right).offset(-16);
        make.bottom.equalTo(_upView.mas_bottom).offset(-16);
    }];
    
    self.view1 = [[UIView alloc] init];
    self.view1.layer.borderWidth = 1;
    self.view1.layer.borderColor = STEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:self.view1];
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_upView.mas_bottom).offset(8);
        make.left.equalTo(self.view.mas_left).offset(-1);
        make.height.equalTo(@72);
        make.width.equalTo(@((VIEW_CONTROLLER_FRAME_WIDTH + 4) / 3));
    }];
    
    UILabel *view1Title = [[UILabel alloc] init];
    [view1Title setText:@"总步数"];
    [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view1Title setFont:[UIFont systemFontOfSize:12]];
    [self.view1 addSubview:view1Title];
    [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view1.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view1StepLabel = [[UILabel alloc] init];
    [_view1StepLabel setText:@"0"];
    [_view1StepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view1StepLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view1 addSubview:_view1StepLabel];
    [_view1StepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view1.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.borderWidth = 1;
    view2.layer.borderColor = STEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view1.mas_top);
        make.left.equalTo(self.view1.mas_right).offset(-1);
        make.height.equalTo(self.view1);
        make.width.equalTo(self.view1.mas_width);
    }];
    
    UILabel *view2Title = [[UILabel alloc] init];
    [view2Title setText:@"总里程"];
    [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view2Title setFont:[UIFont systemFontOfSize:12]];
    [view2 addSubview:view2Title];
    [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view2.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view2MileageLabel = [[UILabel alloc] init];
    [_view2MileageLabel setText:@"0"];
    [_view2MileageLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view2MileageLabel setFont:[UIFont systemFontOfSize:14]];
    [view2 addSubview:_view2MileageLabel];
    [_view2MileageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view2.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view3 = [[UIView alloc] init];
    view3.layer.borderWidth = 1;
    view3.layer.borderColor = STEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view1.mas_top);
        make.left.equalTo(view2.mas_right).offset(-1);
        make.height.equalTo(self.view1);
        make.width.equalTo(self.view1.mas_width);
    }];
    
    UILabel *view3Title = [[UILabel alloc] init];
    [view3Title setText:@"总热量"];
    [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view3Title setFont:[UIFont systemFontOfSize:12]];
    [view3 addSubview:view3Title];
    [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view3.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view3kCalLabel = [[UILabel alloc] init];
    [_view3kCalLabel setText:@"0"];
    [_view3kCalLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view3kCalLabel setFont:[UIFont systemFontOfSize:14]];
    [view3 addSubview:_view3kCalLabel];
    [_view3kCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view3.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UILabel *unitLabel = [[UILabel alloc] init];
    [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel setFont:[UIFont systemFontOfSize:8]];
    [unitLabel setText:@"步"];
    [self.view1 addSubview:unitLabel];
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view1StepLabel.mas_right).offset(8);
        make.top.equalTo(_view1StepLabel.mas_bottom);
    }];
    UILabel *unitLabel2 = [[UILabel alloc] init];
    [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel2 setText:@"公里"];
    [self.view1 addSubview:unitLabel2];
    [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view2MileageLabel.mas_right).offset(8);
        make.top.equalTo(_view2MileageLabel.mas_bottom);
    }];
    UILabel *unitLabel3 = [[UILabel alloc] init];
    [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel3 setText:@"千卡"];
    [self.view1 addSubview:unitLabel3];
    [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view3kCalLabel.mas_right).offset(8);
        make.top.equalTo(_view3kCalLabel.mas_bottom);
    }];
    
    self.leftTimeLabel = [[UILabel alloc] init];
    [self.leftTimeLabel setText:@"1"];
    [self.leftTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [self.leftTimeLabel setFont:[UIFont systemFontOfSize:11]];
    [self.view addSubview:self.leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.bottom.equalTo(self.view.mas_bottom).offset(-12);
    }];
    
    self.rightTimeLabel = [[UILabel alloc] init];
    [self.self.rightTimeLabel setText:@"30"];
    [self.rightTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [self.rightTimeLabel setFont:[UIFont systemFontOfSize:11]];
    [self.view addSubview:self.rightTimeLabel];
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.bottom.equalTo(self.leftTimeLabel.mas_bottom);
    }];
    
    [self.stepBarChart setBackgroundColor:TEXT_BLACK_COLOR_LEVEL0];
    
    [self.datePicker setHighlightColor:STEP_CURRENT_BACKGROUND_COLOR];
}

#pragma mark - PNChartDelegate

#pragma mark - DB
- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sumStep = 0;
        sumMileage = 0;
        sumkCal = 0;
        haveDataDays = 0;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
        NSDateComponents *components = [calendar components:unitFlags fromDate:date];
        NSInteger iCurYear = [components year];  //当前的年份
        NSInteger iCurMonth = [components month];  //当前的月份
        
        [self.dataArr removeAllObjects];
        
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)iCurYear ,(long)iCurMonth ,(long)i];
            DLog(@"%@",dateStr);
            NSArray *queryArr = [self.myFmdbManager querySegmentedStepWithDate:dateStr];
            if (queryArr.count == 0) {
                [self.dataArr addObject:@0];
            }else {
                NSInteger daySumStep = 0;
                NSInteger daySumKcal = 0;
                NSInteger daySumMil = 0;
                for (SegmentedStepModel *model in queryArr) {
                    daySumStep = daySumStep + model.stepNumber.integerValue;
                    daySumKcal = daySumKcal + model.kCalNumber.integerValue;
                    daySumMil = daySumMil + model.mileageNumber.integerValue;
                }
                sumStep = sumStep + daySumStep;
                sumkCal = sumkCal + daySumKcal;
                sumMileage = sumMileage + daySumMil;
                haveDataDays ++;
                
                [self.dataArr addObject:@(daySumStep)];
                
                if (daySumStep > self.stepBarChart.yMaxValue * 0.7) {
                    self.stepBarChart.yMaxValue = daySumStep * 1.3;
                }
                
                DLog(@"sumstep == %ld", daySumStep);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.noDataLabel.hidden = sumStep == 0 ? NO : YES;
            float averageMileage = (sumMileage / haveDataDays);
            float averageStep = (sumStep / haveDataDays);
            float averageKcal = (sumkCal / haveDataDays);
            
            [self.view1StepLabel setText:[NSString stringWithFormat:@"%ld", sumStep]];
            [self.view2MileageLabel setText:[NSString stringWithFormat:@"%ld", sumMileage]];
            [self.view3kCalLabel setText:[NSString stringWithFormat:@"%ld", sumkCal]];
            [self.stepLabel setText:[NSString stringWithFormat:@"%.0f",averageStep]];
            [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%.1fkm/%.0f", averageMileage, averageKcal]];
            
            //更新圆环
            [self updateCircleWithFloat:averageStep];
            //更新图表
            [self.stepBarChart setXLabels:self.dateArr];
            [self.stepBarChart setYValues:self.dataArr];
//            [self.stepBarChart updateChartData:self.dataArr];
            [self.stepBarChart strokeChart];
        });
    });
}

- (void)updateCircleWithFloat:(float)stepFloatValue
{
    float progress;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING];
        TargetSettingModel *stepTargetModel = [NSKeyedUnarchiver unarchiveObjectWithData:arr.firstObject];
        progress = stepFloatValue / stepTargetModel.target.floatValue;
    }else {
        progress = stepFloatValue / 10000.f;
    }
    
    [self.stepCircleChart updateChartByCurrent:@(progress)];
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
    if (date) {
        [self updateDBWithDate:date];
    }
    
}

- (void)updateDBWithDate:(NSDate *)date
{
    //获取这个月的天数
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:date];
    [self.rightTimeLabel setText:[NSString stringWithFormat:@"%ld", days.length]];
    [self.dateArr removeAllObjects];
    for (int i = 1; i <= days.length; i ++) {
        [self.dateArr addObject:@(i)];
    }
    [self getHistoryDataWithIntDays:self.dateArr.count withDate:date];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

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

- (PNCircleChart *)stepCircleChart
{
    if (!_stepCircleChart) {
        _stepCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_CONTROLLER_FRAME_WIDTH / 360, 220 * VIEW_CONTROLLER_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:STEP_HISTORY_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_stepCircleChart setStrokeColor:STEP_HISTORY_CIRCLE_COLOR];
        
        [self.view addSubview:_stepCircleChart];
    }
    
    return _stepCircleChart;
}

- (PNBarChart *)stepBarChart
{
    if (!_stepBarChart) {
        _stepBarChart = [[PNBarChart alloc] init];
        [_stepBarChart setStrokeColor:COLOR_WITH_HEX(0x4caf50, 0.54)];
        _stepBarChart.barBackgroundColor = [UIColor clearColor];
        _stepBarChart.yChartLabelWidth = 20.0;
        _stepBarChart.chartMarginLeft = 0;
        _stepBarChart.chartMarginRight = 0;
        _stepBarChart.chartMarginTop = 0;
        _stepBarChart.chartMarginBottom = 0;
        _stepBarChart.yMinValue = 0;
        _stepBarChart.yMaxValue = 200;
        _stepBarChart.barWidth = 12;
        _stepBarChart.barRadius = 0;
        _stepBarChart.showLabel = NO;
        _stepBarChart.showChartBorder = NO;
        _stepBarChart.isShowNumbers = NO;
        _stepBarChart.isGradientShow = NO;
        
        [self.view addSubview:_stepBarChart];
        [_stepBarChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
    }
    
    return  _stepBarChart;
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

- (NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.stepBarChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepBarChart.mas_centerX);
            make.centerY.equalTo(self.stepBarChart.mas_centerY);
        }];
    }
    
    return _noDataLabel;
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
