//
//  GameDataModel.h
//  Tag
//
//  Created by Andrew Zhu on 7/18/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@protocol GameDataModelProtocol <NSObject>

- (void)gameItemsDownloaded:(NSArray *)items;

@end

@interface GameDataModel : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<GameDataModelProtocol> delegate;

- (void)downloadItemsFromGame:(NSString *)game withName:(NSString *)name;

@end
