//
//  ViewController.h
//  Tag
//
//  Created by Andrew Zhu on 7/7/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GameJoinModel.h"
#import "GameLeaveModel.h"
#import "LocationUpdateModel.h"
#import "GameDataModel.h"
#import "Player.h"
#import "PlayerTagModel.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, GameJoinModelProtocol, GameLeaveModelProtocol, LocationUpdateModelProtocol, GameDataModelProtocol, PlayerTagModelProtocol>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *game;
@property (strong, nonatomic) NSNumber *state;
@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UIView *tagButtonView;
@property (weak, nonatomic) IBOutlet UIButton *volunteerItButton;

- (void)leaveGame;

@end

