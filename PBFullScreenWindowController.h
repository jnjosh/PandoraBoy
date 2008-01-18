//
//  PBFullScreenWindowController.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PBView;
@class WebView;

@interface PBFullScreenWindowController : NSObject {
	PBView *pbView;
	NSWindow *window;
	NSWindow *shieldWindow;
	WebView *webView;
	NSView *flashPlayerView;
	NSAnimation *raiseAnimation;
	NSAnimation *lowerAnimation;
	BOOL isActive;
	NSWindow *newWindow;
}

- (id)initWithWebView:(WebView*)aWebView flashPlayerView:(NSView*)aFlashPlayerView;
- (void)showWindow:(id)sender;
- (void)closeAndMoveWebViewToWindow:(NSWindow*)newWindow;
- (BOOL)canChangeState;

- (void)raiseShieldWindow;
- (void)lowerShieldWindow;
- (void)startView;
- (void)stopView;
- (NSViewAnimation*)fadeAnimationFor:(id)target withEffect:(NSString*)effect;
@end
