//
//  PBAnimation.h
//  PandoraBoy
//
//  Created by Rob Napier on 1/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

const extern const NSTimeInterval PBAnimationDefaultDuration;

@interface PBViewAnimation : NSViewAnimation {
	NSTimeInterval startTime;
}

- (id)initWithViewAnimations:(NSArray*)animations startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration;
+ (id)animationWithDictionary:(NSDictionary*)dict startingAt:(NSTimeInterval)start duration:(NSTimeInterval)duration;
+ (id)animationWithDictionary:(NSDictionary*)dict startingAt:(NSTimeInterval)start;
+ (id)animationWithDictionary:(NSDictionary*)dict;

- (NSTimeInterval)startTime;
- (id)inverse;

@end
