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

typedef enum HotKeyIds {
    NEXT_SONG,
    PLAY_PAUSE,
    LIKE_SONG,
    DISLIKE_SONG,
    RAISE_VOLUME,
    LOWER_VOLUME,
    FULL_VOLUME,
    MUTE,
    PREVIOUS_STATION,
    NEXT_STATION
} PandoraHotKeyIds; 

// FIXME: Curse my lousy C, how do I get this from the enum?
#define NUM_HOTKEYS 10

@interface GlobalHotkey : NSObject {
  bool hotKeysRegistered; 
  bool eventRefValid[NUM_HOTKEYS];
  EventHotKeyRef eventHotKeyRefs[NUM_HOTKEYS];
}

+ (GlobalHotkey*) sharedHotkey; 

- (KeyCombo)keyComboForKey:(NSString *)key;
- (void)setKeyCombo:(KeyCombo)aKeyCombo forKey:(NSString *)aKey;

- (void) registerHotkeyHandler;
- (bool) registerHotkeys; 
- (bool) unregisterHotkeys; 
@end

