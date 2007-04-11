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
#import "PandoraControl.h"

// FIXME? This would all be much shorter with a superclass that looked up
//        command class to selector mappings in a dictionary. But maybe that's
//        overengineering the problem to avoid a few dozen lines of code.

@implementation playPauseCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] playPause];
	return self;
}
@end

@implementation skipCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] nextSong];
	return self;
}
@end

@implementation thumbsUpCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] likeSong];
	return self;
}
@end

@implementation thumbsDownCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] dislikeSong];
	return self;
}
@end

@implementation raiseVolumeCommand
-(id)performDefaultImplementation
{
	// FIXME: This should take an (optional?) "count" parameter
	[[PandoraControl sharedController] raiseVolume];
	return self;
}
@end

@implementation lowerVolumeCommand
-(id)performDefaultImplementation
{
	// FIXME: This should take an (optional?) "count" parameter
	[[PandoraControl sharedController] lowerVolume];
	return self;
}
@end

@implementation fullVolumeCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] fullVolume];
	return self;
}
@end

@implementation muteCommand
-(id)performDefaultImplementation
{
	[[PandoraControl sharedController] mute];
	return self;
}
@end

@implementation NSApplication (PandoraBoyScripting)
- (Track *)currentTrack {
    return [[SongNotification sharedNotification] currentTrack];
}

- (NSArray *)tracks {
    return [[SongNotification sharedNotification] tracks];
}

- (int)playerState {
    return [[SongNotification sharedNotification] playerState];
}

@end