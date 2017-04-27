//
//  ViewController.m
//  MiStepViewDemo
//
//  Created by Faith on 2017/4/19.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "FirstViewController.h"
#import "Masonry.h"
#import "StepCircleView.h"

@interface FirstViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CGFloat offsetH;
    CGFloat turnOffsetH;
    CGFloat slideH;
    CGFloat kScreenW;
    NSString *cellID;
    BOOL isSlideMax;
}

@property (nonatomic) UIView *headTopView;
@property (nonatomic) UITableView *dataTableView;
@property (nonatomic) UIView *tipsView;
@property (nonatomic) UILabel *tipsLabel;
@property (nonatomic) UIImageView *tipsImageView;
@property (nonatomic, strong) StepCircleView *stepView;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    offsetH = 406.0;
    turnOffsetH = 214.0;
    slideH = 0.0;
    kScreenW = [UIScreen mainScreen].bounds.size.width;
    cellID = @"CellID";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"iwear";
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.frame = CGRectMake(0, 0, 50, 30);
    self.navigationItem.titleView = titleLabel;
    self.dataTableView.contentInset = UIEdgeInsetsMake(offsetH - 64, 0, 0, 0);
    self.dataTableView.scrollIndicatorInsets = self.dataTableView.contentInset;
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.dataTableView];
    [self.view addSubview:self.headTopView];
    // tipsView
    [self.headTopView addSubview:self.tipsView];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headTopView.mas_bottom);
        make.height.equalTo(@45);
        make.width.equalTo(self.headTopView.mas_width);
        make.centerX.equalTo(self.headTopView.mas_centerX);
    }];
    // tipsLabel
    self.tipsLabel.frame = CGRectMake(0, 0, self.headTopView.frame.size.width, 20);
    [self.tipsView addSubview:self.tipsLabel];
    // tipsImageView
    [self.tipsView addSubview:self.tipsImageView];
    [self.tipsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headTopView.mas_centerX);
        make.top.equalTo(self.tipsLabel.mas_bottom).offset(3);
        make.width.equalTo(@30);
        make.height.equalTo(@15);
    }];
    // dataImageView
    
    self.stepView = [[StepCircleView alloc] init];
    [self.headTopView addSubview:self.stepView];
    [self.stepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headTopView.mas_centerX);
        //为什么这里设置为0才有用呢？
        make.centerY.equalTo(self.headTopView.mas_centerY);
        make.width.equalTo(@264);
        make.height.equalTo(@264);
    }];
    self.stepView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage alloc] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 18;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = @"爱你一万年";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [[UIColor alloc] initWithRed:39/255.0  green:176/255.0 blue:108/255.0 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    slideH = - self.dataTableView.contentOffset.y;
    CGFloat slideMaxH = 0.0;
    CGFloat tipAlpha = 0.0;
    CGFloat stepAlpha = 1.0;
    isSlideMax = false;
    //NSLog(@"滑动距离: %f",slideH);
    if (slideH <= 196) {
        slideH = 196;
    }
    CGRect rect = self.headTopView.frame;
    rect.size.height = slideH;
    self.headTopView.frame = rect;
//    [self.stepView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(@((slideH - 64) * 0.5 + 64));
//    }];
    //NSLog(@"旋转: %f", (offsetH - slideH)/210);
    if (((offsetH - slideH)/210) > 0) {
        self.stepView.layer.transform = CATransform3DMakeRotation(((offsetH - slideH) / 210) * (3.14159265 / 2), 1, 0, 0);
    }
    if (slideH > offsetH) {
        slideMaxH = slideH;
        if (slideMaxH >= 456) {
            slideMaxH = 456;
        }
        if (slideH >= 456) {
            isSlideMax = true;
        } else {
            isSlideMax = false;
        }
        tipAlpha = (slideMaxH - offsetH) / 50.0;
        if (tipAlpha >= 0.99) {
            tipAlpha = 0.99;
        }
        stepAlpha = 0.0;
    }else {
        stepAlpha = (offsetH - slideH) / 210.0;
    }
    NSLog(@"透明度: %f",tipAlpha);
    self.tipsView.alpha = tipAlpha;
    self.stepView.alpha = 1 - stepAlpha;
    if (isSlideMax) {
        self.tipsLabel.text = @"松手开始同步";
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tipsImageView.transform = CGAffineTransformMakeRotation( 3.14159265);
        }];
    } else {
        self.tipsLabel.text = @"下拉同步数据";
        [UIView animateWithDuration:0.3 animations:^{
            self.tipsImageView.transform = CGAffineTransformMakeRotation( 3.14159265 * 2);
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isSlideMax) {
        NSLog(@"触发了刷新");
        [self.stepView startCircleAnimation];
//        [self.dataTableView setContentOffset:CGPointMake(0, 456)];
        NSLog(@"stepView == %@", self.stepView);
    }
}

#pragma mark - lazy
- (UIView *)headTopView
{
    if (!_headTopView) {
        _headTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 406.0)];
        _headTopView.backgroundColor = DISCONNECT_BACKGROUND_COLOR;
    }
    
    return _headTopView;
}

- (UITableView *)dataTableView
{
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    }
    
    return _dataTableView;
}

- (UIView *)tipsView
{
    if (!_tipsView) {
        _tipsView = [[UIView alloc] init];
        _tipsView.backgroundColor = [UIColor clearColor];
    }
    
    return _tipsView;
}

- (UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.text = @"下拉同步数据";
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:12];
    }
    
    return _tipsLabel;
}

- (UIImageView *)tipsImageView
{
    if (!_tipsImageView) {
        _tipsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_pull_down"]];
        _tipsImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _tipsImageView;
}

- (StepCircleView *)stepView
{
    if (!_stepView) {
        //_dataImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"step_image"]];
        _stepView = [[StepCircleView alloc] initWithFrame:CGRectMake(0, 0, 264, 264)];
        //_dataImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _stepView;
}


@end
