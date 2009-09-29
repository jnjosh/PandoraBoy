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

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <ShortcutRecorder/SRCommon.h>

// If you add new hotkeys, don't forget to add them in HotkeyPreferencesController
extern NSString * const PBHotkeyPlayPauseDefaultsKey;
extern NSString * const PBHotkeyNextSongDefaultsKey;
extern NSString * const PBHotkeyLikeSongDefaultsKey;
extern NSString * const PBHotkeyDislikeSongDefaultsKey;
extern NSString * const PBHotkeyRaiseVolumeDefaultsKey;
extern NSString * const PBHotkeyLowerVolumeDefaultsKey;
extern NSString * const PBHotkeyFullVolumeDefaultsKey;
extern NSString * const PBHotkeyMuteDefaultsKey;
extern NSString * const PBHotkeyPreviousStationDefaultsKey;
extern NSString * const PBHotkeyNextStationDefaultsKey;
extern NSString * const PBHotkeyGrowlCurrentSongDefaultsKey;

typedef enum _PBHotKeyID {
    kHotKeyNextSong,
    kHotkeyPlayPause,
    kHotkeyLikeSong,
    kHotkeyDislikeSong,
    kHotkeyRaiseVolume,
    kHotkeyLowerVolume,
    kHotkeyFullVolume,
    kHotkeyMute,
    kHotkeyPreviousStation,
    kHotkeyNextStation,
	kHotkeyGrowlCurrentSong,
	kNumberOfHotkeys
} PBHotKeyID; 

@interface GlobalHotkey : NSObject {
  BOOL hotKeysRegistered;
  BOOL eventRefValid[kNumberOfHotkeys];
  EventHotKeyRef eventHotKeyRefs[kNumberOfHotkeys];
}

+ (GlobalHotkey*)sharedHotkey; 

- (KeyCombo)keyComboForKey:(NSString *)key;
- (void)setKeyCombo:(KeyCombo)aKeyCombo forKey:(NSString *)aKey;

- (void)registerHotkeyHandler;
- (bool)registerHotkeys;
- (bool)unregisterHotkeys;
@end

