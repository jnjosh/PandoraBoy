//
//  ArtworkURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ArtworkURLProtocol.h"
#import "Playlist.h"

@implementation ArtworkURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *urlString = [[request URL] absoluteString];
    return( [super canInitWithRequest:request] &&
            [[Playlist sharedPlaylist] needArtworkForURLString:urlString] );
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[Playlist sharedPlaylist] addArtworkFromData:[self data] forURL:[[self request] URL]];
    [super connectionDidFinishLoading:connection];
}

@end
