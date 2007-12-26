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

@implementation PBFullScreenPandora

- (void)addBackgroundExtension {
    NSWindow *pandoraWindow = [self pandoraWindow];
    NSRect windowFrame = [pandoraWindow frame];
    NSRect imageFrame = NSMakeRect( 0, 0, windowFrame.size.width, 0);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageFrame];
    [imageView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"background_mini.jpg"]];
    [image setFlipped:YES];
    [imageView setImage:image];
    [imageView setImageScaling:NSScaleToFit];
    [[pandoraWindow contentView] addSubview:imageView];
    [imageView release];
    [image release];
}

- (BOOL)startFullScreen {
    [self addBackgroundExtension];

    NSWindow *pandoraWindow = [self pandoraWindow];
    _oldWindowFrame = [pandoraWindow frame];
    [pandoraWindow setLevel:NSScreenSaverWindowLevel];
    [pandoraWindow makeKeyAndOrderFront:nil];

    WebScriptObject *scriptObject = [self pandoraWebScriptObject];
    _spacerMargin = [[scriptObject evaluateWebScript:@"spacer.style.marginLeft"] intValue];
    _tunerWidth   = [[scriptObject valueForKey:@"tunerWidth"] intValue];

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
    [[self pandoraWindow] setLevel:NSNormalWindowLevel];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animation Delegates

- (void)updateAnimationForValue:(float)value {
    NSRect srcRect = _oldWindowFrame;
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
    int leftMargin = (screenRect.size.width - _tunerWidth) / 2;
    [scriptObject evaluateWebScript:[NSString stringWithFormat:
        @"tuner_ad.style.marginLeft = %d; \
          tuner_ad.style.width = tuner_ad.style.width + tuner_ad.style.marginLeft; \
          TunerContainer.style.marginLeft = %d;",
            (int)(leftMargin * value), (int)((leftMargin - _spacerMargin) * value)]];
    [[self pandoraWindow] setFrame:newRect display:YES];
}

@end
