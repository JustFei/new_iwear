//
//  RemindViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindViewController.h"
#import "RemindCollectionViewCell.h"
#import "RemindMoreViewController.h"
#import "SedentaryReminderModel.h"

static NSString * const RemindCollectionViewCellID = @"RemindCollectionViewCell";
static NSString * const RemindCollectionViewFooterID = @"RemindCollectionViewFooter";

@interface RemindViewController () < UICollectionViewDelegate, UICollectionViewDataSource >

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation RemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"remindFunc", nil);
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.collectionView.backgroundColor = CLEAR_COLOR;
    [self.collectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    self.dataArr = nil;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreFunctionAction:(MDButton *)sender
{
    RemindMoreViewController *vc = [[RemindMoreViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionVIewDelegate && UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RemindCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RemindCollectionViewCellID forIndexPath:indexPath];
    
    [cell setNeedsDisplay];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id pushVC = [[NSClassFromString(self.vcArr[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:pushVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(VIEW_CONTROLLER_BOUNDS_WIDTH, 68);
}


//这个也是最重要的方法 获取Header的 方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:RemindCollectionViewFooterID forIndexPath:indexPath];
    MDButton *moreBtn = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
    moreBtn.backgroundColor = WHITE_COLOR;
    [moreBtn setTitle:NSLocalizedString(@"more", nil) forState:UIControlStateNormal];
    [moreBtn setTitleColor:TEXT_BLACK_COLOR_LEVEL2 forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [moreBtn addTarget:self action:@selector(moreFunctionAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footerView.mas_centerX);
        make.centerY.equalTo(footerView.mas_centerY);
        make.width.equalTo(@(288 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
        make.height.equalTo(@36);
    }];
    moreBtn.layer.masksToBounds = YES;
    moreBtn.layer.cornerRadius = 18;
    moreBtn.layer.borderColor = TEXT_BLACK_COLOR_LEVEL1.CGColor;
    moreBtn.layer.borderWidth = 1;
    
    return footerView;
}

#pragma mark - lazy
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        // 设置流水布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        // 定义大小
        layout.itemSize = CGSizeMake(VIEW_CONTROLLER_FRAME_WIDTH / 2, 150);
        // 设置最小行间距
        layout.minimumLineSpacing = -1;
        // 设置垂直间距
        layout.minimumInteritemSpacing = -1;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // 设置滚动方向（默认垂直滚动）
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS collectionViewLayout:layout];
        /** 注册cell */
        [_collectionView registerClass:NSClassFromString(@"RemindCollectionViewCell") forCellWithReuseIdentifier:RemindCollectionViewCellID];
        
        /** 注册 footer */
        [_collectionView registerClass:NSClassFromString(@"UICollectionReusableView") forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:RemindCollectionViewFooterID];
        
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *imageArr = @[@"remind_phone01", @"remind_mgs01", @"remind_sit01", @"remind_alarm01"];
        NSArray *nameArr = @[NSLocalizedString(@"phoneRemind", nil), NSLocalizedString(@"smsRemind", nil), NSLocalizedString(@"sedentaryRemind", nil), NSLocalizedString(@"alarmReminder", nil)];
        
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int i = 0; i < nameArr.count; i ++) {
            RemindModel *model = [[RemindModel alloc] init];
            model.functionName = nameArr[i];
            model.headImageName = imageArr[i];
            model.isOpen = NO;
            switch (i) {
                case 0:
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING]) {
                        model.isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:PHONE_SWITCH_SETTING];
                    }else {
                        model.isOpen = NO;
                    }
                    break;
                case 1:
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING]) {
                        model.isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_SWITCH_SETTING];
                    }else {
                        model.isOpen = NO;
                    }
                    break;
                case 2:
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING]) {
                        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:SEDENTARY_SETTING];
                        SedentaryReminderModel *sedModel = [NSKeyedUnarchiver unarchiveObjectWithData:arr.firstObject];
                        model.isOpen = sedModel.switchIsOpen;
                    }else {
                        model.isOpen = NO;
                    }
                    break;
                case 3:
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:CLOCK_ISOPEN]) {
                        model.isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:CLOCK_ISOPEN];
                    }else {
                        model.isOpen = NO;
                    }
                    break;
                    
                default:
                    break;
            }
            
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

- (NSArray *)vcArr
{
    if (!_vcArr) {
        _vcArr = @[@"PhoneReminderViewController",@"MessageReminderViewController",@"SedentaryReminderViewController",@"ClockReminderViewController"];
    }
    
    return _vcArr;
}

@end
