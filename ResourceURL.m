//
//  ResourceURL.m
//  PandoraBoy
//
//  Created by Rob Napier on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ResourceURL.h"
#import "ResourceURLProtocol.h"

@implementation ResourceURL

+ (ResourceURL*) resourceURLWithPath:(NSString *)path
{
    return [[[NSURL alloc] initWithScheme:@"http"
                                     host:PBResourceHost
                                     path:path] autorelease];
}

@end
