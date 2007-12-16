//
//  Track.m
//  PandoraBoy
//
//  Created by Rob Napier on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

//artistSummary=Pixies
//artistDetailURL=http://www.pandora.com/music/artist/pixies
//matchingSeed=S43802
//composerName=(null)
//isSeed=0
//artistFansURL=http://www.pandora.com/backstage?type=profile&subtype=fansOfArtist&q=R7302
//songExplorerUrl=http://www.pandora.com/xml/music/song/pixies/wave+of+mutilation
//fileGain=0.44
//songDetailURL=http://www.pandora.com/music/song/pixies/wave+of+mutilation
//albumDetailURL=http://www.pandora.com/music/album/pixies/best+of+pixies+wave+of+mutilation
//webId=943559838b34705f
//musicComUrl=http://search.music.com/?b=470286336%7C1073741824%7C1551368192&pl=10%7C3%7C1&t=1551368192&queryType=batchPage&title=&name=&keywords=&q=Pixies+Best+Of+Pixies%3A+Wave+Of+Mutilation&querySrc=pandora
//fanExplorerUrl=http://www.pandora.com/xml/fans/artist/pixies
//rating=0
//artistExplorerUrl=http://www.pandora.com/xml/music/artist/pixies
//artRadio=http://images-lev3-2.pandora.com/images/public/amz/7/2/6/0/652637240627_130W_130H.jpg
//stationId=6021290750249495
//albumTitle=Best Of Pixies: Wave Of Mutilation
//artistMusicId=R7302
//albumExplorerUrl=http://www.pandora.com/xml/music/album/pixies/best+of+pixies+wave+of+mutilation
//amazonUrl=&path=%2Fgp%2Fproduct%2FB0001RVTXO
//audioURL=http://audio-inap-3.pandora.com/access/512191134477788754?version=4&lid=4327959&token=KT75%2F1iKF3ScpUfrJJwrosc5gABIPPsDFS9sMT%2FAZcy0lif1mYSELtdhts4um776QeUYOHdyyF7AhxOs3UXbp8bnt5LZjsGa8m95cUf66r3fxJCEsqdZu46NhMquS5ZsSwVOx%2BMEoTHCmmLRabQZiycscePCvREjLP2EG5%2BFPFSnobJtYcs19bEQGXPzvAmOaxk60URabvVMUjHzvZ5YTj9nZEGHRI%2FbmDuUDseidxjkXW8Eh%2FneSB5j4PLSskvw7W9e81J2G7oom7rk2%2BEod8cf25cd49853a572571253b5c6f506bf3a665d09d43a156
//onTour=0
//itunesUrl=&RD_PARM1=http%253A%252F%252Fphobos.apple.com%252FWebObjects%252FMZSearch.woa%252Fwa%252FadvancedSearchResults%253FartistTerm%253DPixies%252526%2526songTerm%253DWave%252BOf%252BMutilation%2526originStoreFront%253D143441%2526partnerId%3D30
//isClassical=0
//focusTrait=(null)
//musicId=S46249
//songTitle=Wave Of Mutilation
//focusTraitId=(null)
//identity=6dfe24b6ef412f3d93a3cbd67faf28e8

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

- (NSString *)identifier {
    return [self valueForProperty:@"musicId"];
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
    [self setValue:[[NSNumber numberWithInt:value] stringValue] forProperty:@"rating"];
}

- (NSImage *)artworkImage { 
	if( ! _artworkImage) { 
        _artworkImage = [[Playlist sharedPlaylist] artworkImageForURLString:[self valueForProperty:@"artRadio"]];
        if( ! _artworkImage ) {
            _artworkImage = [[Playlist sharedPlaylist] noAlbumArtImage];
        }
        [_artworkImage retain];
	}
	return _artworkImage;
}

- (NSImage *)thumbedArtworkImage {
    // Don't cache this; the rating might change
    if( [self rating] == PBThumbsUpRating ) {
        NSImage *thumbed = [[self artworkImage] copy];
        if( thumbed ) {
            [thumbed lockFocus];
            [thumbed setSize:NSMakeSize(130.0,130.0)];
            [[[Controller sharedController] thumbsUpImage] dissolveToPoint:NSMakePoint(50, 10) fraction:0.65];
            [thumbed unlockFocus];
        }
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
//    NSLog(@"DEBUG:Track:%@=%@", property, value);
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
