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

static SongNotification* sharedInstance = nil;

extern NSString *PBNotifierURL;
NSString *PBNotifierURL = @"http://www.frozensilicon.net/SongNotification.htm";

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
        [self setTracks:[NSMutableArray array]];
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

- (NSMutableArray *)tracks {
    return [[_tracks retain] autorelease];
}

- (void)setTracks:(NSMutableArray *)value {
    if (_tracks != value) {
        [_tracks release];
        _tracks = [value retain];
    }
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

- (Track *)currentTrack {
    return [[self tracks] lastObject];
}

- (void) loadNotifier: (WebView*) view {
	[[view mainFrame] loadRequest:[NSURLRequest requestWithURL:
        [NSURL URLWithString:PBNotifierURL]]];
	 id win = [view windowScriptObject]; 
	 [win setValue:self forKey:@"SongNotification"];
	 NSLog(@"Notifier loaded");
}

- (void) sendPlayerInfoNotification {
    Track *currentTrack = [self currentTrack];
    if( ! [[currentTrack name] isEqualToString:@""] ) {
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
    Track *track = [Track trackWithName:name artist:artist];
    if( ! [[NSApp currentTrack] isEqual:track] ) {
        [[self tracks] addObject:track];
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
