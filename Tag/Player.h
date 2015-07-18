//
//  Player.h
//  Tag
//
//  Created by Andrew Zhu on 7/18/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic, strong) NSNumber *idnum;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@end
