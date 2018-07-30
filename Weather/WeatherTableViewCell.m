//
//  WeatherTableViewCell.m
//  Weather
//
//  Created by Danil Kulheiko on 7/24/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import "WeatherTableViewCell.h"


@implementation WeatherTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.cloudsTableCellImageView = nil;
    [self.dayTableCellLabel setText:@"123"];
    [self.temperatureTableCellLabel setText:@"24"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell:(id)item withIndexPath:(NSIndexPath *)indexPath{
    self.cloudsTableCellImageView = nil;
    [self.dayTableCellLabel setText:@"123"];
    [self.temperatureTableCellLabel setText:@"24"];
    
}

@end
