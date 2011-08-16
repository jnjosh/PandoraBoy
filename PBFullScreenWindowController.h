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

@interface PBFullScreenWindowController : NSObject <NSAnimationDelegate> {
	PBView *pbView;
	NSWindow *window;
	NSWindow *shieldWindow;
	NSView *playerView;
	NSView *flashView;
	NSAnimation *raiseAnimation;
	NSAnimation *lowerAnimation;
	BOOL isActive;
	NSWindow *newWindow;
}

- (id)initWithPlayerView:(NSView*)player flashView:(NSView*)flash;
- (void)showWindow:(id)sender;
- (void)closeAndMoveWebViewToWindow:(NSWindow*)w;
- (BOOL)canChangeState;

- (void)raiseShieldWindow;
- (void)lowerShieldWindow;
- (void)startView;
- (void)stopView;
- (NSViewAnimation*)fadeAnimationFor:(id)target withEffect:(NSString*)effect;
@end
