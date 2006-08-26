//
//  ABTextViewPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 20/01/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//
#import "ABTextViewPatches.h"
#import "PatchingFunctions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"
#import "ABKeyAttachmentCell.h"
#import "GPGKey extensions.h"

@implementation ABTextViewPatches

+(void)initialize
{  
  registerMethodWithNewClass(@"ABTextViewPatches", @selector(findTopInjectionPointAndTidyUpHeaderSpaceForEditMode:), @"ABTextView");

  registerMethodWithNewClass(@"ABTextViewPatches", @selector(findBottomInjectionPoint), @"ABTextView");

  registerMethodWithNewClass(@"ABTextViewPatches", @selector(injectGPGKeyFields:atInsertionPoint:withInputController:), @"ABTextView");

  registerMethodWithNewClass(@"ABTextViewPatches", @selector(injectGPGOptionsFields:atInsertionPoint:withInputController:editMode:), @"ABTextView");

  registerMethodWithNewClass(@"ABTextViewPatches", @selector(buildDividerString), @"ABTextView");
  
  registerMethodWithNewClass(@"ABTextViewPatches", @selector(buildAttributedStringWithLabel:fields:popups:identifier:editMode:), @"ABTextView");
  
  registerMethodWithNewClass(@"ABTextViewPatches", @selector(globalAttributesDictionary), @"ABTextView");
  
  registerMethodWithNewClass(@"ABTextViewPatches", @selector(createPopupAttachmentWithTitles:selectedTitleIndex:label:tag:inputController:target:action:), @"ABTextView");  
  }



-(NSMutableDictionary *)globalAttributesDictionary
{
  static NSDictionary *globalAttributes;
  if(globalAttributes==nil)
  {
	NSMutableParagraphStyle *paragraphStyle=[[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[paragraphStyle setTabStops:[NSArray arrayWithObjects:
	  [[[NSTextTab alloc] initWithType:NSRightTabStopType location:71] autorelease],
	  [[[NSTextTab alloc] initWithType:NSLeftTabStopType location:76] autorelease],
	  [[[NSTextTab alloc] initWithType:NSLeftTabStopType location:81] autorelease],
	  nil]];
	[paragraphStyle setHeadIndent:76];
	[paragraphStyle setLineBreakMode:1];
	
	//create the attributes dictionary for the entire string
	globalAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
	  @"ABBodyAttribute",@"ABBodyAttribute",
	  @"ABFieldsAttribute",@"ABFieldsAttribute",
	  @"ABGPGGroupAttribute",@"ABGPGGroupAttribute",
	  [NSFont fontWithName:@"Helvetica" size:9.0],NSFontAttributeName,
	  paragraphStyle,NSParagraphStyleAttributeName,
	  nil];
  }
  return [NSMutableDictionary dictionaryWithDictionary:globalAttributes];
}



-(NSMutableAttributedString *)createPopupAttachmentWithTitles:(NSArray *)titles selectedTitleIndex:(unsigned int)selectedItemIndex label:(NSString *)label tag:(int)tag inputController:(id)inputController target:(id)target action:(SEL)action
{
  NSTextAttachment *popupAttachment;
  NSMutableAttributedString *attachmentString;
  id popupCell;
  unsigned int i;
      
  popupCell=[[[NSClassFromString(@"ABInstantPopUpButtonCell") alloc] initWithInputController:inputController andField:@"GPGOptions"] autorelease];
  
  for(i=0;i<[titles count];i++)
  {
	[[popupCell itemAtIndex:i] setTitle:KeyManagerLocalizedString([titles objectAtIndex:i],@"popup option")];
	[[popupCell itemAtIndex:i] setTag:tag];
  }
 
  while([popupCell numberOfItems]>i)
	[popupCell removeItemAtIndex:i];
  
  [popupCell setUsesItemFromMenu:YES];
  [popupCell setAutoenablesItems:NO];	  
  [popupCell setTarget:target];
  [popupCell setAction:action];
  [popupCell setTag:tag];
  
  if(selectedItemIndex<[titles count])
	[popupCell selectItemAtIndex:selectedItemIndex];
  
  popupAttachment=[[[NSTextAttachment alloc] initWithFileWrapper:nil] autorelease];
  [popupAttachment setAttachmentCell:popupCell];

  attachmentString=[[[NSMutableAttributedString alloc] initWithString:[KeyManagerLocalizedString(label, @"popup label") stringByAppendingString:@":  "]] autorelease];
  [attachmentString appendAttributedString:[NSAttributedString attributedStringWithAttachment:popupAttachment]];

  return attachmentString;
}

-(int)findBottomInjectionPoint
{
  NSRange noteRange;
      
  //find the body range
  [[self textStorage] attribute:@"ABBodyAttribute" atIndex:[[self textStorage] length]/2 longestEffectiveRange:&noteRange inRange:NSMakeRange(0,[[self textStorage] length])];
    
  return NSMaxRange(noteRange)-1;
}

-(int)findTopInjectionPointAndTidyUpHeaderSpaceForEditMode:(int)editMode
{
  int insertionPoint;
  NSRange titleRange;

  //inject a divider to set up various globals
  NSMutableAttributedString *fieldsToInject=[self buildDividerString];

  [[self textStorage] beginEditing];
  
  //find the end of the title range
  [[self textStorage] attribute:@"ABTitleAttribute" atIndex:1 longestEffectiveRange:&titleRange inRange:NSMakeRange(0,[[self textStorage] length])];
  insertionPoint=NSMaxRange(titleRange);
  
  //remove some of the white space at the top of the record
  insertionPoint-=(2+(editMode==1?1:0));
  [[self textStorage] deleteCharactersInRange:NSMakeRange(insertionPoint,(2+(editMode==1?1:0)))];
  
  //insert the new fields just below the title range
  [[self textStorage] insertAttributedString:fieldsToInject atIndex:insertionPoint];
  
  [[self textStorage] endEditing];
  
  return insertionPoint+[fieldsToInject length];
}



-(int)injectGPGKeyFields:(NSArray *)keys atInsertionPoint:(int)insertionPoint  withInputController:(id)inputController
{
  NSMutableAttributedString *fieldsToInject=[[[NSMutableAttributedString alloc] init] autorelease];

  NSEnumerator *gpgKeyEnumerator=[keys reverseObjectEnumerator];
  GPGKey *currentKey;
  NSString *keyStatus;
  NSArray *popupsArray=nil;
  
  while((currentKey=[gpgKeyEnumerator nextObject]))
  {
	if([currentKey isKeyRevoked])
	{
	  if([[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayRevokedKeys"])
		keyStatus=KeyManagerLocalizedString(@"(revoked)",@"key status");
	  else
		continue;
	}
	else if([currentKey isKeyInvalid])
	{
	  if([[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayRevokedKeys"])
		keyStatus=KeyManagerLocalizedString(@"(invalid)",@"key status");
	  else
		continue;
	}
	
	else if([currentKey hasKeyExpired])
	{
	  if([[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayExpiredKeys"])
		keyStatus=KeyManagerLocalizedString(@"(expired)",@"key status");
	  else
		continue;
	}
	else if([currentKey isKeyDisabled])
	{
	  if([[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayExpiredKeys"])
		keyStatus=KeyManagerLocalizedString(@"(disabled)",@"key status");
	  else
		continue;
	}
	else
	  keyStatus=@"";
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayKeyserverRefreshButtons"])
	{	  
	  ABKeyAttachmentCell *buttonCell=[[[ABKeyAttachmentCell alloc] initWithIdentifier:[currentKey fingerprint]] autorelease];
	  
	  NSTextAttachment *popupAttachment=[[[NSTextAttachment alloc] initWithFileWrapper:nil] autorelease];
	  [popupAttachment setAttachmentCell:buttonCell];
	  
	  NSMutableAttributedString *attachmentString=[[[NSMutableAttributedString alloc] initWithString:@"     "] autorelease];
	  [attachmentString appendAttributedString:[NSAttributedString attributedStringWithAttachment:popupAttachment]];
	  
	  popupsArray=[NSArray arrayWithObject:attachmentString];
	}
	
	[fieldsToInject appendAttributedString:[self buildAttributedStringWithLabel:@"gpg key" fields:[NSArray arrayWithObject:@"GPGKey"] popups:popupsArray identifier:[NSString stringWithFormat:@"GPGKey.%@.%@.%@",[currentKey formattedShortKeyID],keyStatus,[currentKey validityDescription]] editMode:0]];
  }
  
  if([fieldsToInject length]>0)
  {
	//insert space after the gpg key fields
	[fieldsToInject appendAttributedString:[self buildDividerString]];
	
	//inject the fields
	[[self textStorage] beginEditing];
	
	//insert the new fields just below the title range
	[[self textStorage] insertAttributedString:fieldsToInject atIndex:insertionPoint];
	
	[[self textStorage] endEditing];
  }
  
  return insertionPoint+[fieldsToInject length];
}



-(int)injectGPGOptionsFields:(NSDictionary *)GPGOptionsDictionary atInsertionPoint:(int)insertionPoint withInputController:(id)inputController editMode:(int)editMode
{
  NSMutableAttributedString *fieldsToInject=[[[NSMutableAttributedString alloc] init] autorelease];
  NSArray *fieldsArray;
  NSMutableArray *popupsArray;
  
  if(editMode==1)
  {  
	fieldsArray=[NSArray arrayWithObjects:@"",@"",@"",nil];
	
	popupsArray=[NSMutableArray arrayWithCapacity:3];
	
	[popupsArray addObject:[self createPopupAttachmentWithTitles:[NSArray arrayWithObjects:@"default",@"always",@"never",nil] selectedTitleIndex:([GPGOptionsDictionary objectForKey:@"GPGMailSign"]?([[GPGOptionsDictionary objectForKey:@"GPGMailSign"] boolValue]?1:2):0) label:@"sign" tag:0 inputController:inputController target:inputController action:@selector(GPGOptionChangeAction:)]];
	[popupsArray addObject:[self createPopupAttachmentWithTitles:[NSArray arrayWithObjects:@"default",@"always",@"never",nil] selectedTitleIndex:([GPGOptionsDictionary objectForKey:@"GPGMailEncrypt"]?([[GPGOptionsDictionary objectForKey:@"GPGMailEncrypt"] boolValue]?1:2):0) label:@"encrypt" tag:1 inputController:inputController target:inputController action:@selector(GPGOptionChangeAction:)]];
	[popupsArray addObject:[self createPopupAttachmentWithTitles:[NSArray arrayWithObjects:@"default",@"always",nil] selectedTitleIndex:([GPGOptionsDictionary objectForKey:@"GPGMailUseMime"]?([[GPGOptionsDictionary objectForKey:@"GPGMailUseMime"] boolValue]?1:2):0) label:@"use mime message format" tag:2 inputController:inputController target:inputController action:@selector(GPGOptionChangeAction:)]];
  }
  else
  {
	fieldsArray=[NSArray arrayWithObjects:@"Sign",@"Encrypt",@"PGP/Mime",nil];
	popupsArray=nil;
  }
  
  //add the gpgMail option fields the the end of the string to inject
  [fieldsToInject appendAttributedString:[self buildAttributedStringWithLabel:@"gpg mail" fields:fieldsArray popups:popupsArray identifier:@"GPGOptions" editMode:editMode]];
  
  //insert space after the gpgMail options fields
  [fieldsToInject appendAttributedString:[self buildDividerString]];
  
  //inject the fields
  [[self textStorage] beginEditing];
  
  //insert the new fields just below the title range
  [[self textStorage] insertAttributedString:fieldsToInject atIndex:insertionPoint];
  
  [[self textStorage] endEditing];
  
  return insertionPoint+[fieldsToInject length];
}


-(NSAttributedString *)buildDividerString
{
  NSMutableDictionary *globalAttributes=[self globalAttributesDictionary];
  [globalAttributes setObject:@"ABDividerAttribute" forKey:@"ABDividerAttribute"];
  return [[[NSMutableAttributedString alloc] initWithString:@"\n\n" attributes:globalAttributes] autorelease];
}



-(NSMutableAttributedString *)buildAttributedStringWithLabel:(NSString *)label fields:(NSArray *)fields popups:(NSArray *)popups identifier:(NSString *)identifier editMode:(BOOL)editMode
{  
  
  float fontSize=11.0+[[NSUserDefaults standardUserDefaults] integerForKey:@"ABTextSizeIncrement"];
  
  //retrieve the attributes dictionary for the  string
  NSMutableDictionary *globalAttributes=[self globalAttributesDictionary];
  
  //create the start of the result string (to which everything else is appended)
  NSMutableAttributedString *fieldString=[[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:globalAttributes] autorelease];
  [fieldString addAttribute:@"ABDividerAttribute" value:@"ABDividerAttribute" range:NSMakeRange(0,1)];

  //add additional attribute
  [globalAttributes setObject:@"ABFieldPopupAttribute" forKey:@"ABFieldPopupAttribute"];
  
  //add the global attribute that ties together a multiline element (if the element is multiline)
  if([fields count]>1)
	[globalAttributes setObject:identifier forKey:@"ABAddressesAttribute"];
  
  //create a tab divider string
  NSMutableAttributedString *dividerString=[[[NSMutableAttributedString alloc] initWithString:@"\t" attributes:globalAttributes] autorelease];
  [dividerString addAttribute:@"ABDividerAttribute" value:@"ABDividerAttribute" range:NSMakeRange(0,1)];
  
  //create the label string
  NSMutableAttributedString *labelString=[[[NSMutableAttributedString alloc] initWithString:KeyManagerLocalizedString(label,@"field label") attributes:globalAttributes] autorelease];
  //create and apply label attributes
  [labelString addAttributes:
	[NSDictionary dictionaryWithObjectsAndKeys:
	  [NSFont fontWithName:@"Helvetica Bold" size:fontSize],NSFontAttributeName,
	  identifier,@"ABFieldLabelAttribute",
	  nil]
	range:NSMakeRange(0,[labelString length])];

  //apply label attributes that change depending on edit mode status
  [labelString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedWhite:(editMode?0:0.6) alpha:1] range:NSMakeRange(0,[labelString length])];

  //build the string so far:
  [fieldString appendAttributedString:dividerString];
  [fieldString appendAttributedString:labelString];
  [fieldString appendAttributedString:dividerString];

  //build the fieldnames attribute dictionary
  NSDictionary *fieldNameAttributes=[NSDictionary dictionaryWithObjectsAndKeys:
	[NSColor colorWithCalibratedWhite:0.478431 alpha:1], NSForegroundColorAttributeName,
	[NSFont fontWithName:@"Helvetica" size:fontSize],NSFontAttributeName,
	@"ABTextViewTemporaryAttribute",@"ABTextViewTemporaryAttribute",
	nil];
  
  //build the field newline string (for adding linefeeds in a multi-line element)
  NSMutableAttributedString *fieldNewlineString=[[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:globalAttributes] autorelease];
  [fieldNewlineString removeAttribute:@"ABFieldPopupAttribute" range:NSMakeRange(0,[fieldNewlineString length])];
  [fieldNewlineString addAttribute:@"ABDividerAttribute" value:@"ABDividerAttribute" range:NSMakeRange(0,1)];

  //build the popup attribute dictionary
  NSDictionary *popupAttributes=[NSDictionary dictionaryWithObjectsAndKeys:
	[NSColor colorWithCalibratedWhite:0.478431 alpha:1], NSForegroundColorAttributeName,
	[NSFont fontWithName:@"Helvetica" size:fontSize],NSFontAttributeName,
	identifier, @"ABAddressesAttribute",
	nil];
  
  
  //move through each fieldname
  unsigned int i;
  NSString *currentField;
  NSMutableAttributedString *fieldNameString;
  for(i=0;i<[fields count];i++)
  {
	currentField=[fields objectAtIndex:i];
	
	//create the string
	fieldNameString=[[[NSMutableAttributedString alloc] initWithString:KeyManagerLocalizedString(currentField,@"field") attributes:globalAttributes] autorelease];
	//apply the fieldName attributes
	[fieldNameString addAttributes:fieldNameAttributes range:NSMakeRange(0,[fieldNameString length])];
	
	//only if the card is being shown 'normally', not being edited because
	//the ABTextViewAttribute attribute makes the field 'editable' in edit mode, which we don't want
	if(!editMode)
	  //apply the textView attribute which is field-dependent
	  [fieldNameString addAttribute:@"ABTextViewAttribute" value:[identifier stringByAppendingFormat:@".%@",currentField] range:NSMakeRange(0,[fieldNameString length])];
	
	//append the string
	[fieldString appendAttributedString:fieldNameString];
	
	//handle a popup that can appear after a field
	//each entry in the popup array must be a mutable attributed string
	//each entry in the popup array is associated with the same index entry in the fields array
	if(popups!=nil && i<[popups count])
	{
	  [[popups objectAtIndex:i] addAttributes:[self globalAttributesDictionary]  range:NSMakeRange(0,[[popups objectAtIndex:i] length])];
	  
//	  [[popups objectAtIndex:i] addAttributes: fieldNameAttributes   range:NSMakeRange(0,[[popups objectAtIndex:i] length])];


	  //add the global attribute that ties together a multiline element (if the element is multiline)
	  if([fields count]>1)
		[[popups objectAtIndex:i] addAttributes: popupAttributes   range:NSMakeRange(0,[[popups objectAtIndex:i] length])];
	  
	  [fieldString appendAttributedString:[popups objectAtIndex:i]];
	}
  
	//append a newline with all global attributes except the popupfield attribute
	[fieldString appendAttributedString:fieldNewlineString];
  }
  
  //remove the last newline char if the element was only a single line
  if([fields count]==1)
	[fieldString deleteCharactersInRange:NSMakeRange([fieldString length]-1,1)];
  
  return fieldString;
}



@end
