//
//  RemindCollectionViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "RemindCollectionViewCell.h"

@interface RemindCollectionViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *functionNameLabel;
@property (nonatomic, strong) UILabel *isOpenLabel;

@end

@implementation RemindCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.mas_bottom).offset(-72);
            make.width.equalTo(@36);
            make.height.equalTo(@36);
        }];
        
        _functionNameLabel = [[UILabel alloc] init];
        [_functionNameLabel setTextColor:TEXT_COLOR_LEVEL3];
        [_functionNameLabel setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:_functionNameLabel];
        [_functionNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headImageView.mas_centerX);
            make.top.equalTo(_headImageView.mas_bottom).offset(16);
        }];
        
        _isOpenLabel = [[UILabel alloc] init];
        [_isOpenLabel setTextColor:TEXT_COLOR_LEVEL2];
        [_isOpenLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_isOpenLabel];
        [_isOpenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headImageView.mas_centerX);
            make.top.equalTo(_functionNameLabel.mas_bottom).offset(9);
        }];
        
        self.layer.borderColor = TEXT_COLOR_LEVEL1.CGColor;//边框颜色
        self.layer.borderWidth = 1;//边框宽度
    }
    return self;
}

- (void)setModel:(RemindModel *)model
{
    _model = model;
    [self.headImageView setImage:[UIImage imageNamed:model.headImageName]];
    [self.functionNameLabel setText:model.functionName];
    [self.isOpenLabel setText:model.isOpen ? @"已开启" : @"未开启"];
}

@end
