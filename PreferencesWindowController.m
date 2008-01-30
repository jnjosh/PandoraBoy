/****************************************************************************
 *  Copyright 2006 Aaron Rolett                                             *
 *  arolett@mail.rochester.edu                                              *
 *                                                                          *
 *  This file is part of PandoraBoy.                                        *
 *                                                                          *
 *  PandoraBoy is free software; you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by    * 
 *  the Free Software Foundation; either version 2 of the License, or       *
 *  (at your option) any later version.                                     *
 *                                                                          *
 *  PandoraBoy is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           * 
 *  GNU General Public License for more details.                            *
 *                                                                          *
 *  You should have received a copy of the GNU General Public License       * 
 *  along with PandoraBoy; if not, write to the Free Software Foundation,   *
 *  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA          *
 ***************************************************************************/

#import "PreferencesWindowController.h"
#import "PreferencesPaneController.h"
#import "GlobalHotkey.h"

// FIXME (move to Controller)
//NSArray *toolbarItemIdentifiers = { @"General", @"Hotkeys", @"Fullscreen" };

@interface PreferencesWindowController (PrivateAPI)
-(void)addPreferencePaneWithIdentifier:(NSString*)name;
@end

@implementation PreferencesWindowController

-(id)initWithIdentifiers:(NSArray*)someIdentifiers
{
	[super initWithWindowNibName:@"Preferences"];
	
	panes = [[NSMutableDictionary alloc] init];

	identifiers = [someIdentifiers copy];
	NSEnumerator *e = [identifiers objectEnumerator];
	NSString *identifier;
	while ( identifier = [e nextObject] ) {
		[self addPreferencePaneWithIdentifier:identifier];
	}
	
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Preferences"];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:NO];

	identifier = [identifiers objectAtIndex:0];
	[toolbar setSelectedItemIdentifier:identifier];
	[[self window] setToolbar:toolbar];
	[self performToolbarItem:[[toolbar items] objectAtIndex:0]];
	
	[self applyPreferences];
	
	return self;
}

-(void)dealloc {
	[identifiers release];
	[panes release];
	[super dealloc];
}

- (void)addPreferencePaneWithIdentifier:(NSString*)identifier
{
	PreferencesPaneController *pc = [[PreferencesPaneController alloc] initWithIdentifier:identifier];
	
	NSToolbarItem *tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
	[tbItem setLabel:[pc label]]; 
	[tbItem setToolTip:[pc label]];
	[tbItem setTarget:self];
	[tbItem setImage:[pc image]];
	[tbItem setAction:@selector(performToolbarItem:)];
	
	NSDictionary *paneDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  pc, @"paneController",
							  tbItem, @"toolbarItem",
							  nil];
	[pc release];
	[tbItem release];
	
	[panes setObject:paneDict forKey:identifier];
}

- (NSArray*)toolbarItemIdentifiers
{
	return identifiers;
}

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString*)identifier
{
	return [[panes objectForKey:identifier] objectForKey:@"toolbarItem"];
}

- (IBAction)performToolbarItem:(id)sender
{
	NSString *identifier = [sender itemIdentifier];
	PreferencesPaneController *pc = [[panes objectForKey:identifier] objectForKey:@"paneController"];
	
	NSWindow *win = [self window];
	NSView *v = [pc mainView];
	
	NSSize currentSize = [[win contentView] frame].size;
	NSSize newSize = [v frame].size;
	float dWidth = newSize.width - currentSize.width;
	float dHeight = newSize.height - currentSize.height;
	NSRect winFrame = [win frame];
	winFrame.size.height += dHeight;
	winFrame.origin.y    -= dHeight;
	winFrame.size.width  += dWidth;
	
	[win setContentView:[pc mainView]];
	[win setFrame:winFrame display:YES animate:YES];
}

#pragma mark NSToolbar delegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)flag
{
	return [self toolbarItemWithIdentifier:identifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return [self toolbarItemIdentifiers];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [self toolbarItemIdentifiers];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarItemIdentifiers];
}

//
//
//
//
//- (NSRect)makePreferenceWindowRect:(int)offset
//{
//  NSRect prefFrame = [prefWindow frame]; 
//  NSRect rect = NSMakeRect(prefFrame.origin.x, 
//			   prefFrame.origin.y - (offset - prefFrame.size.height),
//			   prefFrame.size.width,
//			   offset);		
//  return rect; 
//}
//
//- (void)switchToGeneralTab {
//  [prefTabs selectTabViewItemAtIndex:0];
//  NSRect rect = [self makePreferenceWindowRect:250];
//  [prefWindow setFrame:rect display:YES animate:YES];
//}
//
//- (void)switchToHotKeysTab {
//  [prefTabs selectTabViewItemAtIndex:1];
//  NSRect rect = [self makePreferenceWindowRect:375];
//  [prefWindow setFrame:rect display:YES animate:YES];
//}
//
//- (void)switchToLastFm { 
//  [prefTabs selectTabViewItemAtIndex:2];
//  NSRect rect = [self makePreferenceWindowRect:260];
//  [prefWindow setFrame:rect display:YES animate:YES];
//}
//
//
//// Delegates Section for the Toolbar in Prefs
//
//- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag 
//{
//  return [items objectForKey:itemIdentifier];
//}
//
//- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
//{
//  return [items allKeys];
//}
//
//- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
//{
//  NSMutableArray *arr = [[NSMutableArray alloc] init];
//  [arr addObject:@"General"];
//  [arr addObject:@"Hotkeys"];
//  [arr addObject:@"LastFm"];
//  return arr;
//}
//- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
//{
//  return [items allKeys];
//}
//
//- (void)toolbaritemclicked:(NSToolbarItem*)item {
//  //This method switches the tabview based on what toolbar item is clicked
//  if([[item label] isEqualToString: @"General"])
//    {
//      [self switchToGeneralTab]; 
//    }
//  else if([[item label] isEqualToString: @"Hotkeys"])
//    {
//      [self switchToHotKeysTab]; 
//    }
//  else if([[item label] isEqualToString: @"LastFm"])
//    {
//      [self switchToLastFm];
//    }
//}

-(IBAction) applyPreferences {
	[[GlobalHotkey sharedHotkey] unregisterHotkeys];
	[[GlobalHotkey sharedHotkey] registerHotkeys];
}

@end

@implementation PreferencesWindowController (NSWindowDelegate)
-(void)windowWillClose:(NSNotification *)aNotification
{
	[self applyPreferences]; 
}
@end
