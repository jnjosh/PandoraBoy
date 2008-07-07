//
//  APIController.h
//  PandoraBoy
//
//  Created by Rob Napier on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;
@class PlayerController;

@interface APIController : NSObject {
    IBOutlet WebView *apiWebView;
	IBOutlet PlayerController *playerController;
}

- (void)reload;

// Delegate functions from Pandora notification system
- (void) pandoraSongPlayed: (NSString*)name :(NSString*)artist; 
- (void) pandoraSongPaused; 
- (void) pandoraStationPlayed:(NSString*)name :(NSString*)identifier;
- (void) pandoraStarted;


@end
