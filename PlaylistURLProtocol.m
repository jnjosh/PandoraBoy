//
//  PlaylistURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PlaylistURLProtocol.h"
#import <Foundation/NSURLProtocol.h>
#import "Playlist.h"

@implementation PlaylistURLProtocol

static NSString *PBPlaylistURLHeader = @"X-PB";
static NSString *PBDataRequest = @"getFragment";
static NSString *PBArtworkRequest = @"artwork";

// Accessors

- (NSURLConnection *)connection {
    return [[_connection retain] autorelease];
}

- (void)setConnection:(NSURLConnection *)value {
    if (_connection != value) {
        [_connection release];
        _connection = [value retain];
    }
}

- (NSURLRequest *)request {
    return [[_request retain] autorelease];
}

- (void)setRequest:(NSURLRequest *)value {
    if (_request != value) {
        [_request release];
        _request = [value retain];
    }
}

- (NSMutableData *)data {
    return [[_data retain] autorelease];
}

- (void)appendData:(NSData *)newData {
    if( _data == nil ) {
        _data = [[NSMutableData alloc] initWithData:newData];
    }
    else
    {
        [_data appendData:newData];
    }
}

// Class methods

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ( [[[request URL] scheme] isEqualToString:@"http"] &&
         [request valueForHTTPHeaderField:PBPlaylistURLHeader] == nil )
    {
        NSString *urlString = [[request URL] absoluteString];
        if( [urlString rangeOfString:PBDataRequest].location != NSNotFound )
        {
            return YES;
        }
        if( [[Playlist sharedPlaylist] needArtworkForURLString:urlString] )
        {
            return YES;
        }
    }
    return NO;
}

// Init/Dealloc

-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client
{
    // Modify request
    NSMutableURLRequest *myRequest = [request mutableCopy];

    NSString *urlString = [[request URL] absoluteString];
    if( [urlString rangeOfString:@"getFragment"].location != NSNotFound )
    {
        [myRequest setValue:PBDataRequest forHTTPHeaderField:PBPlaylistURLHeader];
    }
    else if ( [[Playlist sharedPlaylist] needArtworkForURLString:urlString] )
    {
        [myRequest setValue:PBArtworkRequest forHTTPHeaderField:PBPlaylistURLHeader];
    }
    else
    {
        NSLog(@"BUG: PlaylistURLProtocol received bad request:%@", [request URL]);
    }
        
    self = [super initWithRequest:myRequest
                   cachedResponse:cachedResponse
                           client:client];
    
    if ( self ) {
        [self setRequest:myRequest];
    }
    return self;
}

- (void)dealloc
{
    [_request release];
    [_connection release];
    [_data release];
    [super dealloc];
}

// Instance methods

- (void)startLoading
{
    //  use the regular URL donwload machinery to get the url contents
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[self request]
                                                                delegate:self];
    [self setConnection:connection];
}

-(void)stopLoading {
    [[self connection] cancel];
}

// NSURLConnection delegates (generally we pass these on to our client)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];

    NSString *requestType = [[self request] valueForHTTPHeaderField:PBPlaylistURLHeader];
    if( [requestType isEqualToString:PBDataRequest] )
    {
        [[Playlist sharedPlaylist] addInfoFromData:[self data]];
    }
    else if( [requestType isEqualToString:PBArtworkRequest] )
    {
        [[Playlist sharedPlaylist] addArtworkFromData:[self data] forURL:[[self request] URL]];
    }
}

@end
