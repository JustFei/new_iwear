//
//  SleepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepContentView.h"
#import "SleepHisViewController.h"
#import "UnitsTool.h"
#import "BleManager.h"
#import "PNChart.h"
#import "FMDBManager.h"
#import "StepDataModel.h"
#import "BarView.h"
#import "XXBarChartView.h"
#import "TargetSettingModel.h"

#define BACK_WIDTH self.sleepChartBackView.bounds.size.width
#define BACK_HEIGHT self.sleepChartBackView.bounds.size.height

@interface SleepContentView () < PNChartDelegate >
{
    NSInteger _currentSleepData;
    float clearData;
}

@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) PNCircleChart *sleepCircleChart;
@property (nonatomic, strong) XXBarChartView *sleepChartBackView;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) BleManager *myBleManager;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *noDataLabel;
//中间的需要修改的文本
@property (nonatomic, strong) UILabel *view1Title;
@property (nonatomic, strong) UILabel *InSleepLabel;
@property (nonatomic, strong) UILabel *view2Title;
@property (nonatomic, strong) UILabel *outSleepLabel;
@property (nonatomic, strong) UILabel *view3Title;
@property (nonatomic, strong) UILabel *awakeLabel;
//记录起始 model 和结束 model
@property (nonatomic, strong) SleepModel *startModel;
@property (nonatomic, strong) SleepModel *endModel;

@end

@implementation SleepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleWhenTargetReset:) name:SET_MOTION_TARGET object:nil];
        
        _upView = [[UIView alloc] init];
        _upView.backgroundColor = SLEEP_CURRENT_BACKGROUND_COLOR;
        [self addSubview:_upView];
        [_upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.mas_width);
        }];
        
        [self.sleepCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upView.mas_centerX);
            make.bottom.equalTo(_upView.mas_bottom).offset(-48 * VIEW_FRAME_WIDTH / 360);
            make.width.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
            make.height.equalTo(@(220 * VIEW_FRAME_WIDTH / 360));
        }];
        [self.sleepCircleChart strokeChart];
        [self.sleepCircleChart updateChartByCurrent:@(0)];
        
        [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sleepCircleChart.mas_centerX);
            make.centerY.equalTo(self.sleepCircleChart.mas_centerY);
        }];
        [self.stepLabel setText:@"--"];
        
        UILabel *todayLabel = [[UILabel alloc] init];
        [todayLabel setText:@"今日睡眠"];
        [todayLabel setTextColor:TEXT_WHITE_COLOR_LEVEL3];
        [todayLabel setFont:[UIFont systemFontOfSize:24]];
        [self addSubview:todayLabel];
        [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sleepCircleChart.mas_centerX);
            make.bottom.equalTo(self.stepLabel.mas_top).offset(-18 * VIEW_FRAME_WIDTH / 360);
        }];
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        [headImageView setImage:[UIImage imageNamed:@"sleep_sleep-icon"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sleepCircleChart.mas_centerX);
            make.bottom.equalTo(todayLabel.mas_top);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = WHITE_COLOR;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_FRAME_WIDTH / 360);
            make.centerX.equalTo(self.sleepCircleChart.mas_centerX);
            make.width.equalTo(self.stepLabel.mas_width).offset(-6 * VIEW_FRAME_WIDTH / 360);
            make.height.equalTo(@1);
        }];
        
        [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sleepCircleChart.mas_centerX);
            make.top.equalTo(lineView.mas_bottom).offset(2 * VIEW_FRAME_WIDTH / 360);
        }];
//        [self.mileageAndkCalLabel setText:@"23.7km/1800kcal"];
        
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
        
        self.view1Title = [[UILabel alloc] init];
        [self.view1Title setText:@"昨晚入睡"];
        [self.view1Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.view1Title setFont:[UIFont systemFontOfSize:12]];
        [self.view1 addSubview:self.view1Title];
        [self.view1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view1.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _InSleepLabel = [[UILabel alloc] init];
        [_InSleepLabel setText:@"--"];
        [_InSleepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_InSleepLabel setFont:[UIFont systemFontOfSize:14]];
        [self.view1 addSubview:_InSleepLabel];
        [_InSleepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        
        self.view2Title = [[UILabel alloc] init];
        [self.view2Title setText:@"今天醒来"];
        [self.view2Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.view2Title setFont:[UIFont systemFontOfSize:12]];
        [view2 addSubview:self.view2Title];
        [self.view2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view2.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _outSleepLabel = [[UILabel alloc] init];
        [_outSleepLabel setText:@"--"];
        [_outSleepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_outSleepLabel setFont:[UIFont systemFontOfSize:14]];
        [view2 addSubview:_outSleepLabel];
        [_outSleepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        
        self.view3Title = [[UILabel alloc] init];
        [self.view3Title setText:@"清醒时长"];
        [self.view3Title setTextColor:TEXT_BLACK_COLOR_LEVEL2];
        [self.view3Title setFont:[UIFont systemFontOfSize:12]];
        [view3 addSubview:self.view3Title];
        [self.view3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.top.equalTo(@18);
        }];
        
        _awakeLabel = [[UILabel alloc] init];
        [_awakeLabel setText:@"--"];
        [_awakeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_awakeLabel setFont:[UIFont systemFontOfSize:14]];
        [view3 addSubview:_awakeLabel];
        [_awakeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view3.mas_centerX);
            make.bottom.equalTo(@-17);
        }];

        UILabel *unitLabel3 = [[UILabel alloc] init];
        [unitLabel3 setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [unitLabel3 setFont:[UIFont systemFontOfSize:8]];
        [unitLabel3 setText:@"分"];
        [self.view1 addSubview:unitLabel3];
        [unitLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_awakeLabel.mas_right).offset(8);
            make.top.equalTo(_awakeLabel.mas_bottom);
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
        
        self.sleepChartBackView.backgroundColor = TEXT_BLACK_COLOR_LEVEL0;
    }
    return self;
}

/** 更新视图 */
- (void)updateSleepUIWithDataArr:(NSArray *)dbArr
{
    /**
     1.更新当天睡眠的 UI
     */
    float sumData = 0.f;
    float sumSleepData = 0.f;
    clearData = 0.f;
    float lowData = 0.f;
    float deepData = 0.f;
    if (dbArr.count == 0) {
        self.noDataLabel.hidden = NO;
        [self.stepLabel setText:@"--"];
        [self.mileageAndkCalLabel setText:@""];
        [self.InSleepLabel setText:@"--"];
        [self.outSleepLabel setText:@"--"];
        [self.awakeLabel setText:@"--"];
        [self.sleepCircleChart updateChartByCurrent:@0];
        //没有数据
    }else {
        self.noDataLabel.hidden = YES;
        NSMutableArray *barDataArr = [NSMutableArray array];
        for (int index = 0; index < dbArr.count; index ++) {
            SleepModel *model = dbArr[index];
            
            sumSleepData = sumSleepData + model.sumSleep.floatValue;
            lowData = lowData + model.lowSleep.floatValue;
            deepData = deepData + model.deepSleep.floatValue;
            clearData = clearData + model.clearTime.floatValue;
            if (model.type == SleepTypeClear) {
                sumData = sumData + model.clearTime.floatValue;
            }else {
                sumData = sumData + model.sumSleep.floatValue;
            }
            
            if (index == 0) {
                [self.InSleepLabel setText:[model.startTime substringFromIndex:11]];
                [self.leftTimeLabel setText:[model.startTime substringFromIndex:11]];
                self.startModel = model;
            }
            if (index == dbArr.count -1) {
                [self.outSleepLabel setText:[model.endTime substringFromIndex:11]];
                [self.rightTimeLabel setText:[model.endTime substringFromIndex:11]];
                _currentSleepData = 0;
                self.endModel = model;
            }
        }
        CGFloat averDeep = round((deepData / 60) * 10) / 10;
        CGFloat averLow = round((lowData / 60) * 10) / 10;
        [self.stepLabel setText:[NSString stringWithFormat:@"%.1f",averLow + averDeep]];
        [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"深睡%.1f小时/浅睡%.1f小时", averDeep, averLow]];
        [self.awakeLabel setText:[NSString stringWithFormat:@"%.0f", clearData]];
        
        //处理源数据，拼接成无间隙的数据源
        NSMutableArray *dealDbArr = [NSMutableArray array];
        SleepModel *oldModel = dbArr.firstObject;
        for (int index = 1; index < dbArr.count; index ++) {
            SleepModel *newModel = dbArr[index];
            if (newModel.type == oldModel.type) {
                if (newModel.type == SleepTypeDeep || newModel.type == SleepTypeLow) {
                    oldModel.sumSleep = [NSString stringWithFormat:@"%ld", oldModel.sumSleep.integerValue + newModel.sumSleep.integerValue];
                }else if (newModel.type == SleepTypeClear) {
                    oldModel.clearTime = [NSString stringWithFormat:@"%ld", oldModel.clearTime.integerValue + newModel.clearTime.integerValue];
                }
                oldModel.endTime = newModel.endTime;
            }else {
                [dealDbArr addObject:oldModel];
                oldModel = newModel;
            }
            if (index == dbArr.count - 1)  [dealDbArr addObject:oldModel];
        }
        
        DLog(@"%@", dealDbArr);
        
        for (int index = 0; index < dealDbArr.count; index ++) {
            SleepModel *model = dealDbArr[index];
            
            XXBarDataModel *barModel = [[XXBarDataModel alloc] init];
            float xValue = (float)_currentSleepData / sumData * (BACK_WIDTH - 32);
            float xWidth;
            if (model.type == SleepTypeClear) {
                xWidth = (float)model.clearTime.integerValue / sumData * (BACK_WIDTH - 32);
                _currentSleepData = _currentSleepData + model.clearTime.integerValue;
            }else {
                xWidth = (float)model.sumSleep.integerValue / sumData * (BACK_WIDTH - 32);
                _currentSleepData = _currentSleepData + model.sumSleep.integerValue;
            }
            barModel.xValue = xValue;
            barModel.xWidth = xWidth;
            barModel.barType = model.type;
            [barDataArr addObject:barModel];
        }
        [self drawCircle:sumSleepData / 60];
        //绘制睡眠图表
        [self.sleepChartBackView setXValues:barDataArr];
        [self.sleepChartBackView updateBar];
        
        __weak __typeof__(self) weakSelf = self;
        self.sleepChartBackView.sleepBarClickIndexBlock = ^(NSInteger index, BOOL select) {
            if (select) {       //选中的数据
                SleepModel *model = dealDbArr[index];
                switch (model.type) {
                    case SleepTypeDeep:
                    {
                        weakSelf.view1Title.text = @"深睡开始";
                        weakSelf.view2Title.text = @"深睡结束";
                        weakSelf.awakeLabel.text = model.sumSleep;
                    }
                        break;
                    case SleepTypeLow:
                    {
                        weakSelf.view1Title.text = @"浅睡开始";
                        weakSelf.view2Title.text = @"浅睡结束";
                        weakSelf.awakeLabel.text = model.sumSleep;
                    }
                        break;
                    case SleepTypeClear:
                    {
                        weakSelf.view1Title.text = @"清醒开始";
                        weakSelf.view2Title.text = @"清醒结束";
                        weakSelf.awakeLabel.text = model.clearTime;
                    }
                        break;
                        
                    default:
                        break;
                }
                weakSelf.view3Title.text = @"时长";
                weakSelf.InSleepLabel.text = [model.startTime substringFromIndex:11];
                weakSelf.outSleepLabel.text = [model.endTime substringFromIndex:11];
            }else {             //为选中的数据
                weakSelf.view1Title.text = @"昨晚入睡";
                weakSelf.view2Title.text = @"今天醒来";
                weakSelf.view3Title.text = @"清醒时长";
                weakSelf.InSleepLabel.text = [weakSelf.startModel.startTime substringFromIndex:11];
                weakSelf.outSleepLabel.text = [weakSelf.endModel.endTime substringFromIndex:11];
                weakSelf.awakeLabel.text = [NSString stringWithFormat:@"%.0f",clearData];
            }
        };
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
            [self drawCircle:self.stepLabel.text.floatValue];
        });
    }
}

//更新圆环
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
    [self.sleepCircleChart updateChartByCurrent:@(progress)];
}

#pragma mark - PNChartDelegate



#pragma mark - Action
- (void)showHisVC:(MDButton *)sender
{
    SleepHisViewController *vc = [[SleepHisViewController alloc] init];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (PNCircleChart *)sleepCircleChart
{
    if (!_sleepCircleChart) {
        _sleepCircleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 220 * VIEW_FRAME_WIDTH / 360, 220 * VIEW_FRAME_WIDTH / 360) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:SLEEP_CURRENT_SHADOW_CIRCLE_COLOR displayCountingLabel:NO overrideLineWidth:@10];
        [_sleepCircleChart setStrokeColor:SLEEP_CURRENT_CIRCLE_COLOR];
        
        [self addSubview:_sleepCircleChart];
    }
    
    return _sleepCircleChart;
}

- (XXBarChartView *)sleepChartBackView
{
    if (!_sleepChartBackView) {
        _sleepChartBackView = [[XXBarChartView alloc] init];
        
        [self addSubview:_sleepChartBackView];
        [_sleepChartBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom).offset(-34);
            make.top.equalTo(self.view1.mas_bottom).offset(10);
        }];
    }
    
    return _sleepChartBackView;
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

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setText:@"无数据"];
        
        [self.sleepChartBackView addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.sleepChartBackView.mas_centerX);
            make.centerY.equalTo(self.sleepChartBackView.mas_centerY);
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
