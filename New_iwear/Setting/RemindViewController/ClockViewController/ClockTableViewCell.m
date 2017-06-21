//
//  ClockTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "ClockTableViewCell.h"

@interface ClockTableViewCell ()

@property (nonatomic, strong) MDButton *timeButton;
/** 几小时后开始振动 */
@property (nonatomic, strong) UILabel *ringTimeLabel;
@property (nonatomic, strong) MDButton *switchButton;

@end

@implementation ClockTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _timeButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        _timeButton.backgroundColor = CLEAR_COLOR;
        [_timeButton.titleLabel setFont:[UIFont systemFontOfSize:23]];
        [_timeButton setTitleColor:TEXT_BLACK_COLOR_LEVEL4 forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_timeButton];
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(_timeButton.mas_right).offset(8);
            make.width.equalTo(@1);
            make.height.equalTo(@32);
        }];
        
        _ringTimeLabel = [[UILabel alloc] init];
        [_ringTimeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_ringTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_ringTimeLabel];
        [_ringTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(lineView.mas_left).offset(8);
        }];
        
        _switchButton = [[MDButton alloc] initWithFrame:CGRectZero type:MDButtonTypeFlat rippleColor:CLEAR_COLOR];
        [_switchButton setImage:[UIImage imageNamed:@"ic_off"] forState:UIControlStateNormal];
        [_switchButton setImage:[UIImage imageNamed:@"ic_on"] forState:UIControlStateSelected];
        _switchButton.backgroundColor = CLEAR_COLOR;
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchButton];
        [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
            make.width.equalTo(@48);
            make.height.equalTo(@48);
        }];
    }
    return self;
}

- (void)setModel:(ClockModel *)model
{
    if (model) {
        _model = model;
        [self.timeButton setTitle:model.time forState:UIControlStateNormal];
        [self.timeButton setTitleColor:model.isOpen ? TEXT_BLACK_COLOR_LEVEL4 : TEXT_BLACK_COLOR_LEVEL3  forState:UIControlStateNormal];
        [self.timeButton setEnabled:model.isOpen];
        [self.switchButton setSelected:model.isOpen];
    }
}

#pragma mark - Action
- (void)changeTime:(MDButton *)sender
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        //显示时间选择器
        if (self.timeButtonActionBlock) {
            self.timeButtonActionBlock();
        }
    }
}

- (void)switchAction:(MDButton *)sender
{
    [sender setSelected:!sender.selected];
    [self.timeButton setTitleColor:sender.selected ? TEXT_BLACK_COLOR_LEVEL4 : TEXT_BLACK_COLOR_LEVEL3  forState:UIControlStateNormal];
    [self.timeButton setEnabled:sender.selected];
    if (self.timeSwitchActionBlock) {
        self.timeSwitchActionBlock();
    }
}



@end
