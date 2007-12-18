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
#import "PlayerController.h"

static GlobalHotkey* sharedInstance = nil;

OSStatus HotKeyEventHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
void *userData)
{
    EventHotKeyID hkCom; 
    GetEventParameter(theEvent, kEventParamDirectObject,typeEventHotKeyID,NULL,
    sizeof(hkCom),NULL,&hkCom);
    PandoraHotKeyIds hotKeyId = hkCom.id; 

    // Is there a better way to get to the playerController?
    PlayerController *playerController = [PlayerController sharedController];
      
    switch(hotKeyId) {
        
        case NEXT_SONG:
            [playerController nextSong:nil];
            break;
        case PLAY_PAUSE:
            [playerController playPause:nil];
            break;
        case LIKE_SONG:
            [playerController likeSong:nil];    
            break;
        case DISLIKE_SONG:
            [playerController dislikeSong:nil];
            break; 
        case RAISE_VOLUME:
            [playerController raiseVolume:nil];
            break; 
        case LOWER_VOLUME:
            [playerController lowerVolume:nil];
            break; 
        case FULL_VOLUME:
            [playerController fullVolume:nil];
            break; 
        case MUTE:
            [playerController mute:nil];
            break;
        case PREVIOUS_STATION:
            [playerController previousStation:nil];
            break;
        case NEXT_STATION:
            [playerController nextStation:nil];
            break;
        default:
            NSLog(@"BUG:HotKeyEventHandler got unknown hotKeyId:%d", hotKeyId);
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
	modifiers = [self _filteredCocoaToCarbonFlags:modifiers];
	
	// Go through and register the hotkeys we use one by one. 
	if(!(keycode == 0 || keycode == 1) ) {
	  ghotKeyID.signature = signature;
	  ghotKeyID.id = hkid; 
	  RegisterEventHotKey(keycode, modifiers, ghotKeyID, GetApplicationEventTarget(), 0, &eventHotKeyRefs[refindex]);
	  eventRefValid[refindex] = true;
	  return true;
	}
	else {
	  eventRefValid[refindex] = false;
	  return false;
	}
}

- (bool) registerHotkeys
{
    if(hotKeysRegistered == false) {
        
        [self registerHotkey:@"ShortcutRecorder GlobalPlay" withSignature:'htk1' refindex:0 andHotKeyId:PLAY_PAUSE]; 
        [self registerHotkey:@"ShortcutRecorder GlobalNext" withSignature:'htk2' refindex:1 andHotKeyId:NEXT_SONG]; 
        [self registerHotkey:@"ShortcutRecorder GlobalLikeSong" withSignature:'htk3' refindex:2 andHotKeyId:LIKE_SONG]; 
        [self registerHotkey:@"ShortcutRecorder GlobalDislikeSong" withSignature:'htk4' refindex:3 andHotKeyId:DISLIKE_SONG]; 
        [self registerHotkey:@"ShortcutRecorder GlobalUpVol" withSignature:'htk5' refindex:4 andHotKeyId:RAISE_VOLUME]; 
        [self registerHotkey:@"ShortcutRecorder GlobalDownVol" withSignature:'htk6' refindex:5 andHotKeyId:LOWER_VOLUME]; 
        [self registerHotkey:@"ShortcutRecorder GlobalFullVol" withSignature:'htk7' refindex:6 andHotKeyId:FULL_VOLUME]; 
        [self registerHotkey:@"ShortcutRecorder GlobalMute" withSignature:'htk8' refindex:7 andHotKeyId:MUTE]; 
        [self registerHotkey:@"ShortcutRecorder GlobalPreviousStation" withSignature:'htk9' refindex:8 andHotKeyId:PREVIOUS_STATION];
        [self registerHotkey:@"ShortcutRecorder GlobalNextStation" withSignature:'htka' refindex:9 andHotKeyId:NEXT_STATION];
        
        hotKeysRegistered = true; 
        return true; 
    }
    return false;
}

- (bool) unregisterHotkeys
{
  if(hotKeysRegistered == true) { 
	int i; 
    for(i = 0; i < NUM_HOTKEYS; i++) {
      if(eventRefValid[i])
	UnregisterEventHotKey( eventHotKeyRefs[i] );
    }
    hotKeysRegistered = false;
    return true; 
  }
  return false;
}

@end

