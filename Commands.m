/****************************************************************************
*  Copyright 2007 Rob Napier                                               *
*  rnapier@employees.org                                                   *
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
#import "Commands.h"
#import "Controller.h"
#import "Playlist.h"
#import "PlayerController.h"
#import "StationList.h"

// FIXME? This would all be much shorter with a superclass that looked up
//        command class to selector mappings in a dictionary. But maybe that's
//        overengineering the problem to avoid a few dozen lines of code.

@implementation playPauseCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] playPause:self];
	return self;
}
@end

@implementation skipCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] nextSong:self];
	return self;
}
@end

@implementation thumbsUpCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] likeSong:self];
	return self;
}
@end

@implementation thumbsDownCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] dislikeSong:self];
	return self;
}
@end

@implementation raiseVolumeCommand
-(id)performDefaultImplementation
{
	// FIXME: This should take an (optional?) "count" parameter
	[[PlayerController sharedController] raiseVolume:self];
	return self;
}
@end

@implementation lowerVolumeCommand
-(id)performDefaultImplementation
{
	// FIXME: This should take an (optional?) "count" parameter
	[[PlayerController sharedController] lowerVolume:self];
	return self;
}
@end

@implementation fullVolumeCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] fullVolume:self];
	return self;
}
@end

@implementation muteCommand
-(id)performDefaultImplementation
{
	[[PlayerController sharedController] mute:self];
	return self;
}
@end

@implementation createStationCommand
-(id)performDefaultImplementation
{
	NSString *searchText = [[self evaluatedArguments] objectForKey:@""];
	[[PlayerController sharedController] createStationFromSearchText:searchText];
	return self;
}
@end

@implementation NSApplication (PandoraBoyScripting)
- (Track *)currentTrack {
    return [[Playlist sharedPlaylist] currentTrack];
}

- (NSArray *)tracks {
    return [[Playlist sharedPlaylist] playedTracks];
}

- (NSArray *)stations {
    return [[StationList sharedStationList] stationList];
}

- (int)playerState {
    return [[PlayerController sharedController] playerState];
}

- (Station *)currentStation {
    return [[PlayerController sharedController] currentStation];
}

- (void)setCurrentStation:(Station*)station {
    [[PlayerController sharedController] setStation:station];
}

- (Station *)nextStation {
    return [[StationList sharedStationList] nextStation];
}

- (Station *)previousStation {
    return [[StationList sharedStationList] previousStation];
}

- (Station *)quickMixStation {
    return [[StationList sharedStationList] quickMixStation];
}

@end