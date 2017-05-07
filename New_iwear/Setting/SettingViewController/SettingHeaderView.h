//
//  SettingHeaderView.h
//  New_iwear
//
//  Created by Faith on 2017/5/3.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserInfoButtonClickBlock)(void);

@interface SettingHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *userInfoButton;

@property (nonatomic, copy) UserInfoButtonClickBlock userInfoButtonClickBlock;

@end
