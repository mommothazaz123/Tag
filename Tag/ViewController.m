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
    GameLeaveModel *_gameLeaveModel;
    LocationUpdateModel *_locationUpdateModel;
    GameDataModel *_gameDataModel;
    NSArray *_players;
    NSMutableArray *_taggablePlayers;
    PlayerTagModel *_playerTagModel;
}

@end

@implementation ViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    
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
    // Setup background location updating (Apparently it already does...?)
    
    [self.tagButtonView setHidden:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Join Game" style:UIBarButtonItemStylePlain target:self action:@selector(joinGame)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Leave Game" style:UIBarButtonItemStylePlain target:self action:@selector(leaveGame)];
    
    [self.tagButton addTarget:self action:@selector(tagNearbyPlayer) forControlEvents:UIControlEventTouchDown];
    
    // Set up Model objects
    // Create new object and assign it to variable
    _gameLeaveModel = [[GameLeaveModel alloc] init];
    _gameJoinModel = [[GameJoinModel alloc] init];
    _locationUpdateModel = [[LocationUpdateModel alloc] init];
    _gameDataModel = [[GameDataModel alloc]init];
    _playerTagModel = [[PlayerTagModel alloc]init];
    
    // Set this view controller object as the delegate for the model object
    _gameLeaveModel.delegate = self;
    _gameJoinModel.delegate = self;
    _locationUpdateModel.delegate = self;
    _gameDataModel.delegate = self;
    _playerTagModel.delegate = self;
    
    
    _taggablePlayers = [[NSMutableArray alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Handling

- (void)tagNearbyPlayer
{
#warning todo
    [_playerTagModel tagPlayer:[_taggablePlayers lastObject] fromPlayer:self.name inGame:self.game];
}

- (void)leaveGame
{
    // Call the download items method of the model object
    [_gameLeaveModel leaveGameWithName:self.name];
}

- (void) joinGame
{
    if (self.game){
        UIAlertController *joinMenu = [UIAlertController
                                       alertControllerWithTitle:@"Join Game"
                                       message:@"Please leave your current game first!"
                                       preferredStyle:UIAlertControllerStyleAlert];
        [joinMenu addAction:[UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil]];
        [self presentViewController:joinMenu animated:YES completion:nil];
    } else {
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
}

#pragma mark - Game Delegate Methods

- (void) gameJoined:(BOOL)success
{
    if (success) {
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
                                 self.name = nil;
                                 self.game = nil;
                                 [self joinGame];
                             }]];
        [self presentViewController:joinFail animated:YES completion:nil];
    }
}

- (void)gameLeft:(BOOL)success
{
    if (success) {
        self.name = nil;
        self.game = nil;
        self.state = 0;
        [self.locationManager stopUpdatingLocation];
        UIAlertController *leaveSuccess = [UIAlertController
                                        alertControllerWithTitle:@"Leave Complete"
                                        message:@"You have left the game."
                                        preferredStyle:UIAlertControllerStyleAlert];
        [leaveSuccess addAction:[UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:nil]];
        [self presentViewController:leaveSuccess animated:YES completion:nil];
    } else {
        UIAlertController *leaveFail = [UIAlertController
                                       alertControllerWithTitle:@"Leave Failed"
                                       message:@"Failed to leave game, try again"
                                       preferredStyle:UIAlertControllerStyleAlert];
        [leaveFail addAction:[UIAlertAction
                             actionWithTitle:@"Retry"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action){
                                 [self leaveGame];
                             }]];
        [self presentViewController:leaveFail animated:YES completion:nil];
    }
}

- (void)locationUpdated:(BOOL)success
{
    
}

- (void)gameItemsDownloaded:(NSArray *)items
{
    _players = items;
    _taggablePlayers = nil;
    
    // Remove all existing annotations
    NSArray *currentAnnotations = self.mapView.annotations;
    [self.mapView removeAnnotations:currentAnnotations];
    
    for (int i = 0; i < _players.count; i++) {
        // Iterate over each player
        // Make map annotation
        // Create coordinates from location lat/long
        Player *currentPlayer = _players[i];
        
        if ([currentPlayer.name compare:self.name] == NSOrderedSame) {
            // Check to see if you're it!
            NSLog(@"%@", @"Found me!");
            self.state = currentPlayer.state;
            
        } else {
            CLLocationCoordinate2D playerCoodinates;
            playerCoodinates.latitude = [currentPlayer.latitude doubleValue];
            playerCoodinates.longitude = [currentPlayer.longitude doubleValue];
            
            // Plot pin
            MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
            pin.coordinate = playerCoodinates;
            pin.title = currentPlayer.name;
            if ([currentPlayer.state intValue] == 1) {
                pin.subtitle = @"It!";
            } else {
                pin.subtitle = [NSString stringWithFormat:@"%@", currentPlayer.name];
            }
            [self.mapView addAnnotation:pin];
            // Get distance to each player and add them to the taggable array if possible
            MKMapPoint tagAreaMP = MKMapPointForCoordinate(self.locationManager.location.coordinate);
            MKMapRect tagArea = MKMapRectMake(tagAreaMP.x, tagAreaMP.y, MKMapPointsPerMeterAtLatitude(self.locationManager.location.coordinate.latitude)*20, MKMapPointsPerMeterAtLatitude(self.locationManager.location.coordinate.latitude)*20);
            if (MKMapRectContainsPoint(tagArea, MKMapPointForCoordinate(pin.coordinate))) {
                [_taggablePlayers addObject:currentPlayer];
            }
        }
    }
}

- (void)playerTagged:(BOOL)success
{
    if (success) {
        self.state = 0;
    }
}

#pragma mark - Alert View

- (void) alertControllerHandler:(UIAlertController*)controller
{
    NSString *name = ((UITextField *)[controller.textFields objectAtIndex:0]).text;
    NSString *game = ((UITextField *)[controller.textFields objectAtIndex:1]).text;
    
    self.game = game;
    self.name = name;
    self.state = 0;
    
    // Call the download items method of the model object
    [_gameJoinModel joinGame:game withName:name];
}

#pragma mark - Map Update

- (void) updateMap
{
    // TODO:
    // Update location to server - Thread 1
    if (self.name && self.game) {
        [_locationUpdateModel updateLocationWithLocation:locationManager.location andName:self.name];
    }
    // Get location of other peeps in area from server - T2
    // Show other peeps on map - T2
    // Calculate distance to other peeps - T2
    if (self.name && self.game) {
        [_gameDataModel downloadItemsFromGame:self.game withName:self.name];
    }
    // Show / Don't show Tag button - T3
    // Send tag request to server - T3
    if (self.name && self.game && self.state && _taggablePlayers) {// If you're in a game, and it, and there are people to tag...
        [self.tagButtonView setHidden:NO]; // Show the tag button!
    } else {
        [self.tagButtonView setHidden:YES];
    }
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

#pragma mark - Map View Methods

-(MKAnnotationView*) returnPointView: (CLLocationCoordinate2D) location andTitle: (NSString*) title andColor: (int) color{
    /*Method that acts as a point-generating machine. Takes the parameters of the location, the title, and the color of the
     pin, and it returns a view that holds the pin with those specified details*/
    
    MKPointAnnotation *resultPin = [[MKPointAnnotation alloc] init];
    MKPinAnnotationView *result = [[MKPinAnnotationView alloc] initWithAnnotation:resultPin reuseIdentifier:Nil];
    [resultPin setCoordinate:location];
    resultPin.title = title;
    result.pinColor = color;
    return result;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    int pinColor;
    
    if ([annotation.subtitle  isEqual: @"It!"]) {
        pinColor = MKPinAnnotationColorRed;
    } else if (annotation.subtitle) {
        pinColor = MKPinAnnotationColorGreen;
    } else {
        pinColor = MKPinAnnotationColorPurple;
    }
    
    MKAnnotationView *pinView = [self returnPointView:annotation.coordinate andTitle:annotation.title andColor:pinColor];
    
    return pinView;
}

@end
