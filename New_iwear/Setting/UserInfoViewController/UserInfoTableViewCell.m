//
//  UserInfoTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "UserInfoTableViewCell.h"

@interface UserInfoTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation UserInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:17]];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _unitLabel = [[UILabel alloc] init];
        [_unitLabel setFont:[UIFont systemFontOfSize:17]];
        [_unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [self addSubview:_unitLabel];
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
        
        _textField = [[UITextField alloc] init];
        [_textField setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_textField setFont:[UIFont systemFontOfSize:17]];
        [_textField setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(_nameLabel.mas_right).offset(10);
            make.right.equalTo(_unitLabel.mas_left).offset(10);
        }];
    }
    
    return self;
}

@end
