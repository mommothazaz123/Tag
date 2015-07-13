//
//  LocationUpdateModel.m
//  Tag
//
//  Created by Andrew Zhu on 7/12/15.
//  Copyright (c) 2015 Andrew Zhu. All rights reserved.
//

#import "LocationUpdateModel.h"

@interface LocationUpdateModel()
{
    NSMutableData *_downloadedData;
}
@end

@implementation LocationUpdateModel

- (void)updateLocationWithLocation:(CLLocation *)location andName:(NSString *)name
{
    // Download the json file
    NSString *urlString = [NSString stringWithFormat:@"http://shpquad.org/experimental/updateloc.php?name=%@&lat=%f&long=%f", name, location.coordinate.latitude, location.coordinate.longitude];
    NSURL *updateLocUrl = [NSURL URLWithString:urlString];
    
    // Create the request
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:updateLocUrl];
    
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
        [self.delegate locationUpdated:YES];
    } else if (self.delegate) {
        [self.delegate locationUpdated:NO];
    }
}

@end

