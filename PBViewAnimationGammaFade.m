//
//  PBViewAnimationGammaFade.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewAnimationGammaFade.h"


@implementation PBViewAnimationGammaFade

+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)fadeEffect
{
	return [self animationWithTarget:target fadeEffect:fadeEffect startingAt:0];
}

+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)fadeEffect startingAt:(NSTimeInterval)start
{
	return [self animationWithTarget:target fadeEffect:fadeEffect startingAt:start duration:PBAnimationDefaultDuration];
}

+ (id)animationWithTarget:(id)target fadeEffect:(NSString*)fadeEffect startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  fadeEffect, NSViewAnimationEffectKey,
						  target, NSViewAnimationTargetKey,
						  nil];
	return [super animationWithDictionary:dict startingAt:start duration:duration];
}


@end
