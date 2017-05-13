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
//#import "FMDBTool.h"
#import "StepDataModel.h"

@interface BloodO2ContentView () < PNChartDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *lastTimeLabel;
@property (nonatomic, strong) UILabel *avageBOLabel;
@property (nonatomic, strong) UILabel *lowBOLabel;
@property (nonatomic, strong) UILabel *highBOLabel;
@property (nonatomic, strong) PNCircleChart *boCircleChart;
@property (nonatomic ,strong) BleManager *myBleManager;
@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;

@end

@implementation BloodO2ContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = STEP_CURRENT_BACKGROUND_COLOR;
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
        [self.boCircleChart updateChartByCurrent:@(0.75)];
        
        [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.centerY.equalTo(self.boCircleChart.mas_centerY);
        }];
        [self.stepLabel setText:@"98.5"];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"上次测量结果"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.bottom.equalTo(self.stepLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"walk_walkicon"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.width.equalTo(self.stepLabel.mas_width).offset(-6 * VIEW_FRAME_WIDTH / 360);
            make.height.equalTo(@1);
        }];
        
        [self.lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.boCircleChart.mas_centerX);
            make.top.equalTo(lineView.mas_bottom).offset(2 * VIEW_FRAME_WIDTH / 360);
        }];
        [self.lastTimeLabel setText:@"4月23日 23:48"];
        
        MDButton *hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [hisBtn setImage:[UIImage imageNamed:@"walk_trainingicon"] forState:UIControlStateNormal];
        hisBtn.backgroundColor = CLEAR_COLOR;
        [hisBtn addTarget:self action:@selector(showHisVC:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:hisBtn];
        [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_upView.mas_right).offset(-16);
            make.bottom.equalTo(_upView.mas_bottom).offset(-16);
        }];
        
        MDButton *trainingBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [trainingBtn setImage:[UIImage imageNamed:@"walk_trainingicon"] forState:UIControlStateNormal];
        trainingBtn.backgroundColor = CLEAR_COLOR;
        [trainingBtn addTarget:self action:@selector(showTrainingVC:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:trainingBtn];
        [trainingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(hisBtn.mas_left).offset(-8);
            make.bottom.equalTo(hisBtn.mas_bottom);
        }];
        
        UIView *view1 = [[UIView alloc] init];
        view1.layer.borderWidth = 1;
        view1.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
        [self addSubview:view1];
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_upView.mas_bottom).offset(8);
            make.left.equalTo(self.mas_left).offset(-1);
            make.height.equalTo(@72);
            make.width.equalTo(@((VIEW_FRAME_WIDTH + 4) / 3));
        }];
        
        UILabel *view1Title = [[UILabel alloc] init];
        [view1Title setText:@"平均值"];
        [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view1Title setFont:[UIFont systemFontOfSize:12]];
        [view1 addSubview:view1Title];
        [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _avageBOLabel = [[UILabel alloc] init];
        [_avageBOLabel setText:@"97.5"];
        [_avageBOLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_avageBOLabel setFont:[UIFont systemFontOfSize:14]];
        [view1 addSubview:_avageBOLabel];
        [_avageBOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view1.mas_centerX);
            make.bottom.equalTo(@-17);
        }];
        
        UIView *view2 = [[UIView alloc] init];
        view2.layer.borderWidth = 1;
        view2.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
        [self addSubview:view2];
        [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view1.mas_top);
            make.left.equalTo(view1.mas_right).offset(-1);
            make.height.equalTo(view1);
            make.width.equalTo(view1.mas_width);
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
        [_lowBOLabel setText:@"95.3"];
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
            make.top.equalTo(view1.mas_top);
            make.left.equalTo(view2.mas_right).offset(-1);
            make.height.equalTo(view1);
            make.width.equalTo(view1.mas_width);
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
        [_highBOLabel setText:@"98.2"];
        [_highBOLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_highBOLabel setFont:[UIFont systemFontOfSize:14]];
        [view3 addSubview:_highBOLabel];
        [_highBOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.bottom.equalTo(@-17);
        }];
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.boCircleChart strokeChart];
    });
    [self.boCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate



#pragma mark - Action
- (void)showHisVC:(MDButton *)sender
{
    HeartRateHisViewController *vc = [[HeartRateHisViewController alloc] init];
    vc.vcType = ViewControllerTypeBO;
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

- (void)showTrainingVC:(MDButton *)sender
{
    
}


#pragma mark - 懒加载
- (PNCircleChart *)boCircleChart
{
    if (!_boCircleChart) {
        _boCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:STEP_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_boCircleChart setStrokeColor:STEP_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_boCircleChart];
    }
    
    return _boCircleChart;
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
