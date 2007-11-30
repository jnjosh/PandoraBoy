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
#import "PlaylistURLProtocol.h"
#import "ResourceURLProtocol.h"

extern NSString *PBPandoraURL;
NSString *PBPandoraURL = @"http://www.pandora.com?cmd=mini";

extern NSString *PBAppleRemoteEnabled;
NSString *PBAppleRemoteEnabled = @"AppleRemoteEnabled";

typedef enum {
    WebDashboardBehaviorAlwaysSendMouseEventsToAllWindows,
    WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns,
    WebDashboardBehaviorAlwaysAcceptsFirstMouse,
    WebDashboardBehaviorAllowWheelScrolling
} WebDashboardBehavior;

@implementation Controller

- (id) init 
{
  if(self = [super init]) {
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
  }
  return self;
}

- (void) dealloc {
    [appleRemote release];
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                               forKeyPath:PBAppleRemoteEnabled];
    [super dealloc];
}

- (void)awakeFromNib
{

  //[[LastFm sharedLastFm] test]; 

  [[GlobalHotkey sharedHotkey] registerHotkeyHandler];
  [[GlobalHotkey sharedHotkey] registerHotkeys];

}

- (void) loadPandora 
{
    [[webView mainFrame] loadRequest:
        [NSURLRequest requestWithURL:[NSURL URLWithString:PBPandoraURL]]];
}

- (IBAction)playPause:(id)sender   { [[PandoraControl sharedController] playPause]; }
- (IBAction)nextSong:(id)sender    { [[PandoraControl sharedController] nextSong]; }
- (IBAction)likeSong:(id)sender    { [[PandoraControl sharedController] likeSong]; }
- (IBAction)dislikeSong:(id)sender { [[PandoraControl sharedController] dislikeSong]; }
- (IBAction)raiseVolume:(id)sender { [[PandoraControl sharedController] raiseVolume]; }
- (IBAction)lowerVolume:(id)sender { [[PandoraControl sharedController] lowerVolume]; }
- (IBAction)fullVolume:(id)sender  { [[PandoraControl sharedController] fullVolume]; }
- (IBAction)mute:(id)sender        { [[PandoraControl sharedController] mute]; }

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
        NSView *webNetscapePlugin;
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
            [[PandoraControl sharedController] setWebPlugin: webNetscapePlugin];
        }
        else
        {
            NSLog(@"ERROR: Could not find webNetscapePlugin");
        }
        [[PandoraControl sharedController] setPandoraWindow:pandoraWindow];
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

    [NSURLProtocol registerClass:[PlaylistURLProtocol class]];
    [NSURLProtocol registerClass:[ResourceURLProtocol class]];

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