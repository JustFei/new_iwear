//
//  TakePhotoViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "CameraViewController.h"

@interface TakePhotoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) MDButton *takePhotoButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;


@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"遥控拍照";
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
    [infoLabel setText:@"使用手表遥控拍照"];
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
    
    self.takePhotoButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
    [self.takePhotoButton setImage:[UIImage imageNamed:@"camera_takephone01"] forState:UIControlStateNormal];
    [self.takePhotoButton setBackgroundColor:CLEAR_COLOR];
    [self.takePhotoButton addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.takePhotoButton];
    [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_bottom).offset(105);
        make.width.equalTo(@72);
        make.height.equalTo(@72);
    }];
    self.takePhotoButton.layer.masksToBounds = YES;
    self.takePhotoButton.layer.cornerRadius = 36;
    
    UILabel *takePhotoLabel = [[UILabel alloc] init];
    [takePhotoLabel setText:@"开始拍照"];
    [takePhotoLabel setFont:[UIFont systemFontOfSize:14]];
    [takePhotoLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [self.view addSubview:takePhotoLabel];
    [takePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.takePhotoButton.mas_bottom).offset(17.5);
    }];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)takePhotoAction:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(setTakePhoto:) name:SET_TAKE_PHOTO object:nil];
        [[BleManager shareInstance] writeCameraMode:kCameraModeOpenCamera];
        
        //页面跳转
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    
    /** 由于自定义相机的优化不好，暂时先调用系统的 */
//    CameraViewController *vc = [[CameraViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - observer
- (void)setTakePhoto:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.takePhotoModel.takePhotoAction == YES) {
        [self.imagePicker takePicture];
    }
}

//PickerImage完成后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self saveImageToPhotoAlbum:newPhoto];
    //退出设备的相机模式
    [[BleManager shareInstance] writeCameraMode:kCameraModeCloseCamera];
    //关闭当前界面，即回到主界面去
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //调一下 cancel
    [self takePhotoAction:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //退出设备的相机模式
    [[BleManager shareInstance] writeCameraMode:kCameraModeCloseCamera];
}

#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    MDToast *toast = [[MDToast alloc] initWithText:msg duration:1.5];
    [toast show];
}

#pragma mark - lazy
- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

@end
