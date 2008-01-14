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
#import "PBNotifications.h"
#import "PandoraBoyView.h"

@interface PlayerController : NSObject {
    IBOutlet NSWindow *pandoraWindow; 

    IBOutlet WebView *pandoraWebView;
    IBOutlet WebView *apiWebView;

    NSView *_webNetscapePlugin;
    BOOL _controlDisabled;
    int _playerState;
    NSMutableSet *_pendingWebViews;
    BOOL _isFullScreen;
    PandoraBoyView *_viewPlugin;
	NSWindow *_fullScreenWindow;
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

- (BOOL)canFullScreen;

- (Track *)currentTrack;
- (Station *)currentStation;
- (void)setStation:(Station*)station;

// Delegate functions from Pandora notification system
- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist; 
- (void) pandoraSongPaused; 
- (void) pandoraStationPlayed:(NSString*)name :(NSString*)identifier;
- (void) pandoraStarted;

// Scripting interfaces
- (int)playerState;
- (void)setPlayerState:(int)value;
- (NSString *)playerStateAsString;

@end
