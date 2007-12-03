//
//  StationList.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"

static StationList *sharedStationList = nil;

@implementation StationList

// Accessors
- (NSMutableArray *)stationList {
    if (!_stationList) {
        _stationList = [[NSMutableArray alloc] init];
    }
    return [[_stationList retain] autorelease];
}

- (BOOL)parsingStationIsQuickMix {
    return _parsingStationIsQuickMix;
}

- (void)setParsingStationIsQuickMix:(BOOL)value {
    if (_parsingStationIsQuickMix != value) {
        _parsingStationIsQuickMix = value;
    }
}

- (NSString *)parsingStationName {
    return [[_parsingStationName retain] autorelease];
}

- (void)setParsingStationName:(NSString *)value {
    if (_parsingStationName != value) {
        [_parsingStationName release];
        _parsingStationName = [value retain];
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

// Initializers
- (id) init {
	if (sharedStationList) return sharedStationList;
    
    sharedStationList  = [super init];
    if (self != nil) {
        _stationList        = [[NSMutableArray alloc] initWithCapacity:10];
        _parsingStationIsQuickMix = NO;
        _parsingStationName = nil;
        _parsingKey         = nil;
        _parsingString      = nil;
    }
    return sharedStationList;
}

- (void) dealloc {
    [_stationList release];
    [_parsingStationName release];
    [_parsingKey release];
    [_parsingString release];
    [super dealloc];
}

+ (StationList *)sharedStationList {
	if (sharedStationList) return sharedStationList;
	sharedStationList = [[StationList alloc] init];
	return sharedStationList;
}

- (void)initFromData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];    
}

- (void)addStationWithName:(NSString *)name identifier:(NSString *)identifier isQuickMix:(BOOL)isQuickMix {
    [[self stationList] addObject:[Station stationWithName:name identifier:identifier isQuickMix:isQuickMix]];
}

// XMLParser delegates
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
        if( [[self parsingKey] isEqualToString:@"isQuickMix" ] )
        {
            [self setParsingStationIsQuickMix:[(NSString*)[self parsingString] isEqualToString:@"1"]];
        }
        if( [[self parsingKey] isEqualToString:@"stationName"] )
        {
            [self setParsingStationName:(NSString*)[self parsingString]];
        }
        if( [[self parsingKey] isEqualToString:@"stationId"] )
        {
            [self addStationWithName:[self parsingStationName]
                          identifier:(NSString*)[self parsingString]
                          isQuickMix:[self parsingStationIsQuickMix]];
            [self setParsingStationName:nil];
        }
        [self setParsingKey:nil];
        [self setParsingString:nil];
    }
}

@end
