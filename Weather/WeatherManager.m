//
//  WeatherManager.m
//  Weather
//
//  Created by Danil Kulheiko on 7/25/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import "WeatherManager.h"
#import "CLLocation+APTimeZones.h"

@implementation WeatherManager

static NSString *BASE_URL           = @"https://api.openweathermap.org/data/2.5/weather";
static NSString *FORECAST_URL       = @"https://api.openweathermap.org/data/2.5/forecast";
static NSString *FORECAST_DAILY_URL = @"https://api.openweathermap.org/data/2.5/forecast/daily";
static NSString *SEARCH_URL         = @"https://api.openweathermap.org/data/2.5/find";

static NSString *API_KEY = @"8ac8a41a9bcf5b44e7e16cc0e4e10ccc";
static NSString *SERVER_SIDE_ERROR = @"Request failed: server error (512)";



+ (WeatherManager *)instance
{
    static WeatherManager *instance = nil;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WeatherManager alloc]init];
        });
    }
    return instance;
}


#pragma mark - getWeather

- (void)getWeatherForLatitude:(double)latitude andLongitude:(double)longitude withCompletion:(void(^)(NSDictionary* weather))completion {
    

    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?lat=%f&lon=%f&APPID=%@",BASE_URL,latitude,longitude,API_KEY]];

    NSLog(@"Calling Weather API on %@",destinationUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:destinationUrl];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        completion(responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSLog(@"Error: %ld", (long)error.code);
        
        if ([[error localizedDescription]isEqualToString:SERVER_SIDE_ERROR]) {
            NSLog(@"Error - %@", error.localizedDescription);
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)getWeatherForNextDaysForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion {

    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?q=%@,&cnt=10&APPID=%@",FORECAST_DAILY_URL,cityName,API_KEY]];
 
    NSLog(@"Calling Weather API on %@",destinationUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:destinationUrl];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSLog(@"Error: %ld", (long)error.code);
        
        if ([[error localizedDescription]isEqualToString:SERVER_SIDE_ERROR]) {
            NSLog(@"Error - %@", error.localizedDescription);
        }
        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}


- (void)getWeatherForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion{

    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?q=%@&APPID=%@",BASE_URL,cityName,API_KEY]];
    
    NSLog(@"Calling Weather API on %@",destinationUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:destinationUrl];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSLog(@"Error: %ld", (long)error.code);
        
        if ([[error localizedDescription]isEqualToString:SERVER_SIDE_ERROR]) {
            NSLog(@"Error - %@", error.localizedDescription);
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)getSearchForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion{
    
    if ([cityName containsString:@" "]) {
        cityName = [cityName substringToIndex:[cityName length]-1];
    }
    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?q=%@&type=like&APPID=%@",SEARCH_URL,cityName,API_KEY]];
    
    NSLog(@"Calling Weather API on %@",destinationUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:destinationUrl];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSLog(@"Error: %ld", (long)error.code);
        
        if ([[error localizedDescription]isEqualToString:SERVER_SIDE_ERROR]) {
            NSLog(@"Error - %@", error.localizedDescription);
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)getWeatherPerHourForCity:(NSString*)cityName withCompletion:(void(^)(NSDictionary* weather))completion{

    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?q=%@&APPID=%@",FORECAST_URL,cityName,API_KEY]];
    
    NSLog(@"Calling Weather API on %@",destinationUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:destinationUrl];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSLog(@"Error: %ld", (long)error.code);

    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
