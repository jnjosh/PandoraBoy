//
//  StationList.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Station.h"

@interface StationList : NSObject {
    NSMutableArray *_stationList;

    BOOL _parsingStationIsQuickMix;
    NSString *_parsingStationName;
    NSString *_parsingKey;
    NSMutableString *_parsingString;
    
    Station *_currentStation;
    Station *_quickMixStation;
    
    IBOutlet NSMenu *_stationsMenu;
}

+ (StationList *)sharedStationList;

- (Station *)currentStation;
- (void)setCurrentStation:(Station *)value;

- (void)initFromData:(NSData *)data;

- (Station *)stationForIdentifier:(NSString*)stationId;
- (void)setCurrentStationFromIdentifier:(NSString*)stationId;

@end
