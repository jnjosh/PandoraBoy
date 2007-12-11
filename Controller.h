/****************************************************************************
 *  Copyright 2006 Aaron Rolett                                             *
 *  arolett@mail.rochester.edu                                              *
 *                                                                          *
 *  This file is part of PandoraBoy.                                        *
 *                                                                          *
 *  PandoraBoy is free software; you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by    * 
 *  the Free Software Foundation; either version 2 of the License, or       *
 *  (at your option) any later version.                                     *
 *                                                                          *
 *  PandoraBoy is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           * 
 *  GNU General Public License for more details.                            *
 *                                                                          *
 *  You should have received a copy of the GNU General Public License       * 
 *  along with PandoraBoy; if not, write to the Free Software Foundation,   *
 *  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA          *
 ***************************************************************************/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebUIDelegate.h>
#import <WebKit/WebPolicyDelegate.h>
#import <WebKit/WebView.h>
#import "Playlist.h"
#import "AppleRemote.h"
#import "GrowlNotification.h"
#import "DistributedNotification.h"
#import "StationList.h"
#import "PlayerController.h"

@interface Controller : NSObject
{
    IBOutlet NSWindow *startupWindow; 
    IBOutlet PlayerController *playerController;
    
    AppleRemote *appleRemote;
    bool controlDisabled;
    GrowlNotification *_growl;
    Playlist *_playlist;
    StationList *_stationList;
    DistributedNotification *_distributedNotification;
    
    PlayerController *_playerController;
    
    NSImage *_thumbsUpImage;
    NSImage *_thumbsDownImage;
}

+ (Controller*) sharedController; 

// Accessors
- (NSImage*)thumbsUpImage;
- (NSImage*)thumbsDownImage;

// Actions
- (IBAction)displayHelp:(id)sender; 

@end

@interface Controller(NSApplicationNotifications)
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
@end
