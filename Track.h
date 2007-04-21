//
//  Track.h
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int const PBThumbsUpRating;

@interface Track : NSObject {
    NSMutableDictionary *_properties;
    NSData   *_artwork;
	NSImage  *_artworkImage; 
}

- (NSMutableDictionary *)properties;
- (void)setProperties:(NSMutableDictionary *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)artist;
- (void)setArtist:(NSString *)value;

- (NSData *)artwork;
- (NSImage *)artworkImage; 

- (NSString *)album;
- (NSString *)songUrl;
- (int)rating;

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist;

- (NSString *)valueForProperty:(NSString *)property;
- (void)setValue:(NSString *)value forProperty:(NSString *)property;

- (NSScriptObjectSpecifier *)objectSpecifier;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToTrack:(Track *)aTrack;
- (unsigned)hash;

@end
