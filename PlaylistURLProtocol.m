//
//  PlaylistURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PlaylistURLProtocol.h"
#import "Playlist.h"
#import "StationList.h"

@implementation PlaylistURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *urlString = [[request URL] absoluteString];
    return ( [super canInitWithRequest:request] &&
             [urlString rangeOfString:@"getFragment"].location != NSNotFound );
}

// Init/Dealloc

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    Playlist *sharedPlaylist = [Playlist sharedPlaylist];
    [sharedPlaylist addInfoFromData:[self data]];
    
    NSString *startAnchor = @"&arg1=";
    NSString *endAnchor   = @"&arg2=";
    NSString *urlString = [[[self request] URL] absoluteString];
    NSRange startRange = [urlString rangeOfString:startAnchor];
    if( startRange.location == NSNotFound ) {
        NSLog(@"BUG:Couldn't find startAnchor in %@", urlString);
        return;
    }
    
    NSRange endRange = [urlString rangeOfString:endAnchor];
    if( endRange.location == NSNotFound ) {
        NSLog(@"BUG:Couldn't find endAnchor in %@", urlString);
        return;
    }
    
    NSRange r;
    r.location = startRange.location + [startAnchor length];
    r.length   = endRange.location - r.location;
    
    NSString *stationId = [urlString substringWithRange:r];
    [[StationList sharedStationList] setCurrentStationFromIdentifier:stationId];
}

@end
