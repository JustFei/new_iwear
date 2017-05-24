//
//  TargetSettingTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TargetSettingTableViewCell.h"

@interface TargetSettingTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *targetLabel;

@end

@implementation TargetSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(16);
            make.top.equalTo(self.mas_top).offset(12);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(32);
            make.top.equalTo(_titleLabel.mas_bottom).offset(16);
        }];
        
        _targetLabel = [[UILabel alloc] init];
        [_targetLabel setTextColor:NAVIGATION_BAR_COLOR];
        [_targetLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_targetLabel];
        [_targetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_nameLabel.mas_centerY);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
    
    return self;
}

- (void)setModel:(TargetSettingModel *)model
{
    if (model) {
        _model = model;
        [self.titleLabel setText:model.title];
        [self.nameLabel setText:model.name];
        [self.targetLabel setText:[model.target stringByAppendingString:model.mode == TargetModeMotion ? @"步" : @"小时"]];
    }
}

@end
