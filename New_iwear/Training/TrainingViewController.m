//
//  TrainingViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TrainingViewController.h"
#import "TrainingTableCell.h"

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
@property (nonatomic) UIView *tipsView;
@property (nonatomic) UILabel *tipsLabel;
@property (nonatomic) UIImageView *tipsImageView;
@property (nonatomic, strong) NSArray *dataArr;

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
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = TRAINING_BACKGROUND_COLOR;
    
    offsetH = 230.0;
    turnOffsetH = 150.0;
    slideH = 0.0;
    kScreenW = [UIScreen mainScreen].bounds.size.width;
    
    self.dataTableView.backgroundColor = CLEAR_COLOR;
    [self.view addSubview:self.headTopView];
    
    // dataImageView
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
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TrainingTableCellID];
    if (cell == nil) {
        cell = [[TrainingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TrainingTableCellID];
    }
    
    cell.model = self.dataArr[indexPath.row];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    slideH = - self.dataTableView.contentOffset.y;
    CGFloat slideMaxH = 0.0;
    CGFloat tipAlpha = 0.0;
    CGFloat stepAlpha = 1.0;
    isSlideMax = false;
    //NSLog(@"滑动距离: %f",slideH);
    if (slideH <= 150) {
        slideH = 150;
    }
    CGRect rect = self.headTopView.frame;
    rect.size.height = slideH;
    self.headTopView.frame = rect;
    //    [self.stepView mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.centerY.equalTo(@((slideH - 64) * 0.5 + 64));
    //    }];
    //NSLog(@"旋转: %f", (offsetH - slideH)/210);
    if (((offsetH - slideH)/210) > 0) {
        //self.stepView.layer.transform = CATransform3DMakeRotation(((offsetH - slideH) / 210) * (3.14159265 / 2), 1, 0, 0);
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
    //self.stepView.alpha = 1 - stepAlpha;
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
    }
}

#pragma mark - lazy
- (UIView *)headTopView
{
    if (!_headTopView) {
        _headTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 406.0)];
        _headTopView.backgroundColor = [UIColor colorWithRed:36.0 / 255.0 green:154.0 / 255.0 blue:184.0 / 255.0 alpha:1];
    }
    
    return _headTopView;
}

- (UITableView *)dataTableView
{
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_dataTableView registerClass:NSClassFromString(TrainingTableCellID) forCellReuseIdentifier:TrainingTableCellID];
        _dataTableView.bounces = NO;
        _dataTableView.contentInset = UIEdgeInsetsMake(offsetH - 64, 0, 0, 0);
        _dataTableView.scrollIndicatorInsets = _dataTableView.contentInset;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dataTableView.showsVerticalScrollIndicator = NO;
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        
        [self.view addSubview:_dataTableView];
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

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < 20; index ++) {
            TrainingTableModel *model = [[TrainingTableModel alloc] init];
            model.periodStr = @"12:40~13:10";
            model.sportTypeStr = @"跑步";
            model.timeCountStr = @"30分钟";
            model.stepStr = @"2130步";
            model.kcalStr = @"33千卡";
            [mutArr addObject:model];
        }
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

@end
