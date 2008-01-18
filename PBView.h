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
	WebView *_webView;
	NSRect  origWebViewFrame;
}

+ (PBView*)viewFromBundleNamed:(NSString*)name withFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen;
- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen;
- (void)startView;
- (void)stopView;
- (BOOL)isActive;

- (BOOL)isFullScreen;
- (WebView *)webView;
- (NSRect)origWebViewFrame;
- (void)setOrigWebViewFrame:(NSRect)value;

- (void)pandoraDidPlay:(NSNotification*)notification;
- (void)pandoraDidPause:(NSNotification*)notification;
- (void)pandoraDidThumb:(NSNotification*)notification;
- (void)pandoraDidChangeStation:(NSNotification*)notification;
- (void)pandoraDidLoad:(NSNotification*)notification;

@end