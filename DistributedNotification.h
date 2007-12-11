//
//  DistributedNotification.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
// Handles NSDistributedNotifications. As much as possible, this matches iTunes.

#import <Cocoa/Cocoa.h>

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

@interface DistributedNotification : NSObject {

}

@end
