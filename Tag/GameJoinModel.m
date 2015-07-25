//
//  GameJoinModel.m
//  Tag
//
//  Created by Andrew Zhu on 7/9/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import "GameJoinModel.h"

@interface GameJoinModel()
{
    NSMutableData *_downloadedData;
}
@end

@implementation GameJoinModel

- (void)joinGame:(NSString *)game withName:(NSString *)name
{
    // Download the json file
    NSString *urlString = [NSString stringWithFormat:@"http://shpquad.org/experimental/joingame.php?name=%@&game=%@", name, game];
    NSURL *joinGameUrl = [NSURL URLWithString:urlString];
    
    // Create the request
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:joinGameUrl];
    
    // Create the NSURLConnection
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma mark NSURLConnectionDataProtocol Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Initialize the data object
    _downloadedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the newly downloaded data
    [_downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"%lu",(unsigned long)_downloadedData.length);
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate && _downloadedData.length == 2) {
        [self.delegate gameJoined:YES];
    } else if (self.delegate) {
        [self.delegate gameJoined:NO];
    }
}

@end
