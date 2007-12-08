/****************************************************************************
 *  Copyright 2006 Aaron Rolett                                             *
 *  arolett@mail.rochester.edu                                              *
 *                                                                          *
 *  This file is part of PandoraBoy.                                        *
 *                                                                          *
 *  PandoraBoy is free software; you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by    * 
 *  the Free Software Foundation; either version 2 of the License, or       *
 *  (at your option) any later version.                                     *
 *                                                                          *
 *  PandoraBoy is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           * 
 *  GNU General Public License for more details.                            *
 *                                                                          *
 *  You should have received a copy of the GNU General Public License       * 
 *  along with PandoraBoy; if not, write to the Free Software Foundation,   *
 *  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA          *
 ***************************************************************************/

#import "Controller.h"
#import "SongNotification.h"
#import "PandoraControl.h"
#import "GlobalHotkey.h"
#import <WebKit/WebKit.h>
#import "ProxyURLProtocol.h"

extern NSString *PBPandoraURL;
NSString *PBPandoraURL = @"http://www.pandora.com?cmd=mini";

extern NSString *PBAppleRemoteEnabled;
NSString *PBAppleRemoteEnabled = @"AppleRemoteEnabled";

static Controller* _sharedInstance = nil;

typedef enum {
    WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows,
    WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns,
    WebDashboardBehaviorAlwaysAcceptsFirstMouse,
    WebDashboardBehaviorAllowWheelScrolling
} WebDashboardBehavior;

@implementation Controller

- (id) init 
{
    if (_sharedInstance) return _sharedInstance;

  if(_sharedInstance = [super init]) {
    // Setup all the different default options
    NSMutableDictionary *userDefaultsValuesDict = [NSMutableDictionary
						    dictionary];
    [userDefaultsValuesDict setObject:@"YES"
			    forKey:PBAppleRemoteEnabled];
    [userDefaultsValuesDict setObject:@"NO"
			    forKey:@"DoNotShowStartupWindow2"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:
		      userDefaultsValuesDict];      //Register the defaults
    [[NSUserDefaults standardUserDefaults] synchronize];  //And sync them

    appleRemote = [[AppleRemote alloc] initWithDelegate:self];
    if([[NSUserDefaults standardUserDefaults] boolForKey:PBAppleRemoteEnabled]) {
        [appleRemote startListening:self];
    }

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:PBAppleRemoteEnabled
                                               options: NSKeyValueObservingOptionNew
                                               context:nil];
    controlDisabled = false; 
    [self setGrowl:[[GrowlNotification alloc] init]];

  }
  return _sharedInstance;
}

- (void) dealloc {
    [_growl release];
    [appleRemote release];
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                               forKeyPath:PBAppleRemoteEnabled];
    [super dealloc];
}

- (void)awakeFromNib
{
  [[GlobalHotkey sharedHotkey] registerHotkeyHandler];
  [[GlobalHotkey sharedHotkey] registerHotkeys];
}

+ (Controller*) sharedController
{
	if (_sharedInstance) return _sharedInstance;
	_sharedInstance = [[Controller alloc] init];
	return _sharedInstance;
}

- (void) setControlDisabled 
{
    controlDisabled = true;
}

- (void) setControlEnabled 
{
    controlDisabled = false;
}

- (GrowlNotification *)growl {
    return [[_growl retain] autorelease];
}

- (void)setGrowl:(GrowlNotification *)value {
    if (_growl != value) {
        [_growl release];
        _growl = [value retain];
    }
}

- (bool) sendKeyPress: (int)keyCode withModifiers:(int)modifiers
{
    if(!controlDisabled) {
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
        NSRunAlertPanel(@"Could not control Pandora", @"Global Hotkeys and the Apple Remote cannot control PandoraBoy while it is minimized. This is a bug that will hopefully be fixed soon. Until then, please restore PandoraBoy and try again.", @"OK", nil, nil);
        return false; 
    }
}

- (bool) sendKeyPress: (int)keyCode
{
    return [self sendKeyPress: keyCode withModifiers: 0];
}

- (void) loadPandora 
{
    [[webView mainFrame] loadRequest:
        [NSURLRequest requestWithURL:[NSURL URLWithString:PBPandoraURL]]];
}
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
    if([self sendKeyPress: 69])
        [[self growl] pandoraLikeSong];
}

- (IBAction) dislikeSong:(id)sender
{
    //Minus
    if([self sendKeyPress: 78])
        [[self growl] pandoraDislikeSong];
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

- (IBAction)changeStation:(id)sender {
    NSLog(@"DEBUG:changeStation:%@:%@:%@",sender, [sender representedObject], [[sender representedObject] identifier]);
    WebScriptObject *scriptObject = [[webView windowScriptObject] valueForKey:@"Pandora"];
    [scriptObject callWebScriptMethod:@"launchStationFromId" withArguments:[NSArray arrayWithObject:[[sender representedObject] identifier]]];
}

- (IBAction) refreshPandora:(id)sender { [[webView mainFrame] reload]; }

- (IBAction) displayHelp:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://code.google.com/p/pandoraboy/wiki/FrequentlyAskedQuestions"]];
}

// Accessors

// webView delegates

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
    return newWebView;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if( [sender isEqual:webView] )
    {
        // Find the subview that isn't of size 0
        NSArray *subviews = [[webView hitTest:NSZeroPoint] subviews];
        int i;
        for( i = 0; i < [subviews count]; i++ )
        {
            if( [[subviews objectAtIndex:i] frame].size.height > 0 )
            {
                webNetscapePlugin = [subviews objectAtIndex:i];
                break;
            }
        }

        if( webNetscapePlugin )
        {
            [pandoraWindow makeFirstResponder: webNetscapePlugin];
        }
        else
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
    if( [sender isEqual:webView] ) {
        [listener use];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];
    }
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
    // Make the request be the identifier so we can look up all the information later
    return (request);
}

@end


@implementation Controller(ApplicationNotifications)

-(void)applicationDidFinishLaunching: (NSNotification*)notification
{	
	// FIXME: This doesn't currently work and is generating warnings.
	// http://lists.apple.com/archives/webkitsdk-dev/2006/Sep/msg00010.html
	//[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:YES];
    //	[notificationView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:YES];
    //	
    //	NSLog(@"_dashboardBehavoir: %d", [webView _dashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns]);
    
    // Here's the fix: http://lists.apple.com/archives/webkitsdk-dev/2006/Dec/msg00011.html

    [ProxyURLProtocol registerProxyProtocols];

	[self loadPandora];
    [[SongNotification sharedNotification] loadNotifier:notificationView];

  if([[NSUserDefaults standardUserDefaults] boolForKey:@"DoNotShowStartupWindow2"]==NO) {
    [startupWindow makeKeyAndOrderFront:self]; 
  }
}
@end

@implementation Controller (NSWindowDelegate)

-(void)windowDidMiniaturize:(NSNotification *)aNotification
{
  [[PandoraControl sharedController] setControlDisabled];
  NSLog(@"Minaturized!!!");
}

-(void)windowDidDeminiaturize:(NSNotification *)aNotification
{
  [[PandoraControl sharedController] setControlEnabled];
  NSLog(@"Restored!!!");
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [NSApp terminate:self];
}

@end

@implementation Controller (AppleRemote)

// delegate methods for AppleRemote
- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event 
                   pressedDown: (BOOL) pressedDown 
                 remoteControl: (RemoteControl*) remoteControl
{
    if( pressedDown )
    {
        switch(event) {
            case kRemoteButtonPlus:
                [[PandoraControl sharedController] raiseVolume]; 
                break;
            case kRemoteButtonMinus:
                [[PandoraControl sharedController] lowerVolume]; 
                break;			
            case kRemoteButtonMenu:
                break;
            case kRemoteButtonMenu_Hold:
                break;
            case kRemoteButtonPlay:
                [[PandoraControl sharedController] playPause]; 
                break;
            case kRemoteButtonPlay_Hold:
                break;
            case kRemoteButtonRight:	
                [[PandoraControl sharedController] nextSong]; 
                break;			
            case kRemoteButtonLeft:
                [[PandoraControl sharedController] likeSong];
                break;			
            case kRemoteButtonLeft_Hold:
                break;			
            case kRemoteButtonRight_Hold:
                [[PandoraControl sharedController] dislikeSong];
                break;	
            default:
                NSLog(@"Unmapped event for button %d", event); 
                break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [object isEqualTo:userDefaults] &&
        [keyPath isEqualTo:PBAppleRemoteEnabled] )
    {
        if( [userDefaults boolForKey:PBAppleRemoteEnabled] ) {
            [appleRemote startListening:self];
        }
        else {
            [appleRemote stopListening:self];
        }
    }
    else {
        NSLog(@"BUG:Received observeValueForKeyPath on %@", object);
    }
}

@end