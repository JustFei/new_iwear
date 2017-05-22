//
//  FindMyPeriphearlViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "FindMyPeriphearlViewController.h"

@interface FindMyPeriphearlViewController ()

@property (nonatomic, strong) MDButton *findBtn;
@property (nonatomic, strong) MDToast *timeToast;
@property (nonatomic, strong) NSTimer *findTimer;

@end

@implementation FindMyPeriphearlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"查找手环";
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    
    [self createUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI
{
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setText:@"使用此功能需手环与手机保持连接"];
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
    
    self.findBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [self.findBtn setImage:[UIImage imageNamed:@"find_bracelet"] forState:UIControlStateNormal];
    [self.findBtn setBackgroundColor:CLEAR_COLOR];
    [self.findBtn addTarget:self action:@selector(findPerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.findBtn];
    [self.findBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_bottom).offset(105);
        make.width.equalTo(@72);
        make.height.equalTo(@72);
    }];
    self.findBtn.layer.masksToBounds = YES;
    self.findBtn.layer.cornerRadius = 36;
    
    UILabel *takePhotoLabel = [[UILabel alloc] init];
    [takePhotoLabel setText:@"查找手环"];
    [takePhotoLabel setFont:[UIFont systemFontOfSize:14]];
    [takePhotoLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [self.view addSubview:takePhotoLabel];
    [takePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.findBtn.mas_bottom).offset(17.5);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    [tipLabel setText:@"如果找到手环，手环会振动和亮屏"];
    [tipLabel setFont:[UIFont systemFontOfSize:12]];
    [tipLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(takePhotoLabel.mas_bottom).offset(35);
    }];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)findPerAction:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        self.findBtn.enabled = NO;
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(stopFindTimer:) name:GET_SEARCH_FEEDBACK object:nil];
        [[BleManager shareInstance] writeSearchPeripheralWithONorOFF:YES];
        [self.timeToast show];
        __block int time = 10;
        self.findTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            self.timeToast.text = [NSString stringWithFormat:@"正在查找设备：%d", time];
            time = time - 1;
            if (time  == 0) {
                self.timeToast.text = @"设备未响应，请稍后重试";
                [self endTimerAndDismissToast];
                return ;
            }
        }];
    }
}

- (void)stopFindTimer:(NSNotification *)noti
{
    self.timeToast.text = @"设备已找到";
    [self endTimerAndDismissToast];
}

- (void)endTimerAndDismissToast
{
    [self.findTimer invalidate];
    self.findTimer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.timeToast dismiss];
        self.timeToast = nil;
        self.findBtn.enabled = YES;
    });
}

#pragma mark - lazy
- (MDToast *)timeToast
{
    if (!_timeToast) {
        _timeToast = [[MDToast alloc] initWithText:@"正在查找设备..." duration:15];
    }
    
    return _timeToast;
}

@end
