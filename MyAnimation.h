//
//  MyAnimation.h
//  PandoraBoy
//
//  Created by Rob Napier on 12/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyAnimation : NSAnimation {

}

@end

@interface NSObject (MyAnimation)

- (void)updateAnimationForValue:(float)value;

@end
