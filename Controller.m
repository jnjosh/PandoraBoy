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
#import "AppleRemote.h"
//#import "LastFm.h"
#import "WebViewProxy.h"
#import <WebKit/WebKit.h>

extern NSString *PBPandoraURL;
NSString *PBPandoraURL = @"http://www.pandora.com?cmd=mini";

extern int PBPlayPauseMenuItemTag;
int PBPlayPauseMenuItemTag = 1;

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
			    forKey:@"CheckForUpdates"];
    [userDefaultsValuesDict setObject:@"YES"
			    forKey:@"AppleRemoteEnabled"];
    [userDefaultsValuesDict setObject:@"NO"
			    forKey:@"DoNotShowStartupWindow2"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:
		      userDefaultsValuesDict];      //Register the defaults
    [[NSUserDefaults standardUserDefaults] synchronize];  //And sync them
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"AppleRemoteEnabled"]==YES) {
		[[AppleRemote sharedRemote] setOpenInExclusiveMode:false];
		[[AppleRemote sharedRemote] setListeningToRemote:true];
	}
  }

  return self;
}

- (void)awakeFromNib
{

  //[[LastFm sharedLastFm] test]; 

  [[GlobalHotkey sharedHotkey] registerHotkeyHandler];
  [[GlobalHotkey sharedHotkey] registerHotkeys];
  
  if([[NSUserDefaults standardUserDefaults] boolForKey:@"CheckForUpdates"]==YES) {
    [self checkVersionNumber:self];
  }

  [[AppleRemote sharedRemote] setDelegate: self];

  [webView setPolicyDelegate:self];
  [webView setUIDelegate:self];
}

// delegate methods for AppleRemote
- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown 
{
	switch(buttonIdentifier) {
		case kRemoteButtonVolume_Plus:
		  //if (pressedDown)
		  //  [[PandoraControl sharedController] raiseVolume]; 
		  break;
		case kRemoteButtonVolume_Minus:
		  //if (pressedDown)
		  //  [[PandoraControl sharedController] lowerVolume]; 
		  break;			
/*		case kRemoteButtonMenu:
			buttonName = @"Menu";
			if (pressedDown) pressed = @"(down)"; else pressed = @"(up)";
			break; */			
		case kRemoteButtonPlay:
		  if (pressedDown)
		    [[PandoraControl sharedController] playPause]; 
		  break;			
		case kRemoteButtonRight:	
		  if (pressedDown)
		    [[PandoraControl sharedController] nextSong]; 
		  break;			
		case kRemoteButtonLeft:
		  if (pressedDown)
		    [[PandoraControl sharedController] likeSong];
			break;			
		case kRemoteButtonRight_Hold:
		  if (pressedDown)
		    [[PandoraControl sharedController] dislikeSong];
			break;	
		case kRemoteButtonLeft_Hold:
			break;			
		case kRemoteButtonPlay_Sleep:
			break;			
		default:
			NSLog(@"Unmapped event for button %d", buttonIdentifier); 
			break;
	}
}

- (void) loadPandora 
{
    [[webView mainFrame] loadRequest:
        [NSURLRequest requestWithURL:[NSURL URLWithString:PBPandoraURL]]];
}

- (IBAction)playPause:(id)sender {
    [[PandoraControl sharedController] playPause];
}

- (IBAction)nextSong:(id)sender {
    [[PandoraControl sharedController] nextSong];
}

- (IBAction)likeSong:(id)sender {
    [[PandoraControl sharedController] likeSong];
}

- (IBAction)dislikeSong:(id)sender {
    [[PandoraControl sharedController] dislikeSong];
}

- (IBAction)raiseVolume:(id)sender {
    [[PandoraControl sharedController] raiseVolume];
}

- (IBAction)lowerVolume:(id)sender {
    [[PandoraControl sharedController] lowerVolume];
}

- (IBAction)fullVolume:(id)sender {
    [[PandoraControl sharedController] fullVolume];
}

- (IBAction)mute:(id)sender {
    [[PandoraControl sharedController] mute];
}

- (IBAction) refreshPandora:(id)sender 
{
  [[webView mainFrame] reload];
}

- (IBAction) displayHelp:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.frozensilicon.net/support.html"]];  //Open up the FZ website
}

- (void)webView:(WebView *)sender setFrame:(NSRect)frame
{
  //We do nothing in the setFrame function to prevent Pandora from changing the window size using javascript. 
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{

	NSLog(@"TEST %@", [[request URL] absoluteString]);
	NSLog(@"Output %x", [request URL]);
	if([request URL] != 0) {
		[[NSWorkspace sharedWorkspace] openURL: [request URL]];
		return nil;
	}
	return [[WebViewProxy alloc] init];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
  id webNetscapePlugin = [[[webView hitTest:NSZeroPoint] subviews] objectAtIndex:0];
  [pandoraWindow makeFirstResponder: webNetscapePlugin];
  [[PandoraControl sharedController] setWebPlugin: webNetscapePlugin];
}

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder
{
  // Not sure if this is the best way to stop the firstresponder from changing. We just don't respond to the makeFirstResponder request. Eww
}

- (IBAction) checkVersionNumber:(id)sender 
{
  //Check Version Number online
  //User wants us to check version and update if we need to
	
  NSString *curNum = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSDictionary *webDict = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:@"http://www.frozensilicon.net/version.xml"]];
  NSString *newNum = [webDict valueForKey:@"PandoraBoy"];
		
  int button = 0;
		
  if ( newNum == nil )
    {
      //Error accessing website
      NSBeep();
      [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
      NSRunAlertPanel(@"Could not check for update", @"An error arose while attempting to check for a new version of PandoraBoy.  PandoraBoy may be temporarily unavailable or your network may be down.", @"OK", nil, nil);
    }
  else if ( [newNum isEqualTo: curNum] )
    {
      //We are up to date.
      if(sender!=self) {
	//User clicked button. We should provide some response.
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSRunAlertPanel(@"Software is Up-To-Date", @"You have the most recent version of PandoraBoy.", @"OK", nil, nil);
      }
    }
  else
    {
      [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
      button = NSRunAlertPanel(@"New Version Found", @"A new version of PandoraBoy is available.", @"OK", @"Cancel", nil);
			
      if (NSOKButton == button)
	{
	  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.frozensilicon.net"]];  //Open up the FZ website
	}
    }
}


@end


@implementation Controller(ApplicationNotifications)

-(void)applicationDidFinishLaunching: (NSNotification*)notification
{
  //  [[PandoraControl sharedController] quit];
  //[pandoraWindow makeFirstResponder: webView];	
	
	// FIXME: This doesn't currently work and is generating warnings.
	// http://lists.apple.com/archives/webkitsdk-dev/2006/Sep/msg00010.html
	//[webView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:YES];
    //	[notificationView _setDashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns to:YES];
    //	
    //	NSLog(@"_dashboardBehavoir: %d", [webView _dashboardBehavior:WebDashboardBehaviorAlwaysSendActiveNullEventsToPlugIns]);

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
@end
