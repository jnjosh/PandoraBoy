//
//  FullScreenPreferencesController.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FullScreenPreferencesController.h"
#import "PBView.h"

@interface OutlineItem : NSObject {
	NSString *string;
	id representedObject;
	NSMutableArray *children;
}
- (id)initWithString:(NSString*)aString representedObject:(id)anObject;
+ (id)itemWithString:(NSString*)aString representedObject:anObject;
- (NSString*)string;
- (id)representedObject;
- (NSMutableArray*)children;
@end

@implementation OutlineItem

- (id)initWithString:(NSString*)aString representedObject:(id)anObject
{
	[super init];
	string = [aString copy];
	representedObject = [anObject retain];
	children = [[NSMutableArray alloc] init];
	return self;
}

+ (id)itemWithString:(NSString*)aString representedObject:anObject
{
	return [[[OutlineItem alloc] initWithString:aString representedObject:anObject] autorelease]; 
}

- (NSString*)string
{
	return string;
}

- (NSMutableArray*)children
{
	return children;
}

- (id)representedObject
{
	return representedObject;
}

@end

@implementation FullScreenPreferencesController

- (void)awakeFromNib
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

	NSString *pluginDir = [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"Views"];
    if( ! [fileManager fileExistsAtPath:pluginDir] ) {
        NSLog(@"ERROR: Couldn't find plugin views directory:%@", pluginDir);
        return;
    }
	
	outlineRoots = [[NSMutableArray alloc] init];
	OutlineItem *builtInRoot = [OutlineItem itemWithString:@"Built-in" representedObject:nil];
	[outlineRoots addObject:builtInRoot];
	
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:pluginDir];
    NSString *pluginName;
    while( pluginName = [dirEnumerator nextObject] ) {
		if( ! [[pluginName pathExtension] isEqual:@"pbview"] ) {
			continue;
		}
		pluginName = [pluginName stringByDeletingPathExtension];
		
		NSView *preview = [PBView previewFromBundleNamed:pluginName withFrame:[previewView bounds]];
		[[builtInRoot children] addObject:[OutlineItem itemWithString:pluginName representedObject:preview]];
	}
	[outlineView expandItem:nil expandChildren:YES];
	
	//FIXME: This isn't setting the keyboard focus properly.
	[[outlineView window] makeFirstResponder:outlineView];
}

- (IBAction)performTest:(id)sender
{
}

- (IBAction)performOptions:(id)sender
{
}

#pragma mark NSOutlineDataSource delegates

- (id)outlineView:(NSOutlineView *)outlineView child:(unsigned)index ofItem:(id)item
{
	return (item == nil) ? [outlineRoots objectAtIndex:index] : [[item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return (item == nil) ? ([outlineRoots count] > 0) : ([[item children] count] > 0);
}

- (unsigned)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return (item == nil) ? [outlineRoots count] : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return [item string];
}

#pragma mark NSOutlineView delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return( [item representedObject] != nil );
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	id imageView = [[outlineView itemAtRow:[outlineView selectedRow]] representedObject];
	if( [imageView respondsToSelector:@selector(startView)] ) {
		[imageView startView];
	}
	[imageView setFrame:[previewView bounds]];
	[previewView addSubview:imageView];
}

@end
