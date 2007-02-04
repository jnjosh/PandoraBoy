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

#import "PandoraControl.h"
#import "GrowlNotification.h"
//#import <AppleEvents.h>
#import <Carbon/Carbon.h>

static PandoraControl* sharedInstance = nil;

@implementation PandoraControl

- (id) init 
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
	  controlDisabled = false; 
	}
	
	return self;
}

- (void) dealloc 
{
	[super dealloc];
}

+ (PandoraControl*) sharedController
{
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[PandoraControl alloc] init];
	return sharedInstance;
}

- (void) setControlDisabled 
{
  controlDisabled = true;
}

- (void) setControlEnabled 
{
  controlDisabled = false;
}

- (void) setWebPlugin: (id) webPlugin
{
    webNetscapePlugin = webPlugin; 
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
    [webNetscapePlugin sendEvent:(NSEvent *)&myrecord];
  
    //Make it a keyUp EventRecord and resend it
    myrecord.what = keyUp;
	[webNetscapePlugin sendEvent:(NSEvent *)&myrecord];
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

- (void) nextSong
{
  //Right-arrow
  [self sendKeyPress: 124];  
}

- (void) playPause
{
  //Space-bar
  [self sendKeyPress: 49];
}

- (void) likeSong
{
  //Plus
  if([self sendKeyPress: 69])
    [[GrowlNotification sharedNotification] pandoraLikeSong];
}

- (void) dislikeSong
{
  //Minus
  if([self sendKeyPress: 78])
    [[GrowlNotification sharedNotification] pandoraDislikeSong];
}

- (void) raiseVolume
{
  //Up-Arrow
  int i;
  for(i = 0; i < 4; i++)
	[self sendKeyPress: 126];		
}

- (void) lowerVolume
{
  //Down-Arrow -- currently we don't get multiple keypresses --- so send a bunch of keypress events to make up for it
  int i;
  for(i = 0; i < 4; i++)
	[self sendKeyPress: 125];	
}

- (void) fullVolume
{
  //Shift + Up-Arrow
  [self sendKeyPress: 126 withModifiers: shiftKey];
}

- (void) mute
{
  //Shift + Down-Arrow
  [self sendKeyPress: 125 withModifiers: shiftKey]; 
}
@end
