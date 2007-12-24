//
//  PlayerController.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  PlayerController manages the Pandora window and the hidden API window 

#import "PlayerController.h"
#import <Carbon/Carbon.h>
#import "ResourceURL.h";
#import "Controller.h";
#import "MyAnimation.h"

static PlayerController* _sharedInstance = nil;

extern NSString *PBPandoraURL;
NSString *PBPandoraURL = @"http://www.pandora.com?cmd=mini";

extern NSString *PBAPIPath;
NSString *PBAPIPath = @"/SongNotification.html";

//typedef enum {
//    WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows,
//    WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns,
//    WebDashboardBehaviorAlwaysAcceptsFirstMouse,
//    WebDashboardBehaviorAllowWheelScrolling
//} WebDashboardBehavior;

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

@interface PlayerController (Private)
- (BOOL)controlDisabled;
- (void)setControlDisabled:(BOOL)value;
- (BOOL)isFullScreen;
- (void)setIsFullScreen:(BOOL)value;
@end

@implementation PlayerController

+ (PlayerController*) sharedController
{
    if (_sharedInstance) return _sharedInstance;
    _sharedInstance = [[PlayerController alloc] init];
    return _sharedInstance;
}

- (PlayerController *) init {
    if (_sharedInstance) return _sharedInstance;

    if (_sharedInstance = [super init] ) {;
        [self setControlDisabled:FALSE];
        [self setPlayerState:PBPlayerStateStopped];
        [self setIsFullScreen:NO];
    }
    return _sharedInstance;
}

- (void) dealloc {
    [webNetscapePlugin release];
    [_pendingWebViews release];
    [_fullScreenWindow release];
    [super dealloc];

}

- (void) load
{
    [[pandoraWebView mainFrame] loadRequest:
        [NSURLRequest requestWithURL:[NSURL URLWithString:PBPandoraURL]]];
    
    ResourceURL *notifierURL = [ResourceURL resourceURLWithPath:PBAPIPath];
    [[apiWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:notifierURL]];
    
    WebScriptObject *win = [apiWebView windowScriptObject]; 
    [win setValue:self forKey:@"SongNotification"];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessors

- (BOOL)controlDisabled {
    return _controlDisabled;
}

- (void)setControlDisabled:(BOOL)value {
    if (_controlDisabled != value) {
        _controlDisabled = value;
    }
}

- (BOOL)isFullScreen {
    return _isFullScreen;
}

- (void)setIsFullScreen:(BOOL)value {
    if (_isFullScreen != value) {
        _isFullScreen = value;
    }
}

- (int)playerState {
    return _playerState;
}

- (void)setPlayerState:(int)value {
    if (_playerState != value) {
        _playerState = value;
    }
}

- (Track *)currentTrack {
    return [[Playlist sharedPlaylist] currentTrack];
}

- (Station *)currentStation {
    return [[StationList sharedStationList] currentStation];
}

- (NSString *)playerStateAsString {
    switch ([self playerState]) {
        case PBPlayerStateStopped: return PBPlayerStateStoppedString;
        case PBPlayerStatePaused:  return PBPlayerStatePausedString;
        case PBPlayerStatePlaying: return PBPlayerStatePlayingString;
    }
    return @"";
}

- (void)addPendingWebView:(WebView*)aWebView {
    if( ! _pendingWebViews ) {
        _pendingWebViews = [[NSMutableSet alloc] initWithCapacity:1];
    }
    [_pendingWebViews addObject:aWebView];
}

- (void)removePendingWebview:(WebView*)aWebView {
    [_pendingWebViews removeObject:aWebView];
}

- (NSWindow*)fullScreenWindow {
    if( ! _fullScreenWindow ) {
        NSRect screenRect = [[NSScreen mainScreen] frame];
        _fullScreenWindow = [[NSWindow alloc] initWithContentRect:screenRect
                                                        styleMask:NSBorderlessWindowMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO];
        [_fullScreenWindow setBackgroundColor:[NSColor blackColor]];
        [_fullScreenWindow setAlphaValue:0];
        [_fullScreenWindow setDisplaysWhenScreenProfileChanges:YES];
    }
    return _fullScreenWindow;
}


/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Flash calls

- (bool) sendKeyPress: (int)keyCode withModifiers:(int)modifiers
{
    if(! [self controlDisabled] ) {
        //Generate the keyDown EventRecord
        EventRecord myrecord; 
        myrecord.what = keyDown; 
        myrecord.message = keyCode; 
        myrecord.message = myrecord.message << 8; 
        myrecord.modifiers = modifiers; 
        
        //Send the keyDown press
        [(id)webNetscapePlugin sendEvent:(NSEvent *)&myrecord];
        
        //Make it a keyUp EventRecord and resend it
        myrecord.what = keyUp;
        [(id)webNetscapePlugin sendEvent:(NSEvent *)&myrecord];
        return true; 
    }
    else {
        NSRunAlertPanel(@"Could not control Pandora",
                        @"Global Hotkeys and the Apple Remote cannot control PandoraBoy while it is minimized. This is a bug that will hopefully be fixed soon. Until then, please restore PandoraBoy and try again.",
                        @"OK", nil, nil);
        return false; 
    }
}

- (bool) sendKeyPress: (int)keyCode
{
    return [self sendKeyPress: keyCode withModifiers: 0];
}

- (void)setStation:(Station*)station {
    // It seems that _pandoraScriptObject can't be cached; it changes sometimes.
    WebScriptObject *_pandoraScriptObject = [[pandoraWebView windowScriptObject] valueForKey:@"Pandora"];
    [_pandoraScriptObject callWebScriptMethod:@"launchStationFromId" 
                                withArguments:[NSArray arrayWithObject:[station identifier]]];
    
    // We set the current station twice on purpose. This time makes sure that
    // quick (next|previous)Station calls do the right thing. The second
    // time (in pandoraStationPlayed) makes sure we Growl, etc. and catches
    // non-PB changes to the station.
    [[StationList sharedStationList] setCurrentStation:station];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

- (IBAction) nextSong:(id)sender
{
    //Right-arrow
    [self sendKeyPress: 124];
}

- (IBAction) playPause:(id)sender
{
    //Space-bar
    [self sendKeyPress: 49];
}

- (IBAction) likeSong:(id)sender
{
    //Plus
    [self sendKeyPress: 69];
}

- (IBAction) dislikeSong:(id)sender
{
    //Minus
    [self sendKeyPress: 78];
}

- (IBAction) raiseVolume:(id)sender
{
    //Up-Arrow
    int i;
    for(i = 0; i < 4; i++)
        [self sendKeyPress: 126];       
}

- (IBAction) lowerVolume:(id)sender
{
    //Down-Arrow -- currently we don't get multiple keypresses --- so send a bunch of keypress events to make up for it
    int i;
    for(i = 0; i < 4; i++)
        [self sendKeyPress: 125];   
}

- (IBAction) fullVolume:(id)sender
{
    //Shift + Up-Arrow
    [self sendKeyPress: 126 withModifiers: shiftKey];
}

- (IBAction) mute:(id)sender
{
    //Shift + Down-Arrow
    [self sendKeyPress: 125 withModifiers: shiftKey]; 
}

- (IBAction)setStationToSender:(id)sender {
    [self setStation:[sender representedObject]];
}

- (IBAction) refreshPandora:(id)sender { [[pandoraWebView mainFrame] reload]; }

- (IBAction)nextStation:(id)sender {
    [self setStation:[[StationList sharedStationList] nextStation]];
}
    
- (IBAction)previousStation:(id)sender {
    [self setStation:[[StationList sharedStationList] previousStation]];
}

- (IBAction)fullScreenAction:(id)sender {
    if( ! [self isFullScreen] ) {
        [[self fullScreenWindow] setLevel:NSScreenSaverWindowLevel];
        [[self fullScreenWindow] makeKeyAndOrderFront:nil];

        _oldWindowFrame = [pandoraWindow frame];
        [pandoraWindow setLevel:NSScreenSaverWindowLevel];
        [pandoraWindow makeKeyAndOrderFront:nil];
    
        MyAnimation *animation = [[MyAnimation alloc] initWithDuration:1.5
                                                        animationCurve:NSAnimationEaseIn];
        [animation setDelegate:self];
        [animation startAnimation];
        [animation release];
        [self setIsFullScreen:YES];
        }
    else {
        MyAnimation *animation = [[MyAnimation alloc] initWithDuration:1.5
                                                        animationCurve:NSAnimationEaseOut];
        [animation setDelegate:self];
        [animation startAnimation];
        [animation release];
        [self setIsFullScreen:NO];
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark WebView delegates

- (void)webView:(WebView *)sender setFrame:(NSRect)frame
{
    //We do nothing in the setFrame function to prevent Pandora from changing the window size using javascript. 
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{   
    // On Javascript window.open, Webkit sends a null request here, then sends a
    // loadRequest: to the new WebView, which will include a
    // decidePolicyForNavigation (which is where we'll open our external
    // window).
    WebView *newWebView = [[[WebView alloc] init] autorelease];
    [newWebView setUIDelegate:self];
    [newWebView setPolicyDelegate:self];
    [self addPendingWebView:newWebView];
    return newWebView;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if( [sender isEqualTo:pandoraWebView] && [frame parentFrame] == nil)
    {
        // Find the subview that isn't of size 0
        NSArray *subviews = [[pandoraWebView hitTest:NSZeroPoint] subviews];
        int i;
        for( i = 0; i < [subviews count]; i++ )
        {
            if( [[subviews objectAtIndex:i] frame].size.height > 0 )
            {
                webNetscapePlugin = [subviews objectAtIndex:i];
                [pandoraWindow makeFirstResponder: webNetscapePlugin];
                break;
            }
        }
        
        if( ! webNetscapePlugin )
        {
            NSLog(@"ERROR: Could not find webNetscapePlugin");
        }
    }
}

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder
{
    // Ignore requests to change the first responder. This way, no matter
    // where the user clicks in the window, the webNetscapePluginView (Flash)
    // will always get the keystrokes
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if( [sender isEqual:pandoraWebView] ) {
        [listener use];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];
        [self removePendingWebview:sender];
    }
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
    [self removePendingWebview:sender];
}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
    // Make the request be the identifier so we can look up all the information later
    return (request);
}

/////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark NSWindow Delegates

-(void)windowDidMiniaturize:(NSNotification *)aNotification
{
    [self setControlDisabled:YES];
}

-(void)windowDidDeminiaturize:(NSNotification *)aNotification
{
    [self setControlDisabled:NO];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [NSApp terminate:self];
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Pandora Delegates

- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist
{
    NSLog( @"pandoraSongPlayed name: %@, artist: %@", name, artist); 
    
    Playlist *playlist = [Playlist sharedPlaylist];
    Track *track = [Track trackWithName:name artist:artist];
    // We get called for both track change and unpause, so make sure this isn't the current track
    if( ! [track isEqualToTrack:[self currentTrack]] ) {
        [playlist addPlayedTrack:track];
    }
    [self setPlayerState:PBPlayerStatePlaying];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBSongPlayedNotification
                                                        object:track];
}

- (void) pandoraSongPaused
{
    NSLog( @"pandoraSongPaused"); 
    [self setPlayerState:PBPlayerStatePaused];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBSongPausedNotification
                                                        object:[self currentTrack]];
}

- (void) pandoraStationPlayed:(NSString*)name :(NSString*)identifier {
    NSLog(@"pandoraStationPlayed:%@:%@", name, identifier);
    [[StationList sharedStationList] setCurrentStationFromIdentifier:identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBStationChangedNotification
                                                        object:[self currentStation]];
}

- (void) pandoraEventFired:(NSString*)eventName :(NSString*)argument {
    NSLog(@"DEBUG:pandoraEventFired:%@\n%@", eventName, argument);
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animation Delegates

- (void)updateAnimationForValue:(float)value {
    [[self fullScreenWindow] setAlphaValue:value];

    NSRect srcRect = _oldWindowFrame;
    NSRect screenRect = [[self fullScreenWindow] frame];
    NSRect targetRect = NSMakeRect( screenRect.origin.x, screenRect.size.height - srcRect.size.height,
                                    screenRect.size.width, srcRect.size.height);
    
    // If this goes offscreen vertically, we'd rather have the title bar visible
    NSRect newRect;
    newRect.origin.x = srcRect.origin.x + (targetRect.origin.x - srcRect.origin.x)*value;
    newRect.origin.y = srcRect.origin.y + (targetRect.origin.y - srcRect.origin.y)*value;
    newRect.size.width = srcRect.size.width + (targetRect.size.width - srcRect.size.width)*value;
    newRect.size.height = srcRect.size.height + (targetRect.size.height - srcRect.size.height)*value;

    // NSMenuView menuBarHeight is deprecated, but [[NSApp mainMenu] menuBarHeight]
    // always returns 0 in 10.4. http://lists.apple.com/archives/Cocoa-dev/2005/Oct/msg01293.html
    if( (newRect.origin.y + newRect.size.height) >= (screenRect.size.height - [NSMenuView menuBarHeight]) ) {
        [NSMenu setMenuBarVisible:NO];
    }
    else {
        [NSMenu setMenuBarVisible:YES];
    }
    
    [pandoraWindow setFrame:newRect display:YES];

    WebScriptObject *scriptObject = [pandoraWebView windowScriptObject];
    if( scriptObject ) {
        // HACK: Get 640 out of page.
        int leftMargin = (screenRect.size.width - 640) / 2;
//        int spacerMargin = [[scriptObject evaluateWebScript:@"spacer.style.marginLeft"] intValue];
        int spacerMargin = 44; // HACK
        [scriptObject evaluateWebScript:[NSString stringWithFormat:@"tuner_ad.style.marginLeft = %f; TunerContainer.style.marginLeft = %f",  (leftMargin * value), ( (leftMargin - spacerMargin) * value)]];
//        NSLog(@"DEBUG:spacer:%d", (int)(leftMargin * value) + spacerMargin);
//        [scriptObject evaluateWebScript:[NSString stringWithFormat:@"spacer.style.marginLeft = %d", (int)(leftMargin * value) + spacerMargin]];
    }
}

@end
