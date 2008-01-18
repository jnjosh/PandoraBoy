//
//  PandoraBoyViewBlack.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewBlack.h"

@implementation PBViewBlack

- (void)startView
{
	[super startView];
	NSRect bounds = [self bounds];
	NSRect wvFrame = [[self webView] frame];
	wvFrame.origin = NSMakePoint((bounds.size.width - wvFrame.size.width) / 2,
								 (bounds.size.height - wvFrame.size.height) );
	[[self webView] setFrame:wvFrame];
}

@end
