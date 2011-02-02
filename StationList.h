//
//  StationList.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Station.h"

@interface StationList : NSObject /*<NSXMLParserDelegate> */{
    NSMutableArray *_stationList;

    BOOL _parsingStationIsQuickMix;
    NSString *_parsingStationName;
    NSString *_parsingKey;
    NSMutableString *_parsingString;
    
    Station *_currentStation;
    Station *_quickMixStation;
    
    NSImage *_playImage;
    NSImage *_noPlayImage;
    
    IBOutlet NSMenu *_stationsMenu;
}

+ (StationList *)sharedStationList;

- (Station *)currentStation;
- (void)setCurrentStation:(Station *)value;

- (NSArray *)stationList;

- (Station *)nextStation;
- (Station *)previousStation;

- (void)initFromData:(NSData *)data;

- (Station *)stationForIdentifier:(NSString*)stationId;
- (void)setCurrentStationFromIdentifier:(NSString*)stationId;

- (Station *)quickMixStation;

@end
