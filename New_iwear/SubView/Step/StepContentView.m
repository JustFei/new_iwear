
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "AppDelegate.h"
//#import "StepHistoryViewController.h"
#import "BindPeripheralViewController.h"
#import "UnitsTool.h"

@interface StepContentView () 
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) PNCircleChart *stepCircleChart;

@end

@implementation StepContentView

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
        
//        self.stepCircleChart.backgroundColor = CLEAR_COLOR;
        [self.stepCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48);
            make.width.equalTo(@220);
            make.height.equalTo(@220);
        }];
        [self.stepCircleChart strokeChart];
        [self.stepCircleChart updateChartByCurrent:@(0.75)];
        
        [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.centerY.equalTo(self.stepCircleChart.mas_centerY);
        }];
        [self.stepLabel setText:@"28965"];
        
        [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.stepCircleChart.mas_centerX);
            make.top.equalTo(self.stepLabel.mas_bottom).offset(15);
        }];
        [self.mileageAndkCalLabel setText:@"23.7km/1800kcal"];
        
        
        
        sumStep = 0;
        sumMileage = 0;
        sumkCal = 0;
        
        self.dateArr = [NSMutableArray array];
        self.dataArr = [NSMutableArray array];
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.stepCircleChart strokeChart];
    });
    [self.stepCircleChart updateChartByCurrent:@(progress)];
}

//- (void)showChartView
//{
//    NSMutableArray *xLabelArr = [NSMutableArray array];
//    
//    for (__strong NSString *dateStr in self.dateArr) {
//        dateStr = [dateStr substringFromIndex:5];
//        DLog(@"querystring == %@",dateStr);
//        
//        [xLabelArr addObject:dateStr];
//    }
//    
//    [self.stepChart setXLabels:xLabelArr];
//    
//    PNLineChartData *data02 = [PNLineChartData new];
//    data02.color = PNTwitterColor;
//    data02.itemCount = self.stepChart.xLabels.count;
//    data02.inflexionPointColor = PNLightBlue;
//    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
//    data02.getData = ^(NSUInteger index) {
//        
//        SportModel *model = self.dataArr[index];
//        CGFloat yValue;
//        if (model.stepNumber != 0) {
//            yValue = model.stepNumber.integerValue;
//
//        }else {
//            yValue = 0;
//        }
//        
//        return [PNLineChartDataItem dataItemWithY:yValue];
//    };
//    
//    self.stepChart.chartData = @[data02];
//    [self.stepChart strokeChart];
//}
//
//- (void)showStepStateLabel
//{
//    for (int i = 0; i < self.dataArr.count; i ++) {
//        SportModel *model = self.dataArr[i];
//        
//        if (model.stepNumber != 0) {
//            sumStep += model.stepNumber.integerValue;
//            sumMileage += model.mileageNumber.integerValue;
//            sumkCal += model.kCalNumber.integerValue;
//        }
//    }
//    //    double mileage = sumMileage;
//    _isMetric = [UnitsTool isMetricOrImperialSystem];
//    //判断单位是英制还是公制
//    //TODO: 这里翻译还要改一下
//    [self.weekStatisticsLabel setText:[NSString stringWithFormat:_isMetric ?  NSLocalizedString(@"currentWeekStepData", nil) : NSLocalizedString(@"currentWeekStepDataImperial", nil),sumStep ,_isMetric ?  sumMileage / 1000.f : [UnitsTool kmAndMi:sumMileage / 1000.f withMode:ImperialToMetric] ,sumkCal]];
//    sumStep = sumMileage = sumkCal = 0;
//}

#pragma mark - PNChartDelegate



#pragma mark - Action
- (IBAction)setTargetAction:(UIButton *)sender
{
    StepTargetViewController *vc = [[StepTargetViewController alloc] initWithNibName:@"StepTargetViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 懒加载
- (PNCircleChart *)stepCircleChart
{
    if (!_stepCircleChart) {
        _stepCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectZero total:@1 current:@0 clockwise:YES shadow:YES shadowColor:TEXT_WHITE_COLOR_LEVEL1 displayCountingLabel:NO overrideLineWidth:@5];
        [_stepCircleChart setStrokeColor:COLOR_WITH_HEX(0xffeb3b, 0.87)];
        //[_stepCircleChart setStrokeColorGradientStart:[UIColor colorWithRed:1 green:1 blue:0 alpha:1]];
        
        [self addSubview:_stepCircleChart];
    }
    
    return _stepCircleChart;
}

- (UILabel *)stepLabel
{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        [_stepLabel setTextColor:WHITE_COLOR];
        [_stepLabel setFont:[UIFont systemFontOfSize:59]];
        
        [self addSubview:_stepLabel];
    }
    
    return _stepLabel;
}

- (UILabel *)mileageAndkCalLabel
{
    if (!_mileageAndkCalLabel) {
        _mileageAndkCalLabel = [[UILabel alloc] init];
        [_mileageAndkCalLabel setTextColor:WHITE_COLOR];
        [_mileageAndkCalLabel setFont:[UIFont systemFontOfSize:28]];
        
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
