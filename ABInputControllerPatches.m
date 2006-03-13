//
//  ABInputControllerPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 20/01/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABInputControllerPatches.h"
#import "PatchingFunctions.h"
#import "GPGMEController.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"
#import "ABKeyAttachmentCell.h"
#import "ABKeyWindowAugmentationsManager.h"

@implementation ABInputControllerPatches

+(void)initialize
{
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(_setupDefaultTextViewContent), @"ABInputController", @"original_setupDefaultTextViewContent");  
  
  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(templateMode), @"ABInputController");
  
  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(importMode), @"ABInputController");

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(valueForProperty:), @"ABInputController", @"originalValueForProperty:");

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(setFieldVisible:withBool:), @"ABInputController", @"originalSetFieldVisible:withBool:"); 

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(isFieldVisible:), @"ABInputController", @"originalIsFieldVisible:"); 

  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(clearField:), @"ABInputController", @"originalClearField:"); 
  
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(addFieldWithNoPopup:), @"ABInputController", @"originalAddFieldWithNoPopup:"); 
  
  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(changeGPGOptionPreferenceForKey:toNewValue:), @"ABInputController");

  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(GPGOptionChangeAction:), @"ABInputController");
  
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass( @"ABInputControllerPatches", @selector(fieldContentsForProperty:), @"ABInputController", @"originalFieldContentsForProperty:");
  
  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(  textView:clickedOnCell:inRect:atIndex:), @"ABInputController");
  
  registerMethodWithNewClass(@"ABInputControllerPatches", @selector(refreshGPGKey:), @"ABInputController");
  
  registerMethodWithNewClass(@"ABInputControllerPatches",@selector(gpgEmailSearch:), @"ABInputController");

  registerMethodWithNewClass(@"ABInputControllerPatches",@selector(gpgEmailSearchStatus:), @"ABInputController");  
  
}



//Rendering Patches



-(void)_setupDefaultTextViewContent
{
  id textView;
  GPGContext *context;
  NSArray *keys;
  int topInsertionPoint, compositeEditMode;
    
  [self original_setupDefaultTextViewContent];
  
  //don't do anything to modify the duplicate import comparison window content
  if([self importMode])
	return;
  
  textView=[self textView];
//  NSLog([[textView textStorage] description]);
    
  //retrieve the gpg keys for the card
  context=[[GPGContext alloc] init];
  keys=[[GPGMEController keysForRecord:[self displayedCard] gpgContext:context] retain];
    
  compositeEditMode=([self editMode]?1+([self templateMode]?1:0):0);
  //find the top insertion point
  topInsertionPoint=[textView findTopInjectionPointAndTidyUpHeaderSpaceForEditMode:compositeEditMode];
  //inject the gpg key info fields 
  if(![self editMode] && keys!=nil && [keys count]!=0)
	topInsertionPoint=[textView injectGPGKeyFields:keys atInsertionPoint:topInsertionPoint withInputController:self];
  
  [keys release];
  [context release];

  //insert the gpg mail options fields
  if([self isFieldVisible:@"GPGOptions"])
  {
	int insertionPoint;
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"ABKeyGPGMailOptionsDisplayLocation"]==0)
	  insertionPoint=topInsertionPoint;
	else
	  insertionPoint= [textView findBottomInjectionPoint];
	
	[textView injectGPGOptionsFields:[[self displayedCard] valueForProperty:@"GPGOptions"] atInsertionPoint:insertionPoint withInputController:self editMode:compositeEditMode];
  }

  
  //setup window augmentations
  if(![self templateMode] && [[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayEmailSearchButton"])
  {
	[ABKeyWindowAugmentationsManager augmentWindow:[textView window] controller:self];
	
	if([self editMode] || [[[self displayedCard] valueForProperty:kABEmailProperty] count]==0)
	  [ABKeyWindowAugmentationsManager setAugmentationsEnabled:NO forWindow:[textView window]];
	else
	  [ABKeyWindowAugmentationsManager setAugmentationsEnabled:YES forWindow:[textView window]];
  
	//remove any old registrations for gpgme async notifications and (re)register for the current ABPerson
	[[GPGMEController sharedController] removeObserver:self];
	[[GPGMEController sharedController] add:self selector:@selector(gpgEmailSearchStatus:) forAsyncGPGOperationsConcerningIdentifier:[[self displayedCard] uniqueId]];
  }
       

//  NSLog([[textView textStorage] description]);
}



-(BOOL)templateMode
{return [[self displayedCard] isEmptyPerson];}

-(BOOL)importMode
{return (![self templateMode] && [[[self textView] window] delegate]==nil);}


-(id)valueForProperty:(id)field
{
//  NSLog([field description]);
  id returnValue;
  if([self templateMode])
	return [self originalValueForProperty:field];

  if([field hasPrefix:@"GPGKey"])
  {
	NSArray *keyComponents=[field componentsSeparatedByString:@"."];
	returnValue=[NSString stringWithFormat:@"%@ %@ %@",[keyComponents objectAtIndex:1],[keyComponents objectAtIndex:2],[keyComponents objectAtIndex:3]];
  }
  else if([field hasPrefix:@"GPGOptions"])
  {
	NSDictionary *GPGOptionsDictionary=[[self displayedCard] valueForProperty:@"GPGOptions"];
	   
	if([field hasSuffix:@"Sign"])
	  returnValue=[NSString stringWithFormat:@"%@",
		([GPGOptionsDictionary objectForKey:@"GPGMailSign"]==nil?KeyManagerLocalizedString(@"default signing",@"option setting"):
		 ([[GPGOptionsDictionary objectForKey:@"GPGMailSign"] boolValue]?KeyManagerLocalizedString(@"always sign",@"option setting"):KeyManagerLocalizedString(@"never sign",@"option setting"))
		 )];
	  else if([field hasSuffix:@"Encrypt"])
		returnValue=[NSString stringWithFormat:@"%@",
		  ([GPGOptionsDictionary objectForKey:@"GPGMailEncrypt"]==nil?KeyManagerLocalizedString(@"default encrypting",@"option setting"):
		   ([[GPGOptionsDictionary objectForKey:@"GPGMailEncrypt"] boolValue]?KeyManagerLocalizedString(@"always encrypt",@"option setting"):KeyManagerLocalizedString(@"never encrypt",@"option setting"))
		   )];

	  else if([field hasSuffix:@"PGP/Mime"])
		returnValue=[NSString stringWithFormat:@"%@",
		  ([GPGOptionsDictionary objectForKey:@"GPGMailUseMime"]==nil?KeyManagerLocalizedString(@"default message format",@"option setting"):
		   ([[GPGOptionsDictionary objectForKey:@"GPGMailUseMime"] boolValue]?KeyManagerLocalizedString(@"use mime message format",@"option setting"):KeyManagerLocalizedString(@"use inline message format",@"option setting"))
		   )];
	  
  }
  else
	returnValue=[self originalValueForProperty:field];
  
  //NSLog(@"%@: %@",[field description],[returnValue description]);
  return returnValue;
}



//GPGMail Options enable/disable patches



-(void)setFieldVisible:(id)field withBool:(BOOL)value
{
//    NSLog(@"setFieldVisible:%@ withBool:%i",[field description],value);
if([field hasPrefix:@"GPGOptions"])
  {
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"ABKeyGPGMailOptionsVisible"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ABTemplateLayoutHasChanged" object:self userInfo:nil];
	[self refreshDisplayedCard];
  }
  else
	[self originalSetFieldVisible:field withBool:value];
}



-(BOOL)isFieldVisible:(id)field
{
//    NSLog(@"isFieldVisible:%@",field);
  if([field hasPrefix:@"GPGOptions"])
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyGPGMailOptionsVisible"];
  else
	return [self originalIsFieldVisible:field];
}



-(void)clearField:(id)field
{
//  NSLog(@"clearField:%@",[field description]);

  if([[field objectForKey:@"ABCardItemRulerProperty"] hasPrefix:@"GPGOptions"])
  {
	[self setFieldVisible:@"GPGOptions" withBool:NO];
	[self refreshDisplayedCard];
  }
  else
	[self originalClearField:field];
}


-(void)addFieldWithNoPopup:(int)sender
{
//  NSLog(@"add field sender:%i",sender);
  if(sender==255) //GPGMail Options
	[self setFieldVisible:@"GPGOptions" withBool:YES];
  else
	[self originalAddFieldWithNoPopup:sender];
}


//Edit mode patches



//When the user edits one of the mode options, this method is called
-(void)changeGPGOptionPreferenceForKey:(int)key toNewValue:(int)value
{
  NSMutableDictionary *GPGOptionsDictionary=[NSMutableDictionary dictionaryWithDictionary:[[self displayedCard] valueForProperty:@"GPGOptions"]];
  switch(key)
  {
	case 0:
	  switch(value)
	  {
		case 0:
		  [GPGOptionsDictionary removeObjectForKey:@"GPGMailSign"];
		  break;
		case 1:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"GPGMailSign"];
		  break;
		case 2:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"GPGMailSign"];
		  break;
	  }
	  break;
  
	case 1:
	  switch(value)
	  {
		case 0:
		  [GPGOptionsDictionary removeObjectForKey:@"GPGMailEncrypt"];
		  break;
		case 1:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"GPGMailEncrypt"];
		  break;
		case 2:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"GPGMailEncrypt"];
		  break;
	  }
	  break;
	case 2:
	  switch(value)
	  {
		case 0:
		  [GPGOptionsDictionary removeObjectForKey:@"GPGMailUseMime"];
		  break;
		case 1:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"GPGMailUseMime"];
		  break;
		case 2:
		  [GPGOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"GPGMailUseMime"];
		  break;
	  }
	  break;
  }
  
  if([GPGOptionsDictionary count]==0)
	[[self displayedCard] removeValueForProperty:@"GPGOptions"];
  else
	[[self displayedCard] setValue:GPGOptionsDictionary forProperty:@"GPGOptions"];
}


-(void)GPGOptionChangeAction:(id)sender
{
  [self changeGPGOptionPreferenceForKey:[sender tag] toNewValue:[sender indexOfSelectedItem]];
  [[self textView] setNeedsDisplay:YES];
}



//attachment cell click events

-(void)textView:(NSTextView *)aTextView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(unsigned)charIndex
{
  if([cell isKindOfClass:[ABKeyAttachmentCell class]])
  {
	[cell mouseClicked];
  }
}



//Tooltip patch

-(id)fieldContentsForProperty:(id)property
{
//  NSLog(@"fieldContents: %@",[property description]);
  if([property hasPrefix:@"GPGKey"])
  {
	NSString *keyString=[[property componentsSeparatedByString:@"."] objectAtIndex:1];
	GPGContext *keyToolTipContext=[[GPGContext alloc] init];
	GPGKey *theKey=[[keyToolTipContext keyEnumeratorForSearchPattern:keyString secretKeysOnly:NO] nextObject];
	[keyToolTipContext stopKeyEnumeration];
	NSString *toolTip=[NSString stringWithFormat:KeyManagerLocalizedString(@"GPGKey Tooltip",@"tooltip"),[theKey formattedCreationDate],([theKey expirationDate]==nil?KeyManagerLocalizedString(@"never",@"tooltip"):[theKey formattedExpirationDate]),[theKey length],[theKey algorithmDescription],[theKey statusDescription],[theKey formattedFingerprint]];
	[keyToolTipContext release];
	return toolTip;
  }
  else if([property hasPrefix:@"GPGOptions"])
  {
	int gpgSubfieldIndex=NSMaxRange([property rangeOfString:@"."]);
	NSString *tooltip=[NSString stringWithFormat:@"GPGMail %@ setting",[[property substringWithRange:NSMakeRange(gpgSubfieldIndex,[property length]-gpgSubfieldIndex)] lowercaseString]];
	return KeyManagerLocalizedString(tooltip,@"tooltip");
  }
  else
	return [self originalFieldContentsForProperty:property];
}

//key refresh
-(void)refreshGPGKey:(id)sender
{
  NSLog(@"refresh key: %@", [sender description]);
}



//gpg email search button
-(void)gpgEmailSearch:(id)sender
{
  if([sender state]==NSOnState)
  {
	//NSLog(@"Starting search");
	if(![[GPGMEController sharedController] searchKeyServerForMatchesWithPerson:[self displayedCard]])
	  [sender setState:NSOffState];
  }
  else
  {
	//NSLog(@"Cancelling search");
	[[GPGMEController sharedController] interruptAsyncOperationForIdentifier:[[self displayedCard] uniqueId]];
  }
}




-(void)gpgEmailSearchStatus:(NSNotification *)notification
{
  if([[notification object] isEqualToString:@"asyncOperationStarted"])
  {
	NSProgressIndicator *spinner=[ABKeyWindowAugmentationsManager gpgSearchSpinnerForWindow:[[self textView] window]];
	[spinner setHidden:NO];
	[spinner startAnimation:self];
	[[ABKeyWindowAugmentationsManager gpgSearchButtonForWindow:[[self textView] window]] setState:NSOnState];
  }
  else
  {
	NSProgressIndicator *spinner=[ABKeyWindowAugmentationsManager gpgSearchSpinnerForWindow:[[self textView] window]];
	[spinner stopAnimation:self];
	[spinner setHidden:YES];
	[[ABKeyWindowAugmentationsManager gpgSearchButtonForWindow:[[self textView] window]] setState:NSOffState];
  }
  
}


@end
