//
//  WebFrameProxy.m
//  PandoraBoy
//
//  Created by Aaron Rolett on 11/24/06.
//  Copyright 2006 Aaron Rolett. All rights reserved.
//

#import "WebFrameProxy.h"


@implementation WebFrameProxy

- (void) loadRequest: (NSURLRequest*) request
{
	[[NSWorkspace sharedWorkspace] openURL: [request URL]];	
	 NSLog(@"URL Request");
}


- (void) _loadRequest: (NSURLRequest*) request triggeringAction: (id) trigAction loadType: (id) loadtyp formState: (id) formstat
{
	[self loadRequest: request]; 
}

- (id) _bridge 
{
	return nil;
}

@end
