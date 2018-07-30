//
//  HourlyCollectionViewCell.h
//  Weather
//
//  Created by Danil Kulheiko on 7/24/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourlyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cloudsImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
