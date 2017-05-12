//
//  UserInfoViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoTableViewCell.h"
#import "FMDBManager.h"
#import "BleManager.h"
#import "UserInfoModel.h"
#import "UserInfoSettingModel.h"
#import "UnitsTool.h"

typedef enum : NSUInteger {
    PickerTypeGender = 0,
    PickerTypeAge,
    PickerTypeHeight,
    PickerTypeWeight,
} PickerType;

static NSString * const UserInfoTableViewCellID = @"UserInfoTableViewCell";

@interface UserInfoViewController () <UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate ,UINavigationControllerDelegate ,UIImagePickerControllerDelegate ,UIAlertViewDelegate ,UIPickerViewDelegate ,UIPickerViewDataSource ,BleReceiveDelegate>
{
    NSArray *_userArr;
    NSArray *_genderArr;
}

@property (nonatomic, weak) UIImageView *headImageView;
@property (nonatomic, weak) UITextField *userNameTextField;
@property (nonatomic, weak) UITableView *infoTableView;
@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic, strong) FMDBManager *myFmdbTool;
@property (nonatomic, strong) BleManager *myBleTool;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) BOOL isMetric;
@property (nonatomic ,assign) PickerType pickerType;
@property (nonatomic ,strong) UIPickerView *infoPickerView;
@property (nonatomic ,strong) NSArray *genderArr;
@property (nonatomic ,strong) NSArray *ageArr;
@property (nonatomic ,strong) NSArray *heightArr;
@property (nonatomic ,strong) NSArray *weightArr;

@end

@implementation UserInfoViewController

#pragma mark - lyfeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMetric = [self isMetricOrImperialSystem];
    
    _genderArr = @[NSLocalizedString(@"male", nil),NSLocalizedString(@"Female", nil)];
    
    self.navigationItem.title = @"用户信息";
    self.view.backgroundColor = NAVIGATION_BAR_COLOR;
    
    _userArr = [self.myFmdbTool queryAllUserInfo];
    
    [self.saveButton setBackgroundColor:[UIColor whiteColor]];
    
    if (_userArr.count == 0) {
        [self setInitUI];
    }else {
        [self setSaveUI:_userArr];
    }
    
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 261 * VIEW_CONTROLLER_FRAME_WIDTH / 320, self.view.frame.size.width, 8 * VIEW_CONTROLLER_FRAME_WIDTH / 320)];
    lineView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:lineView];
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.title = @"设备绑定";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = NAVIGATION_BAR_COLOR;
}

- (void)dealloc
{
    //注销掉所有代理和关闭数据库
//    self.infoTableView.delegate = nil;
//    self.infoTableView.dataSource = nil;
//    self.myBleTool.receiveDelegate = nil;
//    [self.myFmdbTool CloseDataBase];
}

- (void)setInitUI
{
    self.headImageView.backgroundColor = [UIColor whiteColor];
}

- (void)setSaveUI:(NSArray *)userArr
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]) {
        DLog(@"hello == %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]);
        [self.userNameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"]) {
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"];
        [self.headImageView setImage:[UIImage imageWithData:imageData]];
    }else {
        self.headImageView.backgroundColor = [UIColor whiteColor];
    }
}

//判断是否是公制单位
- (BOOL)isMetricOrImperialSystem
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"]) {
        BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"];
        return isMetric;
    }else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setHeadImage
{
    AlertTool *alert = [AlertTool alertWithTitle:nil message:nil style:UIAlertControllerStyleActionSheet];
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"相册", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//方式1
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //按钮：拍照，类型：UIAlertActionStyleDefault
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"拍照", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;//方式1
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //按钮：取消，类型：UIAlertActionStyleCancel
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:AlertToolStyleCancel handler:nil]];
    [alert show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//PickerImage完成后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //把newPhono设置成头像
    [self.headImageView setImage:newPhoto];
    //关闭当前界面，即回到主界面去
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showInfoPickerView:(NSString *)infoText
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //self.isChange = YES;
        //获取到该cell的label对象，修改text
//        if (self.title) {
//            self.infoLabel.text = self.title;
//            self.title = nil;
//            switch (self.pickerType) {
//                case PickerTypeGender:
//                {
//                    if ([self.infoLabel.text isEqualToString:@"男"]) {
//                        self.changeModel.gender = 0;
//                    }else if ([self.infoLabel.text isEqualToString:@"女"]) {
//                        self.changeModel.gender = 1;
//                    }else if ([self.infoLabel.text isEqualToString:@"未选择"]) {
//                        self.changeModel.gender = -1;
//                    }
//                }
//                    break;
//                case PickerTypeBirthday:
//                {
//                    self.changeModel.birthday = self.infoLabel.text;
//                }
//                    break;
//                case PickerTypeHeight:
//                {
//                    self.changeModel.height = self.infoLabel.text.integerValue;
//                }
//                    break;
//                case PickerTypeWeight:
//                {
//                    self.changeModel.weight = self.infoLabel.text.integerValue;
//                }
//                    break;
//                case PickerTypeMotionTarget:
//                {
//                    self.changeModel.stepTarget = self.infoLabel.text.integerValue;
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    switch (self.pickerType) {
        case PickerTypeGender:
        {
            self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
            self.infoPickerView.dataSource = self;
            self.infoPickerView.delegate = self;
//            NSInteger index = [self.genderArr indexOfObject:infoText];
            NSInteger index = 0;
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeAge:
        {
            self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
            self.infoPickerView.dataSource = self;
            self.infoPickerView.delegate = self;
            //            NSInteger index = [self.heightArr indexOfObject:infoText];
            NSInteger index = 0;
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeHeight:
        {
            self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
            self.infoPickerView.dataSource = self;
            self.infoPickerView.delegate = self;
//            NSInteger index = [self.heightArr indexOfObject:infoText];
            NSInteger index = 0;
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeWeight:
        {
            self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
            self.infoPickerView.dataSource = self;
            self.infoPickerView.delegate = self;
//            NSInteger index = [self.weightArr indexOfObject:infoText];
            NSInteger index = 0;
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
            
        default:
            break;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -ButtonAction
- (void)saveUserInfo
{
    [self.view endEditing:YES];
//     && self.steplengthTextField.text != nil && self.steplengthTextField.text.length != 0
    if (self.userNameTextField.text != nil && self.userNameTextField.text.length != 0 && self.ageTextField.text != nil && self.ageTextField.text.length != 0 && self.heightTextField.text != nil && self.heightTextField.text.length != 0 && self.weightTextField.text != nil && self.weightTextField.text.length != 0) {
        
        [self.myBleTool writeUserInfoToPeripheralWeight:self.weightTextField.text andHeight:self.heightTextField.text];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        
        NSArray *userArr = [self.myFmdbTool queryAllUserInfo];
        
        //计算出在英制和公制下的身高体重
        NSInteger height = self.isMetric ? self.heightTextField.text.integerValue : [UnitsTool cmAndInch:self.heightTextField.text.integerValue withMode:ImperialToMetric];
        NSInteger weight = self.isMetric ? self.weightTextField.text.integerValue : [UnitsTool kgAndLb:self.weightTextField.text.integerValue withMode:ImperialToMetric];
        
        UserInfoModel *model = [UserInfoModel userInfoModelWithUserName:self.userNameTextField.text andGender:self.genderLabel.text andAge:self.ageTextField.text.integerValue andHeight:height andWeight:weight andStepLength:self.steplengthTextField.text.integerValue andStepTarget:0 andSleepTarget:0];
       
        if (userArr.count == 0) {
           BOOL isSuccess = [self.myFmdbTool insertUserInfoModel:model];
            if (isSuccess) {
                self.hud.label.text = NSLocalizedString(@"saveSuccess", nil);
                
                NSData *imageData = UIImagePNGRepresentation(self.headImageView.image);
                [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"userheadimage"];
                
                [self.hud hideAnimated:YES afterDelay:1];
            }else {
                self.hud.label.text = NSLocalizedString(@"saveFailAndTryAgain", nil);
                [self.hud hideAnimated:YES afterDelay:1];
            }
        }else {
            BOOL isSuccess = [self.myFmdbTool modifyUserInfoWithID:1 model:model];
            if (isSuccess) {
                self.hud.label.text = NSLocalizedString(@"changeSuccess", nil);
                
                NSData *imageData = UIImagePNGRepresentation(self.headImageView.image);
                [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"userheadimage"];
                
                [self.hud hideAnimated:YES afterDelay:1];
            }else {
                self.hud.label.text = NSLocalizedString(@"changeFailAndTryAgain", nil);
                [self.hud hideAnimated:YES afterDelay:1];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"currentusername"];
        
        DLog(@"gang gang set == %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]);
        
    }else {
        AlertTool *vc = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"infoNotComplete", nil) style:UIAlertControllerStyleAlert];
        [vc addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:nil]];
        
        [vc show];
         
    }
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
        case PickerTypeGender:
            return self.genderArr.count;
            break;
        case PickerTypeAge:
            return self.ageArr.count;
            break;
        case PickerTypeHeight:
            return self.heightArr.count;
            break;
        case PickerTypeWeight:
            return self.weightArr.count;
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
        case PickerTypeGender:
            return self.genderArr[row];
            break;
        case PickerTypeAge:
            return self.ageArr[row];
            break;
        case PickerTypeWeight:
            return self.weightArr[row];
            break;
        case PickerTypeHeight:
            return self.heightArr[row];
            break;
            
        default:
            break;
    }
    return 0;
}

// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component

{
    switch (self.pickerType) {
        case PickerTypeGender:
            self.title = self.genderArr[row];
            break;
            
        case PickerTypeAge:
            self.title = self.ageArr[row];
            break;
            
        case PickerTypeHeight:
            self.title = self.heightArr[row];
            break;
            
        case PickerTypeWeight:
            self.title = self.weightArr[row];
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
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.pickerType = indexPath.row;
    UserInfoSettingModel *model = self.dataArr[indexPath.row];
    [self showInfoPickerView:model.placeHoldText];
}

#pragma mark - BleReceiveDelegate
- (void)receiveUserInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypeUserInfoModel) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            
        }
    }
}

#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = CLEAR_COLOR;
        imageView.image = [UIImage imageNamed:@"set_head"];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setHeadImage)];
        [imageView addGestureRecognizer:tap];
        
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(80);
            make.width.equalTo(@127);
            make.height.equalTo(@127);
        }];
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.cornerRadius = 127 / 2;
        
        _headImageView = imageView;
    }
    
    return _headImageView;
}

- (UITextField *)userNameTextField
{
    if (!_userNameTextField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = NSLocalizedString(@"请输入用户名", nil);
        
        [textField setValue:WHITE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:14];
        
        [self.view addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(215);
            make.width.equalTo(@200);
            make.height.equalTo(@34);
        }];
        _userNameTextField = textField;
    }
    
    return _userNameTextField;
}

- (UITableView *)infoTableView
{
    if (!_infoTableView) {
        UITableView *_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.backgroundColor = CLEAR_COLOR;
        
        [_tableView registerClass:NSClassFromString(UserInfoTableViewCellID)forCellReuseIdentifier:UserInfoTableViewCellID];
        
        [self.view addSubview:_tableView];
        _infoTableView = _tableView;
    }
    
    return _infoTableView;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 85 * VIEW_CONTROLLER_FRAME_WIDTH / 320, self.view.frame.size.height - 64 * VIEW_CONTROLLER_FRAME_WIDTH / 320, 170 * VIEW_CONTROLLER_FRAME_WIDTH / 320, 44)];
        [button addTarget:self action:@selector(saveUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 5;
        
        [self.view addSubview:button];
        _saveButton = button;
    }
    
    return _saveButton;
}

- (FMDBManager *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBManager alloc] initWithPath:@"UserList"];
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@""];
    }
    
    return _myFmdbTool;
}

- (BleManager *)myBleTool
{
    if (!_myBleTool) {
        _myBleTool = [BleManager shareInstance];
        _myBleTool.receiveDelegate = self;
    }
    
    return _myBleTool;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *nameArr = @[NSLocalizedString(@"性别", nil),NSLocalizedString(@"年龄", nil),NSLocalizedString(@"身高", nil),NSLocalizedString(@"体重", nil)];
        NSArray *fieldPlaceholdeArr = @[@"男",NSLocalizedString(@"请输入年龄", nil),NSLocalizedString(@"请输入身高", nil),NSLocalizedString(@"请输入体重", nil)];
        NSArray *unitArr = @[@"",NSLocalizedString(@"岁", nil),self.isMetric ? @"(cm)" : @"(In)",self.isMetric ? @"(kg)" : @"(lb)"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < nameArr.count; index ++) {
            UserInfoSettingModel *model = [[UserInfoSettingModel alloc] init];
            model.nameText = nameArr[index];
            model.placeHoldText = fieldPlaceholdeArr[index];
            model.unitText = unitArr[index];
            model.isGenderCell = index == 0 ? YES : NO;
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

- (NSArray *)genderArr
{
    if (!_genderArr) {
        _genderArr = @[@"男",@"女"];
    }
    return _genderArr;
}

- (NSArray *)ageArr
{
    if (!_ageArr) {
        NSMutableArray *ageMutArr = [NSMutableArray array];
        for (int i = 0; i <= 100; i ++) {
            NSString *age = [NSString stringWithFormat:@"%d",i];
            [ageMutArr addObject:age];
        }
        _ageArr = ageMutArr;
    }
    return _ageArr;
}

- (NSArray *)heightArr
{
    if (!_heightArr) {
        NSMutableArray *heightMutArr = [NSMutableArray array];
        for (int i = 90; i <= 200; i ++) {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [heightMutArr addObject:height];
        }
        _heightArr = heightMutArr;
    }
    
    return _heightArr;
}

- (NSArray *)weightArr
{
    if (!_weightArr) {
        NSMutableArray *weightMutArr = [NSMutableArray array];
        for (int i = 15; i <= 150; i ++) {
            NSString *weight = [NSString stringWithFormat:@"%d",i];
            [weightMutArr addObject:weight];
        }
        _weightArr = weightMutArr;
    }
    
    return _weightArr;
}

@end
