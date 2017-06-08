//
//  BloodO2ContentView.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/19.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodO2ContentView.h"
#import "HeartRateHisViewController.h"
#import "UnitsTool.h"
#import "BleManager.h"
#import "PNChart.h"
#import "FMDBManager.h"
#import "StepDataModel.h"

@interface BloodO2ContentView () < PNChartDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *BOLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
@property (nonatomic, strong) UILabel *avageBOLabel;
@property (nonatomic, strong) UILabel *lowBOLabel;
@property (nonatomic, strong) UILabel *highBOLabel;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UILabel *view1Title;
@property (nonatomic, strong) PNCircleChart *boCircleChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *xLabelArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) PNLineChart *BOChart;
@property (nonatomic, strong) NSMutableArray *boArr;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;


@end

@implementation BloodO2ContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBOData:) name:GET_BO_DATA object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = BO_HISTORY_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_width);
        }];
        
        [self.boCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.boCircleChart strokeChart];
        [self.boCircleChart updateChartByCurrent:@(0)];
        
        [self.BOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.centerY.equalTo(self.boCircleChart.mas_centerY);
        }];
        [self.BOLabel setText:@"--"];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"上次测量结果"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.bottom.equalTo(self.BOLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"bloodoxygen_icon01"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.BOLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.width.equalTo(self.BOLabel.mas_width).offset(-6 * VIEW_FRAME_WIDTH / 360);
            make.height.equalTo(@1);
        }];
        
        [self.lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
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
            make.width.equalTo(@28);
            make.height.equalTo(@28);
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
        
        self.view1Title = [[UILabel alloc] init];
        [self.view1Title setText:@"平均值"];
        [self.view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.view1Title setFont:[UIFont systemFontOfSize:12]];
        [self.view1 addSubview:self.view1Title];
        [self.view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _avageBOLabel = [[UILabel alloc] init];
        [_avageBOLabel setText:@"--"];
        [_avageBOLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_avageBOLabel setFont:[UIFont systemFontOfSize:14]];
        [self.view1 addSubview:_avageBOLabel];
        [_avageBOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view2Title setText:@"最低值"];
        [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view2Title setFont:[UIFont systemFontOfSize:12]];
        [view2 addSubview:view2Title];
        [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view2.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _lowBOLabel = [[UILabel alloc] init];
        [_lowBOLabel setText:@"--"];
        [_lowBOLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_lowBOLabel setFont:[UIFont systemFontOfSize:14]];
        [view2 addSubview:_lowBOLabel];
        [_lowBOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view3Title setText:@"最高值"];
        [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view3Title setFont:[UIFont systemFontOfSize:12]];
        [view3 addSubview:view3Title];
        [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _highBOLabel = [[UILabel alloc] init];
        [_highBOLabel setText:@"--"];
        [_highBOLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_highBOLabel setFont:[UIFont systemFontOfSize:14]];
        [view3 addSubview:_highBOLabel];
        [_highBOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.bottom.equalTo(@-17);
        }];
        
        UILabel *unitLabel = [[UILabel alloc] init];
        [unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel setFont:[UIFont systemFontOfSize:8]];
        [unitLabel setText:@"%"];
        [self.view1 addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avageBOLabel.mas_right).offset(8);
            make.top.equalTo(_avageBOLabel.mas_bottom);
        }];
        UILabel *unitLabel2 = [[UILabel alloc] init];
        [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel2 setText:@"%"];
        [self.view1 addSubview:unitLabel2];
        [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_lowBOLabel.mas_right).offset(8);
            make.top.equalTo(_lowBOLabel.mas_bottom);
        }];
        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:@"%"];
        [self.view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_highBOLabel.mas_right).offset(8);
            make.top.equalTo(_highBOLabel.mas_bottom);
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
    NSLog(@"点击了 BOLineChart 的%ld", pointIndex);
    [self.view1Title setText:self.timeArr[pointIndex]];
    CGFloat boValue = [self.boArr[pointIndex] floatValue];
    [self.avageBOLabel setText:[NSString stringWithFormat:@"%.0f", boValue]];
}

- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
{
    NSLog(@"点击了 BOLineChart 的%ld", lineIndex);
}


#pragma mark - Action
- (void)showHisVC:(MDButton *)sender
{
    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
    vc.vcType = ViewControllerTypeBO;
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)getBOData:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.bloodO2Model.bloodO2State == BloodO2DataHistoryData || model.bloodO2Model.bloodO2State == BloodO2DataUpload) {
        if ([model.bloodO2Model.integerString isEqualToString:@"0"] && [model.bloodO2Model.floatString isEqualToString:@"0"]) {
            [self.BOLabel setText:@"--"];
            [self.lastTimeLabel setText:@""];
        }else {
            [self.BOLabel setText:[NSString stringWithFormat:@"%@.%@", model.bloodO2Model.integerString, model.bloodO2Model.floatString]];
            
            NSString *monthStr = [model.bloodO2Model.dayString substringWithRange:NSMakeRange(5, 2)];
            NSString *dayStr = [model.bloodO2Model.dayString substringWithRange:NSMakeRange(8, 2)];
            NSString *timeStr = [model.bloodO2Model.timeString substringWithRange:NSMakeRange(0, 5)];
            self.lastTimeLabel.text = [NSString stringWithFormat:@"%@月%@日 %@", monthStr, dayStr, timeStr];
            
            float progress = self.BOLabel.text.floatValue / 100.f;
            [self.boCircleChart updateChartByCurrent:@(progress)];
        }
    }
}

/** 更新视图 */
- (void)updateBOUIWithDataArr:(NSArray *)dbArr
{
    //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
    [self.timeArr removeAllObjects];
    [self.boArr removeAllObjects];
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
                BloodO2Model *model = dbArr[index];
                float bo = [model.integerString stringByAppendingString:[NSString stringWithFormat:@".%@",model.floatString]].floatValue;
                [self.boArr addObject:@(bo)];
                [self.timeArr addObject:model.timeString];
                if (index == 0) {
                    [self.leftTimeLabel setText:[model.timeString substringToIndex:5]];
                }
                if (index == dbArr.count - 1) {
                    [self.rightTimeLabel setText:[model.timeString substringToIndex:5]];
                }
                
                if (bo >= self.BOChart.yFixedValueMax * 0.7) {
                    self.BOChart.yFixedValueMax = bo * 1.3;
                }
                
                [self.xLabelArr addObject:@""];
                //获取总数
                sumBo = sumBo + bo;
                //获取最大值
                if (bo > HighBo) {
                    HighBo = bo;
                }
                //获取最小值
                if (bo < lowBo) {
                    lowBo = bo;
                }
            }
        }
    
    BloodO2Model *model = dbArr.lastObject;
    //这里暂时只显示整数部分
    float bo = [model.integerString stringByAppendingString:[NSString stringWithFormat:@".%@",model.floatString]].floatValue;
    [self.BOLabel setText:[NSString stringWithFormat:@"%@.%@", model.integerString, model.floatString]];
    [self.lastTimeLabel setText:[NSString stringWithFormat:@"%@ %@", model.dayString, model.timeString]];
    float aveBo = sumBo / dbArr.count;
    [self.view1Title setText:@"平均心率"];
    [self.avageBOLabel setText:[NSString stringWithFormat:@"%.1f", aveBo]];
    [self.highBOLabel setText:[NSString stringWithFormat:@"%.1f", HighBo]];
    [self.lowBOLabel setText:[NSString stringWithFormat:@"%.1f", lowBo]];
    
    float progress = bo / 100;
    
    if (progress <= 1) {
        [self.boCircleChart updateChartByCurrent:@(progress)];
    }else if (progress >= 1) {
        [self.boCircleChart updateChartByCurrent:@(1)];
    }
    [self showChartViewWithData];
}

- (void)showNoDataView
{
    self.noDataLabel.hidden = NO;
    [self.BOLabel setText:@"--"];
    [self.view1Title setText:@"平均心率"];
    [self.lastTimeLabel setText:@""];
    [self.avageBOLabel setText:@"--"];
    [self.lowBOLabel setText:@"--"];
    [self.highBOLabel setText:@"--"];
}

- (void)showChartViewWithData
{
    [self.BOChart setXLabels:self.xLabelArr];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = BO_HISTORY_BACKGROUND_COLOR;
    data01.itemCount = self.BOChart.xLabels.count;
    data01.inflexionPointColor = BO_HISTORY_BACKGROUND_COLOR;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 2;
    data01.getData = ^(NSUInteger index) {
        //TODO:数组越界出现在这里
        CGFloat yValue = [self.boArr[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.BOChart.chartData = @[data01];
    [self.BOChart strokeChart];
}

#pragma mark - 懒加载
- (PNLineChart *)BOChart
{
    if (!_BOChart) {
        _BOChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, self.view1.frame.origin.y + self.view1.frame.size.height + 10, self.frame.size.width , self.frame.size.height - (34 + self.view1.frame.origin.y + self.view1.frame.size.height + 10))];

        _BOChart.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
        _BOChart.delegate = self;
        _BOChart.showCoordinateAxis = NO;
        _BOChart.yFixedValueMin = 70;
        _BOChart.yFixedValueMax = 110;
        [_BOChart setShowLabel:YES];
        [_BOChart setShowGenYLabels:NO];
        
        [self addSubview:_BOChart];
    }
    
    return _BOChart;
}

- (PNCircleChart *)boCircleChart
{
    if (!_boCircleChart) {
        _boCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:BO_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_boCircleChart setStrokeColor:BO_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_boCircleChart];
    }
    
    return _boCircleChart;
}

- (UILabel *)BOLabel
{
    if (!_BOLabel) {
        _BOLabel = [[UILabel alloc] init];
        [_BOLabel setTextColor:WHITE_COLOR];
        [_BOLabel setFont:[UIFont systemFontOfSize:50]];
        
        [self addSubview:_BOLabel];
    }
    
    return _BOLabel;
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

- (NSMutableArray *)xLabelArr
{
    if (!_xLabelArr) {
        _xLabelArr = [NSMutableArray array];
    }
    
    return _xLabelArr;
}



- (NSMutableArray *)timeArr
{
    if (!_timeArr) {
        _timeArr = [NSMutableArray array];
    }
    
    return _timeArr;
}

- (NSMutableArray *)boArr
{
    if (!_boArr) {
        _boArr = [NSMutableArray array];
    }
    
    return _boArr;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.BOChart addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.BOChart.mas_centerX);
            make.centerY.equalTo(self.BOChart.mas_centerY);
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
