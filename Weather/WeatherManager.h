//
//  WeatherManager.h
//  Weather
//
//  Created by Danil Kulheiko on 7/25/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "CLLocation+APTimeZones.h"

@interface WeatherManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *myLoaction;

+ (WeatherManager *)instance;

- (void)getWeatherForLatitude:(double)latitude andLongitude:(double)longitude withCompletion:(void(^)(NSDictionary* weather))completion;
- (void)getWeatherForNextDaysForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion;
- (void)getWeatherForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion;
- (void)getWeatherPerHourForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion;
- (void)getSearchForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion;

@end
