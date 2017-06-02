//
//  MainViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/12.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "StepContentView.h"
#import "HeartRateContentView.h"
#import "SleepContentView.h"
#import "BloodPressureContentView.h"
#import "BloodO2ContentView.h"
#import "SyncTool.h"

@interface MainViewController () < UIScrollViewDelegate >
{
    NSArray *_titleArr;
    BOOL isShowList;
    NSArray *_userArr;
    NSInteger _currentPage;
}

@property (nonatomic, assign) BOOL didEndDecelerating;
@property (nonatomic, strong) StepContentView *stepView;
@property (nonatomic, strong) HeartRateContentView *heartRateView;
@property (nonatomic, strong) SleepContentView *sleepView;
@property (nonatomic, strong) BloodPressureContentView  *bloodPressureView;
@property (nonatomic, strong) BloodO2ContentView *boView;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MDButton *leftButton;
@property (nonatomic, strong) MDSnackbar *stateBar;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleArr = @[NSLocalizedString(@"计步", nil),NSLocalizedString(@"睡眠", nil),NSLocalizedString(@"心率", nil),NSLocalizedString(@"血压", nil),NSLocalizedString(@"血氧", nil)];
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.navigationBar.barTintColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self createUI];
    _currentPage = 0;
    
//    Remind *model = [[Remind alloc] init];
//    model.phone = 1;
//    model.message = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //每次进入主界面时同步数据
        if (![SyncTool shareInstance].syncDataIng && [BleManager shareInstance].connectState == kBLEstateDidConnected) {
            [[SyncTool shareInstance] syncData];
            [self.stateBar setText:@"同步数据"];
            [self.stateBar show];
            [SyncTool shareInstance].syncDataCurrentCountBlock = ^(NSInteger progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.stateBar setText:[NSString stringWithFormat:@"正在同步数据 %ld%%", progress]];
                    if (progress == 100) {
                        self.stateBar.text = @"同步完成";
                        [self notiViewUpdateUI];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.stateBar dismiss];
                        });
                    }
                });
            };
        }
    });
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)createUI
{
    self.titleLabel.text = _titleArr[0];
    self.leftButton.backgroundColor = CLEAR_COLOR;
    self.backScrollView.backgroundColor = WHITE_COLOR;
    self.pageControl.tintColor = CLEAR_COLOR;
}

#pragma mark - Action
- (void)showSettingVC:(MDButton *)sender
{
    SettingViewController *vc = [[SettingViewController alloc] init];
    switch (self.pageControl.currentPage) {
        case 0:
            vc.naviBarColor = STEP_CURRENT_BACKGROUND_COLOR;
            break;
        case 1:
            vc.naviBarColor = SLEEP_CURRENT_BACKGROUND_COLOR;
            break;
        case 2:
            vc.naviBarColor = HR_CURRENT_BACKGROUND_COLOR;
            break;
        case 3:
            vc.naviBarColor = BP_HISTORY_BACKGROUND_COLOR;
            break;
        case 4:
            vc.naviBarColor = BO_HISTORY_BACKGROUND_COLOR;
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

/** 取消通知栏 */
- (void)cancelStateBarAction:(MDButton *)sender
{
    if (self.stateBar.isShowing) {
        [self.stateBar dismiss];
    }
}

/** 通知5个视图更新 UI */
- (void)notiViewUpdateUI
{
    [self.stepView updateUI];
}

#pragma mark - UIScrollViewDelegate
// 开始减速的时候开始self.didEndDecelerating = NO;结束减速就会置为YES,如果滑动很快就还是NO。
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.didEndDecelerating = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    @autoreleasepool {
        [UIView animateWithDuration:0.3 animations:^{
            self.leftButton.alpha = 1.f;
            self.titleLabel.alpha = 1.f;
        }];
        self.didEndDecelerating = YES;
        CGFloat index = scrollView.contentOffset.x / VIEW_CONTROLLER_FRAME_WIDTH;
        //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
        
        int i = roundf(index);
        
        self.titleLabel.text = _titleArr[i];
        self.pageControl.currentPage = i;
    }
}

// 再次拖拽的时候，判断有没有因为滑动太快而没有调用结束减速的方法。
// 如果没有，四舍五入手动确定位置。这样就可以解决滑动过快的问题
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [UIView animateWithDuration:0.3 animations:^{
        self.leftButton.alpha = 0.f;
        self.titleLabel.alpha = 0.f;
    }];
    if (!self.didEndDecelerating) {
        // 先计算当期的page/index
        CGFloat index = scrollView.contentOffset.x / VIEW_CONTROLLER_FRAME_WIDTH;
        //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
        int i = roundf(index);
        self.titleLabel.text = _titleArr[i];
        self.pageControl.currentPage = i;
    }
}

#pragma mark - lazy
- (UIScrollView *)backScrollView
{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -64, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT + 64)];
        _backScrollView.showsVerticalScrollIndicator = NO;
        _backScrollView.showsHorizontalScrollIndicator =  NO;
        _backScrollView.contentSize = CGSizeMake(5 * VIEW_CONTROLLER_FRAME_WIDTH, 0);
        _backScrollView.pagingEnabled = YES;
        _backScrollView.delegate = self;
        _backScrollView.bounces = NO;
        
        self.stepView = [[StepContentView alloc] initWithFrame:CGRectMake(0, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.stepView];
        
        self.sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake( VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.sleepView];
        
        self.heartRateView = [[HeartRateContentView alloc] initWithFrame:CGRectMake(2 * VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.heartRateView];
        
        self.bloodPressureView = [[BloodPressureContentView alloc] initWithFrame:CGRectMake(3 * VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.bloodPressureView];
        
        self.boView = [[BloodO2ContentView alloc] initWithFrame:CGRectMake(4 * VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.boView];
        
        [self.view addSubview:_backScrollView];
    }
    
    return _backScrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *view = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 338 * VIEW_CONTROLLER_FRAME_WIDTH / 375, self.view.frame.size.width, 37)];
        view.numberOfPages = 5;
        view.currentPage = 0;
        view.enabled = NO;
        
        [self.view addSubview:view];
        _pageControl = view;
    }
    
    return _pageControl;
}

- (MDButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [_leftButton setImage:[UIImage imageNamed:@"all_set"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(showSettingVC:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    return _leftButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:WHITE_COLOR];
        self.navigationItem.titleView = _titleLabel;
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.navigationItem.titleView.mas_centerX);
            make.centerY.equalTo(self.navigationItem.titleView.mas_centerY);
        }];
    }
    
    return _titleLabel;
}

- (MDSnackbar *)stateBar
{
    if (!_stateBar) {
        _stateBar = [[MDSnackbar alloc] init];
        [_stateBar setActionTitleColor:NAVIGATION_BAR_COLOR];
        
        //这里1000000秒是让bar长驻在底部
        [_stateBar setDuration:1000000];
        _stateBar.multiline = YES;
        
        MDButton *cancelButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
        [cancelButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelStateBarAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = RED_COLOR;
        [_stateBar addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_stateBar.mas_left).offset(16);
            //        make.top.equalTo(self.stateBar.mas_top).offset(10);
            make.centerY.equalTo(_stateBar.mas_centerY);
        }];
    }
    
    return _stateBar;
}

@end
