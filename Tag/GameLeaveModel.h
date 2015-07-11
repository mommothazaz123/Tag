//
//  GameLeaveModel.h
//  Tag
//
//  Created by Andrew Zhu on 7/11/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameLeaveModelProtocol <NSObject>

- (void)gameLeft:(BOOL)success;

@end

@interface GameLeaveModel : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<GameLeaveModelProtocol> delegate;

- (void)leaveGameWithName:(NSString *)name;

@end
