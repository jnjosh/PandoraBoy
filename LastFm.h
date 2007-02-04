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

//TODO: change from using LastFMStartConneciton to lastFmLogin
//Implement LastFmSubmit

#import <Cocoa/Cocoa.h>

typedef enum {
  LastFmNotConnected,
  LastFmHandshakeStarted,
  LastFmHandshakeCompleted,
  LastFmHandshakeFailed, 
  LastFmSongUploadStarted,
} LastFmConnectionState; 

@interface SubmitItem : NSObject {
	NSString *song; 
	NSString *artist;
	NSDate *date; 
}
@end 

@interface LastFm : NSObject {
  NSURLConnection *lastFmConnection; 
  NSURLResponse *connectionResponse; 
  NSMutableData *connectionData; 
  LastFmConnectionState connectionState; 

  //Handshake variables
  NSString *submitUrl; // The url to submit songs to. 
  NSString *md5ResponseHash; // Equal to md5(md5(your_password) + challenge) 
  NSString *handshakeError; 
  int interval; // The number of seconds to wait between song submissions
  
  NSMutableArray *submitQueue; 
  NSMutableArray *ongoingSubmissionQueue; 

  NSTimer *currentSongTimer; 
  SubmitItem *currentSong; 
  
  bool paused, songSubmitted; 
  bool submissionEnabled; 
}

+ (LastFm*) sharedLastFm; 

-(void) test; 

- (bool) parseHandshake:(NSString *)handshakeResponse; 

/* MD5 Hashing Methods */ 
-(NSData*) calcMd5:(NSString *)string; 
-(NSString*) calcMd5String:(NSString *)string; 

/* Connection Management Methods */ 
- (void) lastFmLogin:(NSString *)username; 
- (void) lastFmSubmit:(NSString *)tilte byArtist:(NSString *)Artist; 
//- (void) startLastFmConnection:(NSURL *)url; 
- (void) endLastFmConnection; 

/* NSURLConnection Delegate Methods */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
@end
