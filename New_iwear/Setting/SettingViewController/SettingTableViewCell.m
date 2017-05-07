//
//  SettingTableViewCell.m
//  
//
//  Created by Faith on 2017/5/3.
//
//

#import "SettingTableViewCell.h"


@interface SettingTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *funNameLabel;

@end

@implementation SettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter model
- (void)setModel:(SettingCellModel *)model
{
    _model = model;
    [_headImageView setImage:[UIImage imageNamed:model.headImageName]];
    [_funNameLabel setText:model.fucName];
}

@end
