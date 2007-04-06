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

#import <Carbon/Carbon.h>
#import <WebKit/WebUIDelegate.h>
#import <WebKit/WebPolicyDelegate.h>
#import <WebKit/WebView.h>

@interface Controller : NSObject
{
    IBOutlet WebView *webView;
    IBOutlet NSWindow *pandoraWindow; 
    IBOutlet NSWindow *startupWindow; 
    IBOutlet WebView *notificationView;
}

-(void) loadPandora;
-(IBAction) refreshPandora:(id)sender; 

-(IBAction) displayHelp:(id)sender; 

//WebView delegates 
- (void)webView:(WebView *)sender setFrame:(NSRect)frame;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder;

- (IBAction) checkVersionNumber:(id)sender; 

@end

@interface Controller(NSApplicationNotifications)
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
@end

@interface Controller (NSWindowDelegate)
- (void)windowDidMiniaturize:(NSNotification *)aNotification;
@end
