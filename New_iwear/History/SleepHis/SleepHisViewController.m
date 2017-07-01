//
//  SleepHisViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SleepHisViewController.h"
#import "PNChart.h"
#import "UnitsTool.h"
#import "FMDBManager.h"
#import "HooDatePicker.h"
#import "TargetSettingModel.h"

@interface SleepHisViewController ()< PNChartDelegate , HooDatePickerDelegate >
{
    float monthSumSleep;
    float monthDeepSleep;
    float monthLowSleep;
    NSInteger haveDataDays;
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
@property (nonatomic, strong) PNBarChart *deepSleepChart;
@property (nonatomic, strong) PNBarChart *sumSleepChart;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *sumDataArr;
@property (nonatomic, strong) NSMutableArray *deepDataArr;
@property (nonatomic, strong) NSMutableArray *lowDataArr;
@property (nonatomic, strong) MDButton *hisBtn;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) HooDatePicker *datePicker;

@end

@implementation SleepHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = WHITE_COLOR;
    self.leftButton.backgroundColor = CLEAR_COLOR;
    self.title = @"睡眠记录";
    [self initUI];
    
    [self updateDBWithDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self.navigationController.navigationBar setBackgroundColor:SLEEP_CURRENT_BACKGROUND_COLOR];
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
    
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.centerY.equalTo(self.stepCircleChart.mas_centerY);
    }];
    [self.stepLabel setText:@"--"];
    
    UILabel *todayLabel = [[UILabel alloc] init];
    [todayLabel setText:@"每日平均睡眠"];
    [todayLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [todayLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:todayLabel];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.bottom.equalTo(self.stepLabel.mas_top).offset(-18 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [headImageView setImage:[UIImage imageNamed:@"sleep_sleepic02"]];
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
    
    MDButton *hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    [hisBtn setTitle:@"本月" forState:UIControlStateNormal];
    [hisBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [hisBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
    hisBtn.backgroundColor = CLEAR_COLOR;
    [hisBtn addTarget:self action:@selector(showTheCalender:) forControlEvents:UIControlEventTouchUpInside];
    [_upView addSubview:hisBtn];
    [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_upView.mas_right).offset(-16);
        make.bottom.equalTo(_upView.mas_bottom).offset(-16);
    }];
    
    self.view1 = [[UIView alloc] init];
    self.view1.layer.borderWidth = 1;
    self.view1.layer.borderColor = SLEEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:self.view1];
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_upView.mas_bottom).offset(8);
        make.left.equalTo(self.view.mas_left).offset(-1);
        make.height.equalTo(@72);
        make.width.equalTo(@((VIEW_CONTROLLER_FRAME_WIDTH + 4) / 3));
    }];
    
    UILabel *view1Title = [[UILabel alloc] init];
    [view1Title setText:@"每日平均睡眠"];
    [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view1Title setFont:[UIFont systemFontOfSize:12]];
    [self.view1 addSubview:view1Title];
    [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view1.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view1StepLabel = [[UILabel alloc] init];
    [_view1StepLabel setText:@"--"];
    [_view1StepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view1StepLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view1 addSubview:_view1StepLabel];
    [_view1StepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view1.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.borderWidth = 1;
    view2.layer.borderColor = SLEEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view1.mas_top);
        make.left.equalTo(self.view1.mas_right).offset(-1);
        make.height.equalTo(self.view1);
        make.width.equalTo(self.view1.mas_width);
    }];
    
    UILabel *view2Title = [[UILabel alloc] init];
    [view2Title setText:@"深睡"];
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
    view3.layer.borderColor = SLEEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view1.mas_top);
        make.left.equalTo(view2.mas_right).offset(-1);
        make.height.equalTo(self.view1);
        make.width.equalTo(self.view1.mas_width);
    }];
    
    UILabel *view3Title = [[UILabel alloc] init];
    [view3Title setText:@"浅睡"];
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
    
    UILabel *unitLabel = [[UILabel alloc] init];
    [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel setFont:[UIFont systemFontOfSize:8]];
    [unitLabel setText:@"小时"];
    [self.view1 addSubview:unitLabel];
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view1StepLabel.mas_right).offset(8);
        make.top.equalTo(_view1StepLabel.mas_bottom);
    }];
    UILabel *unitLabel2 = [[UILabel alloc] init];
    [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel2 setText:@"小时"];
    [self.view1 addSubview:unitLabel2];
    [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view2MileageLabel.mas_right).offset(8);
        make.top.equalTo(_view2MileageLabel.mas_bottom);
    }];
    UILabel *unitLabel3 = [[UILabel alloc] init];
    [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel3 setText:@"小时"];
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
    
    [self.sumSleepChart setBackgroundColor:TEXT_BLACK_COLOR_LEVEL0];
    [self.deepSleepChart setBackgroundColor:CLEAR_COLOR];
    
    [self.datePicker setHighlightColor:SLEEP_CURRENT_BACKGROUND_COLOR];
    
}

#pragma mark - PNChartDelegate

#pragma mark - DB
- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    NSInteger iCurYear = [components year];  //当前的年份
    NSInteger iCurMonth = [components month];  //当前的月份
    
    [self.sumDataArr removeAllObjects];
    [self.deepDataArr removeAllObjects];
    [self.lowDataArr removeAllObjects];
    
    haveDataDays = 0;
    monthSumSleep = 0;
    monthLowSleep = 0;
    monthDeepSleep = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld/%02ld",(long)iCurYear ,iCurMonth ,i];
            NSLog(@"%@",dateStr);
            NSArray *queryArr = [self.myFmdbManager querySleepWithDate:dateStr];
            if (queryArr.count == 0) {
                [self.sumDataArr addObject:@0];
                [self.deepDataArr addObject:@0];
                [self.lowDataArr addObject:@0];
            }else {
                float daySumDeep = 0;
                float daySumSum = 0;
                float daySumLow = 0;
                for (SleepModel *model in queryArr) {
                    daySumDeep += model.deepSleep.integerValue;
                    daySumSum += model.sumSleep.integerValue;
                    daySumLow += model.lowSleep.integerValue;
                }
                float deep = daySumDeep / 60;
                float sum = daySumSum / 60;
                float low = daySumLow / 60;
                
                [self.deepDataArr addObject:@(deep)];
                [self.sumDataArr addObject:@(sum)];
                [self.lowDataArr addObject:@(low)];
                
                monthSumSleep = monthSumSleep + daySumSum;
                monthLowSleep = monthLowSleep + daySumLow;
                monthDeepSleep = monthDeepSleep + daySumDeep;
                haveDataDays ++;
                
                if (sum > self.sumSleepChart.yMaxValue * 0.7) {
                    self.sumSleepChart.yMaxValue = sum * 1.3 ;
                    self.deepSleepChart.yMaxValue = sum * 1.3;
                }
            }
        }

        //先除再加得到总和，这样不会出现因为四舍五入导致的数据不一致的情况
        CGFloat averageDeepSleep = round(monthDeepSleep / haveDataDays / 60 * 10) / 10;
        CGFloat averageLowSleep = round(monthLowSleep / haveDataDays / 60 * 10) / 10;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.noDataLabel.hidden = monthSumSleep == 0 ? NO : YES;
            if (monthSumSleep == 0) {
                [self.stepLabel setText:@"--"];
                [self.view1StepLabel setText:@"--"];
                [self.view2MileageLabel setText:@"--"];
                [self.view3kCalLabel setText:@"--"];
                self.noDataLabel.hidden = NO;
                [self drawCircle:0];
            }else {
                self.noDataLabel.hidden = YES;
                [self.stepLabel setText:[NSString stringWithFormat:@"%.1f",averageDeepSleep + averageLowSleep]];
                [self.view1StepLabel setText:[NSString stringWithFormat:@"%.1f", averageDeepSleep + averageLowSleep]];
                [self.view2MileageLabel setText:[NSString stringWithFormat:@"%.1f", averageDeepSleep]];
                [self.view3kCalLabel setText:[NSString stringWithFormat:@"%.1f", averageLowSleep]];
                //更新圆环
                [self drawCircle:(averageDeepSleep + averageLowSleep)];
            }
            
            //更新 bar 图
            [self.sumSleepChart setXLabels:_dateArr];
            [self.sumSleepChart setYValues:self.sumDataArr];
            [self.deepSleepChart setXLabels:_dateArr];
            [self.deepSleepChart setYValues:self.deepDataArr];
            [self.sumSleepChart strokeChart];
            [self.deepSleepChart strokeChart];
        });
    });
}

- (void)drawCircle:(float)averageSleep
{
    float progress;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING]) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING];
        TargetSettingModel *sleepTargetModel = [NSKeyedUnarchiver unarchiveObjectWithData:arr.lastObject];
        progress = averageSleep / sleepTargetModel.target.floatValue;
    }else {
        progress = averageSleep / 8.f;
    }
    [self.stepCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date
{
//    NSLog(@"%@",datePicker.date);
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy/MM"];
//    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    NSString *currentDateString = [formatter stringFromDate:datePicker.date];
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
        _stepCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_CONTROLLER_FRAME_WIDTH / 360, 220 * VIEW_CONTROLLER_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:SLEEP_HISTORY_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_stepCircleChart setStrokeColor:SLEEP_HISTORY_CIRCLE_COLOR];
        
        [self.view addSubview:_stepCircleChart];
    }
    
    return _stepCircleChart;
}

- (PNBarChart *)sumSleepChart
{
    if (!_sumSleepChart) {
        _sumSleepChart = [[PNBarChart alloc] init];
        [_sumSleepChart setStrokeColor:SLEEP_CURRENT_LOW_SLEEEP_BAR];
        _sumSleepChart.barBackgroundColor = [UIColor clearColor];
        _sumSleepChart.yChartLabelWidth = 20.0;
        _sumSleepChart.chartMarginLeft = 0;
        _sumSleepChart.chartMarginRight = 0;
        _sumSleepChart.chartMarginTop = 0;
        _sumSleepChart.chartMarginBottom = 0;
        _sumSleepChart.yMinValue = 0;
        _sumSleepChart.yMaxValue = 5;
        _sumSleepChart.barWidth = 12;
        _sumSleepChart.barRadius = 0;
        _sumSleepChart.showLabel = NO;
        _sumSleepChart.showChartBorder = NO;
        _sumSleepChart.isShowNumbers = NO;
        _sumSleepChart.isGradientShow = NO;
        
        [self.view addSubview:_sumSleepChart];
        [_sumSleepChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
    }
    
    return _sumSleepChart;
}

- (PNBarChart *)deepSleepChart
{
    if (!_deepSleepChart) {
        _deepSleepChart = [[PNBarChart alloc] init];
        [_deepSleepChart setStrokeColor:SLEEP_CURRENT_DEEP_SLEEEP_BAR];
        _deepSleepChart.barBackgroundColor = [UIColor clearColor];
        _deepSleepChart.yChartLabelWidth = 20.0;
        _deepSleepChart.chartMarginLeft = 0;
        _deepSleepChart.chartMarginRight = 0;
        _deepSleepChart.chartMarginTop = 0;
        _deepSleepChart.chartMarginBottom = 0;
        _deepSleepChart.yMinValue = 0;
        _deepSleepChart.yMaxValue = 5;
        _deepSleepChart.barWidth = 12;
        _deepSleepChart.barRadius = 0;
        _deepSleepChart.showLabel = NO;
        _deepSleepChart.showChartBorder = NO;
        _deepSleepChart.isShowNumbers = NO;
        _deepSleepChart.isGradientShow = NO;
        
        [self.view addSubview:_deepSleepChart];
        [_deepSleepChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
    }
    
    return _deepSleepChart;
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

- (NSMutableArray *)sumDataArr
{
    if (!_sumDataArr) {
        _sumDataArr = [NSMutableArray array];
    }
    
    return _sumDataArr;
}

- (NSMutableArray *)deepDataArr
{
    if (!_deepDataArr) {
        _deepDataArr = [NSMutableArray array];
    }
    
    return _deepDataArr;
}

- (NSMutableArray *)lowDataArr
{
    if (!_lowDataArr) {
        _lowDataArr = [NSMutableArray array];
    }
    
    return _lowDataArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.sumSleepChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sumSleepChart.mas_centerX);
            make.centerY.equalTo(self.sumSleepChart.mas_centerY);
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

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
