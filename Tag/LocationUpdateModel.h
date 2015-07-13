//
//  LocationUpdateModel.h
//  Tag
//
//  Created by Andrew Zhu on 7/12/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationUpdateModelProtocol <NSObject>

- (void)locationUpdated:(BOOL)success;

@end

@interface LocationUpdateModel : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<LocationUpdateModelProtocol> delegate;

- (void)updateLocationWithLocation:(CLLocation *)location andName:(NSString *)name;

@end
