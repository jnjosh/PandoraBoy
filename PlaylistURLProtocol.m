//
//  PlaylistURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PlaylistURLProtocol.h"
#import "Playlist.h"

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
    [[Playlist sharedPlaylist] addInfoFromData:[self data]];
}

@end
