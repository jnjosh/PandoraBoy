//
//  PBFullScreenPlugin.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PBFullScreenPlugin.h"
#import "PBNotifications.h"

@implementation PBFullScreenPlugin
- (id)initWithContext:(NSDictionary*)context {
    self = [super init];
    if (self != nil) {
        [self setContext:context];
    }
	
    return self;
}

- (void) dealloc {
	[_context release];
	[super dealloc];
}

#pragma -
#pragma Accessors

- (NSDictionary *)context {
    return [[_context retain] autorelease];
}

- (void)setContext:(NSDictionary *)value {
    if (_context != value) {
        [_context release];
        _context = [value mutableCopy];
    }
}

- (id)nonNilValueForKey:(NSString*)key {
    id value = [[self context] valueForKey:key];
    if( value == nil ) {
        NSLog(@"BUG: Fetched nil value for FullScreenPlugin key:%@", key);
    }
    return value;
}

- (NSWindow*)pandoraWindow {
    return [self nonNilValueForKey:@"pandoraWindow"];
}

- (WebScriptObject*)pandoraWebScriptObject {
    return [[self nonNilValueForKey:@"pandoraWebView"] windowScriptObject];
}

- (WebView*)pandoraWebView {
	return [self nonNilValueForKey:@"pandoraWebView"];
}

- (void)setPandoraWebView:(WebView*)aWebView {
	[[self context] setValue:aWebView forKey:@"pandoraWebView"];
}

#pragma -
#pragma Utility methods


@end
