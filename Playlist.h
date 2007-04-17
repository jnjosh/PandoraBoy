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
    NSMutableSet *_trackInfo;
    NSMutableArray *_playedTracks;

    Track *_parsingTrack;
    NSString *_parsingKey;
    NSMutableString *_parsingString;
    WebDataSource *_dataSource;
}

// Initializers
+ (Playlist *)sharedPlaylist;
- (id)init;

// Accessors
- (NSMutableSet *)trackInfo;
- (void)setTrackInfo:(NSMutableSet *)value;

- (NSMutableArray *)playedTracks;
- (void)setPlayedTracks:(NSMutableArray *)value;

- (Track *)parsingTrack;
- (void)setParsingTrack:(Track *)value;

- (NSString *)parsingKey;
- (void)setParsingKey:(NSString *)value;

- (NSMutableString *)parsingString;
- (void)setParsingString:(NSMutableString *)value;

- (WebDataSource *)dataSource;
- (void)setDataSource:(WebDataSource *)value;

// Methods
- (void)addInfoFromData:(NSData *)data;
- (void)addPlayedTrack:(Track *)track;
- (Track *)currentTrack;

// XMLParser delegates
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
