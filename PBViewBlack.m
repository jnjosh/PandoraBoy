//
//  PandoraBoyViewBlack.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewBlack.h"
#import "PBMoveAnimation.h"

@implementation PBViewBlack

- (void)prepare
{
	[super prepare];
	[self addAnimation:[PBMoveAnimation animationWithTarget:self
													 toOrigin:NSZeroPoint
												 startingAt:PBAnimationDefaultDuration / 2]];
}

@end
