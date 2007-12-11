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

// PandoraBoyNotification manages NSDistributedNotificationCenter messages

#import "SongNotification.h"
#import "WebKit/WebFrame.h"
#import "Playlist.h"
#import "ResourceURL.h"
#import "StationList.h"
#import "PlayerController.h"

static SongNotification* sharedInstance = nil;

NSString *PBPlayerInfoNotificationName = @"net.frozensilicon.pandoraBoy.playerInfo";

// These keys are intended to match iTunes. We don't need them all.
NSString *PBPlayerInfoArtistKey      = @"Artist";
NSString *PBPlayerInfoNameKey        = @"Name";
NSString *PBPlayerInfoGenreKey       = @"Genre";
NSString *PBPlayerInfoTotalTimeKey   = @"Total Time";
NSString *PBPlayerInfoPlayerStateKey = @"Player State";
NSString *PBPlayerInfoTrackNumberKey = @"Track Number";
NSString *PBPlayerInfoStoreURLKey    = @"Store URL";
NSString *PBPlayerInfoAlbumKey       = @"Album";
NSString *PBPlayerInfoComposerKey    = @"Composer";
NSString *PBPlayerInfoLocationKey    = @"Location";
NSString *PBPlayerInfoTrackCountKey  = @"Track Count";
NSString *PBPlayerInfoRatingKey      = @"Rating";
NSString *PBPlayerInfoDiscNumberKey  = @"Disc Number";
NSString *PBPlayerInfoDiscCountKey   = @"Disc Count";

@implementation SongNotification

#pragma public interface

- (id) init
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
	}
	return self;
}

- (void) dealloc 
{
	[super dealloc];
}

+ (SongNotification*) sharedNotification 
{
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[SongNotification alloc] init];
	return sharedInstance;
}

- (void) sendPlayerInfoNotification {
    Playlist *playlist = [Playlist sharedPlaylist];
    Track *currentTrack = [playlist currentTrack];
    int playerState = [[PlayerController sharedController] playerState];
    if( currentTrack && ! [[currentTrack name] isEqualToString:@""] ) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [currentTrack name],                  PBPlayerInfoNameKey, 
            [currentTrack artist],                PBPlayerInfoArtistKey,
            [NSNumber numberWithInt:playerState], PBPlayerInfoPlayerStateKey,
            nil];

        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName:PBPlayerInfoNotificationName
                          object:nil
                        userInfo:dict];
    }
}

@end
