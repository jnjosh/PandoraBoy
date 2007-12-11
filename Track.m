//
//  Track.m
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Track.h"
#import "Playlist.h"
#import "Controller.h"

@implementation Track

- (id) init
{
	if ( self = [super init] ) {
        [self setProperties:[[NSMutableDictionary alloc] initWithCapacity:25]];
	}
	return self;
}

- (void) dealloc 
{
    [_properties release];
	[_artworkImage release];
	[super dealloc];
}

- (NSMutableDictionary *)properties {
    return [[_properties retain] autorelease];
}

- (void)setProperties:(NSMutableDictionary *)value {
    if (_properties != value) {
        [_properties release];
        _properties = [value retain];
    }
}

- (NSString *)name {
    return [self valueForProperty:@"songTitle"];
}

- (void)setName:(NSString *)value {
    [self setValue:value forProperty:@"songTitle"];
}

- (NSString *)artist {
    return [self valueForProperty:@"artistSummary"];
}

- (void)setArtist:(NSString *)value {
    [self setValue:value forProperty:@"artistSummary"];
}

- (NSString *)album {
    return [self valueForProperty:@"albumTitle"];
}

- (NSString *)songUrl {
    return [self valueForProperty:@"songDetailURL"];
}

- (int)rating {
    return [[self valueForProperty:@"rating"] intValue];
}

- (void)setRating:(int)value {
    NSLog(@"setRating:%d", value);
    [self setValue:[[NSNumber numberWithInt:value] stringValue] forProperty:@"rating"];
}

- (NSImage *)artworkImage { 
	if( ! _artworkImage) { 
        _artworkImage = [[Playlist sharedPlaylist] artworkImageForURLString:[self valueForProperty:@"artRadio"]];
        [_artworkImage retain];
	}
	return _artworkImage;
}

- (NSImage *)thumbedArtworkImage {
    // Don't cache this; the rating might change
    if( [self rating] == PBThumbsUpRating ) {
        NSImage *thumbed = [[self artworkImage] copy];
        [thumbed lockFocus];
        [[[Controller sharedController] thumbsUpImage] dissolveToPoint:NSMakePoint(50, 10) fraction:0.65];
        [thumbed unlockFocus];
        return [thumbed autorelease];
    }
    else {
        return [self artworkImage];
    }
}

- (NSString *)valueForProperty:(NSString *)property {
    return [[self properties] objectForKey:property];
}

- (void)setValue:(NSString *)value forProperty:(NSString *)property {
    NSLog(@"DEBUG:Track:%@=%@", property, value);
    if( property == nil ) {
        NSLog(@"WARNING: Tried to set a nil Track property to \"%@\"", value );
        return;
    }
    if( value == nil ) { value = @""; }
    [[self properties] setObject:value forKey:property];
}

// Initializers

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist {
    Track *provisionalTrack = [[[Track alloc] init] autorelease];
    [provisionalTrack setName:name];
    [provisionalTrack setArtist:artist];
    return [[Playlist sharedPlaylist] trackForProvisionalTrack:provisionalTrack];
}

// NSScriptObjectSpecifiers protocol

- (NSScriptObjectSpecifier *)objectSpecifier{
    unsigned index = [[[Playlist sharedPlaylist] playedTracks] indexOfObjectIdenticalTo:self];
    
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[NSApp class]];

    return [[[NSIndexSpecifier allocWithZone:[self zone]] 
            initWithContainerClassDescription:containerClassDesc
                           containerSpecifier:nil key:@"tracks" index:index] autorelease];
}

// NSObject protocol

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToTrack:other];
}

- (BOOL)isEqualToTrack:(Track *)aTrack {
    if (self == aTrack)
        return YES;
    if (![[self name] isEqualToString:[aTrack name]])
        return NO;
    if (![[self artist] isEqualToString:[aTrack artist]])
        return NO;
    return YES;
}

- (unsigned)hash {
    return [[NSArray arrayWithObjects:[self name], [self artist], nil] hash];
}
@end
