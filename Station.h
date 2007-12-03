//
//  Station.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Station : NSObject {
    NSString *_name;
    NSString *_identifier;
    BOOL _isQuickMix;
}

// Accessors
- (NSString *)name;
- (void)setName:(NSString *)value;
- (NSString *)identifier;
- (void)setIdentifier:(NSString *)value;
- (BOOL)isQuickMix;
- (void)setIsQuickMix:(BOOL)value;


// Initializers
+ (Station *)stationWithName:(NSString*)aName identifier:(NSString*)anIdentifier isQuickMix:(BOOL)isQuickMix;
- (Station *)initWithName:(NSString*)aName identifier:(NSString*)anIdentifier isQuickMix:(BOOL)isQuickMix;

@end
