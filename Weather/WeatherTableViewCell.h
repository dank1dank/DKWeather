//
//  WeatherTableViewCell.h
//  Weather
//
//  Created by Danil Kulheiko on 7/24/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cloudsTableCellImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureTableCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayTableCellLabel;

- (void)setCell:(id)item withIndexPath:(NSIndexPath *)indexPath;
@end

