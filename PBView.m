//
//  PandoraBoyView.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBView.h"
#import "PBNotifications.h"
#import "PBViewAnimation.h"
#import "PBViewAnimationGammaFade.h"

@interface PBView (PrivateAPI)

- (void)setIsActive:(BOOL)value;
- (WebView *)webView;
- (void)setWebView:(WebView *)value;
- (NSWindow *)backgroundWindow;
- (void)setBackgroundWindow:(NSWindow *)value;
- (void)startObserving;
- (void)stopObserving;
- (void)setAnimations:(NSMutableSet *)value;
- (NSSet*)reverseAnimations;
- (void)setReverseAnimations:(NSMutableSet *)value;
- (NSTimeInterval)animationDuration;
- (void)setAnimationDuration:(NSTimeInterval)value;
- (void)setIsMoving:(BOOL)value;
@end

@implementation PBView

- (id)initWithFrame:(NSRect)frame webView:(WebView*)webView isFullScreen:(BOOL)isFullScreen {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setIsFullScreen:isFullScreen];
		[self setWebView:webView];
		[self setAnimations:[NSMutableArray arrayWithCapacity:1]];
		[self setReverseAnimations:[NSMutableArray arrayWithCapacity:1]];
		[self setAnimationDuration:0];
		[self setIsMoving:NO];
	}
	return self;
}

- (void)prepare {
	NSWindow *win = [self window];
	NSWindow *bgWin = [[NSWindow alloc] initWithContentRect:[win contentRectForFrameRect:[win frame]]
												  styleMask:NSBorderlessWindowMask
													backing:NSBackingStoreBuffered
													  defer:YES];
	[bgWin setLevel:[win level] - 1];
	[bgWin setBackgroundColor:[NSColor blackColor]];
	[bgWin setAlphaValue:0.0];
	[bgWin orderFront:nil];	
	NSTimeInterval bgFadeDuration = [[self class] shouldGammaFade] ? PBAnimationDefaultDuration : 0;
	[self addAnimation:[PBViewAnimationGammaFade animationWithTarget:bgWin
														  fadeEffect:NSViewAnimationFadeInEffect
															 startingAt:0
															duration:bgFadeDuration]];
	[self setBackgroundWindow:bgWin];
	[bgWin release];
}

- (void) dealloc {
	[self stopView];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_webView release];
	[_animations release];
	[_reverseAnimations release];
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

- (NSSet *)animations {
    return [[_animations retain] autorelease];
}

- (void)setAnimations:(NSMutableSet *)value {
    if (_animations != value) {
        [_animations release];
        _animations = [value retain];
    }
}

- (NSSet *)reverseAnimations {
	return [[_reverseAnimations retain] autorelease];
}

- (void)setReverseAnimations:(NSMutableSet *)value {
	if (_reverseAnimations != value) {
		[_reverseAnimations release];
		_reverseAnimations = [value retain];
	}
}

- (void)addAnimation:(PBViewAnimation*)animation
{
	[animation setDelegate:self];
	[_animations addObject:animation];
	PBViewAnimation *inverse = [animation inverse];
	[inverse setDelegate:self];
	[_reverseAnimations addObject:inverse];
	_animationDuration = MAX(_animationDuration, [animation startTime] + [animation duration]);
}

//- (void)startAnimation:(PBViewAnimation*)animation whenLastAnimationReachesProgress:(NSAnimationProgress)progress
//{
//	if( [_animations count] > 0 )
//	{
//		[self startAnimation:animation whenAnimation:[_animations lastObject] reachesProgress:progress];
//	}
//	else
//	{
//		[animation setDelegate:self];
//		[_animations addObject:animation];
//		[_reverseAnimations addObject:[[animation copy] autorelease]];
//	}
//}
//
//- (void)startAnimation:(PBViewAnimation*)animation whenAnimation:(PBViewAnimation*)linkedAnimation reachesProgress:(NSAnimationProgress)progress
//{
//	[animation setDelegate:self];
//	NSAnimation *inverseAnimation = [animation inverse];
//
//	[animation startWhenAnimation:linkedAnimation reachesProgress:progress];
//	[_animations addObject:animation];
//	
//	[reverseAnimation startWhenAnimation:reverseLinkedAnimation reachesProgress:(1 - progress)];
//	[_reverseAnimations insertObject:reverseAnimation atIndex:0];
//}

- (NSTimeInterval)animationDuration {
    return _animationDuration;
}

- (void)setAnimationDuration:(NSTimeInterval)value {
    if (_animationDuration != value) {
        _animationDuration = value;
    }
}

- (BOOL)isMoving {
    return _isMoving;
}

- (void)setIsMoving:(BOOL)value {
    if (_isMoving != value) {
        _isMoving = value;
    }
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
	[self setIsMoving:YES];
	[self startObserving];
	[self setIsActive:YES];
//	[[[self animations] objectAtIndex:0] startAnimation];
	NSEnumerator *e = [[self animations] objectEnumerator];
	PBViewAnimation *a;
	while( a = [e nextObject] ) {
		[a performSelector:@selector(startAnimation) withObject:nil afterDelay:[a startTime]];
	}
}

- (void)stopView {
	[self setIsMoving:YES];
	[self setIsActive:NO];
	[self stopObserving];
//	[[[self reverseAnimations] objectAtIndex:0] startAnimation];
	NSTimeInterval animationDuration = [self animationDuration];
	NSEnumerator *e = [[self reverseAnimations] objectEnumerator];
	PBViewAnimation *a;
	while( a = [e nextObject] ) {
		[a performSelector:@selector(startAnimation) withObject:nil afterDelay:(animationDuration - [a startTime] - [a duration])];
	}
//	if( [[self class] shouldGammaFade] ) {
//		// FIXME
//		return NO;
//	}
//	else {
//		[[self backgroundWindow] orderOut:nil];
//		return YES;
//	}
}

- (void)animationDidEnd:(NSAnimation *)animation {
	NSMutableSet *activeSet = [self isActive] ? _animations : _reverseAnimations;
	[activeSet removeObject:animation];
	if( [activeSet count] == 0 ) {
		[self setIsMoving:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:PBFullScreenDidFinishNotification
															object:nil];
	}
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

//#pragma mark -
//#pragma View movement
//- (void)viewDidMoveToWindow
//{
//	NSWindow *bgWin = [self backgroundWindow];
//	if( [self window] )
//	{
//		[bgWin setFrame:[[self window] contentRectForFrameRect:[[self window] frame]] display:NO];
//		[bgWin setLevel:[[self window] level] - 1];
//		[bgWin orderFront:nil];
//	}
//	else
//	{
//		[bgWin orderOut:nil];
//	}
//}
//
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
