//
//  PBViewAnimationGammaFade.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBViewAnimation.h"

@interface PBViewAnimationGammaFade : PBViewAnimation {

}

+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)viewAnimationFadeEffect;
+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)viewAnimationFadeEffect startingAt:(NSTimeInterval)start;
+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)viewAnimationFadeEffect startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration;

@end
