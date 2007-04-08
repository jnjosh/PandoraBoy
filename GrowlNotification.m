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

NSString *PBGrowlNotificationSongPlaying = @"Song Playing";
NSString *PBGrowlNotificationSongPaused  = @"Song Paused";
NSString *PBGrowlNotificationSongThumbed = @"Song Thumbed";
NSString *PBGrowlNotificationError       = @"Error";

@implementation GrowlNotification

#pragma public interface

- (id) init 
{
	if ( self = [super init] ) {
        [GrowlApplicationBridge setGrowlDelegate: self];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(playerInfoChanged:)
                                                                name:PBPlayerInfoNotificationName
                                                              object:nil
                                                  suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
        thumbsUpImage = [[NSData dataWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_up.png"]] retain];
        thumbsDownImage = [[NSData dataWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_down.png"]] retain];
	}
	
	return self;
}

- (void) dealloc 
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [thumbsUpImage release];
    [thumbsDownImage release];
	[super dealloc];
}

- (void) playerInfoChanged:(NSNotification*)aNotification {
    SongNotification *song = [SongNotification sharedNotification];
    
    NSString *playerState = [[aNotification userInfo] objectForKey:PBPlayerInfoPlayerStateKey];
    NSString *notificationName;;
    NSString *title;
    if( [playerState isEqualToString:PBPlayerStatePlaying] ) {
        notificationName = PBGrowlNotificationSongPlaying;
        title = [NSLocalizedString(@"Now Playing: ", @"") stringByAppendingString:[song name]];
    }
    else if( [playerState isEqualToString:PBPlayerStatePaused] ) {
        notificationName = PBGrowlNotificationSongPaused;
        title = [NSLocalizedString(@"Paused: ", @"") stringByAppendingString:[song name]];
    }
    else {
        NSLog(@"BUG:playerInfoChanged called with illegal state: %@", playerState);
    }

    [GrowlApplicationBridge notifyWithTitle:title
                                description:[NSLocalizedString(@"Artist: ", @"") stringByAppendingString:[song artist]]
                           notificationName:notificationName
                                   iconData:nil
                                   priority:0
                                   isSticky:false
                               clickContext:nil];
}

- (void) pandoraLikeSong
{
    SongNotification *song = [SongNotification sharedNotification];
    
    [GrowlApplicationBridge
        notifyWithTitle:[song name]
            description:[song artist]
       notificationName:PBGrowlNotificationSongThumbed
               iconData:thumbsUpImage
               priority:0
               isSticky:false
           clickContext:nil];
}

- (void) pandoraDislikeSong
{
    SongNotification *song = [SongNotification sharedNotification];
    
    [GrowlApplicationBridge
        notifyWithTitle:[song name]
            description:[song artist]
       notificationName:PBGrowlNotificationSongThumbed
               iconData:thumbsDownImage
               priority:0
               isSticky:false
           clickContext:nil];
}

// delegate methods for GrowlApplicationBridge
- (NSDictionary *) registrationDictionaryForGrowl {
  NSArray *notifications = [NSArray arrayWithObjects:
				    PBGrowlNotificationSongPlaying,
                    PBGrowlNotificationSongPaused,
                    PBGrowlNotificationSongThumbed,
				    nil];

  NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"PandoraBoy", GROWL_APP_NAME,
                    notifications, GROWL_NOTIFICATIONS_ALL,
					notifications, GROWL_NOTIFICATIONS_DEFAULT,
					nil];
  return regDict;
}

@end
