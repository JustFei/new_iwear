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

@property (weak, nonatomic) IBOutlet UILabel *goToBindLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToBindImage;


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
//    if (peripheralModel.isBind) {
        _goToBindImage.hidden = peripheralModel.isBind;
        _goToBindLabel.hidden = peripheralModel.isBind;
        _peripheralNameLabel.hidden = !peripheralModel.isBind;
        _bindLabel.hidden = !peripheralModel.isBind;
        _connectLabel.hidden = !peripheralModel.isBind;
        _powerLabel.hidden = !peripheralModel.isBind;
        _headImageView.hidden = !peripheralModel.isBind;
        [_peripheralNameLabel setText:peripheralModel.peripheralName];
        [_bindLabel setText:peripheralModel.isBind ? NSLocalizedString(@"haveBindPer", nil) : NSLocalizedString(@"notBindPer", nil)];
        [_connectLabel setText:peripheralModel.isConnect ? NSLocalizedString(@"haveConnect", nil) : NSLocalizedString(@"notConnect", nil)];
        [_powerLabel setText:[NSString stringWithFormat:@"%@:%@%%", NSLocalizedString(@"electricity", nil), peripheralModel.battery]];
}

@end
