//
//  PlaylistURLProtocol.h
//  PandoraBoy
//
//  Created by Rob Napier on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
// Special NSURLProtocol to capture playlist information out of the stream.

#import <Cocoa/Cocoa.h>

@interface PlaylistURLProtocol : NSURLProtocol {
    NSURLRequest *_request;
    NSURLConnection *_connection;
    NSMutableData *_data;
}

@end
