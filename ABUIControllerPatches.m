//
//  ABUIControllerPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 27/04/2005.
//  Copyright 2005 far-blue. All rights reserved.
//

#import "ABUIControllerPatches.h"
#import "PatchingFunctions.h"
#import "ABKeyWindowAugmentationsManager.h"

@implementation ABUIControllerPatches

+(void)initialize
{
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABUIControllerPatches", @selector(switchLayoutTo:withAnimation:), @"ABUIController", @"originalSwitchLayoutTo:withAnimation:");  
  
  //registerMethodWithNewClass(@"ABInputControllerPatches", @selector(templateMode), @"ABInputController");
}

-(void)switchLayoutTo:(int)layout withAnimation:(BOOL)animate
{
  [ABKeyWindowAugmentationsManager adjustAugmentationsInWindow:[self window] forLayout:layout];
  [self originalSwitchLayoutTo:layout withAnimation:animate];
}

@end
