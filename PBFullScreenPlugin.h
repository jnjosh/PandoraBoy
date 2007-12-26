//
//  PBFullScreenPlugin.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/25/07.
//  Copyright 2007 PandoraBoy Contributors. Licensed under the GPLv2.
//
//  Defines @protocol for PandoraBoy Fullscreen Plugins.

#import <WebKit/WebKit.h>

@interface PBFullScreenPlugin : NSObject {
    @private
    NSDictionary *_context;
}

- (id)initWithContext:(NSDictionary*)context;
- (NSDictionary *)context;
- (void)setContext:(NSDictionary *)value;
- (id)nonNilValueForKey:(NSString*)key;

- (NSWindow*)pandoraWindow;
- (WebScriptObject*)pandoraWebScriptObject;

@end

/*!
    @protocol    PBFullScreenProtocol
    @abstract    Fullscreen mode plugins for PandoraBoy
    @discussion  (comprehensive description)
*/

@protocol PBFullScreenProtocol

- (BOOL)startFullScreen;
- (void)stopFullScreen;

@end
