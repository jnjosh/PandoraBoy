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

#import "LastFm.h"
#include <openssl/md5.h>

@interface SubmitItem : NSObject {
	NSString *song; 
	NSString *artist;
	NSDate *date; 
}
@end 

@implementation SubmitItem
- (id) initWithSong:initSong byArtist:initArtist atDate:initDate {
	if( self = [super init] ) {	
		song = initSong;
		artist = initArtist;
		date = initDate; 
	}
	return self;
}

- (NSString*) getSong {
	return song;
}

- (NSString *) getArtist {
	return artist; 
}

- (NSString *) getDate {
	return date; 
}
@end	

@implementation LastFm

static LastFm* sharedInstance=nil;

- (id) init 
{
  if( self = [super init] ) {
    connectionState = LastFmNotConnected; 
	
	submitQueue = [[NSMutableArray alloc] initWithCapacity:5];
	ongoingSubmissionQueue = [[NSMutableArray alloc] initWithCapacity:5]; 
	
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(notifiedSongPlayed:)
		name: @"PandoraSongPlayed" object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(notifiedSongEnded:)
		name: @"PandoraSongEnded" object: nil];
  }
  return self; 
}

- (void) dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
			name: @"PandoraSongPlayed" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
		name: @"PandoraSongEnded" object: nil];

	[submitQueue release];
	[ongoingSubmissionQueue release];
	
	[super dealloc];
 }

- (void)notifiedSongPlayed:(NSNotification *)notification

{
	NSDictionary *dict = [notification object];
	NSString *artist = [dict objectForKey:@"artist"];
	NSString *song = [dict objectForKey:@"song"];
	NSLog( @"Notified: pandoraSongPlayed song: %@, artist: %@", song, artist); 
	if(connectionState == LastFmHandshakeCompleted) {
		[submitQueue addObject:[[SubmitItem alloc] initWithSong:song byArtist:artist atDate:[NSDate date]]];
		[self scheduleSubmit];
	}
		
}

- (void)scheduleSubmit
{
	SubmitItem *song = [submitQueue objectAtIndex:0];
	[submitQueue removeObject:song];
	[self lastFmSubmit:[song getSong] byArtist:[song getArtist]];
	[song release];
}

- (void)notifiedSongEnded:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	NSString *artist = [dict objectForKey:@"artist"];
	NSString *song = [dict objectForKey:@"song"];
	NSLog( @"Notified: pandoraSongEnded song: %@, artist: %@", song, artist); 

}

+ (LastFm*) sharedLastFm 
{
  if (sharedInstance == nil) {
    sharedInstance = [[self alloc] init];
  }
  return sharedInstance;
}

- (void) test
{
  //[self startLastFmConnection:[NSURL URLWithString:@"http://post.audioscrobbler.com/?hs=true&p=1.1&c=tst&v=1.0&u=microchip2"]];
  [self lastFmLogin:@"microchip2"];
  //NSLog(@"String Hash: %@", [self calcMd5String:@"bob"]);
}

- (bool) parseHandshake:(NSString *)handshakeResponse
{
  // This function parses the possible handshake responses of the audioscobbler 1.1 protocol 
  // which is described in: http://www.audioscrobbler.net/wiki/Protocol1.1.merged

  // Make sure to set the enum when return true or false;   

  NSScanner *theScanner = [NSScanner scannerWithString:handshakeResponse];
  //NSCharacterSet *newlineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
  NSCharacterSet *newlineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *responseStatus;	
  NSString *md5Pwd = [self calcMd5String:@"august"]; 

  if([theScanner scanUpToCharactersFromSet:newlineSet intoString:&responseStatus])
    if([responseStatus compare:@"UPTODATE"] == NSOrderedSame) {
      NSString *md5Challenge, *tmpSubmitUrl; 
      int tmpInterval; 
      if([theScanner scanUpToCharactersFromSet:newlineSet intoString:&md5Challenge] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:&tmpSubmitUrl] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:NULL] && 
	 [theScanner scanInt:&tmpInterval]) {
	
	// Now that we know the response was valid ... copy our tmp variables into 
	// the proper member variables 
	submitUrl = [[NSString alloc] initWithString:tmpSubmitUrl];
	//NSString *prehash = ;
	/*NSLog(@"prehash:%@", prehash);
	NSString *md5PwdHash = [self calcMd5String:[md5Challenge stringByAppendingString:md5Pwd]];
	NSLog(@"md5PwdHash:%@", md5PwdHash);
	*/
	md5ResponseHash = [self calcMd5String:[md5Pwd stringByAppendingString:md5Challenge]];
	NSLog(@"md5ResponseHash:%@", md5ResponseHash);
	
	interval = tmpInterval; 
	connectionState = LastFmHandshakeCompleted; 
	NSLog(@"Got a vaild UPTODATE handshake response");
	//[self lastFmSubmit:@"Holiday" byArtist:@"Weezer"];
	return true; 
      }
      else {
	// Our parse failed so we don't know how long we need to wait before we retry and
	// use LastFmNotConnected as a result. 
 	connectionState = LastFmNotConnected; 
	NSLog(@"Got an invalid UPTODATE handshake"); 
	NSLog(@"HandshakeResponse: %@", handshakeResponse);
	return false; 
      }
    }
    else if([responseStatus compare:@"UPDATE"]) {
      NSString *md5Challenge, *tmpSubmitUrl; 
      int tmpInterval; 
      if([theScanner scanUpToCharactersFromSet:newlineSet intoString:NULL] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:&md5Challenge] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:&tmpSubmitUrl] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:NULL] && 
	 [theScanner scanInt:&tmpInterval]) {
	
	// Now that we know the response was valid ... copy our tmp variables into 
	// the proper member variables 
	submitUrl = [NSString stringWithString:tmpSubmitUrl];
	md5ResponseHash = [self calcMd5String:[md5Challenge stringByAppendingString:md5Pwd]];
	interval = tmpInterval; 
	connectionState = LastFmHandshakeCompleted; 
	NSLog(@"Got a vaild UPDATE handshake response");
	return true; 
      }
      else {
	// Our parse failed so we don't know how long we need to wait before we retry and
	// use LastFmNotConnected as a result. 
 	connectionState = LastFmNotConnected; 
	NSLog(@"Got an invalid UPDATE handshake"); 
	return false; 
      }
      NSLog(@"Handle update here"); 
    }
    else if([responseStatus compare:@"FAILED"]) {
      if([theScanner scanUpToCharactersFromSet:newlineSet intoString:&handshakeError] &&
	 [theScanner scanUpToCharactersFromSet:newlineSet intoString:NULL] && 	 
	 [theScanner scanInt:&interval]) {
	connectionState = LastFmHandshakeFailed; 
	NSLog(@"Handle Failed here");
	return false; 
      }
      else {
	connectionState = LastFmNotConnected; 
	NSLog(@"handshake Parse Error"); 
	return false; 
      }	
    }
    else if([responseStatus compare:@"BADUSER"]) {
      if([theScanner scanUpToCharactersFromSet:newlineSet intoString:NULL] && 	 
	 [theScanner scanInt:&interval]) {
	NSLog(@"Handle Baduser here");
	connectionState = LastFmHandshakeFailed; 
	return false; 
      }
      else {
	connectionState = LastFmNotConnected; 
	return false; 
      }
    }
    else {
      connectionState = LastFmHandshakeFailed;; 
      NSLog(@"Got an unknown handshake response!"); 
      return false; 
    }
	// Shouldn't ever get here
	return false;
  }

/* MD5 Hashing Methods */ 
-(NSData*) calcMd5:(NSString *)string
{
   /* 
  NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
  if (data) {
    NSMutableData *digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    if (digest && MD5([data bytes], [data length], [digest mutableBytes]))
      NSLog(@"%@", digest);
  }
  */
  
  // Error checking would be good right about here

  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
  if (data) {
    NSMutableData *digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    if (digest && MD5([data bytes], [data length], [digest mutableBytes])) {
      NSLog(@"Calculated an MD5 Hash of: %@", digest);
      return digest; 
    }
  }
}

-(NSString*) calcMd5String:(NSString *)string
{
  NSData *digestData = [self calcMd5:string];
  unsigned char* digest = [digestData bytes];
  NSString *md5DigestString = [[NSString alloc] initWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			digest[0], digest[1], 
			digest[2], digest[3],
			digest[4], digest[5],
			digest[6], digest[7],
			digest[8], digest[9],
			digest[10], digest[11],
			digest[12], digest[13],
			digest[14], digest[15]];
  NSLog(@"String an MD5 Hash of: %@", md5DigestString);

  return md5DigestString;

}

/* Connection Management Methods */

/* 
- (void)startLastFmConnection:(NSURL *)url {
    NSURLRequest *connectionRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    lastFmConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
    if (lastFmConnection) {
        connectionData = [[NSMutableData alloc] init];
	NSLog(@"Connecting to server");
    } else {
        [self endLastFmConnection];
	NSLog(@"Connection Error");
    }
}
*/

- (void) lastFmLogin:(NSString *)username 
{
  NSString *urlString = [NSString stringWithString:@"http://post.audioscrobbler.com/?hs=true&p=1.1&c=tst&v=1.0&u="];
  urlString = [urlString stringByAppendingString:username];

  NSURLRequest *connectionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
  lastFmConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
  if (lastFmConnection) {
    connectionData = [[NSMutableData alloc] init];
    NSLog(@"Connecting to server");
  } else {
    [self endLastFmConnection];
    NSLog(@"Connection Error");
  }
}

- (void) lastFmSubmit:(NSString *)title byArtist:(NSString *)Artist
{
  NSDate *date = [NSDate date];
  NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:submitUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
  [connectionRequest setHTTPMethod:@"POST"];
  NSString *dataString = [NSString stringWithString:@"u=microchip2&s="];
  dataString = [dataString stringByAppendingString:md5ResponseHash];
  dataString = [dataString stringByAppendingString:@"&a[0]="];
  dataString = [dataString stringByAppendingString:Artist];
  dataString = [dataString stringByAppendingString:@"&t[0]="];
  dataString = [dataString stringByAppendingString:title];
  dataString = [dataString stringByAppendingString:@"&b[0]=&m[0]=&l[0]=60&i[0]="];
  dataString = [dataString stringByAppendingString:[date descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone: [NSTimeZone timeZoneWithName:@"UTC"] locale:nil]];
  
  NSLog(@"Post String is: %@", dataString);
  [connectionRequest setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
  lastFmConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
  if (lastFmConnection) {
    connectionData = [[NSMutableData alloc] init];
    NSLog(@"Connecting to server");
  } else {
    [self endLastFmConnection];
    NSLog(@"Connection Error");
  }

}


- (void)endLastFmConnection {
    [lastFmConnection release];
    lastFmConnection = nil;
    [connectionResponse release];
    connectionResponse = nil;
    [connectionData release];
    connectionData = nil;
}



/* NSURLConnection Delegate Methods */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connectionResponse release];
    connectionResponse = [response retain];
    [connectionData setLength:0];
    NSLog(@"Connected to server");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [connectionData appendData:data];
    NSLog(@"Receiving data"); 
    //[progressField setStringValue:@"Receiving data"];
}

//Not looked at yet
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *string = [[[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding] autorelease], *name = nil;
    //    NSURL *downloadURL = nil;
    [self endLastFmConnection];
    if (string && [string length] > 0) {
      NSLog(@"connectionDidFinishLoading: %@", string);
	  if(connectionState == LastFmNotConnected) {
		[self parseHandshake:string];
	  }
    }
    //if ([self presentConnectionSuccess:name]) [self startUpdateDownload:downloadURL];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self endLastFmConnection];
    NSLog(@"Connection failed"); 
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;     // Never cache
}

@end
