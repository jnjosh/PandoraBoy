//
//  StationsURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "StationsURLProtocol.h"
#import "StationList.h"

@implementation StationsURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *urlString = [[request URL] absoluteString];
    return ( [super canInitWithRequest:request] &&
             [urlString rangeOfString:@"getStations"].location != NSNotFound );
}

// Init/Dealloc

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[StationList sharedStationList] initFromData:[self data]];
    [super connectionDidFinishLoading:connection];
}

@end
