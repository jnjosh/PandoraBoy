//
//  PBMovePandoraAnimation.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBViewAnimation.h"

@interface PBMoveAnimation : PBViewAnimation {

}

+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin;
+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin startingAt:(NSTimeInterval)start;
+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration;

@end
