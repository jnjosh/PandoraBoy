//
//  PandoraBoyView.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PandoraBoyView.h"
#import "PBNotifications.h"
#import "MyAnimation.h"

@interface PandoraBoyView (PrivateAPI)

- (void)setIsActive:(BOOL)value;
- (WebView *)webView;
- (void)setWebView:(WebView *)value;
- (NSViewAnimation *)gammaFadeAnimation;
- (void)setGammaFadeAnimation:(NSViewAnimation *)value;
- (NSWindow *)backgroundWindow;
- (void)setBackgroundWindow:(NSWindow *)value;
@end 

@implementation PandoraBoyView

- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setIsFullScreen:isFullScreen];
		[self setWebView:webView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(pandoraDidLoad:)
													 name:PBPandoraDidLoadNotification
												   object:nil];
	}
	return self;
}

- (void) dealloc {
	[self stop];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_webView release];
	[_gammaFadeAnimation release];
	[_backgroundWindow release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isActive {
    return _isActive;
}

- (void)setIsActive:(BOOL)value {
    if (_isActive != value) {
        _isActive = value;
    }
}

- (WebView *)webView {
    return [[_webView retain] autorelease];
}

- (void)setWebView:(WebView *)value {
    if (_webView != value) {
        [_webView release];
        _webView = [value retain];
    }
}

+ (BOOL)shouldGammaFade {
	return YES;
}

- (NSViewAnimation *)gammaFadeAnimation {
    return [[_gammaFadeAnimation retain] autorelease];
}

- (void)setGammaFadeAnimation:(NSViewAnimation *)value {
    if (_gammaFadeAnimation != value) {
        [_gammaFadeAnimation release];
        _gammaFadeAnimation = [value retain];
    }
}

- (BOOL)isFullScreen {
    return _isFullScreen;
}

- (void)setIsFullScreen:(BOOL)value {
    if (_isFullScreen != value) {
        _isFullScreen = value;
    }
}

- (NSWindow *)backgroundWindow {
    return [[_backgroundWindow retain] autorelease];
}

- (void)setBackgroundWindow:(NSWindow *)value {
    if (_backgroundWindow != value) {
        [_backgroundWindow release];
        _backgroundWindow = [value retain];
    }
}

#pragma mark -
#pragma mark Actions

- (void)start {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pandoraDidPlay:)
												 name:PBSongPlayedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pandoraDidPause:)
												 name:PBSongPausedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pandoraDidThumb:)
												 name:PBSongThumbedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pandoraDidChangeStation:)
												 name:PBStationChangedNotification
											   object:nil];
	[self setIsActive:YES];
	NSWindow *bgWin = [[NSWindow alloc] initWithContentRect:[[self window] contentRectForFrameRect:[[self window] frame]]
												  styleMask:NSBorderlessWindowMask
													backing:NSBackingStoreBuffered
													  defer:NO];
	[bgWin setLevel:[[self window] level]];
	[bgWin setBackgroundColor:[NSColor blackColor]];
	[bgWin setAlphaValue:0.0];
	[bgWin orderBack:nil];
	if( [[self class] shouldGammaFade] ) {
		[[self gammaFadeAnimation] stopAnimation];
		NSDictionary *fadeInEffect = [NSDictionary dictionaryWithObjectsAndKeys:
										NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
										bgWin, NSViewAnimationTargetKey,
										nil];
		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:fadeInEffect]];
		[animation setDuration:1.5];
		[animation setAnimationBlockingMode:NSAnimationNonblocking];
		[animation startAnimation];

		[self setGammaFadeAnimation:animation];
		[animation release];
	}
	else {
		[bgWin setAlphaValue:1.0];
	}
	
	[self setBackgroundWindow:bgWin];
	[bgWin release];
}

- (void)stop {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PBSongPlayedNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PBSongPausedNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PBSongThumbedNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PBStationChangedNotification
												  object:nil];

	if( [[self class] shouldGammaFade] ) {
		[[self gammaFadeAnimation] stopAnimation];
		NSDictionary *fadeOutEffect = [NSDictionary dictionaryWithObjectsAndKeys:
									  NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
									  [self backgroundWindow], NSViewAnimationTargetKey,
									  nil];
		NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:fadeOutEffect]];
		[animation setDuration:1.5];
		[animation setAnimationBlockingMode:NSAnimationNonblocking];
		[animation startAnimation];
		
		[self setGammaFadeAnimation:animation];
		[animation release];
	}
	else {
		[[self backgroundWindow] setAlphaValue:0.0];
	}

	[self setIsActive:NO];
}

- (void)drawRect:(NSRect)rect {
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:rect];
}

- (BOOL)hasConfigureSheet {
	return NO;
}

- (NSWindow*)configureSheet {
	return nil;
}

- (NSView*)preview {
	return self;
}

#pragma mark -
#pragma Delegates

- (void)pandoraDidPlay:(NSNotification*)notification {
	NSLog(@"DEBUG:(PandoraBoyView)pandoraDidPlay");
}

- (void)pandoraDidPause:(NSNotification*)notification {
	NSLog(@"DEBUG:(PandoraBoyView)pandoraDidPause");
}

- (void)pandoraDidThumb:(NSNotification*)notification {
	NSLog(@"DEBUG:(PandoraBoyView)pandoraDidThumb");
}

- (void)pandoraDidChangeStation:(NSNotification*)notification {
	NSLog(@"DEBUG:(PandoraBoyView)pandoraDidChangeStation");
}

- (void)pandoraDidLoad:(NSNotification*)notification {
	NSLog(@"DEBUG:(PandoraBoyView)pandoraDidLoad");
}

@end
