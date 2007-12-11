//
//  Track.h
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int const PBThumbsUpRating;
extern int const PBUnsetRating;
extern int const PBThumbsDownRating;

@interface Track : NSObject {
    NSMutableDictionary *_properties;
	NSImage  *_artworkImage;
    NSImage *_thumbsUpImage;
}

- (NSMutableDictionary *)properties;
- (void)setProperties:(NSMutableDictionary *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)artist;
- (void)setArtist:(NSString *)value;

- (NSImage *)artworkImage; 
- (NSImage *)thumbedArtworkImage;

- (NSString *)album;
- (NSString *)songUrl;
- (int)rating;
- (void)setRating:(int)value;

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist;

- (NSString *)valueForProperty:(NSString *)property;
- (void)setValue:(NSString *)value forProperty:(NSString *)property;

- (NSScriptObjectSpecifier *)objectSpecifier;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToTrack:(Track *)aTrack;
- (unsigned)hash;

@end
