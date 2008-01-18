//
//  PandoraBoyView.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBView.h"
#import "PBNotifications.h"

@interface PBView (PrivateAPI)

- (void)setIsActive:(BOOL)value;
- (void)setIsFullScreen:(BOOL)value;
- (void)setWebView:(WebView *)value;
- (void)startObserving;
- (void)stopObserving;

@end

@implementation PBView

+ (PBView*)viewFromBundleNamed:(NSString*)name withFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen {
	NSString *pluginDir = [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"Views"];
	NSString *pluginPath = [[pluginDir stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"pbview"];
	NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginPath];
	if( pluginBundle == nil ) {
		NSLog(@"ERROR: Could not load plugin:%@", pluginPath);
		return nil;
	}
	
	Class principalClass = [pluginBundle principalClass];
	if( principalClass == nil ) {
		NSLog(@"ERROR: Could not load principal place for plug-in at path: %@", pluginPath);
		NSLog(@"Make sure the PrincipalClass target setting is correct.");
		return nil;
	}
	
	if( ![principalClass isSubclassOfClass:[PBView class]] ) {
		NSLog(@"Plug-in %@ (%@) is not a PandoraBoyView", principalClass, pluginPath);
		return nil;
	}
	
	id pluginInstance = [[principalClass alloc] initWithFrame:frame
													  webView:webView
												 isFullScreen:isFullScreen];
	if( pluginInstance == nil ) {
		NSLog(@"ERROR: Could not initialize plugin: %@", pluginPath);
		return nil;
	}
	
	return [pluginInstance autorelease];
}

- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setIsFullScreen:isFullScreen];
		[self setWebView:webView];
	}
	return self;
}

- (void) dealloc {
	[self stopView];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_webView release];
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

- (BOOL)isFullScreen {
    return _isFullScreen;
}

- (void)setIsFullScreen:(BOOL)value {
    if (_isFullScreen != value) {
        _isFullScreen = value;
    }
}

- (NSRect)origWebViewFrame {
    return origWebViewFrame;
}

- (void)setOrigWebViewFrame:(NSRect)value {
	origWebViewFrame = value;
}

#pragma mark -
#pragma mark Observing

- (void)startObserving {
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
}	

- (void)stopObserving
{
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
}	

#pragma mark -
#pragma mark Actions

- (void)startView {
	[self startObserving];
	[self setIsActive:YES];
	[self setOrigWebViewFrame:[[self webView] frame]];
}

- (void)stopView {
	[self setIsActive:NO];
	[self stopObserving];
	[[self webView] setFrame:[self origWebViewFrame]];
}

- (void)drawRect:(NSRect)rect {
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:rect];
}


#pragma mark -
#pragma Pandora Delegates

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
