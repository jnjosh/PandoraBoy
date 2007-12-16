//
//  Playlist.h
//  PandoraBoy
//
//  Created by Rob Napier on 4/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebDataSource.h>
#import "Track.h"

@interface Playlist : NSObject {
    NSMutableDictionary *_trackInfo;
    NSMutableArray      *_playedTracks;
    NSMutableDictionary *_artworkLibrary;

    Track *_parsingTrack;
    NSString *_parsingKey;
    NSMutableString *_parsingString;
    
    NSImage *_noAlbumArtImage;
    NSMutableData *_noAlbumArtData;
    NSURLConnection *_noAlbumArtConnection;
}

// Initializers
+ (Playlist *)sharedPlaylist;
- (id)init;

// Accessors
- (NSMutableArray *)playedTracks;
- (void)setPlayedTracks:(NSMutableArray *)value;

- (Track *)parsingTrack;
- (void)setParsingTrack:(Track *)value;

- (NSString *)parsingKey;
- (void)setParsingKey:(NSString *)value;

- (NSMutableString *)parsingString;
- (void)setParsingString:(NSMutableString *)value;

- (NSMutableDictionary *)artworkLibrary;
- (void)setArtworkLibrary:(NSMutableDictionary *)value;

- (NSImage*)noAlbumArtImage;

// Methods
- (void)addArtworkFromData:(NSData *)data forURL:(NSURL *)url;
- (NSImage *)artworkImageForURLString:(NSString *)urlString;
- (BOOL)needArtworkForURLString:(NSString *)urlString;
- (void)setNeedArtworkForURLString:(NSString *)urlString;
- (void)addInfoFromData:(NSData *)data;
- (void)addPlayedTrack:(Track *)track;
- (Track *)currentTrack;
- (Track*)trackForProvisionalTrack:(Track*)track;

// XMLParser delegates
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
