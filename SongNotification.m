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

#import "SongNotification.h"

static SongNotification* sharedInstance = nil;

@implementation SongNotification

#pragma public interface

- (id) init 
{
	if (sharedInstance) return sharedInstance;
	
	if ( self = [super init] ) {
	  //notificationView  = [[WebView alloc] initWithFrame: NSMakeRect (0,0,640,480)];
		//[notificationView setWebUIDelegate: self]; 
	}
	
	return self;
}

/*
- (void)webView:(WebView *)sender addMessageToConsole:(NSDictinoary*)dictionary
{
	NSLog(@"Dictionary: %@", dictionary);
}
*/

- (void) dealloc 
{
	[super dealloc];
}

+ (SongNotification*) sharedNotification 
{
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[SongNotification alloc] init];
	return sharedInstance;
}

- (void) loadNotifier: (WebView*) view;
{
  //WebView *view  = [[WebView alloc] initWithFrame: NSMakeRect (0,0,640,480)];
  //  notificationView = view; 
	[[view mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.frozensilicon.net/SongNotification.htm"]]];
	 id win = [view windowScriptObject]; 
	 [win setValue:self forKey:@"SongNotification"];
	 NSLog(@"Notifier loaded");
}

- (void) setDelegate: (id) _delegate 
{
  //	if ([_delegate respondsToSelector:@selector(appleRemoteButton:pressedDown:)]==NO) return;
	
	[_delegate retain];
	[delegate release];
	delegate = _delegate;
}
- (id) delegate {
	return delegate;
}

- (void) sendSongArtistNotification: (NSString*)song byArtist:(NSString*)artist toNotification:(NSString*)notification
{
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
					    song,
                        @"song", 
                        artist,
                        @"artist", 
				        nil];
  [[NSNotificationCenter defaultCenter]	
		postNotificationName: notification object: dict];						
}

- (void) pandoraSongPlayed: (NSString*)song :(NSString*)artist
{
  NSLog( @"pandoraSongPlayed song: %@, artist: %@", song, artist); 
  [self sendSongArtistNotification:song byArtist:artist toNotification:@"PandoraSongPlayed"];
  if(delegate) {
    [delegate pandoraSongPlayed:song :artist];
  }
}

- (void) pandoraSongPaused
{
  //exit(1);
  NSLog( @"pandoraSongPaused"); 
  [[NSNotificationCenter defaultCenter]	
    postNotificationName:@"PandoraSongPaused" object:nil];		    
  if(delegate) {
    [delegate pandoraSongPaused];
  }
}

- (void) pandoraEventsError: (NSString*)errormsg
{
  NSLog( @"pandoraEventsError: %@", errormsg); 
  if(delegate) {
    [delegate pandoraEventsError:errormsg];
  }
}

- (void) pandoraSongEnded: (NSString*)song :(NSString*)artist
{
  NSLog( @"pandoraSongEnded song: %@, artist: %@", song, artist); 
  [self sendSongArtistNotification:song byArtist:artist toNotification:@"PandoraSongEnded"];
  if(delegate) {
    [delegate pandoraSongEnded:song :artist];
  }
  
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }

@end
