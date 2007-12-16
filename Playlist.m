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
        _trackInfo       = [[NSMutableDictionary alloc] initWithCapacity:100];
        _playedTracks    = [[NSMutableArray alloc] initWithCapacity:100];
        _artworkLibrary  = [[NSMutableDictionary alloc] initWithCapacity:100];
        _noAlbumArtImage = nil;
        _noAlbumArtData  = [[NSMutableData alloc] initWithCapacity:512];
        _parsingTrack    = nil;
        _parsingString   = nil;
        
        // Load _noAlbumArtImage
        NSURL *url = [NSURL URLWithString:@"http://www.pandora.com/images/no_album_art.jpg"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _noAlbumArtConnection=[[NSURLConnection alloc] initWithRequest:request
                                                              delegate:self];
        if( ! _noAlbumArtConnection ) {
            NSLog(@"ERROR: Couldn't fetch noAlbumArt");
        }
    }
    return sharedInstance;
}

+ (Playlist *)sharedPlaylist {
	if (sharedInstance) return sharedInstance;
	sharedInstance = [[Playlist alloc] init];
	return sharedInstance;
}

- (void) dealloc {
    [_artworkLibrary release];
    [_trackInfo release];
    [_playedTracks release];
    [_parsingTrack release];
    [_parsingString release];
    [super dealloc];
}

// Accessors
- (NSMutableDictionary *)artworkLibrary {
    return [[_artworkLibrary retain] autorelease];
}

- (void)setArtworkLibrary:(NSMutableDictionary *)value {
    if (_artworkLibrary != value) {
        [_artworkLibrary release];
        _artworkLibrary = [value retain];
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

- (NSImage *)noAlbumArtImage {
    return [[_noAlbumArtImage retain] autorelease];
}

// Methods
- (void)addInfoFromData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}


- (NSString *)keyForURLString:(NSString *)urlString {
    // The URL without any extra query stuff
    return [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
}

- (void)addArtworkFromData:(NSData *)data forURL:(NSURL *)url {
    NSString *key = [self keyForURLString:[url absoluteString]];
    if( data && key ) {
        [[self artworkLibrary] setObject:data forKey:key];
    }
}

- (NSImage *)artworkImageForURLString:(NSString *)urlString {
    id artworkData = [[self artworkLibrary] objectForKey:[self keyForURLString:urlString]];
    if( [artworkData isKindOfClass:[NSData class]] ) { 
        return [[[NSImage alloc] initWithData:artworkData] autorelease];
    }
    return nil;
}

- (BOOL)needArtworkForURLString:(NSString *)urlString {
    // If there's a key there, but no data, then we need artwork
    NSString *key = [self keyForURLString:urlString];
    return( [[[self artworkLibrary] objectForKey:key] isEqual:@""] );
}

- (void)setNeedArtworkForURLString:(NSString *)urlString {
    if( urlString && ! [self artworkImageForURLString:urlString] ) {
        [[self artworkLibrary] setObject:@"" forKey:[self keyForURLString:urlString]];
    }
}

- (Track *)currentTrack {
	if([[self playedTracks] count]) { 
		return [[self playedTracks] objectAtIndex:0];
	}
	return nil;
}

- (id)keyForTrack:(Track *)track {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [track name], @"name",
        [track artist], @"artist",
        nil];
}

- (void)addTrackInfo:(Track *)track {
    id key = [self keyForTrack:track];
    if( ! [_trackInfo objectForKey:key] ) {
        [_trackInfo setValue:track forKey:key];
    }
}

- (void)addPlayedTrack:(Track *)track {
	if( track ) {
        [self willChangeValueForKey:@"_playedTracks"];
        [[self playedTracks] insertObject:track atIndex:0];
        [self didChangeValueForKey:@"_playedTracks"];	
    }
    else {
        NSLog(@"BUG:addPlayedTrack passed nil");
    }
}

- (Track*)trackForProvisionalTrack:(Track*)track {
    return [_trackInfo objectForKey:[self keyForTrack:track]];
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
    Track *parsingTrack = [self parsingTrack];
    
    if( [elementName isEqualToString:@"name"] ) {
        [self setParsingKey:(NSString*)[self parsingString]];
        [self setParsingString:nil];
    }
    else if( [elementName isEqualToString:@"value"] ) {
        [parsingTrack setValue:(NSString*)[self parsingString] forProperty:[self parsingKey]];
        if( [[self parsingKey] isEqualToString:@"artRadio"] )
        {
            [self setNeedArtworkForURLString:[self parsingString]];
        }
        [self setParsingKey:nil];
        [self setParsingString:nil];
    }
    else if( [elementName isEqualToString:@"struct"] ) {
        [self addTrackInfo:parsingTrack];
        [self setParsingTrack:nil];
    }
}

// NSURLConnection delegates (for _noAlbumArtImage)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_noAlbumArtData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_noAlbumArtData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_noAlbumArtConnection release];
    [_noAlbumArtData release];
    NSLog(@"ERROR: Failed to load noAlbumArt: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _noAlbumArtImage = [[NSImage alloc] initWithData:_noAlbumArtData];
    [_noAlbumArtConnection release];
    [_noAlbumArtData release];
}

@end
