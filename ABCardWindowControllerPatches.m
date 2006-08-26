//
//  ABCardWindowControllerPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABCardWindowControllerPatches.h"
#import "PatchingFunctions.h"
#import "ABKeyWindowAugmentationsManager.h"
#import "GPGMEController.h"

@implementation ABCardWindowControllerPatches

+(void)initialize
{    
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABCardWindowControllerPatches", @selector(validateMenuItem:), @"ABCardWindowController", @"originalValidateMenuItem:"); 

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABCardWindowControllerPatches", @selector(windowWillClose:), @"ABCardWindowController", @"originalWindowWillClose:");  
  
  registerMethodWithNewClass(@"ABCardWindowControllerPatches", @selector(inputController),@"ABCardWindowController");
}


-(id)inputController
{
  id inputController;
  object_getInstanceVariable(self,"_cardInputController" ,(void **)&inputController);
  return inputController;
}



-(BOOL)validateMenuItem:(id)sender
{
  if([sender tag]==255)//GPGMail Options info
	return ![[self inputController] isFieldVisible:@"GPGOptions"];
  
  return [self originalValidateMenuItem:sender];
}



-(void)windowWillClose:(id)foo
{
  [ABKeyWindowAugmentationsManager removeWindow:[self window]];
  [[GPGMEController sharedController] removeObserver:[self inputController]];
  [self originalWindowWillClose:foo];
}
@end
