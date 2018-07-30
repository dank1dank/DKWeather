//
//  SearchCityViewController.m
//  Weather
//
//  Created by Danil Kulheiko on 7/27/18.
//  Copyright © 2018 Danil Kulheiko. All rights reserved.
//

#import "SearchCityViewController.h"
#import "MainViewController.h"
#import "WeatherManager.h"

@interface SearchCityViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) NSArray *searchedArray;
@property (nonatomic, assign) BOOL search;

@end

@implementation SearchCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate & DataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchedArray.count;
}

-(UITableViewCell*) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifire = @"CitiesCell_ID";
    [self.tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:reuseIdentifire];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifire];
    
    NSDictionary *dict = [self.searchedArray objectAtIndex:indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%@, %@", [dict valueForKey:@"name"], [[dict valueForKey:@"sys"] valueForKey:@"country"]];
    cell.textLabel.text = str;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MainViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([MainViewController class])];

    [self.searchedArray objectAtIndex:indexPath.row];
    controller.cityName = [[self.searchedArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)onSearchButton:(id)sender {

    [[WeatherManager instance] getSearchForCity:self.searchTextField.text withCompletion:^(NSDictionary *weather) {
        self.searchedArray = [NSArray arrayWithArray: [weather valueForKey:@"list"]];
        [self.tableView reloadData];
    }];
}

- (IBAction)backButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
