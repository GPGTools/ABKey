//
//  ABMainWindowControllerPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 02/04/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABMainWindowControllerPatches.h"
#import "PatchingFunctions.h"


@implementation ABMainWindowControllerPatches

+(void)initialize
{    
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABMainWindowControllerPatches", @selector(validateMenuItem:), @"ABMainWindowController", @"originalValidateMenuItem:"); 
  
  registerMethodWithNewClass(@"ABMainWindowControllerPatches", @selector(registerForRefreshNotifications),@"ABMainWindowController");
  
  registerMethodWithNewClass(@"ABMainWindowControllerPatches", @selector(refreshNotification:),@"ABMainWindowController");
}


-(BOOL)validateMenuItem:(id)sender
{
  if([sender tag]==255)//GPGMail Options info
	return ![[self inputController] isFieldVisible:@"GPGOptions"];
  
  return [self originalValidateMenuItem:sender];
}



-(void)registerForRefreshNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:@"GPGKeyringChangedNotification" object:nil];
}



-(void)refreshNotification:(NSNotification *)notification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ABTemplateLayoutHasChanged" object:nil userInfo:nil];
}

@end
