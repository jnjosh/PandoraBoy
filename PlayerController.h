//
//  PlayerController.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Station.h"
#import "Track.h"

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

@interface PlayerController : NSObject {
    IBOutlet NSWindow *pandoraWindow; 

    IBOutlet WebView *pandoraWebView;
    IBOutlet WebView *apiWebView;

    NSView *webNetscapePlugin;
    BOOL _controlDisabled;
    int _playerState;
    NSMutableSet *_pendingWebViews;
    BOOL _isFullScreen;
    id _fullScreenPlugin;
}

+ (PlayerController*) sharedController;
- (void)load;

- (IBAction)refreshPandora:(id)sender; 
- (IBAction)playPause:(id)sender;
- (IBAction)nextSong:(id)sender;
- (IBAction)likeSong:(id)sender;
- (IBAction)dislikeSong:(id)sender;
- (IBAction)raiseVolume:(id)sender;
- (IBAction)lowerVolume:(id)sender;
- (IBAction)fullVolume:(id)sender;
- (IBAction)mute:(id)sender;
- (IBAction)setStationToSender:(id)sender; 
- (IBAction)nextStation:(id)sender;
- (IBAction)previousStation:(id)sender;
- (IBAction)fullScreenAction:(id)sender;

- (Track *)currentTrack;
- (Station *)currentStation;
- (void)setStation:(Station*)station;

// Delegate functions from Pandora notification system
- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist; 
- (void) pandoraSongPaused; 
- (void) pandoraStationPlayed:(NSString*)name :(NSString*)identifier;

// Scripting interfaces
- (int)playerState;
- (void)setPlayerState:(int)value;
- (NSString *)playerStateAsString;

@end
