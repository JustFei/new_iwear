//
//  RemindMoreTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindMoreTableViewCell.h"

@interface RemindMoreTableViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *funcNameLabel;

@end

@implementation RemindMoreTableViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        DLog(@"00000");
        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
            make.width.equalTo(@24);
            make.height.equalTo(@24);
        }];
        
        _funcNameLabel = [[UILabel alloc] init];
        [_funcNameLabel setFont:[UIFont systemFontOfSize:16]];
        [_funcNameLabel setTextColor:TEXT_COLOR_LEVEL4];
        [self addSubview:_funcNameLabel];
        [_funcNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(72);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_chevron_right"]];
        [self addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
            make.width.equalTo(@24);
            make.height.equalTo(@24);
        }];
    }
    return self;
}

- (void)setModel:(RemindModel *)model
{
    DLog(@"111111");
    _model = model;
    [self.headImageView setImage:[UIImage imageNamed:model.headImageName]];
    [self.funcNameLabel setText:model.functionName];
}

@end
