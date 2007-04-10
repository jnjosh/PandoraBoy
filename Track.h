//
//  Track.h
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Track : NSObject {
    NSString *_name;
    NSString *_artist;
}

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)artist;
- (void)setArtist:(NSString *)value;

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist;

- (NSScriptObjectSpecifier *)objectSpecifier;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToTrack:(Track *)aTrack;

@end
