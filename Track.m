//
//  Track.m
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Track.h"
#import "SongNotification.h"

@implementation Track

- (id) init
{
	if ( self = [super init] ) {
        [self setName:@""];
        [self setArtist:@""];
	}
	return self;
}

- (void) dealloc 
{
    [_name release];
    [_artist release];
	[super dealloc];
}

- (NSString *)name {
    return [[_name retain] autorelease];
}

- (void)setName:(NSString *)value {
    if (_name != value) {
        [_name release];
        _name = [value retain];
    }
}

- (NSString *)artist {
    return [[_artist retain] autorelease];
}

- (void)setArtist:(NSString *)value {
    if (_artist != value) {
        [_artist release];
        _artist = [value retain];
    }
}

- (NSData *)artwork {
    return [[_artwork retain] autorelease];
}

- (void)setArtwork:(NSData *)value {
    if (_artwork != value) {
        [_artwork release];
        _artwork = [value retain];
    }
}

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist artwork:(NSData*)artwork {
    Track *track = [[Track alloc] init];
    [track setName:name];
    [track setArtist:artist];
    [track setArtwork:artwork];
    return [track autorelease];
}

- (NSScriptObjectSpecifier *)objectSpecifier{
    unsigned index = [[[SongNotification sharedNotification] tracks] indexOfObjectIdenticalTo:self];
    
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[NSApp class]];

    return [[[NSIndexSpecifier allocWithZone:[self zone]] 
            initWithContainerClassDescription:containerClassDesc
                           containerSpecifier:nil key:@"tracks" index:index] autorelease];
}

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
@end
