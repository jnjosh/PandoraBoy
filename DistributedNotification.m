//
//  DistributedNotification.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DistributedNotification.h"
#import "PlayerController.h"

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

@interface DistributedNotification (Private)

- (void) sendNotificationWithTrack:(Track*)track playerState:(int)state;

@end

@implementation DistributedNotification

- (DistributedNotification*) init {
    self = [super init];
    if (self != nil) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(songPlayed:)
                   name:PBSongPlayedNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(songPaused:)
                   name:PBSongPausedNotification
                 object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) songPlayed:(NSNotification*)notification {
    Track *track = [notification object];
    [self sendNotificationWithTrack:track
                        playerState:PBPlayerStatePlaying];
}

- (void) songPaused:(NSNotification*)notification {
    Track *track = [notification object];
    [self sendNotificationWithTrack:track
                        playerState:PBPlayerStatePaused];
}

- (void) sendNotificationWithTrack:(Track*)track playerState:(int)playerState {
    if( track ) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [track name],                         PBPlayerInfoNameKey, 
            [track artist],                       PBPlayerInfoArtistKey,
            [NSNumber numberWithInt:playerState], PBPlayerInfoPlayerStateKey,
            nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName:PBPlayerInfoNotificationName
                          object:nil
                        userInfo:dict];
    }
    else {
        NSLog(@"BUG: sendNotificationWithTrack called with no Track");
    }
}
@end
