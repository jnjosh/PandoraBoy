//
//  PreferencePaneController.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesPaneController : NSObject {
	IBOutlet NSView      *mainView;
	IBOutlet NSImageView *imageView;
	IBOutlet NSTextField *labelView;
	
	NSString *identifier;
	NSString *nibName;
}

- (id)initWithIdentifier:(NSString*)identifier;
- (NSImage*)image;
- (NSString*)label;
- (NSView*)mainView;

@end
