//
//  ResourceURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ResourceURLProtocol.h"

NSString *PBResourceHost = @".RESOURCE.";

@implementation ResourceURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ( [[[request URL] scheme] isEqualToString:@"http"] &&
             [[[request URL] host] isEqualToString:PBResourceHost] );
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

-(void)startLoading
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *notifierPath = [[thisBundle resourcePath] stringByAppendingPathComponent:[[[self request] URL] path]];
    NSError *err;
    NSData *data = [NSData dataWithContentsOfFile:notifierPath
                                          options:NSUncachedRead
                                            error:&err];
    if( data )
    {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[[self request] URL]
                                                            MIMEType:@"text/html"
                                               expectedContentLength:[data length]
                                                    textEncodingName:nil];

        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [[self client] URLProtocol:self didLoadData:data];
        [[self client] URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSLog(@"BUG:Unable to load resource:%@:%@", notifierPath, [err description]);
        [[self client] URLProtocol:self didFailWithError:err];
    }
}

-(void)stopLoading
{
    return;
}

@end
