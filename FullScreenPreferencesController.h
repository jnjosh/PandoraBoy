//
//  FullScreenPreferencesController.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OutlineItem;

@interface FullScreenPreferencesController : NSObject {
	IBOutlet NSView *previewView;
	IBOutlet NSOutlineView *outlineView;
	
	NSMutableArray *outlineRoots;
}

- (IBAction)performOptions:(id)sender;
- (IBAction)performTest:(id)sender;
@end
