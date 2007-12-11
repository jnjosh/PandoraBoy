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
#import "GlobalHotkey.h"
#import <WebKit/WebKit.h>
#import "ProxyURLProtocol.h"

extern NSString *PBAppleRemoteEnabled;
NSString *PBAppleRemoteEnabled = @"AppleRemoteEnabled";

static Controller* _sharedInstance = nil;

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
        [self setGrowl:[[GrowlNotification alloc] init]];
        
        _playerController = [[PlayerController alloc] init];
        
        _thumbsUpImage = [[NSImage alloc] initWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_up.png"]];
        _thumbsDownImage = [[NSImage alloc] initWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/thumbs_down.png"]];
        
  }
  return _sharedInstance;
}

- (void) dealloc {
    [_growl release];
    [_playerController release];
    [appleRemote release];
    [_thumbsUpImage release];
    [_thumbsDownImage release];
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

- (GrowlNotification *)growl {
    return [[_growl retain] autorelease];
}

- (void)setGrowl:(GrowlNotification *)value {
    if (_growl != value) {
        [_growl release];
        _growl = [value retain];
    }
}

- (NSImage*)thumbsUpImage {
    return [[_thumbsUpImage retain] autorelease];
}

- (NSImage*)thumbsDownImage {
    return [[_thumbsDownImage retain] autorelease];
}

- (IBAction) displayHelp:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://code.google.com/p/pandoraboy/wiki/FrequentlyAskedQuestions"]];
}

// Accessors

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
    [[PlayerController sharedController] load];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DoNotShowStartupWindow2"]==NO) {
        [startupWindow makeKeyAndOrderFront:self]; 
    }
}
@end

@implementation Controller (AppleRemote)

// delegate methods for AppleRemote -- This might move to another object
- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event 
                   pressedDown: (BOOL) pressedDown 
                 remoteControl: (RemoteControl*) remoteControl
{
    if( pressedDown )
    {
        switch(event) {
            case kRemoteButtonPlus:
                [_playerController raiseVolume:self]; 
                break;
            case kRemoteButtonMinus:
                [_playerController lowerVolume:self];
                break;			
            case kRemoteButtonMenu:
                break;
            case kRemoteButtonMenu_Hold:
                break;
            case kRemoteButtonPlay:
                [_playerController playPause:self];
                break;
            case kRemoteButtonPlay_Hold:
                break;
            case kRemoteButtonRight:	
                [_playerController nextSong:self];
                break;			
            case kRemoteButtonLeft:
                [_playerController likeSong:self];
                break;			
            case kRemoteButtonLeft_Hold:
                break;			
            case kRemoteButtonRight_Hold:
                [_playerController dislikeSong:self];
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