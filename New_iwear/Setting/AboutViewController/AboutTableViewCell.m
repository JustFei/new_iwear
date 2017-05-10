//
//  AboutTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "AboutTableViewCell.h"

@implementation AboutTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(16);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_chevron_right"]];
        [self addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-16);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    
    return self;
}

@end
