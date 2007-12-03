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
}

+ (StationList *)sharedStationList;
- (void)initFromData:(NSData *)data;

@end
