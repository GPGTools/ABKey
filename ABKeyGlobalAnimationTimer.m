//
//  ABKeyGlobalAnimationTimer.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 03/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyGlobalAnimationTimer.h"


@implementation ABKeyGlobalAnimationTimer

id sharedAnimationTimer=nil;

+(ABKeyGlobalAnimationTimer *)sharedController
{
  if(sharedAnimationTimer==nil)
	sharedAnimationTimer=[[ABKeyGlobalAnimationTimer alloc] init];
  return sharedAnimationTimer;
}



-(id)init
{
  if([super init])
  {
	interestedParties=[[NSNotificationCenter alloc] init];
	interestedPartiesCount=0;
	animationTimer=nil;
  }
  return self;
}



-(void)startAnimationTimer
{
//  NSLog(@"Initiating animation timer");
  animationTimer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animationTimerEvent:) userInfo:nil repeats:YES];
}
 

-(void)animationTimerEvent:(NSTimer *)theTimer
{
//  NSLog(@"Sending animation notification");
  [interestedParties postNotificationName:@"animationTimerEvent" object:nil];
}


-(void)addToGlobalAnimationTimer:(id)observer selector:(SEL)selector
{
//  NSLog(@"Adding animation timer observer %@",[observer description]);
  [interestedParties addObserver:observer selector:selector name:@"animationTimerEvent" object:nil];
  interestedPartiesCount++;
  if(interestedPartiesCount==1 && animationTimer==nil)
	[self startAnimationTimer];
}


-(void)removeObserver:(id)observer
{
//  NSLog(@"Removing animation timer observer %@",[observer description]);
  [interestedParties removeObserver:observer];
  interestedPartiesCount--;
  if(interestedPartiesCount==0)
  {
//	NSLog(@"Invalidating animation timer");
	[animationTimer invalidate];
	animationTimer=nil;
  }
}




//What other classes see

+(void)addToGlobalAnimationTimer:(id)observer selector:(SEL)selector
{[[self sharedController] addToGlobalAnimationTimer:observer selector:selector];}

+(void)removeObserver:(id)observer
{[[self sharedController] removeObserver:observer];}


@end
