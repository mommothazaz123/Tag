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
    BOOL notAskingIt;
    BOOL inGame;
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
    [self.volunteerItButton setHidden:YES];
    [self.volunteerItButton setEnabled:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Join Game" style:UIBarButtonItemStylePlain target:self action:@selector(joinGame)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Leave Game" style:UIBarButtonItemStylePlain target:self action:@selector(leaveGame)];
    
    [self.tagButton addTarget:self action:@selector(tagNearbyPlayer) forControlEvents:UIControlEventTouchDown];
    [self.volunteerItButton addTarget:self action:@selector(tagMe) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    notAskingIt = YES;
    inGame = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Handling

- (void)tagNearbyPlayer
{
    [_playerTagModel tagPlayer:[_taggablePlayers lastObject] fromPlayer:self.name inGame:self.game];
}

- (void)tagMe
{
    // Create a new location object and set its props to JsonElement properties
    Player *me = [[Player alloc] init];
    me.idnum = 0;
    me.name = self.name;
    me.game = self.game;
    me.state = self.state;
    me.latitude = 0;
    me.longitude = 0;
    [_playerTagModel tagPlayer:me fromPlayer:nil inGame:self.game];
    notAskingIt = YES;
}

- (void)leaveGame
{
    // Call the download items method of the model object
    [_gameLeaveModel leaveGameWithName:self.name];
    notAskingIt = YES;
    inGame = NO;
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
            inGame = YES;
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
        // Remove all existing annotations
        NSArray *currentAnnotations = self.mapView.annotations;
        [self.mapView removeAnnotations:currentAnnotations];
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
    if (inGame) {
        _players = items;
        [_taggablePlayers removeAllObjects];
        
        // Remove all existing annotations
        NSArray *currentAnnotations = self.mapView.annotations;
        [self.mapView removeAnnotations:currentAnnotations];
        
        // Initialize an array holding all players to check if ther is an it already
        NSMutableArray *itPlayers = [[NSMutableArray alloc]initWithCapacity:_players.count];
        
        for (Player *currentPlayer in _players) {
            // Iterate over each player
            // Make map annotation
            // Create coordinates from location lat/long
            
            if ([currentPlayer.name compare:self.name] == NSOrderedSame) {
                // Check to see if you're it!
                NSLog(@"%@", @"Found me!");
                self.state = currentPlayer.state;
                if (self.state.integerValue == 1) {
                    NSLog(@"%@", @"I'm it!");
                }
                
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
                    [itPlayers addObject:currentPlayer];
                } else {
                    pin.subtitle = [NSString stringWithFormat:@"%@", currentPlayer.name];
                }
                
                // only show players that are visible for efficiency
                if (MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(pin.coordinate))) {
                    
                    if (self.state.intValue == 1) {
                        NSLog(@"%@", @"Checking for taggable players...");
                        // Check to see if the player is within 10m of the player
                        CLCircularRegion *tagArea = [[CLCircularRegion alloc] initWithCenter:self.locationManager.location.coordinate radius:10 identifier:@"tagArea"];
                        if ([tagArea containsCoordinate:playerCoodinates]) {
                            [_taggablePlayers addObject:currentPlayer];
                            NSLog(@"I can tag %lu players", (unsigned long)[_taggablePlayers count]);
                        }
                    }
                    
                    [self.mapView addAnnotation:pin];
                    
                    if (itPlayers.count == 0 && notAskingIt && self.state.intValue == 0) {
                        [self.volunteerItButton setHidden:NO];
                        [self.volunteerItButton setEnabled:YES];
                    } else {
                        [self.volunteerItButton setHidden:YES];
                        [self.volunteerItButton setEnabled:NO];
                    }
                }
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
    if (self.name && self.game && self.state.intValue == 1 && _taggablePlayers) {// If you're in a game, and it, and there are people to tag...
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
