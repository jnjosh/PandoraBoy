//
//  Station.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
// isCreator         : boolean
// originalStationId : string (may be null)
// genre             : string[]
// originalCreatorId : string (numeric)
// initialSeed       : seedId:string
//                     artist:isComposer:boolean
//                            likelyMatch:boolean
//                            artistName:string
//                            musicId:"R1119"
//                            score:?
//                     musicId:"R1119"
// isNew             : boolean
// transformType     : "TRANSFORM_CONFIRM"
// stationIdToken    : "2e4fa3c3ca8859322301abbd7e98baee425ba2910f7abf8b"
// isQuickMix        : boolean
// stationName       : string
// stationId         : string (numeric)

#import "Station.h"
#import "StationList.h"

@implementation Station

// Accessors
- (NSString *)name {
    return [[_name retain] autorelease];
}

- (void)setName:(NSString *)value {
    if (_name != value) {
        [_name release];
        _name = [value copy];
    }
}

- (NSString *)identifier {
    return [[_identifier retain] autorelease];
}

- (void)setIdentifier:(NSString *)value {
    if (_identifier != value) {
        [_identifier release];
        _identifier = [value copy];
    }
}

- (BOOL)isQuickMix {
    return _isQuickMix;
}

- (void)setIsQuickMix:(BOOL)value {
    if (_isQuickMix != value) {
        _isQuickMix = value;
    }
}

// Initializers
+ (Station *)stationWithName:(NSString*)aName identifier:(NSString*)anIdentifier isQuickMix:(BOOL)isQuickMix {
    return [[[Station alloc] initWithName:aName identifier:anIdentifier isQuickMix:isQuickMix] autorelease];
}

- (Station *)initWithName:(NSString*)aName identifier:(NSString*)anIdentifier isQuickMix:(BOOL)isQuickMix {
	if ( self = [super init] ) {
        [self setName:aName];
        [self setIdentifier:anIdentifier];
        [self setIsQuickMix:isQuickMix];
    }
	return self;
}

// NSScriptObjectSpecifiers protocol

- (NSScriptObjectSpecifier *)objectSpecifier{
    unsigned index = [[[StationList sharedStationList] stationList] indexOfObjectIdenticalTo:self];
    
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[NSApp class]];
    
    return [[[NSIndexSpecifier allocWithZone:[self zone]] 
            initWithContainerClassDescription:containerClassDesc
                           containerSpecifier:nil key:@"stations" index:index] autorelease];
}

@end
