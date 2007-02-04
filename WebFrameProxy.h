//
//  WebFrameProxy.h
//  PandoraBoy
//
//  Created by Aaron Rolett on 11/24/06.
//  Copyright 2006 Aaron Rolett. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WebFrameProxy : NSObject {

}

- (void) loadRequest: (NSURLRequest*) request;
- (void) _loadRequest: (NSURLRequest*) request triggeringAction: (id) trigAction loadType: (id) loadtyp formState: (id) formstat;
- (id) _bridge; 

@end
