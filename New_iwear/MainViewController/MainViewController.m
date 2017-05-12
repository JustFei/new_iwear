//
//  MainViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/12.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "MainViewController.h"
#import "StepContentView.h"
#import "HeartRateContentView.h"
#import "SleepContentView.h"
#import "BloodPressureContentView.h"
#import "BloodO2ContentView.h"

@interface MainViewController ()

@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - lazy
- (UIScrollView *)backScrollView
{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS];
        _backScrollView.contentSize = CGSizeMake(VIEW_CONTROLLER_FRAME_WIDTH, VIEW_CONTROLLER_FRAME_HEIGHT);
        _backScrollView.showsVerticalScrollIndicator = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesScrollViewAction)];
        [_backScrollView addGestureRecognizer:tap];
        
        _backScrollView.contentSize = CGSizeMake(5 * WIDTH, 0);
        _backScrollView.pagingEnabled = YES;
        _backScrollView.delegate = self;
        _backScrollView.bounces = NO;
        
        self.stepView = [[StepContentView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [_backScrollView addSubview:self.stepView];
        
        self.heartRateView = [[HeartRateContentView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
        [_backScrollView addSubview:self.heartRateView];
        
        //        self.temperatureView = [[TemperatureContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
        //        [view addSubview:self.temperatureView];
        
        self.sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
        [_backScrollView addSubview:self.sleepView];
        
        self.bloodPressureView = [[BloodPressureContentView alloc] initWithFrame:CGRectMake(3 * WIDTH, 0, WIDTH, HEIGHT)];
        [_backScrollView addSubview:self.bloodPressureView];
        
        self.boView = [[BloodO2ContentView alloc] initWithFrame:CGRectMake(4 * WIDTH, 0, WIDTH, HEIGHT)];
        [_backScrollView addSubview:self.boView];
        
        [self.view addSubview:_backScrollView];
    }
}

@end
