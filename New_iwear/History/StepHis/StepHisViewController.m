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

@interface StepHisViewController ()< PNChartDelegate >
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) UILabel *view1StepLabel;
@property (nonatomic, strong) UILabel *view2MileageLabel;
@property (nonatomic, strong) UILabel *view3kCalLabel;
@property (nonatomic, strong) PNCircleChart *stepCircleChart;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation StepHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITE_COLOR;
    self.leftButton.backgroundColor = CLEAR_COLOR;
    self.title = @"历史记录";
    [self initUI];
    [self getDataFromDB];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self.navigationController.navigationBar setBackgroundColor:STEP_HISTORY_BACKGROUND_COLOR];
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
    [self.stepCircleChart updateChartByCurrent:@(0.75)];
    
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepCircleChart.mas_centerX);
        make.centerY.equalTo(self.stepCircleChart.mas_centerY);
    }];
    [self.stepLabel setText:@"69632"];
    
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
    [self.mileageAndkCalLabel setText:@"23.7km/1800kcal"];
    
    MDButton *hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    [hisBtn setTitle:@"本月" forState:UIControlStateNormal];
    [hisBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [hisBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
    hisBtn.backgroundColor = CLEAR_COLOR;
    [hisBtn addTarget:self action:@selector(showHisVC:) forControlEvents:UIControlEventTouchUpInside];
    [_upView addSubview:hisBtn];
    [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_upView.mas_right).offset(-16);
        make.bottom.equalTo(_upView.mas_bottom).offset(-16);
    }];
    
    UIView *view1 = [[UIView alloc] init];
    view1.layer.borderWidth = 1;
    view1.layer.borderColor = STEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_upView.mas_bottom).offset(8);
        make.left.equalTo(self.view.mas_left).offset(-1);
        make.height.equalTo(@72);
        make.width.equalTo(@((VIEW_CONTROLLER_FRAME_WIDTH + 4) / 3));
    }];
    
    UILabel *view1Title = [[UILabel alloc] init];
    [view1Title setText:@"总步数"];
    [view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
    [view1Title setFont:[UIFont systemFontOfSize:12]];
    [view1 addSubview:view1Title];
    [view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1.mas_centerX);
        make.top.equalTo(@18);
    }];
    
    _view1StepLabel = [[UILabel alloc] init];
    [_view1StepLabel setText:@"232651"];
    [_view1StepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view1StepLabel setFont:[UIFont systemFontOfSize:14]];
    [view1 addSubview:_view1StepLabel];
    [_view1StepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.borderWidth = 1;
    view2.layer.borderColor = STEP_HISTORY_BACKGROUND_COLOR.CGColor;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top);
        make.left.equalTo(view1.mas_right).offset(-1);
        make.height.equalTo(view1);
        make.width.equalTo(view1.mas_width);
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
    [_view2MileageLabel setText:@"180"];
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
        make.top.equalTo(view1.mas_top);
        make.left.equalTo(view2.mas_right).offset(-1);
        make.height.equalTo(view1);
        make.width.equalTo(view1.mas_width);
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
    [_view3kCalLabel setText:@"13265"];
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
    [view1 addSubview:unitLabel];
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view1StepLabel.mas_right).offset(8);
        make.top.equalTo(_view1StepLabel.mas_bottom);
    }];
    UILabel *unitLabel2 = [[UILabel alloc] init];
    [unitLabel2 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel2 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel2 setText:@"公里"];
    [view1 addSubview:unitLabel2];
    [unitLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view2MileageLabel.mas_right).offset(8);
        make.top.equalTo(_view2MileageLabel.mas_bottom);
    }];
    UILabel *unitLabel3 = [[UILabel alloc] init];
    [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
    [unitLabel3 setText:@"千卡"];
    [view1 addSubview:unitLabel3];
    [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_view3kCalLabel.mas_right).offset(8);
        make.top.equalTo(_view3kCalLabel.mas_bottom);
    }];
    
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.stepCircleChart strokeChart];
    });
    [self.stepCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate

#pragma mark - DB
- (void)getDataFromDB
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (; <#condition#>; <#increment#>) {
//            <#statements#>
//        }
//        self.myFmdbManager querySegmentedStepWithDate:<#(NSString *)#>
//    });
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHisVC:(MDButton *)sender
{
    
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
