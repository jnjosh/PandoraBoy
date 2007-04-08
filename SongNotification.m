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

NSString *PBPlayerStatePlaying = @"Playing";
NSString *PBPlayerStatePaused  = @"Paused";

@implementation SongNotification

#pragma public interface

- (id) init 
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
        [self setName:@""];
        [self setArtist:@""];
        [self setPlayerState:@""];
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

- (NSString *)name {
    return [[_name retain] autorelease];
}

- (void)setName:(NSString *)value {
    if (_name != value) {
        [_name release];
        _name = [value retain];
    }
}

- (NSString *)artist {
    return [[_artist retain] autorelease];
}

- (void)setArtist:(NSString *)value {
    if (_artist != value) {
        [_artist release];
        _artist = [value retain];
    }
}

- (NSString *)playerState {
    return [[_playerState retain] autorelease];
}

- (void)setPlayerState:(NSString *)value {
    if (_playerState != value) {
        [_playerState release];
        _playerState = [value retain];
    }
}

- (void) loadNotifier: (WebView*) view {
	[[view mainFrame] loadRequest:[NSURLRequest requestWithURL:
        [NSURL URLWithString:PBNotifierURL]]];
	 id win = [view windowScriptObject]; 
	 [win setValue:self forKey:@"SongNotification"];
	 NSLog(@"Notifier loaded");
}

- (void) sendPlayerInfoNotification {
    if( ! [[self name] isEqualToString:@""] ) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self name],        PBPlayerInfoNameKey, 
                            [self artist],      PBPlayerInfoArtistKey,
                            [self playerState], PBPlayerInfoPlayerStateKey,
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
    [self setName:name];
    [self setArtist:artist];
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
