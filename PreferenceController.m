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

// Some of this preference controller code is taken from PrefController.m which was written by Dustin Bachrach of OpenSoft and released under the GNU GPL

#import "PreferenceController.h"
#import "GlobalHotkey.h"
#import "AppleRemote.h"
//#import "KeyChain.h"

@implementation PreferenceController

-(id)init
{
  if(self = [super init]) {
    items=[[NSMutableDictionary alloc] init];
  }
  return self;
}

-(void)dealloc {
  [items dealloc];
  [super dealloc];
}

- (NSRect)makePreferenceWindowRect:(int)offset
{
  NSRect prefFrame = [prefWindow frame]; 
  NSRect rect = NSMakeRect(prefFrame.origin.x, 
			   prefFrame.origin.y - (offset - prefFrame.size.height),
			   prefFrame.size.width,
			   offset);		
  return rect; 
}

- (void)switchToGeneralTab {
  [prefTabs selectTabViewItemAtIndex:0];
  NSRect rect = [self makePreferenceWindowRect:250];
  [prefWindow setFrame:rect display:YES animate:YES];
}

- (void)switchToHotKeysTab {
  [prefTabs selectTabViewItemAtIndex:1];
  NSRect rect = [self makePreferenceWindowRect:355];
  [prefWindow setFrame:rect display:YES animate:YES];
}

- (void)switchToLastFm { 
  [prefTabs selectTabViewItemAtIndex:2];
  NSRect rect = [self makePreferenceWindowRect:260];
  [prefWindow setFrame:rect display:YES animate:YES];
}

-(void)awakeFromNib {
  NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:NO];
  [toolbar setAutosavesConfiguration:NO];
	
  [self addItemToToolbar:@"General" withImage:@"General.tiff"];
  [self addItemToToolbar:@"Hotkeys" withImage:@"KeyboardIcon"];
  //[self addItemToToolbar:@"LastFm" withImage:@"lastfm.icns"];
  [self applyPreferences]; // This function should really be called refreshHotkeyTitles ... change it? 

  [toolbar setSelectedItemIdentifier:@"General"];
  [prefWindow setToolbar:toolbar];
  
  [self switchToGeneralTab];
}

/*
- (NSString *) getUsername { 
  NSString *username = [[NSUserDefaults standardUserDefaults] 
			 stringForKey:@"LastFmUsername"];
  return username; 
} 

- (NSString *) getPassword { 
  NSString *username = [self getUsername]; 
  if(username) {
    NSDictionary *keychain = [KeyChain accessToKeyChain:@"Load" user:username pw:nil];
    NSString *authpw = [keychain objectForKey:@"Password"];
    if(authpw) {
      NSLog(@"Password from keychain: %@", authpw); 
    }
    return authpw;
  }
  return nil; 
}
*/

// Delegates Section for the Toolbar in Prefs

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag 
{
  return [items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
  return [items allKeys];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  [arr addObject:@"General"];
  [arr addObject:@"Hotkeys"];
  [arr addObject:@"LastFm"];
  return arr;
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  return [items allKeys];
}

- (void)toolbaritemclicked:(NSToolbarItem*)item {
  //This method switches the tabview based on what toolbar item is clicked
  if([[item label] isEqualToString: @"General"])
    {
      [self switchToGeneralTab]; 
    }
  else if([[item label] isEqualToString: @"Hotkeys"])
    {
      [self switchToHotKeysTab]; 
    }
  else if([[item label] isEqualToString: @"LastFm"])
    {
      [self switchToLastFm];
    }
}

/*
-(IBAction)setUsername:(id)sender 
{
//  NSLog(@"Username: %@", LastFmUsername);
}

-(IBAction)setPassword:(id)sender 
{
  NSLog(@"Password: %@", LastFmPassword);
}

*/

- (IBAction)setUsername:(id)sender {
    // FIXME: Implement
    NSLog(@"WARN:setUsername not implemented.");
}

- (IBAction)setPassword:(id)sender {
    // FIXME: Implement
    NSLog(@"WARN:setPassword not implemented.");
}

-(IBAction) applyPreferences{
  [[GlobalHotkey sharedHotkey] unregisterHotkeys];
  [[GlobalHotkey sharedHotkey] registerHotkeys];

  if([[NSUserDefaults standardUserDefaults] boolForKey:@"AppleRemoteEnabled"]==YES) {
    [[AppleRemote sharedRemote] setOpenInExclusiveMode:false];
    [[AppleRemote sharedRemote] setListeningToRemote:true];
  }
  else {
    [[AppleRemote sharedRemote] setOpenInExclusiveMode:false];
    [[AppleRemote sharedRemote] setListeningToRemote:false];
  }

//  NSString *username = [[NSUserDefaults standardUserDefaults] 
//			stringForKey:@"LastFmUsername"];
//  if(username != nil && LastFmPassword != nil) 
//    [KeyChain accessToKeyChain:@"Save" user:username pw:LastFmPassword];
}

-(void) addItemToToolbar:(NSString*)name withImage:(NSString*)imageName
{
  NSToolbarItem *item=[[NSToolbarItem alloc] initWithItemIdentifier: name];
  [item setPaletteLabel: name]; 
  [item setLabel: name]; 
  [item setToolTip: name]; // tooltip
  [item setTarget:self];
  [item setImage:[NSImage imageNamed: imageName]];
  [item setAction:@selector(toolbaritemclicked:)];
  [items setObject:item forKey: name]; // add to toolbar list
  [item release];
}

@end

@implementation PreferenceController (NSWindowDelegate)
-(void)windowWillClose:(NSNotification *)aNotification
{
  NSLog(@"In HandlePrefWindowClose");
  [self applyPreferences]; 
}
@end
