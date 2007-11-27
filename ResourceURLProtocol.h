//
//  ResourceURLProtocol.h
//  PandoraBoy
//
//  Created by Rob Napier on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
// This is a NSURLProtocol to handle URLs of the type http://.RESOURCE./
// These point into the package's resource directory. Files that interact with
// Flash v8+ cannot appear to come from the localhost or else Flash will refuse
// to let them interact with the network. This protocol works around that by
// making local files seem to come from the network.
// http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager02.html

#import <Cocoa/Cocoa.h>

extern NSString *PBResourceHost;

@interface ResourceURLProtocol : NSURLProtocol {

}

@end
