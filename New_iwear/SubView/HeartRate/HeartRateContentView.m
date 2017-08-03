//
//  HeartRateContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateContentView.h"
#import "HeartRateHisViewController.h"
#import "UnitsTool.h"
#import "BleManager.h"
#import "PNChart.h"
#import "StepDataModel.h"

@interface HeartRateContentView () < PNChartDelegate >

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *todayLabel;
@property (nonatomic, strong) UILabel *hrLabel;
@property (nonatomic, strong) MDButton *singleTestButton;
@property (nonatomic, strong) UILabel *averageHR;
@property (nonatomic, strong) UILabel *minHR;
@property (nonatomic, strong) UILabel *maxHR;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UILabel *view1Title;
@property (nonatomic, strong) PNCircleChart *hrCircleChart;
@property (nonatomic, strong) PNLineChart *hrBarChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *xLabelArr;
@property (nonatomic, strong) NSMutableArray *hrArr;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;


@end

@implementation HeartRateContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHrData:) name:GET_HR_DATA object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHRTestState:) name:SET_HR_STATE object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = HR_CURRENT_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_width);
        }];
        
        [self.hrCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.hrCircleChart strokeChart];
        [self.hrCircleChart updateChartByCurrent:@(0)];
        
        [self.hrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.centerY.equalTo(self.hrCircleChart.mas_centerY);
        }];
        [self.hrLabel setText:@"--"];
        
        self.todayLabel = [[UILabel alloc] init];
        [self.todayLabel setText:NSLocalizedString(@"lastTestResult", nil)];
        [self.todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [self.todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:self.todayLabel];
        [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.bottom.equalTo(self.hrLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"heart_heart-icon"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.bottom.equalTo(self.todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hrLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.width.equalTo(@(158 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@1);
        }];
        
        [self.singleTestButton setTitle:NSLocalizedString(@"test", nil) forState:UIControlStateNormal];
        [self.singleTestButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.top.equalTo(lineView.mas_bottom).offset(8 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@92);
            make.height.equalTo(@36);
        }];
        _singleTestButton.layer.masksToBounds = YES;
        _singleTestButton.layer.cornerRadius = 18;
        _singleTestButton.layer.borderColor = TEXT_WHITE_COLOR_LEVEL3.CGColor;
        _singleTestButton.layer.borderWidth = 1;
        
        
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
        [trainingBtn setImage:[UIImage imageNamed:@"heart_measure"] forState:UIControlStateNormal];
        trainingBtn.backgroundColor = CLEAR_COLOR;
        [trainingBtn addTarget:self action:@selector(showTrainingVC:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:trainingBtn];
        [trainingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(hisBtn.mas_left).offset(-8);
            make.bottom.equalTo(hisBtn.mas_bottom);
        }];
        trainingBtn.hidden = YES;
        
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
        
        self.view1Title = [[UILabel alloc] init];
        [self.view1Title setText:NSLocalizedString(@"averageHr", nil)];
        [self.view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.view1Title setFont:[UIFont systemFontOfSize:12]];
        [self.view1 addSubview:self.view1Title];
        [self.view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _averageHR = [[UILabel alloc] init];
        [_averageHR setText:@"--"];
        [_averageHR setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_averageHR setFont:[UIFont systemFontOfSize:14]];
        [self.view1 addSubview:_averageHR];
        [_averageHR mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view2Title setText:NSLocalizedString(@"minimumHr", nil)];
        [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view2Title setFont:[UIFont systemFontOfSize:12]];
        [view2 addSubview:view2Title];
        [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view2.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _minHR = [[UILabel alloc] init];
        [_minHR setText:@"--"];
        [_minHR setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_minHR setFont:[UIFont systemFontOfSize:14]];
        [view2 addSubview:_minHR];
        [_minHR mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view3Title setText:NSLocalizedString(@"maximumHr", nil)];
        [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view3Title setFont:[UIFont systemFontOfSize:12]];
        [view3 addSubview:view3Title];
        [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _maxHR = [[UILabel alloc] init];
        [_maxHR setText:@"--"];
        [_maxHR setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_maxHR setFont:[UIFont systemFontOfSize:14]];
        [view3 addSubview:_maxHR];
        [_maxHR mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.bottom.equalTo(@-17);
        }];
        
        UILabel *unitLabel = [[UILabel alloc] init];
        [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel setFont:[UIFont systemFontOfSize:8]];
        [unitLabel setText:NSLocalizedString(@"time/min", nil)];
        [self.view1 addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_averageHR.mas_right).offset(8);
            make.top.equalTo(_averageHR.mas_bottom);
        }];
        UILabel *unitLabel2 = [[UILabel alloc] init];
        [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel2 setText:NSLocalizedString(@"time/min", nil)];
        [self.view1 addSubview:unitLabel2];
        [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_minHR.mas_right).offset(8);
            make.top.equalTo(_minHR.mas_bottom);
        }];
        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:NSLocalizedString(@"time/min", nil)];
        [self.view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_maxHR.mas_right).offset(8);
            make.top.equalTo(_maxHR.mas_bottom);
        }];
        
        self.leftTimeLabel = [[UILabel alloc] init];
        [self.leftTimeLabel setText:@"00:00"];
        [self.leftTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.leftTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.leftTimeLabel];
        [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(16);
            make.bottom.equalTo(self.mas_bottom).offset(-12);
        }];
        
        self.rightTimeLabel = [[UILabel alloc] init];
        [self.self.rightTimeLabel setText:@"23:59"];
        [self.rightTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.rightTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.rightTimeLabel];
        [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-16);
            make.bottom.equalTo(self.leftTimeLabel.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - PNChartDelegate
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex
{
    NSLog(@"点击了 HRLineChart 的%ld", pointIndex);
    [self.view1Title setText:self.timeArr[pointIndex]];
    CGFloat hrValue = [self.hrArr[pointIndex] floatValue];
    [self.averageHR setText:[NSString stringWithFormat:@"%.0f", hrValue]];
}

- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
{
    NSLog(@"点击了 HRLineChart 的%ld", lineIndex);
}


#pragma mark - Action
- (void)testHR:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"test", nil)]) {
            [[BleManager shareInstance] writeHeartRateTestStateToPeripheral:HeartRateDataStateSingle];
            sender.enabled = NO;
        }else {
            [[BleManager shareInstance] writeHeartRateTestStateToPeripheral:HeartRateTestStateStop];
        }
        
    }
}

- (void)showHisVC:(MDButton *)sender
{
    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
    vc.vcType = ViewControllerTypeHR;
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)showTrainingVC:(MDButton *)sender
{
    
}

- (void)getHrData:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.heartRateModel.heartRateState == HeartRateDataContinuous || model.heartRateModel.heartRateState == HeartRateDataUpload) {
        if ([model.heartRateModel.heartRate isEqualToString:@"0"]) {
            [self.hrLabel setText:@"--"];
        }else {
            [self.hrLabel setText:model.heartRateModel.heartRate];
            float progress = model.heartRateModel.heartRate.floatValue / 200.f;
            [self.hrCircleChart updateChartByCurrent:@(progress)];
        }
    }
}

- (void)getHRTestState:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.heartRateModel.heartRateState == HeartRateDataSingleTestSuccess) {
        if (model.heartRateModel.singleTestSuccess) {
            self.singleTestButton.enabled = YES;
            [self.singleTestButton setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            [self.todayLabel setText:NSLocalizedString(@"testing", nil)];
        }else {
            self.singleTestButton.enabled = YES;
            MDToast *failToast = [[MDToast alloc] initWithText:NSLocalizedString(@"testFail", nil) duration:1.5];
            [failToast show];
            [self.todayLabel setText:NSLocalizedString(@"lastTestHr", nil)];
        }
    }else if (model.heartRateModel.heartRateState == HeartRateDataUpload) {
        //每次进入主界面时同步数据
        [[SyncTool shareInstance] syncAllData];
        self.singleTestButton.enabled = YES;
        [self.singleTestButton setTitle:NSLocalizedString(@"test", nil) forState:UIControlStateNormal];
        [self.todayLabel setText:NSLocalizedString(@"testEnd", nil)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.todayLabel setText:NSLocalizedString(@"lastTestHr", nil)];
        });
    }
}

/** 更新视图 */
- (void)updateHRUIWithDataArr:(NSArray *)dbArr
{
    //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
    [self.hrArr removeAllObjects];
    [self.timeArr removeAllObjects];
    [self.xLabelArr removeAllObjects];
    
    float sumBo = 0;
    float HighBo = 0;
    float lowBo = 10000;
    if (dbArr.count == 0) {
        [self showNoDataView];
        return;
    }else {
        self.noDataLabel.hidden = YES;
        for (NSInteger index = 0; index < dbArr.count; index ++) {
            HeartRateModel *model = dbArr[index];
            float hr = model.heartRate.floatValue;
            [self.hrArr addObject:@(hr)];
            [self.timeArr addObject:[model.time substringWithRange:NSMakeRange(6, 5)]];
            if (index == 0) {
                [self.leftTimeLabel setText:[model.time substringWithRange:NSMakeRange(6, 5)]];
            }
            if (index == dbArr.count - 1) {
                [self.rightTimeLabel setText:[model.time substringWithRange:NSMakeRange(6, 5)]];
            }

            if (hr >= self.hrBarChart.yFixedValueMax * 0.7) {
                self.hrBarChart.yFixedValueMax = hr * 1.3;
            }
            
            [self.xLabelArr addObject:@""];
            //获取总数
            sumBo = sumBo + hr;
            //获取最大值
            if (hr > HighBo) {
                HighBo = hr;
            }
            //获取最小值
            if (hr < lowBo) {
                lowBo = hr;
            }
        }
    }
    
    HeartRateModel *model = dbArr.lastObject;
    //这里暂时只显示整数部分
    [self.hrLabel setText:model.heartRate];
    float aveBo = sumBo / dbArr.count;
    [self.view1Title setText:NSLocalizedString(@"averageHr", nil)];
    [self.averageHR setText:[NSString stringWithFormat:@"%.0f", aveBo]];
    [self.maxHR setText:[NSString stringWithFormat:@"%.0f", HighBo]];
    [self.minHR setText:[NSString stringWithFormat:@"%.0f", lowBo]];
    
    float highProgress = model.heartRate.floatValue / 220;
    
    if (highProgress <= 1) {
        [self.hrCircleChart updateChartByCurrent:@(highProgress)];
    }else if (highProgress >= 1) {
        [self.hrCircleChart updateChartByCurrent:@(1)];
    }
    [self showChartViewWithData];
}

- (void)showNoDataView
{
    self.noDataLabel.hidden = NO;
    [self.hrLabel setText:@"--"];
    [self.view1Title setText:NSLocalizedString(@"averageHr", nil)];
    [self.averageHR setText:@"--"];
    [self.minHR setText:@"--"];
    [self.maxHR setText:@"--"];
}

- (void)showChartViewWithData
{
    [self.hrBarChart setXLabels:self.xLabelArr];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = HR_CURRENT_BACKGROUND_COLOR;
    data01.itemCount = self.hrBarChart.xLabels.count;
    data01.inflexionPointColor = HR_CURRENT_BACKGROUND_COLOR;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 2;
    data01.getData = ^(NSUInteger index) {
        //TODO:数组越界出现在这里
        CGFloat yValue = [self.hrArr[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.hrBarChart.chartData = @[data01];
    [self.hrBarChart strokeChart];
}

#pragma mark - 懒加载
- (PNLineChart *)hrBarChart
{
    if (!_hrBarChart) {
        _hrBarChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, self.view1.frame.origin.y + self.view1.frame.size.height + 10, self.frame.size.width , self.frame.size.height - (34 + self.view1.frame.origin.y + self.view1.frame.size.height + 10))];
        
        _hrBarChart.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
        _hrBarChart.delegate = self;
        _hrBarChart.showCoordinateAxis = NO;
        _hrBarChart.yFixedValueMin = 0;
        _hrBarChart.yFixedValueMax = 220;
        [_hrBarChart setShowLabel:YES];
        [_hrBarChart setShowGenYLabels:NO];
        
        [self addSubview:_hrBarChart];
    }
    
    return _hrBarChart;
}

- (PNCircleChart *)hrCircleChart
{
    if (!_hrCircleChart) {
        _hrCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:HR_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_hrCircleChart setStrokeColor:HR_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_hrCircleChart];
    }
    
    return _hrCircleChart;
}

- (UILabel *)hrLabel
{
    if (!_hrLabel) {
        _hrLabel = [[UILabel alloc] init];
        [_hrLabel setTextColor:WHITE_COLOR];
        [_hrLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self addSubview:_hrLabel];
    }
    
    return _hrLabel;
}

- (MDButton *)singleTestButton
{
    if (!_singleTestButton) {
        _singleTestButton = [[MDButton alloc] init];
        [_singleTestButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [_singleTestButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _singleTestButton.backgroundColor = CLEAR_COLOR;
        [_singleTestButton addTarget:self action:@selector(testHR:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_singleTestButton];
    }
    
    return _singleTestButton;
}



- (NSMutableArray *)xLabelArr
{
    if (!_xLabelArr) {
        _xLabelArr = [NSMutableArray array];
    }
    
    return _xLabelArr;
}

- (NSMutableArray *)hrArr
{
    if (!_hrArr) {
        _hrArr = [NSMutableArray array];
    }
    
    return _hrArr;
}

- (NSMutableArray *)timeArr
{
    if (!_timeArr) {
        _timeArr = [NSMutableArray array];
    }
    
    return _timeArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:NSLocalizedString(@"noData", nil)];
        
        [self.hrBarChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrBarChart.mas_centerX);
            make.centerY.equalTo(self.hrBarChart.mas_centerY);
        }];
    }
    
    return _noDataLabel;
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
