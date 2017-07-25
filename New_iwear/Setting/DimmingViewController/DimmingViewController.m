//
//  DimmingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "DimmingViewController.h"

@interface DimmingViewController ()
{
    float _currentDim;
}
@property (nonatomic, strong) UILabel *currentDimLabel;
@property (nonatomic, strong) MDSlider *slider;
@property (nonatomic, strong) MDButton *subtractBtn;
@property (nonatomic, strong) MDButton *plusBtn;

@end

@implementation DimmingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"dimmingSetting", nil);
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(weatheSuccess:) name:SET_FIRMWARE object:nil];
    
    [self createUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI
{
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setText:NSLocalizedString(@"setPerDimming", nil)];
    [infoLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [infoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_top).offset(25 + 64);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(infoLabel.mas_bottom).offset(18);
        make.height.equalTo(@1);
    }];
    
    _currentDimLabel = [[UILabel alloc] init];
    
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
    [self.view addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_currentDimLabel.mas_bottom).offset(40);
        make.width.equalTo(@(225 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
        make.height.equalTo(@10);
    }];
    
    if ([[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING]) {
        float value = [[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING];
        [_currentDimLabel setText:[NSString stringWithFormat:@"%0.f%%", value]];
        _slider.value = value;
    }else {
        [_currentDimLabel setText:@"90%"];
        _slider.value = 90;
    }
    
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _currentDim = _slider.value;

    _subtractBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [_subtractBtn setTitle:@"-" forState:UIControlStateNormal];
    [_subtractBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [_subtractBtn setTitleColor:COLOR_WITH_HEX(0x1e1e1e, 1) forState:UIControlStateNormal];
//    _subtractBtn.backgroundColor = CLEAR_COLOR;
    _subtractBtn.layer.masksToBounds = YES;
    _subtractBtn.layer.cornerRadius = 12;
    [_subtractBtn addTarget:self action:@selector(subtractAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_subtractBtn];
    [_subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_slider.mas_left).offset(-10);
        make.centerY.equalTo(_slider.mas_top).offset(52);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
    
    _plusBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [_plusBtn setTitle:@"+" forState:UIControlStateNormal];
    [_plusBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [_plusBtn setTitleColor:COLOR_WITH_HEX(0x1e1e1e, 1) forState:UIControlStateNormal];
//    _plusBtn.backgroundColor = CLEAR_COLOR;
    _plusBtn.layer.masksToBounds = YES;
    _plusBtn.layer.cornerRadius = 12;
    [_plusBtn addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_plusBtn];
    [_plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_slider.mas_right).offset(10);
        make.centerY.equalTo(_slider.mas_top).offset(52);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender {
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        self.slider.value = _currentDim;
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        _currentDim = _slider.value;
        self.currentDimLabel.text = [NSString stringWithFormat:@"%0.f%%", _slider.value];
    }
    [self writeVlaueToPer:self.slider.value];
}

- (void)subtractAction:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        if (self.slider.value >= 10) {
            self.slider.value = self.slider.value - 10.f;
        }else if (self.slider.value >= 0 && self.slider.value < 10) {
            self.slider.value = 0.f;
        }
    }
}

- (void)plusAction:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        if (self.slider.value <= 90) {
            self.slider.value = self.slider.value + 10.f;
        }else if (self.slider.value > 90 && self.slider.value <= 100) {
            self.slider.value = 100.f;
        }
    }
}

- (void)writeVlaueToPer:(float)value
{
    [[BleManager shareInstance] writeDimmingToPeripheral:value];
}

- (void)weatheSuccess:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.receiveDataType == ReturnModelTypeFirwmave){
        //这里不能直接写 if (isFirst),必须如下写法
        if (model.firmwareModel.mode == FirmwareModeSetLCD) {
            [[NSUserDefaults standardUserDefaults] setFloat:self.slider.value forKey:DIMMING_SETTING];
            MDToast *sucToast = [[MDToast alloc] initWithText:NSLocalizedString(@"saveSuccess", nil) duration:1.5];
            [sucToast show];
        }else {
            //做失败处理
            MDToast *sucToast = [[MDToast alloc] initWithText:NSLocalizedString(@"saveFial", nil) duration:1.5];
            [sucToast show];
        }
    }
}

@end
