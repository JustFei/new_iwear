//
//  VersionUpdateTableViewCell.m
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "VersionUpdateTableViewCell.h"

@interface VersionUpdateTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *verLabel;
@property (nonatomic, strong) MDButton *checkUpdateButton;

@end

@implementation VersionUpdateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _verLabel = [[UILabel alloc] init];
        [_verLabel setFont:[UIFont systemFontOfSize:12]];
        [_verLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [self addSubview:_verLabel];
        [_verLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        _checkUpdateButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:nil];
        [_checkUpdateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_checkUpdateButton setTitle:@"检查版本" forState:UIControlStateNormal];
        [_checkUpdateButton setTitleColor:COLOR_WITH_HEX(0x2196f3, 0.87) forState:UIControlStateNormal];
        [_checkUpdateButton addTarget:self action:@selector(checkUpdateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkUpdateButton];
        [_checkUpdateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
    }
    
    return self;
}

- (void)checkUpdateAction:(MDButton *)sender
{
    
}

- (void)setModel:(VersionModel *)model
{
    if (model) {
        _model = model;
        [self.titleLabel setText:model.title];
        [self.verLabel setText:model.version];
    }
}

@end
