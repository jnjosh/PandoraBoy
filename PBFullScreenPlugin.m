//
//  PBFullScreenPlugin.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PBFullScreenPlugin.h"


@implementation PBFullScreenPlugin
- (id)initWithContext:(NSDictionary*)context {
    self = [super init];
    if (self != nil) {
        [self setContext:context];
    }
    return self;
}

#pragma -
#pragma Accessors

- (NSDictionary *)context {
    return [[_context retain] autorelease];
}

- (void)setContext:(NSDictionary *)value {
    if (_context != value) {
        [_context release];
        _context = [value copy];
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
    return [self nonNilValueForKey:@"pandoraWebScriptObject"];
}

#pragma -
#pragma Utility methods


@end
