//
//  PlaylistGuiController.m
//  PandoraBoy
//
//  Created by Aaron Rolett on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PlaylistGuiController.h"
#import <Track.h>


@implementation PlaylistGuiController

-(void)awakeFromNib {
	[playlistGuiWindow setExcludedFromWindowsMenu:YES];
}

- (void)openSongUrlForSelection:(NSArray*)selection
{
	Track *track = [selection objectAtIndex:0]; 
	if(track != nil) {
		NSURL *songUrl = [NSURL URLWithString:[track songUrl]];
		[[NSWorkspace sharedWorkspace] openURL:songUrl]; 
	}
}

- (BOOL)windowShouldClose:(id)sender 
{
	//[sender orderOut:self];
	return YES;
}
@end
