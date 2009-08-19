//
//  APIController.m
//  PandoraBoy
//
//  Created by Rob Napier on 7/1/08.
//  Copyright 2008 Rob Napier. All rights reserved.
//

#import "APIController.h"
#import "ResourceURL.h";
#import "Playlist.h"
#import "PBNotifications.h"
#import "PlayerController.h"
#import "StationList.h"
#import <WebKit/WebKit.h>

NSString *PBAPIPath = @"/SongNotification.html";

@implementation APIController

-(void)reload
{
	ResourceURL *notifierURL = [ResourceURL resourceURLWithPath:PBAPIPath];
    [[apiWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:notifierURL]];
	WebScriptObject *win = [apiWebView windowScriptObject]; 
    [win setValue:self forKey:@"SongNotification"];    
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Pandora Delegates

- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist
{
    Playlist *playlist = [Playlist sharedPlaylist];
    Track *track = [Track trackWithName:name artist:artist];
    // We get called for both track change and unpause, so make sure this isn't the current track
    if( ! [track isEqualToTrack:[playerController currentTrack]] ) {
        [playlist addPlayedTrack:track];
    }
    [playerController setPlayerState:PBPlayerStatePlaying];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBSongPlayedNotification
                                                        object:track];
}

- (void) pandoraSongPaused
{
    [playerController setPlayerState:PBPlayerStatePaused];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBSongPausedNotification
                                                        object:[playerController currentTrack]];
}

- (void) pandoraStationPlayed:(NSString*)name :(NSString*)identifier {
    [[StationList sharedStationList] setCurrentStationFromIdentifier:identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBStationChangedNotification
                                                        object:[playerController currentStation]];
}

- (void) pandoraStarted
{
}

- (void) pandoraEventFired:(NSString*)eventName :(NSString*)argument {
    NSLog(@"DEBUG:pandoraEventFired:%@\n%@", eventName, argument);
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark WebView delegates

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR:API didFailProvisionalLoadWithError: %@", error);
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR:API didFailLoadWithError: %@", error);
}

@end
