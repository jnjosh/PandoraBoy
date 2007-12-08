//
//  Playlist.m
//  PandoraBoy
//
//  Created by Rob Napier on 4/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Playlist.h"

static Playlist* sharedInstance = nil;

@implementation Playlist

// Initializers
- (id) init {
	if (sharedInstance) return sharedInstance;

    sharedInstance  = [super init];
    if (sharedInstance != nil) {
        _trackInfo     = [[NSMutableSet alloc] initWithCapacity:100];
        _playedTracks  = [[NSMutableArray alloc] initWithCapacity:100];
        _artwork       = [[NSMutableDictionary alloc] initWithCapacity:100];
        _parsingTrack  = nil;
        _parsingString = nil;
    }
    return sharedInstance;
}

+ (Playlist *)sharedPlaylist {
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[Playlist alloc] init];
	return sharedInstance;
}

- (void) dealloc {
    [_artwork release];
    [_trackInfo release];
    [_playedTracks release];
    [_parsingTrack release];
    [_parsingString release];
    [super dealloc];
}

// Accessors
- (NSMutableDictionary *)artwork {
    return [[_artwork retain] autorelease];
}

- (void)setArtwork:(NSMutableDictionary *)value {
    if (_artwork != value) {
        [_artwork release];
        _artwork = [value retain];
    }
}

- (NSMutableSet *)trackInfo {
    return [[_trackInfo retain] autorelease];
}

- (void)setTrackInfo:(NSMutableSet *)value {
    if (_trackInfo != value) {
        [_trackInfo release];
        _trackInfo = [value retain];
    }
}

- (NSMutableArray *)playedTracks {
    return [[_playedTracks retain] autorelease];
}

- (void)setPlayedTracks:(NSMutableArray *)value {
    if (_playedTracks != value) {
        [_playedTracks release];
        _playedTracks = [value retain];
    }
}

- (Track *)parsingTrack {
    return [[_parsingTrack retain] autorelease];
}

- (void)setParsingTrack:(Track *)value {
    if (_parsingTrack != value) {
        [_parsingTrack release];
        _parsingTrack = [value retain];
    }
}

- (NSString *)parsingKey {
    return [[_parsingKey retain] autorelease];
}

- (void)setParsingKey:(NSString *)value {
    if (_parsingKey != value) {
        [_parsingKey release];
        _parsingKey = [value retain];
    }
}

- (NSMutableString *)parsingString {
    return [[_parsingString retain] autorelease];
}

- (void)setParsingString:(NSMutableString *)value {
    if (_parsingString != value) {
        [_parsingString release];
        _parsingString = [value retain];
    }
}

// Methods
- (void)addInfoFromData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

- (NSString *)keyForURLString:(NSString *)urlString {
    return [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
}

- (void)addArtworkFromData:(NSData *)data forURL:(NSURL *)url {
    NSString *key = [self keyForURLString:[url absoluteString]];
    if( data && key ) {
        [[self artwork] setObject:data forKey:key];
    }
}

- (NSData *)artworkForURLString:(NSString *)urlString {
    id artwork = [[self artwork] objectForKey:[self keyForURLString:urlString]];
    if( [artwork isKindOfClass:[NSData class]] ) { return artwork; }
    return nil;
}

- (BOOL)needArtworkForURLString:(NSString *)urlString {
    // If there's a key there, but no data, then we need artwork
    NSString *key = [self keyForURLString:urlString];
    return( [[[self artwork] objectForKey:key] isEqual:@""] );
}

- (void)setNeedArtworkForURLString:(NSString *)urlString {
    if( urlString && ! [self artworkForURLString:urlString] ) {
        [[self artwork] setObject:@"" forKey:[self keyForURLString:urlString]];
    }
}

- (Track *)currentTrack {
	if([[self playedTracks] count]) { 
		return [[self playedTracks] objectAtIndex:0];
	}
	return nil;
}

- (void)addPlayedTrack:(Track *)track {
    Track *trackWithInfo = [[self trackInfo] member:track];
	if( trackWithInfo) {
        // NSMutableArray does not send out KVC updates. This means that NSArrayController (and our gui by extension)
        // do not see changes the the playedTracks array unless the notifications are explicitly sent out. 
        // Notify the ArrayController that we are about to add a key. 
        [self willChangeValueForKey:@"_playedTracks"];
        [[self playedTracks] insertObject:trackWithInfo atIndex:0];
        [self didChangeValueForKey:@"_playedTracks"];	
    }
}

// XMLParser delegates
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"struct"]) {
        [self setParsingTrack:[[Track alloc] init]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (! [self parsingString]) {
        [self setParsingString:[[NSMutableString alloc] initWithCapacity:20]];
    }
    [[self parsingString] appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if( [elementName isEqualToString:@"name"] ) {
        [self setParsingKey:(NSString*)[self parsingString]];
        [self setParsingString:nil];
    }
    else if( [elementName isEqualToString:@"value"] ) {
        [[self parsingTrack] setValue:(NSString*)[self parsingString] forProperty:[self parsingKey]];
        if( [[self parsingKey] isEqualToString:@"artRadio"] )
        {
            [self setNeedArtworkForURLString:[self parsingString]];
        }
        [self setParsingKey:nil];
        [self setParsingString:nil];
    }
    else if( [elementName isEqualToString:@"struct"] ) {
        if( [[self trackInfo] member:[self parsingTrack]] == nil ) {
            [[self trackInfo] addObject:[self parsingTrack]];
            [self setParsingTrack:nil];
        }
    }
}
@end
