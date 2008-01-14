#define PBPandoraDidLoadNotification @"PBPandoraDidLoadNotification"

extern NSString *PBPlayerStateStoppedString;
extern NSString *PBPlayerStatePlayingString;
extern NSString *PBPlayerStatePausedString;

// These match iTunes (4-char codes)
typedef enum _PBPlayerStates {
    PBPlayerStateStopped = 'stop',
    PBPlayerStatePlaying = 'play',
    PBPlayerStatePaused  = 'paus'
} PBPlayerStates;

extern NSString *PBCurrentTrackKey;
extern NSString *PBCurrentStationKey;
extern NSString *PlayerStateKey;

extern NSString *PBSongPlayedNotification;
extern NSString *PBSongPausedNotification;
extern NSString *PBSongThumbedNotification;
extern NSString *PBStationChangedNotification;

extern NSString *PBFullScreenDidFinishNotification;