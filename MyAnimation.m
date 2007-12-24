//
//  MyAnimation.m
//  PandoraBoy
//
//  Created by Rob Napier on 12/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MyAnimation.h"

@implementation MyAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    [super setCurrentProgress:progress];
    [[self delegate] updateAnimationForValue:[self currentValue]];
}

@end
