//
//  TrainingViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TrainingViewController.h"
#import "TrainingTableCell.h"
#import "FMDBManager.h"
#import "PNChart.h"

static NSString * const TrainingTableCellID = @"TrainingTableCell";

@interface TrainingViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CGFloat offsetH;
    CGFloat turnOffsetH;
    CGFloat slideH;
    CGFloat kScreenW;
    BOOL isSlideMax;
}

@property (nonatomic) UIView *headTopView;
@property (nonatomic) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *tableDataArr;
@property (nonatomic, strong) NSMutableArray *barChartDataArr;
@property (nonatomic, strong) NSMutableArray *xArr;
@property (nonatomic, strong) FMDBManager *myFmdbManager;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) PNBarChart *runBarChart;


@end

@implementation TrainingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"训练";
    
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = TRAINING_BACKGROUND_COLOR;
    self.dataTableView.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.runBarChart.backgroundColor = CLEAR_COLOR;
    [self.runBarChart strokeChart];
    
    [self.hud showAnimated:YES];
    self.noDataLabel.hidden = YES;
    [self getDataFromDBWithDate:[NSDate date]];
}

- (void)getDataFromDBWithDate:(NSDate *)queryDate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        formatter1.dateFormat = @"yyyy-MM-dd";
        NSArray *runDataArr = [self.myFmdbManager querySegmentedRunWithDate:[formatter1 stringFromDate:queryDate]];
        if (runDataArr.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
                self.noDataLabel.hidden = NO;
            });
            return ;
        }else {
            [self.tableDataArr removeAllObjects];
            [self.barChartDataArr removeAllObjects];
            [self.xArr removeAllObjects];
            
            for (SegmentedRunModel *model in runDataArr) {
                //获取列表数据源
                TrainingTableModel *tableModel = [[TrainingTableModel alloc] init];
                tableModel.periodStr = model.startTime;
                tableModel.sportTypeStr = @"跑步";
                tableModel.timeCountStr = [NSString stringWithFormat:@"%ld", model.timeInterval];
                tableModel.stepStr = model.stepNumber;
                tableModel.kcalStr = model.kCalNumber;
                [self.tableDataArr addObject:tableModel];
                
                //获取 barChart 的数据源
                [self.barChartDataArr addObject:@(model.stepNumber.integerValue)];
                
                //设置数据源的最大值为 barChart 的最大值的2/3
                if (model.stepNumber.integerValue > self.runBarChart.yMaxValue * 0.7) {
                    self.runBarChart.yMaxValue = model.stepNumber.integerValue * 1.3;
                }
            }
            NSMutableArray *indexArr = [NSMutableArray array];
            for (int index = 0; index < 24; index ++) {
                [indexArr addObject:[NSString stringWithFormat:@"%02d", index]];
                [self.xArr addObject:@""];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回主线程更新 UI
                [self.hud hideAnimated:YES];
                [self.runBarChart setXLabels:self.xArr];
                [self.runBarChart setYValues:self.barChartDataArr];
                [self.runBarChart updateChartData:self.barChartDataArr];
                [self.dataTableView reloadData];
            });
        }
    });
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TrainingTableCellID];
    if (cell == nil) {
        cell = [[TrainingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TrainingTableCellID];
    }
    
    cell.model = self.tableDataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    slideH = - self.dataTableView.contentOffset.y;
//    CGFloat slideMaxH = 0.0;
//    CGFloat tipAlpha = 0.0;
//    CGFloat stepAlpha = 1.0;
//    isSlideMax = false;
//    //NSLog(@"滑动距离: %f",slideH);
//    if (slideH <= 214) {
//        slideH = 214;
//    }
//    CGRect rect = self.headTopView.frame;
//    rect.size.height = slideH;
//    self.headTopView.frame = rect;
//    //    [self.stepView mas_updateConstraints:^(MASConstraintMaker *make) {
//    //        make.centerY.equalTo(@((slideH - 64) * 0.5 + 64));
//    //    }];
//    //NSLog(@"旋转: %f", (offsetH - slideH)/210);
//    if (((offsetH - slideH)/210) > 0) {
//        //self.stepView.layer.transform = CATransform3DMakeRotation(((offsetH - slideH) / 210) * (3.14159265 / 2), 1, 0, 0);
//    }
//    if (slideH > offsetH) {
//        slideMaxH = slideH;
//        if (slideMaxH >= 456) {
//            slideMaxH = 456;
//        }
//        if (slideH >= 456) {
//            isSlideMax = true;
//        } else {
//            isSlideMax = false;
//        }
//        tipAlpha = (slideMaxH - offsetH) / 50.0;
//        if (tipAlpha >= 0.99) {
//            tipAlpha = 0.99;
//        }
//        stepAlpha = 0.0;
//    }else {
//        stepAlpha = (offsetH - slideH) / 210.0;
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (isSlideMax) {
//        NSLog(@"触发了刷新");
//    }
//}

#pragma mark - lazy
- (UIView *)headTopView
{
    if (!_headTopView) {
        _headTopView = [[UIView alloc] initWithFrame:CGRectZero];
        _headTopView.backgroundColor = CLEAR_COLOR;
        
        [self.view addSubview:_headTopView];
        [_headTopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@262);
            make.top.equalTo(self.view.mas_top);
        }];
    }
    
    return _headTopView;
}

- (UITableView *)dataTableView
{
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_dataTableView registerClass:NSClassFromString(TrainingTableCellID) forCellReuseIdentifier:TrainingTableCellID];
        _dataTableView.bounces = NO;
//        _dataTableView.contentInset = UIEdgeInsetsMake(offsetH - 64, 0, 0, 0);
//        _dataTableView.scrollIndicatorInsets = _dataTableView.contentInset;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dataTableView.showsVerticalScrollIndicator = NO;
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        
        [self.view addSubview:_dataTableView];
        [_dataTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
            make.top.equalTo(self.headTopView.mas_bottom);
        }];
    }
    
    return _dataTableView;
}

/** 列表数据源 */
- (NSMutableArray *)tableDataArr
{
    if (!_tableDataArr) {
        _tableDataArr = [NSMutableArray array];
    }
    
    return _tableDataArr;
}

/** 图表数据源 */
- (NSMutableArray *)barChartDataArr
{
    if (!_barChartDataArr) {
        _barChartDataArr = [NSMutableArray array];
    }
    
    return _barChartDataArr;
}

- (NSMutableArray *)xArr
{
    if (!_xArr) {
        _xArr = [NSMutableArray array];
    }
    
    return _xArr;
}

- (FMDBManager *)myFmdbManager
{
    if (!_myFmdbManager) {
        _myFmdbManager = [[FMDBManager alloc] initWithPath:DB_NAME];
    }
    
    return _myFmdbManager;
}

- (UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        _noDataLabel.text = @"无数据";
        
        [self.dataTableView addSubview:_noDataLabel];
        [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.dataTableView.mas_centerX);
            make.centerY.equalTo(self.dataTableView.mas_centerY);
        }];
    }
    
    return _noDataLabel;
}

- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    
    return _hud;
}

- (PNBarChart *)runBarChart
{
    if (!_runBarChart) {
        _runBarChart = [[PNBarChart alloc] init];
        [_runBarChart setStrokeColor:STEP_CURRENT_CIRCLE_COLOR];
        _runBarChart.barBackgroundColor = [UIColor clearColor];
        _runBarChart.yChartLabelWidth = 20.0;
        _runBarChart.chartMarginLeft = 0;
        _runBarChart.chartMarginRight = 0;
        _runBarChart.chartMarginTop = 0;
        _runBarChart.chartMarginBottom = 0;
        _runBarChart.yMinValue = 0;
        _runBarChart.yMaxValue = 200;
        _runBarChart.barWidth = 12;
        _runBarChart.barRadius = 0;
        _runBarChart.showLabel = NO;
        _runBarChart.showChartBorder = NO;
        _runBarChart.isShowNumbers = NO;
        _runBarChart.isGradientShow = NO;
//        _runBarChart.delegate = self;
        
        [self.headTopView addSubview:_runBarChart];
        [_runBarChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headTopView.mas_left);
            make.right.equalTo(self.headTopView.mas_right);
            make.bottom.equalTo(self.headTopView.mas_bottom);
            make.height.equalTo(@150);
        }];
    }
    
    return _runBarChart;
}

@end
