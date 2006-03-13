//
//  ABKeyGlobalAnimationTimer.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 03/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ABKeyGlobalAnimationTimer : NSObject
{
  NSNotificationCenter *interestedParties;
  int interestedPartiesCount;
  NSTimer *animationTimer;
}

+(void)addToGlobalAnimationTimer:(id)observer selector:(SEL)selector;
+(void)removeObserver:(id)observer;

@end
