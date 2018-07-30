//
//  MainViewController.m
//  Weather
//
//  Created by Danil Kulheiko on 7/23/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import "MainViewController.h"
#import "HourlyCollectionViewCell.h"
#import "WeatherTableViewCell.h"
#import "WeatherManager.h"
#import "SearchCityViewController.h"

#import <MapKit/MapKit.h>

#define HourlyCell_ID @"HourlyCollectionViewCell_ID"
#define WeatherTableViewCell_ID @"WeatherTableViewCell_ID"
#define degreeCelsius @"\u00b0C"

typedef enum {
    понедельник = 0,
    вторник = 1,
    среда = 2,
    четверг = 3,
    пятница = 4,
    суббота = 5,
    воскресенье = 6
} Day;


@interface MainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

//UI IBOutlet's
@property(nonatomic, strong) IBOutlet UIView *weatherView;
@property(nonatomic, strong) IBOutlet UIButton *cityButton;
@property(nonatomic, strong) IBOutlet UILabel *currentDate;
@property(nonatomic, strong) IBOutlet UIImageView *cloudImageView;
@property(nonatomic, strong) IBOutlet UILabel *currentTemperature;
@property(nonatomic, strong) IBOutlet UILabel *humidityLabel;
@property(nonatomic, strong) IBOutlet UILabel *windLabel;
@property(nonatomic, strong) IBOutlet UIImageView *windDirection;
@property(nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, strong) UIButton *choosenLocation;

//Data
@property (strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic, strong) NSDictionary *perHourWeather;
@property(nonatomic, strong) NSDictionary *dayWeatherDictionary;
@property(nonatomic, strong) NSDictionary *nextDaysInfoDictionary;
@property(nonatomic, strong) NSMutableArray *nextDaysArray;
@property(nonatomic, strong) CLLocation *myLocation;
@property(nonatomic) NSInteger *daysCount;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate =self;
    self.tableView.dataSource = self;
    
    self.navigationController.navigationBarHidden =YES;
    
    if (!self.cityName) {
        
        [self initializeCurrentLocation];
        
        if (!self.cityName) {
            [self myLocation:nil];
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    if (self.cityName) {
        [[WeatherManager instance] getWeatherForCity:self.cityName withCompletion:^(NSDictionary *weather) {
            [self updateCurrentViewWithDictionary:weather];
            [self configureHourlyDayViewForCity:self.cityName];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location
- (void) initializeCurrentLocation{
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter=kCLDistanceFilterNone;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *crnLoc = [locations lastObject];

    self.myLocation = crnLoc;
    NSLog(@"%@", [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude]);
    NSLog(@"%@", [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude]);
    
    [[WeatherManager instance] getWeatherForLatitude:crnLoc.coordinate.latitude andLongitude:crnLoc.coordinate.longitude withCompletion:^(NSDictionary *weather) {
        self.cityName = [weather valueForKey:@"name"];
        [self updateCurrentViewWithDictionary:weather];
        [self configureHourlyDayViewForCity:[self toString:[weather valueForKey:@"name"]]];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

    NSLog(@"Error: %@",error.description);
}

- (void)configureHourlyDayViewForCity:(NSString*)cityName {
    
    [[WeatherManager instance] getWeatherPerHourForCity:cityName withCompletion:^(NSDictionary *weather) {
        
        self.perHourWeather = [NSDictionary dictionaryWithDictionary:weather];
        self.dayWeatherDictionary = [self getDictionaryPerDayFromDictionary:self.perHourWeather];
        [self.collectionView reloadData];
        [self.tableView reloadData];
    }];
}

#pragma mark - Delegates
#pragma mark - UICollectionViewDelegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 17;
}

-(NSString*)getTimeFromDictionary:(NSDictionary*)dictionary{
    NSString *fullTime = [self toString:[dictionary valueForKey:@"dt_txt"]];
    return [[fullTime substringFromIndex:11] substringToIndex:5];
}

- (UIImage*)getCloudsImageFromDictionary:(NSDictionary*)dictionary{
    
    UIImage *cloudsImage = [self setImageForClouds:YES withValue:[self getIconFromDictionary:[dictionary valueForKey:@"weather"]]];
    return cloudsImage;
}

- (NSString*)getTemperatureFromDictionary:(NSDictionary*)dictionary {
    NSDictionary *weatherDict = [dictionary valueForKey:@"main"];
    NSString *temp = [NSString stringWithFormat:@"%ld %@", [[weatherDict valueForKey:@"temp"]integerValue]-273, degreeCelsius];
    return temp;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HourlyCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:HourlyCell_ID forIndexPath:indexPath];
    
    NSArray *array = [self.perHourWeather valueForKey:@"list"];

    if (array) {
        cell.timeLabel.text = [self getTimeFromDictionary:[array objectAtIndex:indexPath.row]];
        cell.temperatureLabel.text = [self getTemperatureFromDictionary:[array objectAtIndex:indexPath.row]];
        cell.cloudsImageView.image= [self getCloudsImageFromDictionary:[array objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(65, self.collectionView.frame.size.height);
}

#pragma mark - UITableViewDelegate & DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dayWeatherDictionary.count;
}

- (UITableViewCell*) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    static NSString *reuseIdentifire = @"WeatherTableViewCell_ID";
    WeatherTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifire];
    
    if (!self.dayWeatherDictionary) {
        self.dayWeatherDictionary = [self getDictionaryPerDayFromDictionary:self.perHourWeather];
    }
    
    NSDictionary *dic = [self.nextDaysArray objectAtIndex:indexPath.row];
    
    cell.dayTableCellLabel.text = [self getDayNameFromTimestamp:[[dic valueForKey:@"dt"]doubleValue]];
    
    NSInteger maxTemp = ([[[dic valueForKey:@"main"] valueForKey:@"temp_max"] integerValue] -273);
    NSInteger minTemp = ([[[dic valueForKey:@"main"] valueForKey:@"temp_min"] integerValue] -273);
    
    cell.temperatureTableCellLabel.text = [NSString stringWithFormat:@"%ld\u00b0 / %ld\u00b0", (long)maxTemp, (long)minTemp];
    UIImage *img = [self getCloudsImageFromDictionary:dic];
    cell.cloudsTableCellImageView.image = img;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.layer.borderWidth = 2;
    bgColorView.layer.opacity = 1;
    
    UIColor *color =     [UIColor colorWithRed:90.0f/255.0f green:159.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    bgColorView.layer.borderColor = color.CGColor;

    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self updateCurrentViewWithDictionary:[self.nextDaysArray objectAtIndex:indexPath.row]];
    [self currentDate:NO withDictionary:[self.nextDaysArray objectAtIndex:indexPath.row]];
}

#pragma mark - Date

- (BOOL) day:(NSString*)date{
    NSDate *nowDate = [NSDate date];
    NSDate *dateOnly = [self getDateFrom:date];
    NSComparisonResult result = [dateOnly compare:nowDate];
    BOOL future;
    switch (result) {
        case NSOrderedAscending:
            future = NO;
            break;
        case NSOrderedDescending:
            future = YES;
            break;
            
        default:
            future = NO;
            break;
    }
    return future;
}

- (NSDate*)getDateFrom:(NSString*)dateString{
    
    double unixTimeStamp =[dateString doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    return date;
}

- (NSString*)getDayNameFromTimestamp:(double)timestamp{
    
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setLocale:[[NSLocale alloc]
                        initWithLocaleIdentifier:@"ru_UA"]];
    [weekday setDateFormat: @"EEEE"];
    NSTimeInterval _interval=timestamp;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSString *str = [self toString:[weekday stringFromDate:date]];
    
    if ([str isEqualToString:@"понедельник"]) {
        str = [NSString stringWithFormat:@"ПН"];
    } else if ([str isEqualToString:@"вторник"]){
        str = [NSString stringWithFormat:@"ВТ"];
    } else if ([str isEqualToString:@"среда"]){
        str = [NSString stringWithFormat:@"СР"];
    } else if ([str isEqualToString:@"четверг"]){
        str = [NSString stringWithFormat:@"ЧТ"];
    } else if ([str isEqualToString:@"пятница"]){
        str = [NSString stringWithFormat:@"ПТ"];
    } else if ([str isEqualToString:@"суббота"]){
        str = [NSString stringWithFormat:@"СБ"];
    } else {
        str = [NSString stringWithFormat:@"ВС"];
    }
    return str;
}

#pragma mark - Getters

- (NSDictionary*) getDictionaryPerDayFromDictionary:(NSDictionary*)dict {
    
    self.nextDaysArray = [[NSMutableArray alloc] init];
    NSDictionary *dayDictionary;
    NSMutableDictionary *arr = [NSMutableDictionary new];
    if (self.perHourWeather) {
        NSArray *byDayArray = [self.perHourWeather valueForKey:@"list"];
        for (NSDictionary* dict in byDayArray) {
            
            NSString *date = [dict valueForKey:@"dt"];
            BOOL dsa= [self day:date];
            if (dsa) {
                NSString *str = [self getDayNameFromTimestamp:[[dict valueForKey:@"dt"] doubleValue]];
                
                if (![arr valueForKey:str]) {
                    [arr setValue:dict forKey:str];
                    [self.nextDaysArray addObject:dict];
                }
            }
        }
        NSArray *array = [NSArray arrayWithObjects:arr, nil];
        dayDictionary = [array objectAtIndex:0];
    }
    return dayDictionary;
}

-(NSString*)getIconFromDictionary:(NSDictionary*)dictionary{
    
    NSString *cloudIcon = [[self toString:[dictionary valueForKey:@"icon"]]substringWithRange:NSMakeRange(6,3)];
    return cloudIcon;
}


- (void)updateCurrentViewWithDictionary:(NSDictionary *)weather {
    
    //set date
    [self currentDate:YES withDictionary:nil];
    
    //set city
    if ([weather valueForKey:@"name"]) {
        
        self.cityName = [self toString:[weather valueForKey:@"name"]];
        [self.cityButton setTitle:[self toString:[weather valueForKey:@"name"]] forState:UIControlStateNormal];
    }
    //set clouds
    self.cloudImageView.image = [self setImageForClouds:YES withValue:[self getIconFromDictionary:[weather valueForKey:@"weather"]]];
    
    //set temp
    NSInteger maxTemp = ([[[weather valueForKey:@"main"] valueForKey:@"temp_max"] integerValue] -273);
    NSInteger minTemp = ([[[weather valueForKey:@"main"] valueForKey:@"temp_min"] integerValue] -273);
    
    self.currentTemperature.text = [NSString stringWithFormat:@"%ld%@ / %ld%@", (long)maxTemp, degreeCelsius, (long)minTemp, degreeCelsius];
    
    //set humidity
    self.humidityLabel.text = [[self toString:[[weather valueForKey:@"main"] valueForKey:@"humidity"]] stringByAppendingString:@" %"];
    
    //set wind speed
    self.windLabel.text = [[self toString:[[weather valueForKey:@"wind"] valueForKey:@"speed"]] stringByAppendingString:@" м/с"];
    
    //set wind direction
    self.windDirection.image = [self setImageForClouds:NO withValue:[[weather valueForKey:@"wind"] valueForKey:@"deg"]];
}

- (UIImage*)setImageForClouds:(BOOL)forClouds withValue:(NSString*)value{
    
    if (forClouds) {
        if ([value isEqualToString:@"03d"] || [value isEqualToString:@"04d"] || [value isEqualToString:@"50d"]) {
            value = @"02d";
        } else if ([value isEqualToString:@"03n"] || [value isEqualToString:@"04n"] || [value isEqualToString:@"50n"]) {
            value = @"02n";
        }
        UIImage *image =[UIImage imageNamed:value];
        
        return image;
        
    } else{
        
        NSString *wind = [self windDirectionFromDegrees:value.floatValue];
        UIImage *image =[UIImage imageNamed:wind];
        
        return image;
    }
}

- (NSString *)windDirectionFromDegrees:(float)degrees {
    
    static NSArray *directions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Initialize array on first call.
        
        directions = @[@"wind_n", @"wind_ne", @"wind_e", @"wind_se", @"wind_s", @"wind_ws", @"wind_w", @"wind_wn"];
    });
    
    int i = (degrees + 11.25)/45;
    return directions[i % 8];
}

- (NSString*)toString:(id)value{
    return [NSString stringWithFormat:@"%@",value];
}

- (void)setNextDaysInfoWithDictionary:(NSDictionary*)nextDaysDictionary{
    
    self.nextDaysInfoDictionary = nextDaysDictionary;
}

- (void)currentDate:(BOOL)today withDictionary:(NSDictionary*)dateDict {
    
    if (today) {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLocale* currentLocale = [NSLocale currentLocale];
        NSString *date = [[self toString:[[NSDate date] descriptionWithLocale:currentLocale]] substringToIndex:16];
        
        self.currentDate.text = date;
    } else {
        self.currentDate.text = [[dateDict valueForKey:@"dt_txt"] substringToIndex:10];
    }
}

#pragma mark - Gesture

- (void)addGestureRecogniserToMapView {
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(addPinToMap:)];
    lpgr.minimumPressDuration = 0.5; //
    [self.mapView addGestureRecognizer:lpgr];
}

- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *toAdd = [[MKPointAnnotation alloc]init];
    
    toAdd.coordinate = touchMapCoordinate;
    toAdd.title = @"Dropped Pin";
    
    //Set your API Key at the top of this class, if you do not want to use an API key pass in nil
    [[WeatherManager instance] getWeatherForLatitude:toAdd.coordinate.latitude andLongitude:toAdd.coordinate.longitude withCompletion:^(NSDictionary *weather) {
        [self.choosenLocation setTitle:@"Done" forState:UIControlStateNormal];
        [self updateCurrentViewWithDictionary:weather];
        [self configureHourlyDayViewForCity:[self toString:[weather valueForKey:@"name"]]];
    }];
    [self.mapView addAnnotation:toAdd];
}

#pragma mark - Actions

- (IBAction)openMap:(id)sender {
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.weatherView.frame];
    self.weatherView.hidden = YES;

    [self.mapView addSubview:[self createDoneButton]];
    
    [self.view addSubview:self.mapView];
    [self addGestureRecogniserToMapView];
}

- (IBAction)setLocation:(UIButton *)choosenLocation {
    
    SearchCityViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([SearchCityViewController class])];
    [self presentViewController:controller animated:YES completion:nil];
}
- (UIButton*) createDoneButton {
    
    self.choosenLocation = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.choosenLocation setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.choosenLocation addTarget:self action:@selector(onDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.choosenLocation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    self.choosenLocation.frame=CGRectMake(self.mapView.bounds.size.width-70, 30, 70, 50);
    
    return self.choosenLocation;
}

- (void)onDoneButton:(id)sender {
    
    self.mapView.hidden = YES;
    self.weatherView.hidden = NO;
    [self.view layoutIfNeeded];
}

- (IBAction)myLocation:(id)sender {

    [[WeatherManager instance] getWeatherForLatitude:self.myLocation.coordinate.latitude andLongitude:self.myLocation.coordinate.longitude withCompletion:^(NSDictionary *weather) {
        [self updateCurrentViewWithDictionary:weather];
        [self configureHourlyDayViewForCity:[self toString:[weather valueForKey:@"name"]]];
    }];
}

@end
