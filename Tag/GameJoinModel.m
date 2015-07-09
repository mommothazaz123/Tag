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
#warning Incomplete Implementation
    NSString *urlString = [NSString stringWithFormat:@"http://example.com/joingame.php?name=%@&game=%@", name, game];
    NSURL *jsonFileUrl = [NSURL URLWithString:urlString];
    
    // Create the request
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:jsonFileUrl];
    
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
    BOOL success = _downloadedData;
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate && success) {
        [self.delegate gameJoined:YES];
    } else if (self.delegate) {
        [self.delegate gameJoined:NO];
    }
}

@end
