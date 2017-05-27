//
//  TargetSettingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TargetSettingViewController.h"
#import "TargetSettingTableViewCell.h"

typedef enum : NSUInteger {
    PickerTypeMotionTarget = 0,
    PickerTypeSleepTarget
} PickerType;


static NSString * const TargetSettingTableViewCellID = @"TargetSettingTableViewCell";

@interface TargetSettingViewController () < UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *motionArr;
@property (nonatomic, strong) NSArray *sleepArr;
@property (nonatomic, copy) NSString *selectTilte;
@property (nonatomic, strong) UIPickerView *infoPickerView;
@property (nonatomic, assign) PickerType pickerType;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation TargetSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"目标设置";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveMotionTargetAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMotionTargetWeatherSuccess:) name:SET_MOTION_TARGET object:nil];
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

- (void)saveMotionTargetAction
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BleManager shareInstance] writeMotionTargetToPeripheral:((TargetSettingModel*)self.dataArr.firstObject).target];
}

- (void)setMotionTargetWeatherSuccess:(NSNotification *)noti
{
    BOOL isFirst = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"isFirst:%d",isFirst);
    //这里不能直接写 if (isFirst),必须如下写法
    if (isFirst == 1) {
        //保存设置到本地
        NSMutableArray *saveMutArr = [NSMutableArray array];
        for (TargetSettingModel *model in self.dataArr) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
            [saveMutArr addObject:data];
        }
        //这里只能保存不可变数组，所以要转换
        NSArray *saveArr = [NSArray arrayWithArray:saveMutArr];
        [[NSUserDefaults standardUserDefaults] setObject:saveArr forKey:TARGET_SETTING];
        
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
        [sucToast show];
    }else {
        //做失败处理
        [self.hud hideAnimated:YES];
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存失败，稍后再试" duration:1.5];
        [sucToast show];
    }
}

#pragma mark - 选择器
- (void)showTimePickerViewWith:(NSIndexPath *)indexPath
{
    self.pickerType = indexPath.row == 0 ? TargetModeMotion : TargetModeSleep;
    NSArray *targetArr = indexPath.row == 0 ? self.motionArr : self.sleepArr;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //初始化 selectTime
        self.selectTilte = @"";
    }];
    
    //修改数据源的数据
    TargetSettingModel *model = self.dataArr[indexPath.row];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        model.target = self.selectTilte;
        [self.tableView reloadData];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    //这一步的目的：如果用户没有改变 picker 的值，就直接初始化为 model.time
    self.selectTilte = model.target;
    self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
    self.infoPickerView.dataSource = self;
    self.infoPickerView.delegate = self;
    
    NSInteger index = [targetArr indexOfObject:model.target];
    [self.infoPickerView selectRow:index inComponent:0 animated:NO];
    [alert.view addSubview:self.infoPickerView];
    
    //    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    //    [currentFormatter setDateFormat:@"hh:mm"];
    //    self.selectTitle = [currentFormatter stringFromDate:[NSDate date]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
// UIPickerViewDataSource中定义的方法，该方法的返回值决定改控件包含多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// UIPickerViewDataSource中定义的方法，该方法的返回值决定该控件指定列包含多少哥列表项

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case PickerTypeMotionTarget:
            return self.motionArr.count;
            break;
        case PickerTypeSleepTarget:
            return self.sleepArr.count;
            break;
            
        default:
            break;
    }
    
    return 0;
}

// UIPickerViewDelegate中定义的方法，该方法返回NSString将作为UIPickerView中指定列和列表项上显示的标题

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case PickerTypeMotionTarget:
            return self.motionArr[row];
            break;
        case PickerTypeSleepTarget:
            return self.sleepArr[row];
        default:
            break;
    }
    return 0;
}

// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component

{
    switch (self.pickerType) {
            
        case PickerTypeMotionTarget:
            self.selectTilte = self.motionArr[row];
            break;
        case PickerTypeSleepTarget:
            self.selectTilte = self.sleepArr[row];
            break;
            
        default:
            break;
    }
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
    TargetSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TargetSettingTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        //show data picker
        [self showTimePickerViewWith:indexPath];
    }
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(TargetSettingTableViewCellID) forCellReuseIdentifier:TargetSettingTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING]) {
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_SETTING];
            NSMutableArray *mutArr = [NSMutableArray array];
            for (NSData *data in arr) {
                TargetSettingModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [mutArr addObject:model];
            }
            _dataArr = mutArr;
        }else {
            TargetSettingModel *model1 = [[TargetSettingModel alloc] init];
            model1.title = @"运动目标";
            model1.name = @"每天步行";
            model1.target = @"8000";
            model1.mode = TargetModeMotion;
            
            TargetSettingModel *model2 = [[TargetSettingModel alloc] init];
            model2.title = @"睡眠目标";
            model2.name = @"每天睡眠";
            model2.target = @"8";
            model2.mode = TargetModeSleep;
            _dataArr = @[model1, model2];
        }
    }
    
    return _dataArr;
}

- (NSArray *)motionArr
{
    if (!_motionArr) {
        NSMutableArray *targetMutArr = [NSMutableArray array];
        for (int i = 1000; i <= 50000; i = i + 1000) {
            [targetMutArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
        _motionArr = targetMutArr;
    }
    
    return _motionArr;
}

- (NSArray *)sleepArr
{
    if (!_sleepArr) {
        NSMutableArray *targetMutArr = [NSMutableArray array];
        for (int i = 0; i <= 12; i ++) {
            [targetMutArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
        _sleepArr = targetMutArr;
    }
    
    return _sleepArr;
}

@end
