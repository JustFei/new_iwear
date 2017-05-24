//
//  InterfaceSelectionViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "InterfaceSelectionViewController.h"
#import "InterfaceSelectionCollectionViewCell.h"

static NSString *const interfaceCollectionViewCellID = @"interfaceCollectionViewCell";
static NSString *const interfaceCollectionViewHeaderID = @"interfaceCollectionViewHeader";

@interface InterfaceSelectionViewController () < UICollectionViewDelegate, UICollectionViewDataSource >

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation InterfaceSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"界面选择";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.collectionView.backgroundColor = CLEAR_COLOR;
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    
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
    InterfaceSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:interfaceCollectionViewCellID forIndexPath:indexPath];
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

//这个方法是返回 Header的大小 size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(VIEW_CONTROLLER_BOUNDS_WIDTH, 56);
}

//这个也是最重要的方法 获取Header的 方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:interfaceCollectionViewHeaderID forIndexPath:indexPath];
    UILabel *tipLabel = [[UILabel alloc] init];
    [tipLabel setText:@"选择需要在设备上显示的界面"];
    [tipLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [tipLabel setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView.mas_left).offset(16);
        make.centerY.equalTo(headerView.mas_centerY).offset(4);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView.mas_left);
        make.right.equalTo(headerView.mas_right);
        make.bottom.equalTo(headerView.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        InterfaceSelectionModel *model = self.dataArr[indexPath.row];
        if (model.selectMode == SelectModeUnchoose) {
            return;
        }
        model.selectMode = model.selectMode == SelectModeSelected ? SelectModeUnselected : SelectModeSelected;
        NSMutableArray *mutArr = [NSMutableArray arrayWithArray:self.dataArr];
        [mutArr replaceObjectAtIndex:indexPath.row withObject:model];
        self.dataArr = mutArr;
        NSArray *indexPathArr = @[indexPath];
        [self.collectionView reloadItemsAtIndexPaths:indexPathArr];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        // 设置流水布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        // 定义大小
        layout.itemSize = CGSizeMake(88 * VIEW_CONTROLLER_FRAME_WIDTH / 375, 176 * VIEW_CONTROLLER_FRAME_WIDTH / 375);
        // 设置最小行间距
        layout.minimumLineSpacing = 4;
        // 设置垂直间距
        layout.minimumInteritemSpacing = 4;
        layout.sectionInset = UIEdgeInsetsMake(4, 43 * VIEW_CONTROLLER_FRAME_WIDTH / 375, 4, 43 * VIEW_CONTROLLER_FRAME_WIDTH / 375);
        // 设置滚动方向（默认垂直滚动）
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS collectionViewLayout:layout];
        /** 注册cell */
        [_collectionView registerClass:NSClassFromString(@"InterfaceSelectionCollectionViewCell") forCellWithReuseIdentifier:interfaceCollectionViewCellID];
        /** 注册 header */
        [_collectionView registerClass:NSClassFromString(@"UICollectionReusableView") forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:interfaceCollectionViewHeaderID];
        
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *nameArr = @[@"待机",@"计步",@"运动",@"心率",@"睡眠",@"查找",@"闹钟",@"关于",@"关机"];
        NSArray *imageArr = @[@"selection_standby",@"selection_sport",@"selection_step",@"selection_heartrate",@"selection_sleep",@"selection_find",@"selection_alarmclock",@"selection_about",@"selection_turnoff"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int i = 0; i < nameArr.count; i ++) {
            InterfaceSelectionModel *model = [[InterfaceSelectionModel alloc] init];
            model.functionName = nameArr[i];
            model.functionImageName = imageArr[i];
            if (i == 0) {
                model.selectMode = SelectModeUnchoose;
            }else {
                model.selectMode = SelectModeSelected;
            }
            
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

@end
