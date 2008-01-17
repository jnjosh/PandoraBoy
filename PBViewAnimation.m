//
//  PBViewAnimation.m
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewAnimation.h"

const NSTimeInterval PBAnimationDefaultDuration = 1.5;

@interface PBViewAnimation (PrivateAPI)
- (void)setStartTime:(NSTimeInterval)value;

@end

@implementation PBViewAnimation

- (id)initWithViewAnimations:(NSArray*)animations startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration
{
	[super initWithViewAnimations:animations];
	[self setStartTime:start];
	[self setDuration:duration];
	[self setAnimationBlockingMode:NSAnimationNonblocking];
	return self;
}

+ (id)animationWithDictionary:(NSDictionary*)dict startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration
{
	NSViewAnimation *animation = [[self alloc] initWithViewAnimations:[NSArray arrayWithObject:dict] startingAt:start duration:duration];
	return [animation autorelease];
}	

+ (id)animationWithDictionary:(NSDictionary*)dict startingAt:(NSTimeInterval)start
{
	return [self animationWithDictionary:dict startingAt:start duration:PBAnimationDefaultDuration];
}

+ (id)animationWithDictionary:(NSDictionary*)dict
{
	return [self animationWithDictionary:dict startingAt:0];
}

- (NSTimeInterval)startTime {
    return startTime;
}

- (void)setStartTime:(NSTimeInterval)value {
    if (startTime != value) {
        startTime = value;
    }
}

- (id)inverse {
	NSArray *viewAnimations = [self viewAnimations];
	NSMutableArray *inverseAnimations = [NSMutableArray arrayWithCapacity:[viewAnimations count]];
	NSDictionary *dict;
	NSEnumerator *e = [viewAnimations objectEnumerator];
	while( dict = [e nextObject] ) {
		NSMutableDictionary *inverse = [NSMutableDictionary dictionaryWithCapacity:2];
		NSString *key;
		NSEnumerator *k = [dict keyEnumerator];
		while( key = [k nextObject] ) {
			id value = [dict objectForKey:key];
			if( [key isEqualToString:NSViewAnimationTargetKey] ) {
				[inverse setObject:value forKey:key];
			} else if( [key isEqualToString:NSViewAnimationStartFrameKey] ) {
				[inverse setObject:value forKey:NSViewAnimationEndFrameKey];
			} else if( [key isEqualToString:NSViewAnimationEndFrameKey] ) {
				[inverse setObject:value forKey:NSViewAnimationStartFrameKey];
			} else if( [key isEqualToString:NSViewAnimationEffectKey] ) {
				if( [value isEqualToString:NSViewAnimationFadeInEffect] ) {
					[inverse setObject:NSViewAnimationFadeOutEffect forKey:key];
				} else {
					[inverse setObject:NSViewAnimationFadeInEffect forKey:key];
				}
			} else {
				NSLog(@"BUG: Bad key (%@) found in viewAnimation: %@", key, self);
				return nil;
			}
		}
		[inverseAnimations addObject:inverse];
	}
	return [[[[self class] alloc] initWithViewAnimations:inverseAnimations
											  startingAt:[self startTime]
												duration:[self duration]] autorelease];
}
@end
