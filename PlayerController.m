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
#import "PBNotifications.h"
#import "Controller.h";
#import "Station.h"
#import "Track.h"
#import "Playlist.h"
#import "StationList.h"
#import "PBFullScreenWindowController.h"

static PlayerController* _sharedInstance = nil;

NSString *PBPandoraURLFormat = @"http://www.pandora.com?cmd=mini&mtverify=%@";

//typedef enum {
//    WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows,
//    WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns,
//    WebDashboardBehaviorAlwaysAcceptsFirstMouse,
//    WebDashboardBehaviorAllowWheelScrolling
//} WebDashboardBehavior;

@interface PlayerController (Private)
- (BOOL)controlDisabled;
- (void)setControlDisabled:(BOOL)value;
- (BOOL)isFullScreen;
- (void)setIsFullScreen:(BOOL)value;
- (NSView *)webNetscapePlugin;
- (void)setWebNetscapePlugin:(NSView *)value;
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

    if (_sharedInstance = [super init] ) {
        [self setControlDisabled:FALSE];
        [self setPlayerState:PBPlayerStateStopped];
        [self setIsFullScreen:NO];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidUnhide:) name:NSApplicationDidUnhideNotification object:nil];
    }
    return _sharedInstance;
}

- (void)awakeFromNib {
    // Setup user-stylesheet
    [pandoraWebView setPreferencesIdentifier:@"PandoraBoy"];
    [[pandoraWebView preferences] setUserStyleSheetEnabled:YES];
    [[pandoraWebView preferences] setUserStyleSheetLocation:
        [NSURL fileURLWithPath:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PandoraBoy.css"]]];
	
	[pandoraWindow setExcludedFromWindowsMenu:YES];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [_webNetscapePlugin release];
    [_pendingWebViews release];
	[fullScreenWindowController release];
    [super dealloc];
}

- (void) reload
{
	[apiController reload];

	NSString *mtverify = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
	NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
															   @"TRUE", NSHTTPCookieDiscard,
															   @".pandora.com", NSHTTPCookieDomain,
															   @"/", NSHTTPCookiePath,
															   @"mtverify", NSHTTPCookieName,
															   mtverify, NSHTTPCookieValue,
															   nil]];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    NSURL *pbURL = [NSURL URLWithString:[NSString stringWithFormat:PBPandoraURLFormat, mtverify]];
	[[pandoraWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:pbURL]];
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

- (void)removePendingWebView:(WebView*)aWebView {
    [_pendingWebViews removeObject:aWebView];
}

- (NSView *)webNetscapePlugin {
	return [[_webNetscapePlugin retain] autorelease];
}

- (void)setWebNetscapePlugin:(NSView *)value {
    if (_webNetscapePlugin != value) {
        [_webNetscapePlugin release];
        _webNetscapePlugin = [value retain];
    }
}

- (BOOL)canFullScreen {
	return (([self webNetscapePlugin] != nil) && (!fullScreenWindowController || [fullScreenWindowController canChangeState]));
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
        [(id)[self webNetscapePlugin] sendEvent:(NSEvent *)&myrecord];
        
        //Make it a keyUp EventRecord and resend it
        myrecord.what = keyUp;
        [(id)[self webNetscapePlugin] sendEvent:(NSEvent *)&myrecord];
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

- (IBAction)refreshPandora:(id)sender { [self reload]; }

- (IBAction)nextStation:(id)sender {
    [self setStation:[[StationList sharedStationList] nextStation]];
}
    
- (IBAction)previousStation:(id)sender {
    [self setStation:[[StationList sharedStationList] previousStation]];
}

- (IBAction)fullScreenAction:(id)sender {
    if( [self isFullScreen] ) {
        [self setIsFullScreen:NO];
		[fullScreenWindowController closeAndMoveWebViewToWindow:pandoraWindow];
	}
    else {
        [self setIsFullScreen:YES];
		[fullScreenWindowController release];
		fullScreenWindowController = [[PBFullScreenWindowController alloc] initWithPlayerView:pandoraWebView
																		   flashView:[self webNetscapePlugin]];
		[fullScreenWindowController showWindow:nil];
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark WebView delegates

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
		// Find that Flash plugin (WebNetscapePluginDocumentView isa WebBaseNetscapePluginView)
		NSPoint point = NSMakePoint([[pandoraWindow contentView] bounds].size.width / 2,
									[[pandoraWindow contentView] bounds].size.width / 3);
		NSView *view = [pandoraWebView hitTest:point];

		// Depending on exactly how WebKit rendered things, we might have gotten
		// the plugin itself, or we may have gotten the WebHTML view, in which
		// case we'll need to go fishing around for the plugin.
		if( [[view className] isEqual:@"WebBaseNetscapePluginView"] ||
			[[view className] isEqual:@"WebNetscapePluginDocumentView"] ) {
			[self setWebNetscapePlugin:view];
		}
		else {
			// Find the subview that isn't of size 0
			NSArray *subviews = [view subviews];
			int i;
			for( i = 0; i < [subviews count]; i++ )
			{
				if( [[subviews objectAtIndex:i] frame].size.height > 0 )
				{
					[self setWebNetscapePlugin:[subviews objectAtIndex:i]];
					break;
				}
			}
		}

		if( [self webNetscapePlugin] ) {
			[pandoraWindow makeFirstResponder: [self webNetscapePlugin]];
		} else {
			NSLog(@"ERROR: Could not find webNetscapePlugin.");
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
        [self removePendingWebView:sender];
    }
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
    [self removePendingWebView:sender];
}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
    // Make the request be the identifier so we can look up all the information later
    return (request);
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR:didFailProvisionalLoadWithError: %@", error);
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR:didFailLoadWithError: %@", error);
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

/////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark NSApplication Notifications

- (void)applicationDidUnhide:(NSNotification*)note
{
	[pandoraWebView setNeedsDisplay:YES];
}

@end
