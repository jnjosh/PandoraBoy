//
//  PandoraBoyViewBlack.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewBlack.h"
#import <QuartzComposer/QCView.h>

@implementation PBViewBlack

- (void)startView
{
	[super startView];
	NSRect bounds = [self bounds];
	NSRect wvFrame = [[self playerView] frame];
	wvFrame.origin = NSMakePoint((bounds.size.width - wvFrame.size.width) / 2,
								 (bounds.size.height - wvFrame.size.height) );
	[[self playerView] setFrame:wvFrame];
	
	QCView *infoCrawl = [[QCView alloc] initWithFrame:NSMakeRect(0, 0, bounds.size.width, bounds.size.height / 2)];
	[infoCrawl loadCompositionFromFile:[[self widgetPath] stringByAppendingPathComponent:@"PBTrackInfoCrawlWidget.qtz"]];
	[infoCrawl setValue:@"Song Information" forInputKey:@"Text"];
	[infoCrawl startRendering];
	[self addSubview:infoCrawl];
}

@end
