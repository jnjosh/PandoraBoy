//
//  PlayerWindow.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PlayerWindow.h"


@implementation PlayerWindow

- (IBAction)performShowOrHide:(id)sender
{
	if ([self isVisible])
	{
		[self orderOut:nil];
	}
	else
	{
		[self makeKeyAndOrderFront:nil];
	}
}

- (void)close
{
	[self orderOut:nil];
}

@end
