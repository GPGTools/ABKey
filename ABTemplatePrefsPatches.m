//
//  ABTemplatePrefsPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 22/01/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABTemplatePrefsPatches.h"
#import "PatchingFunctions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

@implementation ABTemplatePrefsPatches

+(void)initialize
{  
  registerMethodWithNewClass(@"ABTemplatePrefsPatches", @selector(inputController), @"ABTemplatePrefsModule");

  registerMethodWithNewClass(@"ABTemplatePrefsPatches", @selector(preferencesView), @"ABTemplatePrefsModule");

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABTemplatePrefsPatches", @selector(awakeFromNib), @"ABTemplatePrefsModule", @"originalAwakeFromNib");  
  
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABTemplatePrefsPatches", @selector(validateMenuItem:), @"ABTemplatePrefsModule", @"originalValidateMenuItem:"); 
  
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass (@"ABTemplatePrefsPatches", @selector(addField:), @"ABTemplatePrefsModule", @"originalAddField:"); 
}



-(id)inputController
{
  id inputController;
  object_getInstanceVariable(self,"_inputController" ,(void **)&inputController);
  return inputController;
}

-(id)preferencesView
{
  id preferencesView;
  object_getInstanceVariable(self,"_preferencesView" ,(void **)&preferencesView);
  return preferencesView;
}


-(void)awakeFromNib
{
  [self originalAwakeFromNib];
  NSArray *templatePaneElements=[[[[self preferencesView] subviews] lastObject] subviews];
  NSEnumerator *elementEnumerator=[templatePaneElements objectEnumerator];
  id currentElement;
  do
	currentElement=[elementEnumerator nextObject];
  while(currentElement!=nil && ![currentElement isMemberOfClass:[NSPopUpButton class]]);
  
  if(currentElement!=nil)
  {
	NSMenu *theMenu=[currentElement menu];
	//Add GPGMail field to list of toggleable fields in popup
	NSMenuItem *newItem=[theMenu addItemWithTitle:KeyManagerLocalizedString(@"GPGMail Options",@"template preferences menu item") action:@selector(addField:) keyEquivalent:@""];
	[newItem setTag:255];
	[newItem setTarget:[[theMenu itemAtIndex:3] target]];
  }
}



-(BOOL)validateMenuItem:(id)sender
{
  if([sender tag]==255)//GPGMail Options info
	return ![[self inputController] isFieldVisible:@"GPGOptions"];
  
  return (BOOL)[self originalValidateMenuItem:sender];
}



-(void)addField:(id)sender
{
  //  NSLog(@"addField:%@",[sender description]);
  
  if([sender tag]==255) //GPGMail options info
  {
	[[self inputController] setFieldVisible:@"GPGOptions" withBool:YES];
	[self layoutChanged:self];
  }
  else
	[self originalAddField:sender];
}


@end
