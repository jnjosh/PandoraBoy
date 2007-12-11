//
//  PlaylistGuiController.h
//  PandoraBoy
//
//  Created by Aaron Rolett on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlaylistGuiController : NSObject {
	IBOutlet NSWindow *playlistGuiWindow;	
}


- (void)openSongUrlForSelection:(NSArray*)selection; 

@end
