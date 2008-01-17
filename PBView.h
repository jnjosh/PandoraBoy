//
//  PandoraBoyView.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/13/08.
//  Copyright 2008. All rights reserved.
//
//  Abstract class for plugin views of PandoraBoy. Based heavily on ScreenSaverView.

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>

@class PBViewAnimation;

@interface PBView : NSView {
	BOOL	_isFullScreen;
	BOOL	_isActive;
	BOOL	_isMoving;
	WebView *_webView;
	NSMutableSet *_animations;
	NSMutableSet *_reverseAnimations;
	NSWindow *_backgroundWindow;
	NSTimeInterval _animationDuration;
}

- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen;
- (void)prepare;
- (void)startView;
- (void)stopView;
- (BOOL)isActive;
- (BOOL)isMoving;

+ (BOOL)shouldGammaFade;

- (NSSet*)animations;
- (void)addAnimation:(PBViewAnimation*)animation;

- (BOOL)isFullScreen;
- (void)setIsFullScreen:(BOOL)value;

- (BOOL)hasConfigureSheet;
- (NSWindow*)configureSheet;

- (NSView*)preview;

- (void)pandoraDidPlay:(NSNotification*)notification;
- (void)pandoraDidPause:(NSNotification*)notification;
- (void)pandoraDidThumb:(NSNotification*)notification;
- (void)pandoraDidChangeStation:(NSNotification*)notification;
- (void)pandoraDidLoad:(NSNotification*)notification;

@end