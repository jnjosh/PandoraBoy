//
//  PreferencePaneController.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferencesPaneController.h"


@implementation PreferencesPaneController

- (NSImage*)image
{
	NSImage *image;
	if( imageView ) {
		image = [imageView image];
	} else {
		image = [NSImage imageNamed:nibName];
	}
	if( !image ) {
		image = [NSImage imageNamed:@"NSPreferencesGeneral"];
	}
	
	return image;
}	

- (NSString*)label
{
	NSString *label;
	if( labelView ) {
		label = [labelView stringValue];
	} else {
		label = identifier;
	}
	return label;
}

- (NSView*)mainView
{
	return mainView;
}

- (id)initWithIdentifier:(NSString*)anIdentifier
{
	[super init];
	
	identifier = [anIdentifier copy];
	nibName = [@"Preferences" stringByAppendingString:anIdentifier];

	[NSBundle loadNibNamed:nibName owner:self];
	return self;
}

@end
