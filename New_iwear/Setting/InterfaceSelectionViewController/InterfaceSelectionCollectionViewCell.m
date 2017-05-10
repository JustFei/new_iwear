//
//  InterfaceSelectionCollectionViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/5.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "InterfaceSelectionCollectionViewCell.h"

@interface InterfaceSelectionCollectionViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *selectView;

@end

@implementation InterfaceSelectionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = WHITE_COLOR;
        _headImageView = [[UIImageView alloc] init];
        //    [_headImageView setImage:[UIImage imageNamed:@"interface_camera"]];
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom).offset(-49);
        }];
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = CLEAR_COLOR;
        _bottomView.layer.borderColor = TEXT_BLACK_COLOR_LEVEL3.CGColor;//边框颜色
        _bottomView.layer.borderWidth = 1;//边框宽度
        
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_bottom).offset(-49);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_nameLabel setFont:[UIFont systemFontOfSize:16]];
        [_bottomView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomView.mas_centerY);
            make.left.equalTo(_bottomView.mas_left).offset(16 * SCREEN_BOUNDS.size.width / 375);
        }];
        
        _selectView = [[UIImageView alloc] init];
        [_bottomView addSubview:_selectView];
        [_selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomView.mas_centerY);
            make.left.equalTo(_nameLabel.mas_right).offset(8 * SCREEN_BOUNDS.size.width / 375);
            make.width.equalTo(@18);
            make.height.equalTo(@18);
        }];
    }
    return self;
}

- (void)setModel:(InterfaceSelectionModel *)model
{
    _model = model;
    [self.headImageView setImage:[UIImage imageNamed:model.functionImageName]];
    [self.nameLabel setText:model.functionName];
    switch (model.selectMode) {
        case SelectModeSelected:
            [self.selectView setImage:[UIImage imageNamed:@"interface_select_hig"]];
            break;
        case SelectModeUnselected:
            [self.selectView setImage:[UIImage imageNamed:@"interface_frame"]];
            break;
        case SelectModeUnchoose:
            [self.selectView setImage:[UIImage imageNamed:@"interface_select_nor"]];
            break;
            
        default:
            break;
    }
}



@end
