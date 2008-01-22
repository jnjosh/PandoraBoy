//
//  PBFullScreenWindowController.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBFullScreenWindowController.h"
#import "PBView.h"

@implementation PBFullScreenWindowController

- (id)initWithPlayerView:(NSView*)aPlayerView flashView:(NSView*)aFlashView
{
	[super init];
	playerView = [aPlayerView retain];
	flashView = [aFlashView retain];
	
	window = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
										 styleMask:NSBorderlessWindowMask
										   backing:NSBackingStoreBuffered
											 defer:YES];
	[window setLevel:NSScreenSaverWindowLevel];
	
	shieldWindow = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
											   styleMask:NSBorderlessWindowMask
												 backing:NSBackingStoreBuffered
												   defer:YES];
	[shieldWindow setLevel:NSScreenSaverWindowLevel];
	[shieldWindow setBackgroundColor:[NSColor blackColor]];
	[shieldWindow setAlphaValue:0.0];

	// FIXME: Hardcoded
	pbView = [[PBView viewFromBundleNamed:@"Black"
								withFrame:[window frame]
								  playerView:playerView
							 isFullScreen:YES] retain];
	[window setContentView:pbView];
	
	raiseAnimation = [[self fadeAnimationFor:shieldWindow withEffect:NSViewAnimationFadeInEffect] retain];
	lowerAnimation = [[self fadeAnimationFor:shieldWindow withEffect:NSViewAnimationFadeOutEffect] retain];
	
	isActive = NO;
	
	return self;
}

- (void)dealloc {
	[pbView release];
	[window release];
	[shieldWindow release];
	[playerView release];
	[flashView release];
	[raiseAnimation release];
	[lowerAnimation release];
	[super dealloc];
}

- (BOOL)canChangeState
{
	return ! ([raiseAnimation isAnimating] || [lowerAnimation isAnimating]);
}

- (NSViewAnimation*)fadeAnimationFor:(id)target withEffect:(NSString*)effect
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  target, NSViewAnimationTargetKey,
						  effect, NSViewAnimationEffectKey,
						  nil];
	NSViewAnimation *an = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[an setDuration:1.5];
	[an setDelegate:self];
	[an setAnimationBlockingMode:NSAnimationNonblocking];
	return [an autorelease];
}

- (void)showWindow:(id)sender
{
	isActive = YES;
	[self raiseShieldWindow];
}

- (void)closeAndMoveWebViewToWindow:(NSWindow*)aWindow
{
	[newWindow release];
	newWindow = [aWindow retain];
	isActive = NO;
	[self raiseShieldWindow];
}

- (void)raiseShieldWindow
{
	[shieldWindow makeKeyAndOrderFront:nil];
	[raiseAnimation startAnimation];
}

- (void)lowerShieldWindow
{
	[lowerAnimation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	if( [animation isEqualTo:raiseAnimation] ) {
		if( isActive ) {
			[self startView];
		} else {
			[self stopView];
		}
		[lowerAnimation startAnimation];
	}
}

- (void)startView
{
	[window orderBack:nil];
	[window makeFirstResponder:flashView];
	[pbView startView];
}	

- (void)stopView
{
	[pbView stopView];
	[[newWindow contentView] addSubview:playerView];
	[newWindow makeFirstResponder:flashView];
	[newWindow makeKeyAndOrderFront:nil];
	[window orderOut:nil];
}

@end
