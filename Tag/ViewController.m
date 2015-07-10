//
//  ViewController.m
//  Tag
//
//  Created by Andrew Zhu on 7/7/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableData *_downloadedData;
    GameJoinModel *_gameJoinModel;
}

@end

@implementation ViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        NSLog(@"Ready for GPS data!");
    }
    [self.locationManager requestAlwaysAuthorization];
    
    if (self.name && self.game) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self joinGame];
    }
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    // TODO:
    // Setup Join Game button
    // Setup Leave Game button
    // Setup auto-game leave on application terminate (see AppDelegate.m)
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Handling

- (void) joinGame
{
    UIAlertController *joinMenu = [UIAlertController
                                   alertControllerWithTitle:@"Join Game"
                                   message:@"Please join a game."
                                   preferredStyle:UIAlertControllerStyleAlert];
    [joinMenu addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name";
        }];
    [joinMenu addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Game";
        }];
    [joinMenu addAction:[UIAlertAction
                         actionWithTitle:@"Join"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action){
                             [self alertControllerHandler:joinMenu];
                         }]];
    [self presentViewController:joinMenu animated:YES completion:nil];
}

- (void) gameJoined:(BOOL)success
{
    if (success) {
#warning Incomplete Implementation.
        if (self.name && self.game) {
            [self.locationManager startUpdatingLocation];
        } else {
            [self joinGame];
        }
    } else {
        UIAlertController *joinFail = [UIAlertController
                                       alertControllerWithTitle:@"Join Failed"
                                       message:@"Invalid username, it may already be taken."
                                       preferredStyle:UIAlertControllerStyleAlert];
        [joinFail addAction:[UIAlertAction
                             actionWithTitle:@"Retry"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action){
                                 [self joinGame];
                             }]];
        [self presentViewController:joinFail animated:YES completion:nil];
    }
}

#pragma mark - Alert View

- (void) alertControllerHandler:(UIAlertController*)controller
{
    NSString *name = ((UITextField *)[controller.textFields objectAtIndex:0]).text;
    NSString *game = ((UITextField *)[controller.textFields objectAtIndex:1]).text;
    
    self.game = game;
    self.name = name;
    
    // Create new HomeModel object and assign it to _homeModel variable
    _gameJoinModel = [[GameJoinModel alloc] init];
    
    // Set this view controller object as the delegate for the home model object
    _gameJoinModel.delegate = self;
    
    // Call the download items method of the home model object
    [_gameJoinModel joinGame:game withName:name];
}

#pragma mark - Map Update

- (void) updateMap
{
    // TODO:
    // Update location to server
    // Get location of other peeps in area from server
    // Show other peeps on map
    // Calculate distance to other peeps
    // Show / Don't show Tag button
    // Send tag request to server
}

#pragma mark - Location Handler

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", @"Core location has a position.");
    [self updateMap];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (self.name && self.game) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self joinGame];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", @"Core location can't get a fix.");
    //[self.locationManager startUpdatingLocation];
}



@end
