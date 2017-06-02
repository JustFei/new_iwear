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
//#import "FMDBTool.h"
#import "StepDataModel.h"

@interface HeartRateContentView () < PNChartDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *hrLabel;
@property (nonatomic, strong) MDButton *singleTestButton;
@property (nonatomic, strong) UILabel *averageHR;
@property (nonatomic, strong) UILabel *minHR;
@property (nonatomic, strong) UILabel *maxHR;
@property (nonatomic, strong) PNCircleChart *hrCircleChart;
@property (nonatomic ,strong) BleManager *myBleManager;
@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;

@end

@implementation HeartRateContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHrData:) name:GET_HR_DATA object:nil];
        
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
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"上次测量结果"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.bottom.equalTo(self.hrLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"heart_heart-icon"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hrLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.hrCircleChart.mas_centerX);
            make.width.equalTo(self.hrLabel.mas_width).offset(-6 * VIEW_FRAME_WIDTH / 360);
            make.height.equalTo(@1);
        }];
        
        [self.singleTestButton setTitle:@"测量" forState:UIControlStateNormal];
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
        [hisBtn setImage:[UIImage imageNamed:@"walk_trainingicon"] forState:UIControlStateNormal];
        hisBtn.backgroundColor = CLEAR_COLOR;
        [hisBtn addTarget:self action:@selector(showHisVC:) forControlEvents:UIControlEventTouchUpInside];
        [_upView addSubview:hisBtn];
        [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_upView.mas_right).offset(-16);
            make.bottom.equalTo(_upView.mas_bottom).offset(-16);
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
        [view1Title setText:@"平均心率"];
        [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view1Title setFont:[UIFont systemFontOfSize:12]];
        [view1 addSubview:view1Title];
        [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _averageHR = [[UILabel alloc] init];
        [_averageHR setText:@"78"];
        [_averageHR setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_averageHR setFont:[UIFont systemFontOfSize:14]];
        [view1 addSubview:_averageHR];
        [_averageHR mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [view2Title setText:@"最低心率"];
        [view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view2Title setFont:[UIFont systemFontOfSize:12]];
        [view2 addSubview:view2Title];
        [view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view2.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _minHR = [[UILabel alloc] init];
        [_minHR setText:@"57"];
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
            make.top.equalTo(view1.mas_top);
            make.left.equalTo(view2.mas_right).offset(-1);
            make.height.equalTo(view1);
            make.width.equalTo(view1.mas_width);
        }];
        
        UILabel *view3Title = [[UILabel alloc] init];
        [view3Title setText:@"最高心率"];
        [view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [view3Title setFont:[UIFont systemFontOfSize:12]];
        [view3 addSubview:view3Title];
        [view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _maxHR = [[UILabel alloc] init];
        [_maxHR setText:@"115"];
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
        [unitLabel setText:@"次/分"];
        [view1 addSubview:unitLabel];
        [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_averageHR.mas_right).offset(8);
            make.top.equalTo(_averageHR.mas_bottom);
        }];
        UILabel *unitLabel2 = [[UILabel alloc] init];
        [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel2 setText:@"次/分"];
        [view1 addSubview:unitLabel2];
        [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_minHR.mas_right).offset(8);
            make.top.equalTo(_minHR.mas_bottom);
        }];
        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:@"次/分"];
        [view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_maxHR.mas_right).offset(8);
            make.top.equalTo(_maxHR.mas_bottom);
        }];
    }
    return self;
}

//- (void)drawProgress:(CGFloat )progress
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self.hrCircleChart strokeChart];
//    });
//    [self.hrCircleChart updateChartByCurrent:@(progress)];
//}

#pragma mark - PNChartDelegate



#pragma mark - Action
- (void)testHR:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        if ([sender.titleLabel.text isEqualToString:@"测量"]) {
            [[BleManager shareInstance] writeHeartRateTestStateToPeripheral:HeartRateDataStateSingle];
            [sender setTitle:@"停止" forState:UIControlStateNormal];
        }else {
            [[BleManager shareInstance] writeHeartRateTestStateToPeripheral:HeartRateTestStateStop];
            [sender setTitle:@"测量" forState:UIControlStateNormal];
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

#pragma mark - 懒加载
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
