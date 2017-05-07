//
//  WeChatViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "WeChatViewController.h"

@interface WeChatViewController ()

@property (nonatomic, strong) UIView *bottomBackView;

@end

@implementation WeChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提醒功能";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = NAVIGATION_BAR_COLOR;
    [self createUI];
}

- (void)createUI
{
    _bottomBackView = [[UIView alloc] init];
    _bottomBackView.backgroundColor = SETTING_BACKGROUND_COLOR;
    [self.view addSubview:_bottomBackView];
    [_bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
        make.height.equalTo(@255);
    }];
    
    UILabel *label1 = [[UILabel alloc] init];
    [label1 setText:@"点击“接入”启动微信后，进入“深圳曼瑞德科技有限公司”账号页面，然后点击“绑定设备”按钮既可完成接入"];
    [label1 setFont:[UIFont systemFontOfSize:17]];
    [label1 setTextColor:TEXT_COLOR_LEVEL4];
    label1.numberOfLines = 0;
    [_bottomBackView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomBackView.mas_top).offset(26);
        make.centerX.equalTo(_bottomBackView.mas_centerX);
        make.width.equalTo(@(288 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
    }];
    
    UILabel *label2 = [[UILabel alloc] init];
    [label2 setText:@"接入后，步数将会同步至微信排行榜中"];
    [label1 setFont:[UIFont systemFontOfSize:17]];
    [label1 setTextColor:TEXT_COLOR_LEVEL4];
    label2.numberOfLines = 0;
    [_bottomBackView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label1.mas_bottom).offset(40);
        make.centerX.equalTo(_bottomBackView.mas_centerX);
        make.width.equalTo(@(288 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
    }];
    
    MDButton *moreBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFloatingAction rippleColor:CLEAR_COLOR];
    [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [moreBtn setTitleColor:TEXT_COLOR_LEVEL3 forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    moreBtn.backgroundColor = WHITE_COLOR;
    [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBackView addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label2.mas_bottom).offset(18);
        make.centerX.equalTo(_bottomBackView.mas_centerX);
        make.width.equalTo(@(288 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
        make.height.equalTo(@36);
    }];
    moreBtn.layer.masksToBounds = YES;
    moreBtn.layer.cornerRadius = 18;
    moreBtn.layer.borderColor = TEXT_COLOR_LEVEL1.CGColor;
    moreBtn.layer.borderWidth = 1;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAction:(MDButton *)sender
{
    
}


@end
