//
//  HeartRateHisViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "HeartRateHisViewController.h"
#import "HRTableViewCell.h"

static NSString * const HRTableViewCellID = @"HRTableViewCell";

@interface HeartRateHisViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *mileageAndkCalLabel;
@property (nonatomic, strong) UILabel *view1StepLabel;
@property (nonatomic, strong) UILabel *view2MileageLabel;
@property (nonatomic, strong) UILabel *view3kCalLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation HeartRateHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = WHITE_COLOR;
    self.leftButton.backgroundColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:1];
    [self initUI];
}

- (void)initUI
{
    UILabel *todayLabel = [[UILabel alloc] init];
    [todayLabel setText:@"上次测量结果"];
    [todayLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [todayLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:todayLabel];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(86 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(todayLabel.mas_bottom).offset(6 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    [self.stepLabel setText:@"68"];
    
    
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [headImageView setImage:[UIImage imageNamed:@"heart_heart-icon"]];
    [self.view addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.stepLabel.mas_left).offset(-8 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.bottom.equalTo(self.stepLabel.mas_bottom);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepLabel.mas_bottom).offset(13 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(150 * VIEW_CONTROLLER_FRAME_WIDTH / 360));
        make.height.equalTo(@1);
    }];
    
    [self.mileageAndkCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_bottom).offset(5 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    [self.mileageAndkCalLabel setText:@"05月08日 13:55"];
    
    MDButton *hisBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    [hisBtn setTitle:@"本月" forState:UIControlStateNormal];
    [hisBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [hisBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
    hisBtn.backgroundColor = CLEAR_COLOR;
    [hisBtn addTarget:self action:@selector(showHisVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hisBtn];
    [hisBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.view.mas_top).offset(201 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
    }];
    
    UIView *view1 = [[UIView alloc] init];
    view1.layer.borderWidth = 1;
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hisBtn.mas_bottom).offset(25 * VIEW_CONTROLLER_FRAME_WIDTH / 360);
        make.left.equalTo(self.view.mas_left).offset(-1);
        make.height.equalTo(@72);
        make.width.equalTo(@((VIEW_CONTROLLER_FRAME_WIDTH + 4) / 3));
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
    
    _view1StepLabel = [[UILabel alloc] init];
    [_view1StepLabel setText:@"78"];
    [_view1StepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view1StepLabel setFont:[UIFont systemFontOfSize:14]];
    [view1 addSubview:_view1StepLabel];
    [_view1StepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.borderWidth = 1;
    view2.layer.borderColor = TEXT_BLACK_COLOR_LEVEL0.CGColor;
    [self.view addSubview:view2];
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
    
    _view2MileageLabel = [[UILabel alloc] init];
    [_view2MileageLabel setText:@"57"];
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
    [self.view addSubview:view3];
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
    
    _view3kCalLabel = [[UILabel alloc] init];
    [_view3kCalLabel setText:@"115"];
    [_view3kCalLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
    [_view3kCalLabel setFont:[UIFont systemFontOfSize:14]];
    [view3 addSubview:_view3kCalLabel];
    [_view3kCalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view3.mas_centerX);
        make.bottom.equalTo(@-17);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(view1.mas_bottom);
    }];
    
    switch (self.vcType) {
        case ViewControllerTypeHR:
        {
            self.title = @"心率记录";
            self.navigationController.navigationBar.barTintColor = HR_HISTORY_BACKGROUND_COLOR;
            view1.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
        }
            break;
        case ViewControllerTypeBP:
        {
            self.title = @"血压记录";
            self.navigationController.navigationBar.barTintColor = HR_HISTORY_BACKGROUND_COLOR;
            view1.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
        }
            break;
        case ViewControllerTypeBO:
        {
            self.title = @"血氧记录";
            self.navigationController.navigationBar.barTintColor = HR_HISTORY_BACKGROUND_COLOR;
            view1.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view2.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
            view3.layer.borderColor = HR_HISTORY_BACKGROUND_COLOR.CGColor;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHisVC:(MDButton *)sender
{
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HRTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark - 懒加载
- (MDButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [_leftButton setImage:[UIImage imageNamed:@"all_set"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    return _leftButton;
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

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = CLEAR_COLOR;
        [_tableView registerClass:NSClassFromString(HRTableViewCellID) forCellReuseIdentifier:HRTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < 20; index ++) {
            HRTableModel *model = [[HRTableModel alloc] init];
            model.dateStr = @"5月9日";
            model.timeStr = @"13:46";
            model.dataStr = @"78";
            model.unitStr = @"次/分钟";
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

@end
