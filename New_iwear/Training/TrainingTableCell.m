//
//  TrainingTableCell.m
//  New_iwear
//
//  Created by JustFei on 2017/5/15.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "TrainingTableCell.h"

@interface TrainingTableCell ()

/** 时间段的文本 */
@property (nonatomic, strong) UILabel *periodLabel;
@property (nonatomic, strong) UILabel *sportTypeLabel;
@property (nonatomic, strong) UILabel *timeCountLabel;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *kcalLabel;

@end

@implementation TrainingTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"train_ic02"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
            make.width.equalTo(@48);
            make.height.equalTo(@48);
        }];
        
        [self.periodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(18);
            make.left.equalTo(headImageView.mas_right).offset(16);
        }];
        
        [self.sportTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.periodLabel.mas_top);
            make.left.equalTo(self.periodLabel.mas_right).offset(8);
        }];
        
        [self.timeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.periodLabel.mas_left);
            make.top.equalTo(self.periodLabel.mas_bottom).offset(8);
        }];
        
        [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeCountLabel.mas_top);
            make.centerX.equalTo(self.mas_centerX).offset(headImageView.frame.size.width / 2);
        }];
        
        [self.kcalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeCountLabel.mas_top);
            make.right.equalTo(self.mas_right).offset(-36);
        }];
        
    }
    
    return self;
}

- (void)setModel:(TrainingTableModel *)model
{
    if (model) {
        _model = model;
        self.periodLabel.text = model.periodStr;
        self.sportTypeLabel.text = model.sportTypeStr;
        self.timeCountLabel.text = model.timeCountStr;
        self.stepLabel.text = model.stepStr;
        self.kcalLabel.text = model.kcalStr;
    }
}

#pragma mark - lazy
- (UILabel *)periodLabel
{
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] init];
        [_periodLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_periodLabel setFont:[UIFont systemFontOfSize:12]];
        
        [self addSubview:_periodLabel];
    }
    
    return _periodLabel;
}

- (UILabel *)sportTypeLabel
{
    if (!_sportTypeLabel) {
        _sportTypeLabel = [[UILabel alloc] init];
        [_sportTypeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_sportTypeLabel setFont:[UIFont systemFontOfSize:12]];
        
        [self addSubview:_sportTypeLabel];
    }
    
    return _sportTypeLabel;
}

- (UILabel *)timeCountLabel
{
    if (!_timeCountLabel) {
        _timeCountLabel = [[UILabel alloc] init];
        [_timeCountLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_timeCountLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_timeCountLabel];
    }
    
    return _timeCountLabel;
}

- (UILabel *)stepLabel
{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        [_stepLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_stepLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_stepLabel];
    }
    
    return _stepLabel;
}

- (UILabel *)kcalLabel
{
    if (!_kcalLabel) {
        _kcalLabel = [[UILabel alloc] init];
        [_kcalLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_kcalLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self addSubview:_kcalLabel];
    }
    
    return _kcalLabel;
}

@end
