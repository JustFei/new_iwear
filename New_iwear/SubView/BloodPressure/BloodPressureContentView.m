//
//  BloodPressureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodPressureContentView.h"
#import "HeartRateHisViewController.h"
#import "UnitsTool.h"
#import "BleManager.h"
#import "PNChart.h"
#import "StepDataModel.h"

@interface BloodPressureContentView () < PNChartDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *BPLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *highBPLabel;
@property (nonatomic, strong) UILabel *lowBPLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) PNCircleChart *bpCircleChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *xArr;
@property (nonatomic, weak) PNBarChart *lowBloodChart;
@property (nonatomic, weak) PNBarChart *highBloodChart;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) NSMutableArray *hbArr;
@property (nonatomic, strong) NSMutableArray *lbArr;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;


@end

@implementation BloodPressureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBPData:) name:GET_BP_DATA object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = BP_HISTORY_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_width);
        }];
        
        [self.bpCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.bpCircleChart strokeChart];
        [self.bpCircleChart updateChartByCurrent:@(0.75)];
        
        [self.BPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.centerY.equalTo(self.bpCircleChart.mas_centerY);
        }];
        [self.BPLabel setText:@"--"];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"上次测量结果"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.bottom.equalTo(self.BPLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"bloodpressure_icon01"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.BPLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
            make.width.equalTo(self.BPLabel.mas_width).offset(-6 * VIEW_FRAME_WIDTH / 360);
            make.height.equalTo(@1);
        }];
        
        [self.lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bpCircleChart.mas_centerX);
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
        [view1Title setText:@"时间"];
        [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view1Title setFont:[UIFont systemFontOfSize:12]];
        [self.view1 addSubview:view1Title];
        [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setText:@"--"];
        [_timeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self.view1 addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view2Title setText:@"收缩压"];
        [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view2Title setFont:[UIFont systemFontOfSize:12]];
        [view2 addSubview:view2Title];
        [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view2.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _highBPLabel = [[UILabel alloc] init];
        [_highBPLabel setText:@"--"];
        [_highBPLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_highBPLabel setFont:[UIFont systemFontOfSize:14]];
        [view2 addSubview:_highBPLabel];
        [_highBPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view3Title setText:@"舒张压"];
        [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view3Title setFont:[UIFont systemFontOfSize:12]];
        [view3 addSubview:view3Title];
        [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _lowBPLabel = [[UILabel alloc] init];
        [_lowBPLabel setText:@"--"];
        [_lowBPLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_lowBPLabel setFont:[UIFont systemFontOfSize:14]];
        [view3 addSubview:_lowBPLabel];
        [_lowBPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.bottom.equalTo(@-17);
        }];
        
        UILabel *unitLabel = [[UILabel alloc] init];
        [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel setFont:[UIFont systemFontOfSize:8]];
        [unitLabel setText:@"次/分"];
        [self.view1 addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLabel.mas_right).offset(8);
            make.top.equalTo(_timeLabel.mas_bottom);
        }];
        UILabel *unitLabel2 = [[UILabel alloc] init];
        [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel2 setText:@"次/分"];
        [self.view1 addSubview:unitLabel2];
        [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_highBPLabel.mas_right).offset(8);
            make.top.equalTo(_highBPLabel.mas_bottom);
        }];
        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:@"次/分"];
        [self.view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_lowBPLabel.mas_right).offset(8);
            make.top.equalTo(_lowBPLabel.mas_bottom);
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
        [self.rightTimeLabel setText:@"23:59"];
        [self.rightTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.rightTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.rightTimeLabel];
        [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-16);
            make.bottom.equalTo(self.leftTimeLabel.mas_bottom);
        }];
        
        self.highBloodChart.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
        self.lowBloodChart.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.bpCircleChart strokeChart];
    });
    [self.bpCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"点击了 BPBarChart 的%ld", barIndex);
    [self.timeLabel setText:self.timeArr[barIndex]];
    [self.highBPLabel setText:[NSString stringWithFormat:@"%@", self.hbArr[barIndex]]];
    [self.lowBPLabel setText:[NSString stringWithFormat:@"%@", self.lbArr[barIndex]]];
}


#pragma mark - Action
- (void)showHisVC:(MDButton *)sender
{
    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
    vc.vcType = ViewControllerTypeBP;
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)getBPData:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodModel.bloodState == BloodDataHistoryData || model.bloodModel.bloodState == BloodDataUpload) {
        if ([model.bloodModel.highBloodString isEqualToString:@"0"] && [model.bloodModel.lowBloodString isEqualToString:@"0"]) {
            [self.BPLabel setText:@"--"];
            [self.lastTimeLabel setText:@""];
        }else {
            [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@", model.bloodModel.highBloodString, model.bloodModel.lowBloodString]];
            NSString *monthStr = [model.bloodModel.dayString substringWithRange:NSMakeRange(5, 2)];
            NSString *dayStr = [model.bloodModel.dayString substringWithRange:NSMakeRange(8, 2)];
            NSString *timeStr = [model.bloodModel.timeString substringWithRange:NSMakeRange(0, 5)];
            self.lastTimeLabel.text = [NSString stringWithFormat:@"%@月%@日 %@", monthStr, dayStr, timeStr];
        }
    }
}

/** 更新视图 */
- (void)updateBPUIWithDataArr:(NSArray *)dbArr
{
    /**
     1.更新血压记录的柱状图
     */
    float sumLowBp = 0;
    float sumHighBp = 0;
    [self.timeArr removeAllObjects];
    [self.hbArr removeAllObjects];
    [self.lbArr removeAllObjects];
    if (dbArr.count == 0) {
        [self showNoDataView];
        return ;
    }else  {
        self.noDataLabel.hidden = YES;
        for (NSInteger index = 0; index < dbArr.count; index ++) {
            BloodModel *model = dbArr[index];
            sumLowBp = sumLowBp + model.lowBloodString.floatValue;
            sumHighBp = sumHighBp + model.highBloodString.floatValue;
            [self.timeArr addObject:[model.timeString substringToIndex:5]];
            [self.hbArr addObject:@(model.highBloodString.integerValue)];
            [self.lbArr addObject:@(model.lowBloodString.integerValue)];
            [self.xArr addObject:@""];
            if (index == 0) {
                [self.leftTimeLabel setText:[model.timeString substringToIndex:5]];
            }
            if (index == dbArr.count - 1) {
                [self.rightTimeLabel setText:[model.timeString substringToIndex:5]];
            }
        }
    }

    BloodModel *model = dbArr.lastObject;
    [self.BPLabel setText:[NSString stringWithFormat:@"%@/%@",model.highBloodString, model.lowBloodString]];
    [self.lastTimeLabel setText:[NSString stringWithFormat:@"%@ %@", model.dayString, model.timeString]];
    [self.timeLabel setText:[model.timeString substringToIndex:5]];
    [self.highBPLabel setText:model.highBloodString];
    [self.lowBPLabel setText:model.lowBloodString];
    
    float lowProgress = model.lowBloodString.floatValue / 200;
    
    if (lowProgress <= 1) {
        [self drawProgress:lowProgress];
    }else if (lowProgress >= 1) {
        [self drawProgress:1];
    }
    [self.bpCircleChart updateChartByCurrent:@(lowProgress)];
    [self showChartViewWithData];
}

- (void)showChartViewWithData
{
    [self.lowBloodChart setXLabels:self.xArr];
    [self.lowBloodChart setYValues:self.lbArr];
//    [self.lowBloodChart strokeChart];
    [self.lowBloodChart updateChartData:self.lbArr];
    
    [self.highBloodChart setXLabels:self.xArr];
    [self.highBloodChart setYValues:self.hbArr];
//    [self.highBloodChart strokeChart];
    [self.highBloodChart updateChartData:self.hbArr];
}

- (void)showNoDataView
{
    self.noDataLabel.hidden = NO;
    [self.BPLabel setText:@"--"];
    [self.lastTimeLabel setText:@""];
    [self.timeLabel setText:@"--"];
    [self.highBPLabel setText:@"--"];
    [self.lowBPLabel setText:@"--"];
}

#pragma mamrk - 懒加载
- (PNCircleChart *)bpCircleChart
{
    if (!_bpCircleChart) {
        _bpCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:BP_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_bpCircleChart setStrokeColor:BP_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_bpCircleChart];
    }
    
    return _bpCircleChart;
}

- (PNBarChart *)lowBloodChart
{
    if (!_lowBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] init];
        view.delegate = self;
        [view setStrokeColor:COLOR_WITH_HEX(0x81c784, 0.54)];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.showLabel = NO;
        view.barWidth = 12;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(-11);
            make.right.equalTo(self.mas_right).offset(-11);
            make.bottom.equalTo(self.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _lowBloodChart = view;
    }
    
    return _lowBloodChart;
}

- (PNBarChart *)highBloodChart
{
    if (!_highBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] init];
        view.delegate = self;
        [view setStrokeColor:COLOR_WITH_HEX(0x4caf50, 0.54)];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.barWidth = 12;
        view.showLabel = NO;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
        _highBloodChart = view;
    }
    
    return _highBloodChart;
}

- (UILabel *)BPLabel
{
    if (!_BPLabel) {
        _BPLabel = [[UILabel alloc] init];
        [_BPLabel setTextColor:WHITE_COLOR];
        [_BPLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self addSubview:_BPLabel];
    }
    
    return _BPLabel;
}

- (UILabel *)lastTimeLabel
{
    if (!_lastTimeLabel) {
        _lastTimeLabel = [[UILabel alloc] init];
        [_lastTimeLabel setTextColor:WHITE_COLOR];
        [_lastTimeLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_lastTimeLabel];
    }
    
    return _lastTimeLabel;
}

- (NSMutableArray *)xArr
{
    if (!_xArr) {
        _xArr = [NSMutableArray array];
    }
    
    return _xArr;
}

- (NSMutableArray *)timeArr
{
    if (!_timeArr) {
        _timeArr = [NSMutableArray array];
    }
    
    return _timeArr;
}

- (NSMutableArray *)hbArr
{
    if (!_hbArr) {
        _hbArr = [NSMutableArray array];
    }
    
    return _hbArr;
}

- (NSMutableArray *)lbArr
{
    if (!_lbArr) {
        _lbArr = [NSMutableArray array];
    }
    
    return _lbArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.highBloodChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.highBloodChart.mas_centerX);
            make.centerY.equalTo(self.highBloodChart.mas_centerY);
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
