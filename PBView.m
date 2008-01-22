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

+ (Class)principalClassFromBundleNamed:(NSString*)name;
- (void)setIsActive:(BOOL)value;
- (void)setIsFullScreen:(BOOL)value;
- (void)setPlayerView:(NSView *)value;
- (void)startObserving;
- (void)stopObserving;
- (NSRect)origPlayerViewFrame;
- (void)setOrigPlayerViewFrame:(NSRect)value;
+ (NSView*)dummyPlayerView;
@end

@implementation PBView

+ (Class)principalClassFromBundleNamed:(NSString*)name
{
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
	return principalClass;
}

+ (PBView*)viewFromBundleNamed:(NSString*)name withFrame:(NSRect)frame playerView:(NSView*)view isFullScreen:(BOOL)isFullScreen {

	Class principalClass = [self principalClassFromBundleNamed:name];

	id pluginInstance = [[principalClass alloc] initWithFrame:frame
													  playerView:view
												 isFullScreen:isFullScreen];
	if( pluginInstance == nil ) {
		NSLog(@"ERROR: Could not initialize plugin: %@", name);
		return nil;
	}
	
	return [pluginInstance autorelease];
}

+ (NSView*)previewFromBundleNamed:(NSString*)name withFrame:(NSRect)frame
{
	Class principalClass = [self principalClassFromBundleNamed:name];
	return [principalClass previewViewWithFrame:frame];
}

- (id)initWithFrame:(NSRect)frame playerView:(NSView*)view isFullScreen:(BOOL)isFullScreen {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setIsFullScreen:isFullScreen];
		[self setPlayerView:view];
	}
	return self;
}

- (void) dealloc {
	[self stopView];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[playerView release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

+ (NSView*)previewViewWithFrame:(NSRect)frame
{
	NSView *previewView = [[self alloc] initWithFrame:frame playerView:[self dummyPlayerView] isFullScreen:NO];
	return [previewView autorelease];
}

+ (NSView*)dummyPlayerView
{
	NSImage *image = [NSImage imageNamed:@"PandoraPreview"];
	NSRect frame;
	frame.origin = NSZeroPoint;
	frame.size = [image size];
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:frame];
	[imageView setImage:image];
	[imageView setEditable:NO];
	return [imageView autorelease];
}

- (BOOL)isActive {
    return _isActive;
}

- (void)setIsActive:(BOOL)value {
    if (_isActive != value) {
        _isActive = value;
    }
}

- (NSView *)playerView {
    return [[playerView retain] autorelease];
}

- (void)setPlayerView:(NSView *)value {
    if (playerView != value) {
        [playerView release];
        playerView = [value retain];
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

- (NSRect)origPlayerViewFrame {
    return origPlayerViewFrame;
}

- (void)setOrigPlayerViewFrame:(NSRect)value {
	origPlayerViewFrame = value;
}

- (NSString*)widgetPath
{
	return [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"Widgets"];
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
	[self setOrigPlayerViewFrame:[[self playerView] frame]];
	[self addSubview:playerView];
}

- (void)stopView {
	[self setIsActive:NO];
	[self stopObserving];
	[[self playerView] setFrame:[self origPlayerViewFrame]];
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
