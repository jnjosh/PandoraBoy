//
//  Track.m
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Track.h"
#import "Playlist.h"

int const PBThumbsUpRating = 1;

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
    [_artwork release];
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
    return [self setValue:value forProperty:@"artistSummary"];
}

- (NSString *)album {
    return [self valueForProperty:@"albumTitle"];
}

- (int)rating {
    return [[self valueForProperty:@"rating"] intValue];
}

- (NSData *)artwork {
    if( ! _artwork ) {
        Playlist *playlist = [Playlist sharedPlaylist];
        WebDataSource *dataSource = [playlist dataSource];

        // You'd think we could use subresourceForURL here, but it seems that
        // subresourceForURL relies on having the exact NSURL that the resource
        // is tied to. We only have the string at this point (since we took it
        // out of the Pandora message). So we have to hunt through the array
        // using the resource descriptions (which includes the URL).
        NSString *url = [self valueForProperty:@"artRadio"];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"description contains %@", url];
        NSArray *results = [[dataSource subresources] filteredArrayUsingPredicate:pred];
        if( [results count] ) {
            WebResource *r = [results objectAtIndex:0];
            _artwork = [r data];
            [_artwork retain];
        }
        else {
            NSLog(@"ERROR:Couldn't get album art. Looking for %@ in\n%@", url, [dataSource subresources]);
        }
    }
    return _artwork;
}

- (NSString *)valueForProperty:(NSString *)property {
    return [[self properties] objectForKey:property];
}

- (void)setValue:(NSString *)value forProperty:(NSString *)property {
    if( value == nil ) { value = @""; }
    [[self properties] setObject:value forKey:property];
}

// Initializers

+ (Track *)trackWithName:(NSString*)name artist:(NSString*)artist {
    Track *track = [[Track alloc] init];
    [track setName:name];
    [track setArtist:artist];
    return [track autorelease];
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
