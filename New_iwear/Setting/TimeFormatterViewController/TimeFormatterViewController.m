//
//  TimeFormatterViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TimeFormatterViewController.h"
#import "InterfaceSelectionCollectionViewCell.h"

static NSString *const timeFormatterCollectionViewCellID = @"timeFormatterCollectionViewCell";
static NSString *const timeFormatterCollectionViewHeaderID = @"timeFormatterCollectionViewHeader";

@interface TimeFormatterViewController () < UICollectionViewDelegate, UICollectionViewDataSource >

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation TimeFormatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"时间格式";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.collectionView.backgroundColor = CLEAR_COLOR;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
    InterfaceSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:timeFormatterCollectionViewCellID forIndexPath:indexPath];
    
    //    [cell setNeedsDisplay];
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
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:timeFormatterCollectionViewHeaderID forIndexPath:indexPath];
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
        [_collectionView registerClass:NSClassFromString(@"InterfaceSelectionCollectionViewCell") forCellWithReuseIdentifier:timeFormatterCollectionViewCellID];
        /** 注册 header */
        [_collectionView registerClass:NSClassFromString(@"UICollectionReusableView") forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:timeFormatterCollectionViewHeaderID];
        
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
        NSArray *nameArr = @[@"12时",@"24时",@"石英"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int i = 0; i < nameArr.count; i ++) {
            InterfaceSelectionModel *model = [[InterfaceSelectionModel alloc] init];
            model.functionName = nameArr[i];
            model.functionImageName = @"interface_camera";
            if (i == 0 || i == 2) {
                model.selectMode = SelectModeUnselected;
            }else if (i == 1) {
                model.selectMode = SelectModeSelected;
            }
            
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}
@end
