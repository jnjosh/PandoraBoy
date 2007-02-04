//
//  WebViewProxy.m
//  PandoraBoy
//
//  Created by Aaron Rolett on 11/24/06.
//  Copyright 2006 Aaron Rolett. All rights reserved.
//

#import "WebViewProxy.h"

@implementation WebViewProxy

- (id) init 
{
	if ( self = [super init] ) {

	}
	
	return self;
}

- (void) loadRequest: (NSURLRequest*) request
{
	 NSLog(@"URL Request");
}

- (id) _UIDelegateForwarder
{
	 NSLog(@"UIDelegate");
	 return nil; 

}

- (void) _setTopLevelFrameName: (NSString*) name 
{
	 NSLog(@"TopLevelFrame: %@", name);
}

- (WebFrameProxy *)mainFrame
{
	 NSLog(@"mainFrame");
	return [[WebFrameProxy alloc] init]; 
}

- (void) dealloc 
{
	[super dealloc];
}

@end
