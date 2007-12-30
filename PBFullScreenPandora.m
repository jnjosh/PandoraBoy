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
	[_oldAutosaveName release];
	[_crawlWindow release];
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

- (NSString *)oldAutosaveName {
    return [[_oldAutosaveName retain] autorelease];
}

- (void)setOldAutosaveName:(NSString *)value {
    if (_oldAutosaveName != value) {
        [_oldAutosaveName release];
        _oldAutosaveName = [value retain];
    }
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

- (NSWindow *)crawlWindow {
    return [[_crawlWindow retain] autorelease];
}

- (void)setCrawlWindow:(NSWindow *)value {
    if (_crawlWindow != value) {
        [_crawlWindow release];
        _crawlWindow = [value retain];
    }
}

///
/// Private Methods
///

#pragma mark -
#pragma mark Private Methods

- (void)addBackgroundExtension {
    NSWindow *pandoraWindow = [self pandoraWindow];
    NSRect windowFrame = [pandoraWindow frame];
    NSRect imageFrame = NSMakeRect( 0, 0, windowFrame.size.width, 0);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageFrame];
    [imageView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];

    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"background_mini.jpg"]];
    if( ! image ) {
        NSLog(@"ERROR: Could not get background_mini.jpg");
        return;
    }
    
    [image setFlipped:YES];
    [imageView setImage:image];
    [imageView setImageScaling:NSScaleToFit];
    
    [[pandoraWindow contentView] addSubview:imageView];
    [imageView release];
    [image release];
}

- (void)addCrawl {
	NSWindow *pandoraWindow = [self pandoraWindow];
    NSRect windowFrame = [pandoraWindow frame];
	// QCViews don't like being in a 0-height window; they'll complain:
	// "Unable to retrieve screen colorspace from owner window"
    NSRect imageFrame = NSMakeRect( 0, 0, windowFrame.size.width, 1);
	
	// Transparent window floats over bottom of pandoraWindow. QCView's can't
	// overlap other views in the same window (even subviews) because of their
	// optimizations.
	NSWindow *crawlWindow = [[NSWindow alloc] initWithContentRect:imageFrame
														styleMask:NSBorderlessWindowMask
														  backing:NSBackingStoreBuffered
															defer:NO];
	QCView *widgetView = [[QCView alloc] initWithFrame:imageFrame];
    [widgetView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    if( ! [widgetView loadCompositionFromFile:[[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"Widgets/PBTrackInfoCrawlWidget.qtz"]] ) {
        NSLog(@"ERROR: Could not load composition");
        [widgetView release];
        return;
    }
	
    [widgetView setValue:@"Test" forInputKey:@"Text"];
	[widgetView setEraseColor:[NSColor clearColor]];
	   
	[crawlWindow setLevel:NSScreenSaverWindowLevel + 1];
	[crawlWindow setBackgroundColor:[NSColor clearColor]];
	[crawlWindow setOpaque:NO];
	[crawlWindow makeKeyAndOrderFront:nil];

	[crawlWindow setContentView:widgetView];
    [widgetView startRendering];
	[self setCrawlWindow:crawlWindow];
	[crawlWindow release];
	[widgetView release];
}

///
/// NSWindow Delegates
///

#pragma mark -
#pragma mark NSWindow Delegates

- (void)windowDidResize:(NSNotification*)notification {
	NSRect newFrame = [[self pandoraWindow] frame];
	newFrame.size.height -= [self oldWindowFrame].size.height;
	// QCViews don't like being in a 0-height window; they'll complain:
	// "Unable to retrieve screen colorspace from owner window"
	if( newFrame.size.height > 0 ) {
		[[self crawlWindow] setFrame:newFrame display:YES];
	}
}

///
/// PBFullScreenProtocol
///

#pragma mark -
#pragma mark PBFullScreenProtocol

- (BOOL)startFullScreen {
    [self addBackgroundExtension];

    NSWindow *pandoraWindow = [self pandoraWindow];
	
	[self setOldWindowFrame:[pandoraWindow frame]];
	[self setOldAutosaveName:[pandoraWindow frameAutosaveName]];
	[pandoraWindow setFrameAutosaveName:@""];

    [pandoraWindow setLevel:NSScreenSaverWindowLevel];
    [pandoraWindow makeKeyAndOrderFront:nil];

	[self addCrawl];

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

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowDidResize:)
												 name:NSWindowDidResizeNotification
											   object:pandoraWindow];
	
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self crawlWindow] orderOut:nil];
    [[self pandoraWindow] setLevel:NSNormalWindowLevel];
	[[self pandoraWindow] setFrameAutosaveName:[self oldAutosaveName]];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animation Delegates

- (void)updateAnimationForValue:(float)value {
    NSRect srcRect = [self oldWindowFrame];
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSRect targetRect = NSMakeRect( screenRect.origin.x, screenRect.size.height - srcRect.size.height,
                                    screenRect.size.width, screenRect.size.height);
    
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
    [[self pandoraWindow] setFrame:newRect display:YES];
}

@end
