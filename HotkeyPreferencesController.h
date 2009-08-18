//
//  HotkeyPreferencesController.h
//  PandoraBoy
//
//  Created by Rob Napier on 8/16/09.
//  Copyright 2009 Rob Napier. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SRRecorderControl;

@interface HotkeyPreferencesController : NSObject 
{
	SRRecorderControl *_playPauseControl;
	SRRecorderControl *_nextSongControl;
	SRRecorderControl *_previousStationControl;
	SRRecorderControl *_nextStationControl;
	SRRecorderControl *_raiseVolumeControl;
	SRRecorderControl *_lowerVolumeControl;
	SRRecorderControl *_fullVolumeControl;
	SRRecorderControl *_muteControl;
	SRRecorderControl *_likeSongControl;
	SRRecorderControl *_dislikeSongControl;
	NSDictionary *_controlForKey;
}

@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *playPauseControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *nextSongControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *previousStationControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *nextStationControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *raiseVolumeControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *lowerVolumeControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *fullVolumeControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *muteControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *likeSongControl;
@property (nonatomic, readwrite, retain) IBOutlet SRRecorderControl *dislikeSongControl;

@end
