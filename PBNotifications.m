#import <Foundation/Foundation.h>

NSString *PBPlayerStateStoppedString = @"Stopped";
NSString *PBPlayerStatePausedString  = @"Paused";
NSString *PBPlayerStatePlayingString = @"Playing";

NSString *PBCurrentTrackKey   = @"currentTrack";
NSString *PBCurrentStationKey = @"currentStation";
NSString *PBPlayerStateKey    = @"currentState";



// These are human readable strings (used by Growl)
NSString *PBSongPlayedNotification = @"Song Playing";
NSString *PBSongPausedNotification = @"Song Paused";
NSString *PBSongThumbedNotification = @"Song Thumbed";
NSString *PBStationChangedNotification = @"Station Changed";

NSString *PBFullScreenDidFinishNotification = @"PBFullScreenDidFinish";
