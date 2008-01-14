//
//  PandoraBoyView.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/13/08.
//  Copyright 2008. All rights reserved.
//
//  Abstract class for plugin views of PandoraBoy. Based heavily on ScreenSaverView.
//  Context keys:
//     PBWindowKey			: (NSWindow*) The main Pandora window
//     PBWebViewKey         : (WebView*) Pandora's flash-player webview

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>

@interface PandoraBoyView : NSView {
	BOOL	_isFullScreen;
	BOOL	_isActive;
	WebView *_webView;
	NSViewAnimation *_gammaFadeAnimation;
	NSWindow *_backgroundWindow;
}

- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen;

+ (BOOL)shouldGammaFade;

- (void)start;
- (void)stop;
- (BOOL)isActive;

- (void)drawRect:(NSRect)rect;
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