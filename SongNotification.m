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

#import "SongNotification.h"
#import "WebKit/WebFrame.h"
#import "Playlist.h"
#import "ResourceURL.h"

static SongNotification* sharedInstance = nil;

NSString *PBPlayerInfoNotificationName = @"net.frozensilicon.pandoraBoy.playerInfo";

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

NSString *PBPlayerStateStoppedString = @"Stopped";
NSString *PBPlayerStatePausedString  = @"Paused";
NSString *PBPlayerStatePlayingString = @"Playing";

@implementation SongNotification

#pragma public interface

- (id) init
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
        [self setPlayerState:PBPlayerStateStopped];
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

- (int)playerState {
    return _playerState;
}

- (void)setPlayerState:(int)value {
    if (_playerState != value) {
        _playerState = value;
    }
}

- (NSString *)playerStateAsString {
    switch ([self playerState]) {
        case PBPlayerStateStopped: return PBPlayerStateStoppedString;
        case PBPlayerStatePaused:  return PBPlayerStatePausedString;
        case PBPlayerStatePlaying: return PBPlayerStatePlayingString;
    }
    return @"";
}

- (void) loadNotifier: (WebView*) view {
    ResourceURL *notifierURL = [ResourceURL resourceURLWithPath:@"/SongNotification.html"];
	[[view mainFrame] loadRequest:[NSURLRequest requestWithURL:notifierURL]];

    id win = [view windowScriptObject]; 
    [win setValue:self forKey:@"SongNotification"];
}

- (void) sendPlayerInfoNotification {
    Playlist *playlist = [Playlist sharedPlaylist];
    Track *currentTrack = [playlist currentTrack];
    if( currentTrack && ! [[currentTrack name] isEqualToString:@""] ) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [currentTrack name],                         PBPlayerInfoNameKey, 
            [currentTrack artist],                       PBPlayerInfoArtistKey,
            [NSNumber numberWithInt:[self playerState]], PBPlayerInfoPlayerStateKey,
            nil];

        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName:PBPlayerInfoNotificationName
                          object:nil
                        userInfo:dict];
    }
}

// Delegate methods from Pandora's notification system
- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist
{
    NSLog( @"pandoraSongPlayed name: %@, artist: %@", name, artist); 

    // FIXME: playlist isn't implemented yet
    Playlist *playlist = [Playlist sharedPlaylist];
    Track *track = [Track trackWithName:name artist:artist];
    // We get called for both track change and unpause, so make sure this isn't the current track
    if( ! [track isEqualToTrack:[playlist currentTrack]] ) {
        [playlist addPlayedTrack:track];
    }
    [self setPlayerState:PBPlayerStatePlaying];
    [self sendPlayerInfoNotification];
}

- (void) pandoraSongPaused
{
    NSLog( @"pandoraSongPaused"); 
    [self setPlayerState:PBPlayerStatePaused];
    [self sendPlayerInfoNotification];
}

- (void) pandoraEventsError: (NSString*)errormsg
{
  NSLog( @"pandoraEventsError: %@", errormsg); 
}

- (void) pandoraSongEnded: (NSString*)name :(NSString*)artist
{
  NSLog( @"pandoraSongEnded name: %@, artist: %@", name, artist); 
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }

@end
