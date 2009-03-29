//
//  PlayerController.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PBNotifications.h"

@class Station;
@class Track;
@class PBFullScreenWindowController;
@class APIController;

@interface PlayerController : NSObject {
    IBOutlet NSWindow *pandoraWindow; 
    IBOutlet WebView *pandoraWebView;
	IBOutlet APIController *apiController;

    NSView *_webNetscapePlugin;
    BOOL _controlDisabled;
    int _playerState;
    NSMutableSet *_pendingWebViews;
    BOOL _isFullScreen;
	PBFullScreenWindowController *fullScreenWindowController;
}

+ (PlayerController*) sharedController;
- (void)reload;

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

- (void)createStationFromSearchText:(NSString*)text;

- (BOOL)canFullScreen;

- (Track *)currentTrack;
- (Station *)currentStation;
- (void)setStation:(Station*)station;

- (void)showWindow;

// Scripting interfaces
- (int)playerState;
- (void)setPlayerState:(int)value;
- (NSString *)playerStateAsString;

@end
