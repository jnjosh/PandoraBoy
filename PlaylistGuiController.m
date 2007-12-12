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

- (IBAction)toggleTrackHistoryWindow:(id)sender {
    if( [playlistGuiWindow isVisible] ) {
        [sender setState:NSOffState];
        [playlistGuiWindow close];
    }
    else {
        [sender setState:NSOnState];
        [playlistGuiWindow makeKeyAndOrderFront:self];
    }
}

- (void)openSongUrlForSelection:(NSArray*)selection
{
	Track *track = [selection objectAtIndex:0]; 
	if(track != nil) {
		NSURL *songUrl = [NSURL URLWithString:[track songUrl]];
		[[NSWorkspace sharedWorkspace] openURL:songUrl]; 
	}
}

@end
