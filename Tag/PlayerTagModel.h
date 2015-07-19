//
//  PlayerTagModel.h
//  Tag
//
//  Created by Andrew Zhu on 7/19/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@protocol PlayerTagModelProtocol <NSObject>

- (void)playerTagged:(BOOL)success;

@end

@interface PlayerTagModel : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<PlayerTagModelProtocol> delegate;

- (void)tagPlayer:(Player *)player fromPlayer:(NSString *)from inGame:(NSString *)game;

@end