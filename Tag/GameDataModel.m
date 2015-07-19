//
//  GameDataModel.m
//  Tag
//
//  Created by Andrew Zhu on 7/18/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import "GameDataModel.h"

@interface GameDataModel()
{
    NSMutableData *_downloadedData;
}
@end

@implementation GameDataModel

- (void)downloadItemsFromGame:(NSString *)game withName:(NSString *)name
{
    // Download the json file
    NSString *urlString = [NSString stringWithFormat:@"http://shpquad.org/experimental/game.php?game=%@&name=%@", game, nil];
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
    // Create an array to store the locations
    NSMutableArray *_players = [[NSMutableArray alloc] init];
    
    // Parse the JSON that came in
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:_downloadedData options:NSJSONReadingAllowFragments error:&error];
    
    // Loop through Json objects, create question objects and add them to our questions array
    for (int i = 0; i < jsonArray.count; i++)
    {
        NSDictionary *jsonElement = jsonArray[i];
        
        // Create a new location object and set its props to JsonElement properties
        Player *newPlayer = [[Player alloc] init];
        newPlayer.idnum = jsonElement[@"id"];
        newPlayer.name = jsonElement[@"name"];
        newPlayer.game = jsonElement[@"game"];
        newPlayer.state = jsonElement[@"state"];
        newPlayer.latitude = jsonElement[@"latitude"];
        newPlayer.longitude = jsonElement[@"longitude"];
        
        // Add this question to the locations array
        [_players addObject:newPlayer];
    }
    
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate)
    {
        [self.delegate gameItemsDownloaded:_players];
        NSLog(@"%lu", (unsigned long)_downloadedData.length);
    }
}

@end
