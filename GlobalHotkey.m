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

// NSUserDefaults constants. The odd format is historic. They used to be autosave defaults from
// ShortcutRecorder, but that functionality was deprectated. We've kept the old keys for backward
// compatibility, since they're written into the config files.
NSString * const PBHotkeyPlayPauseDefaultsKey = @"ShortcutRecorder GlobalPlay";
NSString * const PBHotkeyNextSongDefaultsKey = @"ShortcutRecorder GlobalNext";
NSString * const PBHotkeyLikeSongDefaultsKey = @"ShortcutRecorder GlobalLikeSong";
NSString * const PBHotkeyDislikeSongDefaultsKey = @"ShortcutRecorder GlobalDislikeSong";
NSString * const PBHotkeyRaiseVolumeDefaultsKey = @"ShortcutRecorder GlobalUpVol";
NSString * const PBHotkeyLowerVolumeDefaultsKey = @"ShortcutRecorder GlobalDownVol";
NSString * const PBHotkeyFullVolumeDefaultsKey = @"ShortcutRecorder GlobalFullVol";
NSString * const PBHotkeyMuteDefaultsKey = @"ShortcutRecorder GlobalMute";
NSString * const PBHotkeyPreviousStationDefaultsKey = @"ShortcutRecorder GlobalPreviousStation";
NSString * const PBHotkeyNextStationDefaultsKey = @"ShortcutRecorder GlobalNextStation";
NSString * const PBHotkeyGrowlCurrentSongDefaultsKey = @"ShortcutRecorder GrowlCurrentStation";

NSString * const kModifierFlagsDefaultsKey = @"modifierFlags";
NSString * const kKeyCodeDefaultsKey = @"keyCode";

OSStatus HotKeyEventHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData)
{
    EventHotKeyID hkCom;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
    PBHotKeyID hotKeyId = hkCom.id;

    PlayerController *playerController = [PlayerController sharedController];

    switch(hotKeyId) {
        case kHotKeyNextSong:
            [playerController nextSong:nil];
            break;
        case kHotkeyPlayPause:
            [playerController playPause:nil];
            break;
        case kHotkeyLikeSong:
            [playerController likeSong:nil];
            break;
        case kHotkeyDislikeSong:
            [playerController dislikeSong:nil];
            break;
        case kHotkeyRaiseVolume:
            [playerController raiseVolume:nil];
            break;
        case kHotkeyLowerVolume:
            [playerController lowerVolume:nil];
            break; 
        case kHotkeyFullVolume:
            [playerController fullVolume:nil];
            break; 
        case kHotkeyMute:
            [playerController mute:nil];
            break;
        case kHotkeyPreviousStation:
            [playerController previousStation:nil];
            break;
        case kHotkeyNextStation:
            [playerController nextStation:nil];
            break;
		case kHotkeyGrowlCurrentSong:
			// FIXME: This can cause more than just growling, but GrowlNotification isn't a singleton yet
			[[NSNotificationCenter defaultCenter] postNotificationName:PBSongPlayedNotification
																object:[playerController currentTrack]];
			break;
			
        default:
            NSLog(@"BUG:HotKeyEventHandler got unknown hotKeyId:%d", hotKeyId);
    }
    return noErr;
}

#pragma public interface

@implementation GlobalHotkey

- (id)init 
{
	if (sharedInstance) return sharedInstance;

	if ( self = [super init] ) {
		hotKeysRegistered = false; 
	}
	
	return self;
}

- (void)dealloc 
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

- (KeyCombo)keyComboForKey:(NSString *)key
{
	KeyCombo combo;
	NSDictionary *savedCombo = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	combo.code = [[savedCombo valueForKey:kKeyCodeDefaultsKey] shortValue];
	combo.flags  = [[savedCombo valueForKey:kModifierFlagsDefaultsKey] unsignedIntValue];
	return combo;
}

- (void)setKeyCombo:(KeyCombo)aKeyCombo forKey:(NSString *)aKey
{
	KeyCombo oldCombo = [self keyComboForKey:aKey];
	if (oldCombo.code != aKeyCombo.code	|| oldCombo.flags != aKeyCombo.flags)
	{
		NSDictionary *comboDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithShort:aKeyCombo.code], kKeyCodeDefaultsKey,
								   [NSNumber numberWithUnsignedInt:aKeyCombo.flags], kModifierFlagsDefaultsKey,
								   nil];
		[[NSUserDefaults standardUserDefaults] setObject:comboDict forKey:aKey];
	}
}

- (bool) registerHotkey:(NSString*)HotkeyName withSignature:(int)signature refindex:(int)refindex andHotKeyId:(PBHotKeyID)hkid
{
	EventHotKeyID ghotKeyID; 
    signed short keycode; 
    unsigned int modifiers; 

	KeyCombo combo = [self keyComboForKey:HotkeyName];
	keycode = combo.code;
	modifiers = [self _filteredCocoaToCarbonFlags:combo.flags];
	
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
        
        [self registerHotkey:PBHotkeyPlayPauseDefaultsKey withSignature:'htk1' refindex:0 andHotKeyId:kHotkeyPlayPause]; 
        [self registerHotkey:PBHotkeyNextSongDefaultsKey withSignature:'htk2' refindex:1 andHotKeyId:kHotKeyNextSong]; 
        [self registerHotkey:PBHotkeyLikeSongDefaultsKey withSignature:'htk3' refindex:2 andHotKeyId:kHotkeyLikeSong]; 
        [self registerHotkey:PBHotkeyDislikeSongDefaultsKey withSignature:'htk4' refindex:3 andHotKeyId:kHotkeyDislikeSong]; 
        [self registerHotkey:PBHotkeyRaiseVolumeDefaultsKey withSignature:'htk5' refindex:4 andHotKeyId:kHotkeyRaiseVolume]; 
        [self registerHotkey:PBHotkeyLowerVolumeDefaultsKey withSignature:'htk6' refindex:5 andHotKeyId:kHotkeyLowerVolume]; 
        [self registerHotkey:PBHotkeyFullVolumeDefaultsKey withSignature:'htk7' refindex:6 andHotKeyId:kHotkeyFullVolume]; 
        [self registerHotkey:PBHotkeyMuteDefaultsKey withSignature:'htk8' refindex:7 andHotKeyId:kHotkeyMute]; 
        [self registerHotkey:PBHotkeyPreviousStationDefaultsKey withSignature:'htk9' refindex:8 andHotKeyId:kHotkeyPreviousStation];
        [self registerHotkey:PBHotkeyNextStationDefaultsKey withSignature:'htka' refindex:9 andHotKeyId:kHotkeyNextStation];
        [self registerHotkey:PBHotkeyGrowlCurrentSongDefaultsKey withSignature:'htkb' refindex:10 andHotKeyId:kHotkeyGrowlCurrentSong];
        
        hotKeysRegistered = true; 
        return true; 
    }
    return false;
}

- (bool) unregisterHotkeys
{
  if(hotKeysRegistered == true) { 
	int i; 
    for(i = 0; i < kNumberOfHotkeys; i++) {
      if(eventRefValid[i])
	UnregisterEventHotKey( eventHotKeyRefs[i] );
    }
    hotKeysRegistered = false;
    return true; 
  }
  return false;
}

@end

