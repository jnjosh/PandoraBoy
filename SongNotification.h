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
#import <WebKit/WebView.h>
#import <Track.h>

extern NSString *PBPlayerInfoNotificationName;

extern NSString *PBPlayerInfoArtistKey;
extern NSString *PBPlayerInfoNameKey;
extern NSString *PBPlayerInfoGenreKey;
extern NSString *PBPlayerInfoTotalTimeKey;
extern NSString *PBPlayerInfoPlayerStateKey;
extern NSString *PBPlayerInfoTrackNumberKey;
extern NSString *PBPlayerInfoStoreURLKey;
extern NSString *PBPlayerInfoAlbumKey;
extern NSString *PBPlayerInfoComposerKey;
extern NSString *PBPlayerInfoLocationKey;
extern NSString *PBPlayerInfoTrackCountKey;
extern NSString *PBPlayerInfoRatingKey;
extern NSString *PBPlayerInfoDiscNumberKey;
extern NSString *PBPlayerInfoDiscCountKey;

extern NSString *PBPlayerStatePlaying;
extern NSString *PBPlayerStatePaused;

@interface SongNotification : NSObject {
    NSMutableArray *_tracks;
    NSString *_playerState;
}

- (NSMutableArray *)tracks;
- (void)setTracks:(NSMutableArray *)value;

- (NSString *)playerState;
- (void)setPlayerState:(NSString *)value;

- (Track *)currentTrack;

+ (SongNotification*) sharedNotification; 

- (void) loadNotifier: (WebView*)view; 
- (void) sendPlayerInfoNotification;

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector;

// Delegate functions from Pandora notification system
- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist; 
- (void) pandoraSongPaused; 
- (void) pandoraEventsError: (NSString*)errormsg; 
- (void) pandoraSongEnded: (NSString*)name :(NSString*)artist; 

@end
