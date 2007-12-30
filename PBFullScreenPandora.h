//
//  PBFullScreenPandora.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBFullScreenPlugin.h"
#import <QuartzComposer/QCView.h>

@interface PBFullScreenPandora : PBFullScreenPlugin <PBFullScreenProtocol> {
    NSRect _oldWindowFrame;
	NSString *_oldAutosaveName;
    int _spacerMargin;
    int _tunerWidth;
    NSWindow *_crawlWindow;
}

@end
