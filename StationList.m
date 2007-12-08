//
//  StationList.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"
#import "Controller.h"

static StationList *_sharedStationList = nil;

extern NSString *PBQuickMixMenuItemTitle;
NSString *PBQuickMixMenuItemTitle = @"QuickMix";

@implementation StationList

// Accessors
- (Station *)currentStation {
    return [[_currentStation retain] autorelease];
}

- (void)setCurrentStation:(Station *)value {
    if (_currentStation != value) {
        [_currentStation release];
        _currentStation = [value retain];
    }
}

- (Station *)quickMixStation {
    return [[_quickMixStation retain] autorelease];
}

- (void)setQuickMixStation:(Station *)value {
    if (_quickMixStation != value) {
        [_quickMixStation release];
        _quickMixStation = [value retain];
    }
}

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
	if (_sharedStationList) return _sharedStationList;
    
    _sharedStationList  = [super init];
    if (self != nil) {
        _stationList        = [[NSMutableArray alloc] initWithCapacity:10];
        _currentStation     = nil;
        _quickMixStation    = nil;
        
        _parsingStationIsQuickMix = NO;
        _parsingStationName = nil;
        _parsingKey         = nil;
        _parsingString      = nil;
    }
    return _sharedStationList;
}

- (void) awakeFromNib {
    [_stationsMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *menuItem = [_stationsMenu addItemWithTitle:PBQuickMixMenuItemTitle
                                                    action:@selector(changeStation:)
                                             keyEquivalent:@""];
    [menuItem setEnabled:NO];
    [menuItem setTarget:[Controller sharedController]];
}

- (void) dealloc {
    [_stationList release];
    [_parsingStationName release];
    [_parsingKey release];
    [_parsingString release];
    [super dealloc];
}

+ (StationList *)sharedStationList {
	if (_sharedStationList) return _sharedStationList;
	_sharedStationList = [[StationList alloc] init];
	return _sharedStationList;
}

- (void)initFromData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];    
}

- (void)addStationWithName:(NSString *)name identifier:(NSString *)identifier isQuickMix:(BOOL)isQuickMix {
    Station *station = [Station stationWithName:name
                                     identifier:identifier
                                     isQuickMix:isQuickMix];
        if( ! name || ! identifier ) {
        NSLog(@"BUG:addStationWithName called with nil:%@:%@", name, identifier);
        return;
    }
    
    // FIXME: I don't know what happens if someone shares a QuickMix station
    // with you. I might have to check the identifier, too.
    if( isQuickMix ) {
        [self setQuickMixStation:station];
        NSMenuItem *quickMixStationMenuItem = [_stationsMenu itemWithTitle:PBQuickMixMenuItemTitle];
        if( ! quickMixStationMenuItem ) {
            NSLog(@"BUG:Couldn't find QuickMix station menu item");
            return;
        }        
        [quickMixStationMenuItem setEnabled:YES];
        [quickMixStationMenuItem setRepresentedObject:station];

    }
    else {
        [[self stationList] addObject:station];
        NSMenuItem *menuItem = [_stationsMenu insertItemWithTitle:name
                                                        action:@selector(changeStation:)
                                                 keyEquivalent:@""
                                                          atIndex:[_stationsMenu numberOfItems] - 2];
        [menuItem setTarget:[Controller sharedController]];
        [menuItem setRepresentedObject:station];
    }
}

- (Station *)stationForIdentifier:(NSString*)stationId {
    NSEnumerator *e = [[self stationList] objectEnumerator];
    Station *station;
    while( station = [e nextObject] ) {
        if( [[station identifier] isEqualToString:stationId] ) {
            return station;
        }
    }
    return nil;
}

- (void)setCurrentStationFromIdentifier:(NSString*)stationId {
    NSLog(@"DEBUG: setCurrentStationFromIdentifier:%@:%@", stationId, [[self stationForIdentifier:stationId] name]);
    [self setCurrentStation:[self stationForIdentifier:stationId]];
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
