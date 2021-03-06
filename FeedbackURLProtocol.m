//
//  FeedbackURLProtocol.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FeedbackURLProtocol.h"
#import "PlayerController.h"
#import "Playlist.h"
#import "Track.h"

@implementation FeedbackURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *urlString = [[request URL] absoluteString];
    return ( [super canInitWithRequest:request] &&
             [urlString rangeOfString:@"addFeedback"].location != NSNotFound );
}

-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client
{
    id retval = [super initWithRequest:request cachedResponse:cachedResponse client:client];

	NSString *musicId = [self valueForParameter:@"arg2"];
	Track *track = [[Playlist sharedPlaylist] trackForIdentifier:musicId];
    NSString *thumbedUpString = [self valueForParameter:@"arg7"];
    if( thumbedUpString ) {
        if( [thumbedUpString isEqualToString:@"true"] ) {
            [track setRating:PBThumbsUpRating];
        }
        else if( [thumbedUpString isEqualToString:@"false"] ) {
            [track setRating:PBThumbsDownRating];
        }
        else {
            NSLog(@"BUG:Bad rating in query:%@", [[[self request] URL] absoluteString]);
        }
    }
    else {
        NSLog(@"BUG:Bad feedback request:%@", [[[self request] URL] absoluteString]);
    }
    return retval;
}

@end
