//
//  PBFullScreenPandora.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PBFullScreenPandora.h"
#import "MyAnimation.h"
#import <Carbon/Carbon.h>
#import <QuartzComposer/QCView.h>

@implementation PBFullScreenPandora

- (void) dealloc {
	[_fullScreenWindow release];
	[super dealloc];
}

///
/// Accessors
///

#pragma mark -
#pragma mark Accessors

- (NSRect)oldWindowFrame {
    return _oldWindowFrame;
}

- (void)setOldWindowFrame:(NSRect)value {
	_oldWindowFrame = value;
}

- (int)spacerMargin {
    return _spacerMargin;
}

- (void)setSpacerMargin:(int)value {
    if (_spacerMargin != value) {
        _spacerMargin = value;
    }
}

- (int)tunerWidth {
    return _tunerWidth;
}

- (void)setTunerWidth:(int)value {
    if (_tunerWidth != value) {
        _tunerWidth = value;
    }
}

- (NSWindow *)fullScreenWindow {
    return [[_fullScreenWindow retain] autorelease];
}

- (void)setFullScreenWindow:(NSWindow *)value {
    if (_fullScreenWindow != value) {
        [_fullScreenWindow release];
        _fullScreenWindow = [value retain];
    }
}

///
/// Private Methods
///

#pragma mark -
#pragma mark Private Methods

- (void)addBackgroundExtension {
    NSWindow *fullScreenWindow = [self fullScreenWindow];
    NSRect windowFrame = [fullScreenWindow frame];

	// QCViews don't like being in a 0-height window; they'll complain:
	// "Unable to retrieve screen colorspace from owner window"
    NSRect widgetFrame = NSMakeRect( 0, 0, windowFrame.size.width, 1);
	
	QCView *widgetView = [[QCView alloc] initWithFrame:widgetFrame];
	
    [widgetView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    if( ! [widgetView loadCompositionFromFile:[[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"Widgets/PBTrackInfoCrawlWidget.qtz"]] ) {
        NSLog(@"ERROR: Could not load composition");
		[widgetView release];
        return;
    }
	
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"background_mini.jpg"]];
    if( ! image ) {
        NSLog(@"ERROR: Could not get background_mini.jpg");
		[widgetView release];
        return;
    }
    
	[widgetView setValue:image forInputKey:@"BackgroundImage"];
	[widgetView setValue:[NSNumber numberWithFloat:180.0] forInputKey:@"BackgroundImageRotation"];
    [widgetView setValue:@"Test" forInputKey:@"Text"];
	[widgetView setEraseColor:[NSColor clearColor]];
	
    [[fullScreenWindow contentView] addSubview:widgetView];
 
	[widgetView startRendering];
	[widgetView release];
	[image release];
}

///
/// PBFullScreenProtocol
///

#pragma mark -
#pragma mark PBFullScreenProtocol

- (BOOL)startFullScreen {
    NSWindow *pandoraWindow = [self pandoraWindow];
	[self setFullScreenWindow:[[[NSWindow alloc] initWithContentRect:[pandoraWindow contentRectForFrameRect:[pandoraWindow frame]]
														   styleMask:NSBorderlessWindowMask
															 backing:NSBackingStoreBuffered
															   defer:NO] autorelease]];
	NSWindow *fullScreenWindow = [self fullScreenWindow];
	[self setOldWindowFrame:[fullScreenWindow frame]];

	[[fullScreenWindow contentView] addSubview:[self pandoraWebView]];
	[self addBackgroundExtension];
    
	[fullScreenWindow setLevel:NSScreenSaverWindowLevel];
    [fullScreenWindow makeKeyAndOrderFront:nil];
	[pandoraWindow orderOut:nil];
	
    WebScriptObject *scriptObject = [self pandoraWebScriptObject];
    if( scriptObject ) {
        id result = [scriptObject evaluateWebScript:@"spacer.style.marginLeft"];
        if( result && ! [[WebUndefined undefined] isEqualTo:result] ) {
            [self setSpacerMargin:[result intValue]];
        }
        else {
            NSLog(@"ERROR: Could not get spacerMargin");
            [self setSpacerMargin:44];
        }
        
        @try { [self setTunerWidth:[[scriptObject valueForKey:@"tunerWidth"] intValue]]; }
        @catch (NSException * e) {
            NSLog(@"ERROR: Could not get tunerWidth");
            [self setTunerWidth:640];
        }
    }

	MyAnimation *animation = [[MyAnimation alloc] initWithDuration:1.5
                                                    animationCurve:NSAnimationEaseIn];
    [animation setDelegate:self];
    [animation startAnimation];
    [animation release];
	
    return YES;
}

- (void)stopFullScreen {
    MyAnimation *animation = [[MyAnimation alloc] initWithDuration:1.5
                                                    animationCurve:NSAnimationEaseOut];
    [animation setDelegate:self];
    [animation startAnimation];
    [animation release];
	
	[[[self pandoraWindow] contentView] addSubview:[self pandoraWebView]];
	[[self pandoraWindow] makeKeyAndOrderFront:nil];
	[[self fullScreenWindow] orderOut:nil];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animation Delegates

- (void)updateAnimationForValue:(float)value {
    NSRect srcRect = [self oldWindowFrame];
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSRect targetRect = screenRect; 
    
    // If this goes offscreen vertically, we'd rather have the title bar visible
    NSRect newRect;
    newRect.origin.x = srcRect.origin.x + (targetRect.origin.x - srcRect.origin.x)*value;
    newRect.origin.y = srcRect.origin.y + (targetRect.origin.y - srcRect.origin.y)*value;
    newRect.size.width = srcRect.size.width + (targetRect.size.width - srcRect.size.width)*value;
    newRect.size.height = srcRect.size.height + (targetRect.size.height - srcRect.size.height)*value;
    
    OSStatus error;
    // The +1 here is because we're using floats, and we might be a fraction of a pixel over the line.
    if( (newRect.origin.y + newRect.size.height) >= (screenRect.size.height - [NSMenuView menuBarHeight]) + 1) {
        error = SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);
        if( error != noErr ) {
            NSLog(@"ERROR:Could not hide menu bar:%d", (int)error);
        }
    }
    else {
        error = SetSystemUIMode(kUIModeNormal, 0);
        if( error != noErr ) {
            NSLog(@"ERROR:Could not show menu bar:%d", (int)error);
        }
    }
    
    WebScriptObject *scriptObject = [self pandoraWebScriptObject];
    int leftMargin = (int)( value * (screenRect.size.width - _tunerWidth - _spacerMargin) / 2 );
	int tipsMargin = (int)( value * (screenRect.size.width - _tunerWidth + _spacerMargin) / 2 );
	int tipsWidth  = (int)( [self oldWindowFrame].size.width + value * ([self tunerWidth] - [self oldWindowFrame].size.width ) );;
    [scriptObject evaluateWebScript:[NSString stringWithFormat:
		@"margin = %d; \
		  tuner_ad_container.style.marginLeft = margin; \
          tuner_ad_container.style.width = tuner_ad_container.style.width + margin; \
		  TunerContainer.style.marginLeft = margin; \
		  pandora_tips.style.marginLeft = %d; \
		  pandora_tips.style.width = %d;", leftMargin, tipsMargin, tipsWidth]];
    [[self fullScreenWindow] setFrame:newRect display:YES];
}

@end
