//
//  GameJoinModel.h
//  Tag
//
//  Created by Andrew Zhu on 7/9/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameJoinModelProtocol <NSObject>

- (void)gameJoined:(BOOL)success;

@end

@interface GameJoinModel : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<GameJoinModelProtocol> delegate;

- (void)joinGame:(NSString *)game withName:(NSString *)name;

@end
