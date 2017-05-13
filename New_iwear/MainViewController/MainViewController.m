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

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleArr = @[NSLocalizedString(@"计步", nil),NSLocalizedString(@"心率", nil),NSLocalizedString(@"睡眠", nil),NSLocalizedString(@"血压", nil),NSLocalizedString(@"血氧", nil)];
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.navigationBar.barTintColor = CLEAR_COLOR;
    [[self.navigationController.navigationBar subviews].firstObject setAlpha:0];
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
    [self.navigationController pushViewController:vc animated:YES];
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
        
        self.heartRateView = [[HeartRateContentView alloc] initWithFrame:CGRectMake(VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.heartRateView];
        
        self.sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake(2 * VIEW_CONTROLLER_FRAME_WIDTH, 0, VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT)];
        [_backScrollView addSubview:self.sleepView];
        
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

@end
