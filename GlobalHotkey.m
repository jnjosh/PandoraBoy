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

#import "GlobalHotkey.h"
#import "PandoraControl.h"

static GlobalHotkey* sharedInstance = nil;

typedef enum HotKeyIds {
  NEXT_SONG,
  PLAY_PAUSE,
  LIKE_SONG,
  DISLIKE_SONG,
  RAISE_VOLUME,
  LOWER_VOLUME,
  FULL_VOLUME,
  MUTE
} PandoraHotKeyIds; 

OSStatus HotKeyEventHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
void *userData)
{
  NSLog(@"In Hotkey Handler");
  EventHotKeyID hkCom; 
  GetEventParameter(theEvent, kEventParamDirectObject,typeEventHotKeyID,NULL,
		    sizeof(hkCom),NULL,&hkCom);
  PandoraHotKeyIds hotKeyId = hkCom.id; 

  switch(hotKeyId) {
  case NEXT_SONG:
    [[PandoraControl sharedController] nextSong];
    break;
  case PLAY_PAUSE:
    [[PandoraControl sharedController] playPause];
    break;
  case LIKE_SONG:
    [[PandoraControl sharedController] likeSong];    
    break;
  case DISLIKE_SONG:
    [[PandoraControl sharedController] dislikeSong];
    break; 
  case RAISE_VOLUME:
    [[PandoraControl sharedController] raiseVolume];
    break; 
  case LOWER_VOLUME:
    [[PandoraControl sharedController] lowerVolume];
    break; 
  case FULL_VOLUME:
    [[PandoraControl sharedController] fullVolume];
    break; 
  case MUTE:
    [[PandoraControl sharedController] mute];
    break; 

  }
  return noErr;
}

#pragma public interface

@implementation GlobalHotkey

- (id) init 

{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
	  hotKeysRegistered = false; 
	}
	
	return self;
}

- (void) dealloc 
{
	[super dealloc];
}

+ (GlobalHotkey*) sharedHotkey 
{
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[GlobalHotkey alloc] init];
	return sharedInstance;
}

- (void) setupDefaults
{
  NSMutableDictionary *userDefaultsValuesDict = [NSMutableDictionary
						  dictionary];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:49]
			  forKey:@"GlobalHotKeyCodePlay"]; //Space
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey+optionKey]
			  forKey:@"GlobalModifiersPlay"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:124] 
			  forKey:@"GlobalHotKeyCodeNext"]; // Right-arrow
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey+optionKey]
			  forKey:@"GlobalModifiersNext"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:126] 
			  forKey:@"GlobalHotKeyCodeLikeSong"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey+optionKey]
			  forKey:@"GlobalModifiersLikeSong"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:125] 
			  forKey:@"GlobalHotKeyCodeDislikeSong"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey+optionKey]
			  forKey:@"GlobalModifiersDislikeSong"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999] 
			  forKey:@"GlobalHotKeyCodeUpVol"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999]
			  forKey:@"GlobalModifiersUpVol"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999] 
			  forKey:@"GlobalHotKeyCodeDownVol"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999]
			  forKey:@"GlobalModifiersDownVol"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999] 
			  forKey:@"GlobalHotKeyCodeFullVol"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999]
			  forKey:@"GlobalModifiersFullVol"];

  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999] 
			  forKey:@"GlobalHotKeyCodeMuteVol"];
  [userDefaultsValuesDict setObject:[NSNumber numberWithInt:-999]
			  forKey:@"GlobalModifiersMuteVol"];


  [[NSUserDefaults standardUserDefaults] registerDefaults:
		  userDefaultsValuesDict];      //Register the defaults
  [[NSUserDefaults standardUserDefaults] synchronize];  //And sync them
}

// [FIXME] This code is duplicated from ShortcutRecorderCell and should be removed!


- (void) registerHotkeyHandler
{
  //Register the Hotkeys
  EventTypeSpec eventType;
  eventType.eventClass=kEventClassKeyboard;
  eventType.eventKind=kEventHotKeyPressed;
  
  InstallApplicationEventHandler(&HotKeyEventHandler,1,&eventType,NULL,NULL);
}

// [FIXME] This code was lifted from ShortcutRecorderCell (ShortcutRecorder) and shouldn't exist in both places
// Move the code into a common place where both can use it. 
- (unsigned int)_filteredCocoaToCarbonFlags:(unsigned int)cocoaFlags
{
	unsigned int carbonFlags = 0;

	if (cocoaFlags & NSCommandKeyMask) carbonFlags += cmdKey;
	if (cocoaFlags & NSAlternateKeyMask) carbonFlags += optionKey;
	if (cocoaFlags & NSControlKeyMask) carbonFlags += controlKey;
	if (cocoaFlags & NSShiftKeyMask) carbonFlags += shiftKey;
	
	return carbonFlags;
}

- (bool) registerHotkey:(NSString*)HotkeyName withSignature:(int)signature refindex:(int)refindex andHotKeyId:(PandoraHotKeyIds)hkid
{
	EventHotKeyID ghotKeyID; 
    signed short keycode; 
    unsigned int modifiers; 

	id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
	NSDictionary *savedCombo = [values valueForKey:HotkeyName];
		
	keycode = [[savedCombo valueForKey: @"keyCode"] shortValue];
	modifiers  = [[savedCombo valueForKey: @"modifierFlags"] unsignedIntValue];

	NSLog(@"keycode %d", keycode);
	NSLog(@"flags %d", modifiers);
	modifiers = [self _filteredCocoaToCarbonFlags:modifiers];
	// Go through and register the hotkeys we use one by one. 
	if(!(keycode == 0 || keycode == 1) ) {
	  ghotKeyID.signature = signature;
	  ghotKeyID.id = hkid; 
	  RegisterEventHotKey(keycode, modifiers, ghotKeyID, GetApplicationEventTarget(), 0, &eventHotKeyRefs[refindex]);
	  eventRefValid[0] = true;
	  return true;
	}
	else {
	  eventRefValid[0] = false;
	  return false;
	}
}

- (bool) registerHotkeys
{
  if(hotKeysRegistered == false) {
 
	[self registerHotkey:@"GlobalPlay" withSignature:'htk1' refindex:0 andHotKeyId:PLAY_PAUSE]; 
	[self registerHotkey:@"GlobalNext" withSignature:'htk2' refindex:1 andHotKeyId:NEXT_SONG]; 
	[self registerHotkey:@"GlobalLikeSong" withSignature:'htk3' refindex:2 andHotKeyId:LIKE_SONG]; 
	[self registerHotkey:@"GlobalDislikeSong" withSignature:'htk4' refindex:3 andHotKeyId:DISLIKE_SONG]; 
	[self registerHotkey:@"GlobalUpVol" withSignature:'htk5' refindex:4 andHotKeyId:RAISE_VOLUME]; 
	[self registerHotkey:@"GlobalDownVol" withSignature:'htk6' refindex:5 andHotKeyId:LOWER_VOLUME]; 
	//[self registerHotkey:@"GlobalFullVol" withSignature:'htk7' refindex:6 andHotKeyId:FULL_VOLUME]; 
	//[self registerHotkey:@"GlobalMuteVol" withSignature:'htk8' refindex:7 andHotKeyId:MUTE]; 
	
	hotKeysRegistered = true; 
	return true; 
  }
  return false;
}

- (bool) unregisterHotkeys
{
  if(hotKeysRegistered == true) { 
	int i; 
    for(i = 0; i < 8; i++) {
      if(eventRefValid[i])
	UnregisterEventHotKey( eventHotKeyRefs[i] );
    }
    hotKeysRegistered = false;
    return true; 
  }
  return false;
}

@end

