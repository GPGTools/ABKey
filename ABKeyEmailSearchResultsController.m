//
//  ABKeyEmailSearchResultsController.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 20/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "GPGMEController.h"
#import "ABKeyEmailSearchResultsController.h"
#import "ABKeyEmailSearchSelectButtonCell.h"
#import "GPGKey extensions.h"

@implementation ABKeyEmailSearchResultsController

+(void)showEmailSearchResults:(GPGContext *)results forPerson:(ABPerson *)thePerson
{
  [[self alloc] initWithReturnedContext:results forPerson:thePerson];
}



-(id)initWithReturnedContext:(GPGContext *)theContext forPerson:(ABPerson *)thePerson
{
  if([super init])
  {
	  unsigned int i;
	person=[thePerson retain];
	context=[theContext retain];
		
	NSArray *keyArray=[[context operationResults] objectForKey:@"keys"];
	NSArray *localKeys=[GPGMEController keysForRecord:thePerson gpgContext:theContext];

//	NSLog(@"local keys: %@. remote keys: %@",[[localKeys lastObject] shortKeyID],[[keyArray lastObject] shortKeyID]);
	
	selectedKeys=[[NSMutableSet alloc] initWithCapacity:[keyArray count]];
	keys=[[NSMutableArray alloc] initWithCapacity:[keyArray count]];
	NSEnumerator *keyEnumerator=[keyArray objectEnumerator];
	GPGRemoteKey *currentGPGKey;
	while((currentGPGKey=[keyEnumerator nextObject]))
	{
	  if(![keys containsObject:currentGPGKey])
	  {
		  BOOL existsLocally=NO;
		[keys addObject:currentGPGKey];
		for(i=0;i<[localKeys count];i++)
			if([[[localKeys objectAtIndex:i] shortKeyID] isEqualToString:[currentGPGKey shortKeyID]])
			{
				existsLocally=YES;
				break;
			}
		if(!existsLocally && ![currentGPGKey isKeyRevoked])
		  [self addKeyToSelected:currentGPGKey];
	  }
	}
		
	[NSBundle loadNibNamed:@"EmailSearchResults" owner:self];
	
	[self setCurrentKey:nil];
	
	[window setTitle:[NSString stringWithFormat:@"Key Search for %@ %@",[person valueForProperty:kABFirstNameProperty],[person valueForProperty:kABLastNameProperty]]];
	
	[window makeKeyAndOrderFront:self];
	[[GPGMEController sharedController] addEmailSearchDialogue:window forPerson:person];
  }
  return self;
}

-(void)addKeyToSelected:(GPGRemoteKey *)newKey
{
  if([selectedKeys count]==0)
	[importKeys setEnabled:YES];
  [selectedKeys addObject:newKey];
}

-(void)removeKeyFromSelected:(GPGRemoteKey *)newKey
{
  [selectedKeys removeObject:newKey];
  if([selectedKeys count]==0)
	[importKeys setEnabled:NO];
}

//bindings
-(GPGRemoteKey *)currentKey
{
  return currentKey;
}

-(void)setCurrentKey:(GPGRemoteKey *)newKey
{
  [self willChangeValueForKey:@"currentKey"];
  currentKey=newKey;
  [self didChangeValueForKey:@"currentKey"];
}



//window delegate methods
-(void)windowWillClose:(NSNotification *)aNotification
{
  [[GPGMEController sharedController] removeEmailSearchDialogueForPerson:person];
  [self release];
}


//outline view delegate methods
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  id selectedItem=[outlineView itemAtRow:[outlineView selectedRow]];
  if([selectedItem isKindOfClass:[GPGRemoteKey class]])
	[self setCurrentKey:selectedItem];
  else if([selectedItem isKindOfClass:[GPGRemoteUserID class]])
	[self setCurrentKey:(GPGRemoteKey *)[selectedItem key]];
  else
	  [self setCurrentKey:nil];
}



//Outline view datasource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(int)childIndex ofItem:(id)item
{
  if(item)
	return [[item userIDs] objectAtIndex:childIndex];
  return [keys objectAtIndex:childIndex]; //nil -> root items
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{ return [item isKindOfClass:[GPGRemoteKey class]];}


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if(item)
	return [[item userIDs] count];
  return [keys count]; //nil -> root items
}



- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{ 
  if([[tableColumn identifier] isEqualToString:@"select"])
  {
	if([item isKindOfClass:[GPGRemoteKey class]])
	  return [NSNumber numberWithInt:[selectedKeys containsObject:item]];
	return [NSNumber numberWithInt:-1];
  }
  else if([[tableColumn identifier] isEqualToString:@"info"])
  {
	if([item isKindOfClass:[GPGRemoteKey class]])
	{
	  if([item isKeyRevoked])
		return [[[NSAttributedString alloc] initWithString:[item formattedShortKeyID] attributes:[NSDictionary dictionaryWithObject:[NSColor colorWithCalibratedRed:0.7 green:0.0 blue:0.0 alpha:1] forKey:NSForegroundColorAttributeName]] autorelease];
	  return [item formattedShortKeyID];
	}
	else if([item isKindOfClass:[GPGRemoteUserID class]])
 	  return [item userID];
  }
  return @"";
}


-(void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if(![[tableColumn identifier] isEqualToString:@"select"])
	return;
  if([object intValue]==1)
	[self addKeyToSelected:item];
  else
	[self removeKeyFromSelected:item];
}


//button targets
-(IBAction)close:(id)sender
{[window close];}

 
-(IBAction)import:(id)sender
{
  if([selectedKeys count]==0)
	return;
  
  //change the view and animate the window resize
  NSRect importViewFrame=[window frameRectForContentRect:[importingView frame]];
  NSRect windowFrame=[window frame];
  importViewFrame.origin.y=windowFrame.origin.y+windowFrame.size.height-importViewFrame.size.height;
  importViewFrame.origin.x=windowFrame.origin.x+(windowFrame.size.width/2)-(importViewFrame.size.width/2);
  [window setContentView:importingView];
  [window setShowsResizeIndicator:NO];
  [window setTitle:@"Importing..."];
  [window setFrame:importViewFrame display:YES animate:YES];
  
  //start the progress indicator
  [importingProgress startAnimation:self];
  
  //register for notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailKeyImportStatus:) name:@"GPGAsynchronousOperationDidTerminateNotification" object:context];
  
  //download the selected keys
  [context asyncDownloadKeys:[selectedKeys allObjects] serverOptions:nil];
}

-(IBAction)cancelImport:(id)sender
{
  [context interruptAsyncOperation];
  //this will automatically result in a notification which will close the window and clean up
}


-(void)emailKeyImportStatus:(NSNotification *)notification
{
  [window close];
}



-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [keys release];
  [selectedKeys release];
  [person release];
  [context release];
  [super dealloc];
}

@end
