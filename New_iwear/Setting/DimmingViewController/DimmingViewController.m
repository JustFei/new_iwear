//
//  DimmingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "DimmingViewController.h"

@interface DimmingViewController ()

@property (nonatomic, strong) UILabel *currentDimLabel;
@property (nonatomic, strong) MDSlider *slider;
@property (nonatomic, strong) MDButton *subtractBtn;
@property (nonatomic, strong) MDButton *plusBtn;

@end

@implementation DimmingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"亮度调节";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    
    [self createUI];
}

- (void)createUI
{
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setText:@"设置手表的亮度"];
    [infoLabel setTextColor:TEXT_COLOR_LEVEL3];
    [infoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_top).offset(25 + 64);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(infoLabel.mas_bottom).offset(18);
        make.height.equalTo(@1);
    }];
    
    _currentDimLabel = [[UILabel alloc] init];
    [_currentDimLabel setText:@"100%%"];
    [_currentDimLabel setTextColor:COLOR_WITH_HEX(0x2196f3, 1)];
    [_currentDimLabel setFont:[UIFont systemFontOfSize:16]];
    [self.view addSubview:_currentDimLabel];
    [_currentDimLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_top).offset(29);
    }];
    
    _slider = [[MDSlider alloc] init];
    _slider.minimumValue = 0;
    _slider.maximumValue = 100;
    _slider.step = 10;
    _slider.enabledValueLabel = YES;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_currentDimLabel.mas_bottom).offset(40);
        make.width.equalTo(@(225 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
        make.height.equalTo(@10);
    }];
//    _slider.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slider attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender {
    self.currentDimLabel.text =
    [NSString stringWithFormat:@"%.01f", _slider.value];
}

@end
