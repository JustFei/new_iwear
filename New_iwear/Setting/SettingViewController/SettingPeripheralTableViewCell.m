//
//  SettingPeripheralTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/3.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SettingPeripheralTableViewCell.h"

@interface SettingPeripheralTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *peripheralNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;

@end

@implementation SettingPeripheralTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter model
- (void)setPeripheralModel:(PeripheralCellModel *)peripheralModel
{
    [_peripheralNameLabel setText:peripheralModel.peripheralName];
    [_bindLabel setText:peripheralModel.isBind ? @"已绑定" : @"未绑定"];
    [_connectLabel setText:peripheralModel.isConnect ? @"已连接" : @"未连接"];
    [_powerLabel setText:[NSString stringWithFormat:@"剩余电量:%ld%%", peripheralModel.battery]];
}

@end