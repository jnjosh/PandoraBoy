//
//  HotkeyPreferencesController.m
//  PandoraBoy
//
//  Created by rnapier on 8/16/09.
//  Copyright 2009 My Company. All rights reserved.
//

#import "HotkeyPreferencesController.h"
#import "GlobalHotkey.h"
#import <ShortcutRecorder/SRRecorderControl.h>

@interface HotkeyPreferencesController ()
@property (nonatomic, readwrite, retain) NSDictionary *controlForKey;
@end

@implementation HotkeyPreferencesController
@synthesize playPauseControl = _playPauseControl;
@synthesize nextSongControl = _nextSongControl;
@synthesize previousStationControl = _previousStationControl;
@synthesize nextStationControl = _nextStationControl;
@synthesize raiseVolumeControl = _raiseVolumeControl;
@synthesize lowerVolumeControl = _lowerVolumeControl;
@synthesize fullVolumeControl = _fullVolumeControl;
@synthesize muteControl = _muteControl;
@synthesize likeSongControl = _likeSongControl;
@synthesize dislikeSongControl = _dislikeSongControl;
@synthesize growlCurrentSongControl = _growlCurrentSongControl;
@synthesize controlForKey = _controlForKey;

- (void)awakeFromNib
{	
	self.controlForKey = [NSDictionary dictionaryWithObjectsAndKeys:
						  self.playPauseControl, PBHotkeyPlayPauseDefaultsKey,
						  self.nextSongControl, PBHotkeyNextSongDefaultsKey,
						  self.previousStationControl, PBHotkeyPreviousStationDefaultsKey,
						  self.nextStationControl, PBHotkeyNextStationDefaultsKey,
						  self.raiseVolumeControl, PBHotkeyRaiseVolumeDefaultsKey,
						  self.lowerVolumeControl, PBHotkeyLowerVolumeDefaultsKey,
						  self.fullVolumeControl, PBHotkeyFullVolumeDefaultsKey,
						  self.muteControl, PBHotkeyMuteDefaultsKey,
						  self.likeSongControl, PBHotkeyLikeSongDefaultsKey,
						  self.dislikeSongControl, PBHotkeyDislikeSongDefaultsKey,
                          self.growlCurrentSongControl, PBHotkeyGrowlCurrentSongDefaultsKey,
						  nil];
	
	GlobalHotkey *hk = [GlobalHotkey sharedHotkey];
	for (NSString *key in [self.controlForKey allKeys])
	{
		[[self.controlForKey objectForKey:key] setKeyCombo:[hk keyComboForKey:key]];
	}
}

- (void) dealloc
{
	[_playPauseControl release];
	_playPauseControl = nil;
	
	[_nextSongControl release];
	_nextSongControl = nil;
	
	[_previousStationControl release];
	_previousStationControl = nil;
	
	[_nextStationControl release];
	_nextStationControl = nil;
	
	[_raiseVolumeControl release];
	_raiseVolumeControl = nil;
	
	[_lowerVolumeControl release];
	_lowerVolumeControl = nil;
	
	[_fullVolumeControl release];
	_fullVolumeControl = nil;
	
	[_muteControl release];
	_muteControl = nil;
	
	[_likeSongControl release];
	_likeSongControl = nil;
	
	[_dislikeSongControl release];
	_dislikeSongControl = nil;
	
    [_growlCurrentSongControl release];
    _growlCurrentSongControl = nil;
    
	[_controlForKey release];
	_controlForKey = nil;
    
	[super dealloc];
}

- (NSString *)keyForControl:(SRRecorderControl *)aControl
{
	NSArray *keys = [self.controlForKey allKeysForObject:aControl];
	if ([keys count] == 1)
	{
		return [keys objectAtIndex:0];
	}
	else
	{
		NSAssert2(NO, @"Unexpected control (%@) without key: %@", aControl, self.controlForKey);
		return nil;
	}
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	[[GlobalHotkey sharedHotkey] setKeyCombo:newKeyCombo forKey:[self keyForControl:aRecorder]];
}

@end
