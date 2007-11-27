//
//  ResourceURL.h
//  PandoraBoy
//
//  Created by Rob Napier on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
// See ResourceURLProtocol for an explanation of this class.

#import <Cocoa/Cocoa.h>


@interface ResourceURL : NSURL {

}

+ (ResourceURL*) resourceURLWithPath:(NSString *)path;

@end
