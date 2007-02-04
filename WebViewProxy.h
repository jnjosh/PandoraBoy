//
//  WebViewProxy.h
//  PandoraBoy
//
//  Created by Aaron Rolett on 11/24/06.
//  Copyright 2006 Aaron Rolett. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>
#import "WebFrameProxy.h"

@interface WebViewProxy : NSObject {

}

-(void) loadRequest: (NSURLRequest*) request;
-(void) _setTopLevelFrameName: (NSString*) name; 
-(WebFrameProxy *)mainFrame; 
- (id) _UIDelegateForwarder;
@end
