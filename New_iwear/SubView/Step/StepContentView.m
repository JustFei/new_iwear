
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "StepHisViewController.h"
#import "TrainingViewController.h"
#import "UnitsTool.h"
#import "PNChart.h"
#import "TargetSettingModel.h"
#import "StepDataModel.h"
#import "FMDBManager.h"

@interface StepContentView () < PNChartDelegate >
{
//    NSInteger sumStep;
//    NSInteger sumMileage;
//    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UILabel *view1StepLabel;
@property (nonatomic, strong) UILabel *view2MileageLabel;
@property (nonatomic, strong) UILabel *view3kCalLabel;
@property (nonatomic, strong) UILabel *unitLabel2;
@property (nonatomic, strong) PNCircleChart *stepCircleChart;
@property (nonatomic, strong) PNBarChart *stepBarChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *milArr;
@property (nonatomic, strong) NSMutableArray *kcalArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) UILabel *noDataLabel;

@end

@implementation StepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMotionData:) name:GET_MOTION_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleWhenTargetReset:) name:SET_MOTION_TARGET object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = STEP_CURRENT_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_width);
        }];
        
        [self.stepCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.stepCircleChart strokeChart];
        [self.stepCircleChart updateChartByCurrent:@(0)];
        
        [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.centerY.equalTo(self.stepCircleChart.mas_centerY);
        }];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:NSLocalizedString(@"todayStep", nil)];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.bottom.equalTo(self.stepLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"walk_walkicon"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.width.equalTo(@(158 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@1);
        }];
        
        [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.top.equalTo(lineView.mas_bottom).offset(2 * VIEW_FRAME_WIDTH / 360);
        }];
        
        MDButton *hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [hisBtn setImage:[UIImage imageNamed:@"all_historyicon"] forState:UIControlStateNormal];
        hisBtn.backgroundColor = CLEAR_COLOR;
        [hisBtn addTarget:self action:@selector(showHisVC:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:hisBtn];
        [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_upView.mas_right).offset(-16);
            make.bottom.equalTo(_upView.mas_bottom).offset(-16);
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }];
        
        MDButton *trainingBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [trainingBtn setImage:[UIImage imageNamed:@"walk_trainingicon"] forState:UIControlStateNormal];
        trainingBtn.backgroundColor = CLEAR_COLOR;
        [trainingBtn addTarget:self action:@selector(showTrainingVC:) forControlEvents:UIControlEventTouchUpInside];
        trainingBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_upView addSubview:trainingBtn];
        [trainingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(hisBtn.mas_left).offset(-8);
            make.bottom.equalTo(hisBtn.mas_bottom);
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }];
        //trainingBtn.hidden = YES;
        
        self.view1 = [[UIView alloc] init];
        self.view1.layer.borderWidth = 1;
        self.view1.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
        [self addSubview:self.view1];
        [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_upView.mas_bottom).offset(8);
            make.left.equalTo(self.mas_left).offset(-1);
            make.height.equalTo(@72);
            make.width.equalTo(@((VIEW_FRAME_WIDTH + 4) / 3));
        }];
        
        UILabel *view1Title = [[UILabel alloc] init];
        [view1Title setText:NSLocalizedString(@"stepValue", nil)];
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
        view2.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
        [self addSubview:view2];
        [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view1.mas_top);
            make.left.equalTo(self.view1.mas_right).offset(-1);
            make.height.equalTo(self.view1);
            make.width.equalTo(self.view1.mas_width);
        }];
        
        UILabel *view2Title = [[UILabel alloc] init];
        [view2Title setText:NSLocalizedString(@"mileageValue", nil)];
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
        [self addSubview:view3];
        [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view1.mas_top);
            make.left.equalTo(view2.mas_right).offset(-1);
            make.height.equalTo(self.view1);
            make.width.equalTo(self.view1.mas_width);
        }];
        
        UILabel *view3Title = [[UILabel alloc] init];
        [view3Title setText:NSLocalizedString(@"kcalValue", nil)];
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
        [unitLabel setText:NSLocalizedString(@"step1", nil)];
        [self.view1 addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_view1StepLabel.mas_right).offset(8);
            make.top.equalTo(_view1StepLabel.mas_bottom);
        }];
        self.unitLabel2 = [[UILabel alloc] init];
        [self.unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [self.unitLabel2 setFont:[UIFont systemFontOfSize:8]];
        if ([UnitsTool isMetricOrImperialSystem]) {
            [self.unitLabel2 setText:NSLocalizedString(@"kilometre", nil)];
        }else {
            [self.unitLabel2 setText:NSLocalizedString(@"mile", nil)];
        }
        
        [self.view1 addSubview:self.unitLabel2];
        [self.unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_view2MileageLabel.mas_right).offset(8);
            make.top.equalTo(_view2MileageLabel.mas_bottom);
        }];
        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:NSLocalizedString(@"kCalorie", nil)];
        [self.view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_view3kCalLabel.mas_right).offset(8);
            make.top.equalTo(_view3kCalLabel.mas_bottom);
        }];
        
        UILabel *leftTimeLabel = [[UILabel alloc] init];
        [leftTimeLabel setText:@"00:00"];
        [leftTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [leftTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:leftTimeLabel];
        [leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(16);
            make.bottom.equalTo(self.mas_bottom).offset(-12);
        }];
        
        UILabel *rightTimeLabel = [[UILabel alloc] init];
        [rightTimeLabel setText:@"23:59"];
        [rightTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [rightTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:rightTimeLabel];
        [rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-16);
            make.bottom.equalTo(leftTimeLabel.mas_bottom);
        }];
        
        //先展示数据库里的数据
        //步数 : 展示的是今天的数据
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"HH"];
        [formatter1 setDateFormat:@"yyyy/MM/dd"];
        [formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        NSString *todayString = [formatter1 stringFromDate:[NSDate date]];
        
        NSArray *stepArr = [self.myFmdbManager queryStepWithDate:todayString];
        if (stepArr.count) {
            SportModel *sportModel = stepArr.lastObject;
            self.stepLabel.text = sportModel.stepNumber;
            if ([UnitsTool isMetricOrImperialSystem]) {
                [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%.3f%@/%@%@", sportModel.mileageNumber.floatValue / 1000, NSLocalizedString(@"kilometre", nil), sportModel.kCalNumber, NSLocalizedString(@"kCalorie", nil)]];
                [self.unitLabel2 setText:NSLocalizedString(@"kilometre", nil)];
            }else {
                float km = [UnitsTool kmAndMi:(sportModel.mileageNumber.floatValue / 1000) withMode:MetricToImperial];
                [self.view2MileageLabel setText:[NSString stringWithFormat:@"%.3f", km]];
                [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%.3f%@/%@%@", km, NSLocalizedString(@"mile", nil), sportModel.kCalNumber, NSLocalizedString(@"kCalorie", nil)]];
                [self.unitLabel2 setText:NSLocalizedString(@"mile", nil)];
            }
            
            [self updateCircleWithFloat:sportModel.stepNumber.floatValue];
        }else {
            [self.stepLabel setText:@"--"];
            [self updateCircleWithFloat:0];
        }
        
        self.stepBarChart.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
        [self.stepBarChart strokeChart];
    }
    return self;
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"点击了 stepBarChart 的%ld", barIndex);
    [self.view1StepLabel setText:[NSString stringWithFormat:@"%@", self.dataArr[barIndex]]];
    [self.view3kCalLabel setText:[NSString stringWithFormat:@"%@", self.kcalArr[barIndex]]];
    if ([UnitsTool isMetricOrImperialSystem]) {
        [self.view2MileageLabel setText:[NSString stringWithFormat:@"%.3f", ((NSNumber *)self.milArr[barIndex]).floatValue / 1000]];
        [self.unitLabel2 setText:NSLocalizedString(@"kilometre", nil)];
    }else {
        float km = [UnitsTool kmAndMi:((NSString *)self.milArr[barIndex]).integerValue withMode:MetricToImperial];
        [self.view2MileageLabel setText:[NSString stringWithFormat:@"%0.3f", km / 1000]];
        [self.unitLabel2 setText:NSLocalizedString(@"mile", nil)];
    }
}


#pragma mark - Action
- (void)showHisVC:(MDButton *)sender
{
    StepHisViewController *vc = [[StepHisViewController alloc] init];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)showTrainingVC:(MDButton *)sender
{
    TrainingViewController *vc = [[TrainingViewController alloc] init];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

#pragma mark - noti motion
- (void)getMotionData:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.sportModel.motionType == MotionTypeStepAndkCal) {
        if ([model.sportModel.stepNumber isEqualToString:@"0"]) {
            [self.stepLabel setText:@"--"];
        }else {
            [self.stepLabel setText:[NSString stringWithFormat:@"%@", model.sportModel.stepNumber]];
            
            [self updateCircleWithFloat:model.sportModel.stepNumber.floatValue];
            [self.view1StepLabel setText:[NSString stringWithFormat:@"%@", model.sportModel.stepNumber]];
            //长度单位转换
            if ([UnitsTool isMetricOrImperialSystem]) {
                [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%.3f%@/%@%@", model.sportModel.mileageNumber.floatValue / 1000, NSLocalizedString(@"kilometre", nil), model.sportModel.kCalNumber, NSLocalizedString(@"kCalorie", nil)]];
                [self.view2MileageLabel setText:[NSString stringWithFormat:@"%.3f", model.sportModel.mileageNumber.floatValue / 1000]];
                [self.unitLabel2 setText:NSLocalizedString(@"kilometre", nil)];
            }else {
                float km = [UnitsTool kmAndMi:(model.sportModel.mileageNumber.floatValue / 1000) withMode:MetricToImperial];
                [self.view2MileageLabel setText:[NSString stringWithFormat:@"%.3f", km]];
                [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%.3f%@/%@%@", km, NSLocalizedString(@"mile", nil), model.sportModel.kCalNumber, NSLocalizedString(@"kCalorie", nil)]];
                [self.unitLabel2 setText:NSLocalizedString(@"mile", nil)];
            }
            
            [self.view3kCalLabel setText:[NSString stringWithFormat:@"%@",model.sportModel.kCalNumber]];
            
            //保存motion数据到数据库
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy/MM/dd"];
            NSDate *currentDate = [NSDate date];
            NSString *currentDateString = [dateformatter stringFromDate:currentDate];
            //存储至数据库
            NSArray *stepArr = [self.myFmdbManager queryStepWithDate:currentDateString];
            if (stepArr.count == 0) {
                [self.myFmdbManager insertStepModel:model.sportModel];
                
            }else {
                [self.myFmdbManager modifyStepWithDate:currentDateString model:model.sportModel];
            }
        }
    }
}

- (void)updateCircleWhenTargetReset:(NSNotification *)noti
{
    BOOL isFirst = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"isFirst:%d",isFirst);
    //这里不能直接写 if (isFirst),必须如下写法
    if (isFirst == 1) {
        //延迟一秒再去刷新圆环，因为保存目标到沙盒需要点时间
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateCircleWithFloat:self.stepLabel.text.floatValue];
        });
    }
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

/** 更新视图 */
- (void)updateStepUIWithDataArr:(NSArray *)dbArr
{
    /**
     1.更新按小时记录的柱状图
     */
    [self.dataArr removeAllObjects];
    [self.dateArr removeAllObjects];
    [self.milArr removeAllObjects];
    [self.kcalArr removeAllObjects];
    if (dbArr.count == 0) {
        [self showNoDataView];
        return ;
    }else {
        self.noDataLabel.hidden = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dbDic = [NSMutableDictionary dictionaryWithCapacity:dbArr.count];
            for (SegmentedStepModel *model in dbArr) {
                //            [self.dataArr addObject:@(model.stepNumber.integerValue)];
                [dbDic setObject:model  forKey:[model.startTime substringWithRange:NSMakeRange(11, 2)]];
                //设置数据源的最大值为 barChart 的最大值的2/3
                if (model.stepNumber.integerValue > self.stepBarChart.yMaxValue * 0.7) {
                    self.stepBarChart.yMaxValue = model.stepNumber.integerValue * 1.3;
                }
            }
            NSMutableArray *indexArr = [NSMutableArray array];
            for (int index = 0; index < 24; index ++) {
                [indexArr addObject:[NSString stringWithFormat:@"%02d", index]];
                [self.dateArr addObject:@""];
            }
            
            //从数组中取出该时间有没有计步信息，没有的填充0
            for (NSString *index in indexArr) {
                SegmentedStepModel *model = dbDic[index];
                if (model) {
                    [self.dataArr addObject:@(model.stepNumber.integerValue)];
                    [self.milArr addObject:@(model.mileageNumber.integerValue)];
                    [self.kcalArr addObject:@(model.kCalNumber.integerValue)];
                    NSLog(@"-----------kcal == %ld", model.kCalNumber.integerValue);
                }else {
                    [self.dataArr addObject:@(0)];
                    [self.milArr addObject:@(0)];
                    [self.kcalArr addObject:@(0)];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回主线程更新 UI
                [self.stepBarChart setXLabels:self.dateArr];
                [self.stepBarChart setYValues:self.dataArr];
                [self.stepBarChart updateChartData:self.dataArr];
            });
        });
    }
}

- (void)showNoDataView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataArr removeAllObjects];
        [self.dateArr removeAllObjects];
        [self.stepBarChart strokeChart];
        self.noDataLabel.hidden = NO;
//        self.stepBarChart.hidden = YES;
    });
}

#pragma mark - 懒加载
- (PNCircleChart *)stepCircleChart
{
    if (!_stepCircleChart) {
        _stepCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:STEP_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_stepCircleChart setStrokeColor:STEP_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_stepCircleChart];
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
        _stepBarChart.delegate = self;
        
        [self addSubview:_stepBarChart];
        [_stepBarChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
    }
    
    return _stepBarChart;
}

- (UILabel *)stepLabel
{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        [_stepLabel setTextColor:WHITE_COLOR];
        [_stepLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self addSubview:_stepLabel];
    }
    
    return _stepLabel;
}

- (UILabel *)mileageAndkCalLabel
{
    if (!_mileageAndkCalLabel) {
        _mileageAndkCalLabel = [[UILabel alloc] init];
        [_mileageAndkCalLabel setTextColor:WHITE_COLOR];
        [_mileageAndkCalLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_mileageAndkCalLabel];
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

- (NSMutableArray *)milArr
{
    if (!_milArr) {
        _milArr = [NSMutableArray array];
    }
    
    return _milArr;
}

- (NSMutableArray *)kcalArr
{
    if (!_kcalArr) {
        _kcalArr = [NSMutableArray array];
    }
    
    return _kcalArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:NSLocalizedString(@"noData", nil)];
        
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
