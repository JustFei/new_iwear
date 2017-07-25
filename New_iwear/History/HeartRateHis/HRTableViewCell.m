//
//  HRTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/13.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "HRTableViewCell.h"

@interface HRTableViewCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation HRTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dateLabel = [[UILabel alloc] init];
        [_dateLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_dateLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_dateLabel];
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        _unitLabel = [[UILabel alloc] init];
        [_unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_unitLabel setFont:[UIFont systemFontOfSize:8]];
        [_unitLabel setText:NSLocalizedString(@"time/min", nil)];
        [self addSubview:_unitLabel];
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset(8);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
        
        _dataLabel = [[UILabel alloc] init];
        [_dataLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_dataLabel setFont:[UIFont systemFontOfSize:17]];
        [self addSubview:_dataLabel];
        [_dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(_unitLabel.mas_left);
        }];
    }
    
    return self;
}

- (void)setModel:(HRTableModel *)model
{
    if (model) {
        _model = model;
        self.dateLabel.text = model.dateStr;
        self.timeLabel.text = model.timeStr;
        self.dataLabel.text = model.dataStr;
        self.unitLabel.text = model.unitStr;
    }
}

@end
