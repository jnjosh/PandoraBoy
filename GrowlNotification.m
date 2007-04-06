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

#import "GrowlNotification.h"

static GrowlNotification* sharedInstance = nil;

@implementation GrowlNotification

#pragma public interface

- (id) init 
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
	  [GrowlApplicationBridge setGrowlDelegate: self]; 
	  currentValid = false; 
	}
	
	return self;
}

- (void) dealloc 
{
	[super dealloc];
}

+ (GrowlNotification*) sharedNotification 
{
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[GrowlNotification alloc] init];
	return sharedInstance;
}

- (void) pandoraLikeSong
{
  // Only show the notification if we are currently playing a song
  if(currentValid) { 
    NSData *thumbsUp = [NSData dataWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_up.png"]];
   [GrowlApplicationBridge
    notifyWithTitle:currentSong
    description:currentArtist
    notificationName:@"Like/Dislike Song"
    iconData:thumbsUp
    priority:0
    isSticky:false
    clickContext:nil];
  }
}

- (void) pandoraDislikeSong
{
  if(currentValid) { 
    NSData *thumbsDown = [NSData dataWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_down.png"]];
   [GrowlApplicationBridge
    notifyWithTitle:currentSong
    description:currentArtist
    notificationName:@"Like/Dislike Song"
    iconData:thumbsDown
    priority:0
    isSticky:false
    clickContext:nil];
  }
}

- (void) pandoraSongPlayed: (NSString*)song :(NSString*)artist
{
  if(currentValid) {
    [currentSong release];
    [currentArtist release];
  }

  currentSong = [NSString stringWithString: song]; 
  currentArtist = [NSString stringWithString: artist]; 
  currentValid = true; 

  [currentSong retain];
  [currentArtist retain]; 

  [GrowlApplicationBridge
    notifyWithTitle:currentSong
    description:currentArtist
    notificationName:@"Song Changed"
    iconData:nil
    priority:0
    isSticky:false
    clickContext:nil]; 
}

- (void) pandoraSongPaused
{
  [GrowlApplicationBridge
    notifyWithTitle:@"Playback Paused"
     description:nil
    notificationName:@"Playback Paused"
    iconData:nil
    priority:0
    isSticky:false
    clickContext:nil];   
}

- (void) pandoraEventsError: (NSString*)errormsg 
{
   [GrowlApplicationBridge
    notifyWithTitle:@"An Error Occured"
     description:errormsg
    notificationName:@"Notification Error"
    iconData:nil
    priority:0
    isSticky:false
    clickContext:nil];     
}

- (void) pandoraSongEnded: (NSString*)song :(NSString*)artist
{
   [GrowlApplicationBridge
    notifyWithTitle:song
     description:artist
    notificationName:@"Song Ended"
    iconData:nil
    priority:0
    isSticky:false
    clickContext:nil];     

}

// delegate methods for GrowlApplicationBridge
- (NSDictionary *) registrationDictionaryForGrowl {
  NSArray *notifications = [NSArray arrayWithObjects:
				    @"Song Ended",
				    @"Song Changed",
				    @"Playback Paused",
				    @"Notification Error",
				    @"Like/Dislike Song", 
				    nil];

  NSArray *defaultNotifications = [NSArray arrayWithObjects:
					   @"Song Changed",
					   @"Notification Error",
					   @"Like/Dislike Song",
					   nil];
 	
  NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
					  @"PandoraBoy", GROWL_APP_NAME,
					notifications, GROWL_NOTIFICATIONS_ALL,
					defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
					nil];
 	
  return regDict;
}
@end
