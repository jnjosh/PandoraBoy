//
//  Track.h
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PBThumbsUpRating    1
#define PBUnsetRating       0
#define PBThumbsDownRating -1

@interface Track : NSObject {
    NSMutableDictionary *_properties;
	NSImage  *_artworkImage;
}

- (NSMutableDictionary *)properties;
- (void)setProperties:(NSMutableDictionary *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;
- (NSString *)thumbedName;

- (NSString *)artist;
- (void)setArtist:(NSString *)value;

- (NSString *)identifier;

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

@end
