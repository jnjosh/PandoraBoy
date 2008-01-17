//
//  PBMovePandoraAnimation.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBMoveAnimation.h"

@implementation PBMoveAnimation

+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin
{
	return [self animationWithTarget:target toOrigin:toOrigin startingAt:0];
}

+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin startingAt:(NSTimeInterval)start
{
	return [self animationWithTarget:target toOrigin:toOrigin startingAt:start duration:PBAnimationDefaultDuration];
}

+ (id)animationWithTarget:(id)target toOrigin:(NSPoint)toOrigin startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration
{
	NSRect oldFrame = [target frame];
	NSRect newFrame = oldFrame;
	newFrame.origin = toOrigin;
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSValue valueWithRect:oldFrame], NSViewAnimationStartFrameKey,
						  [NSValue valueWithRect:newFrame], NSViewAnimationEndFrameKey,
						  target, NSViewAnimationTargetKey,
						  nil];
	return [super animationWithDictionary:dict startingAt:start duration:duration];
}

@end
