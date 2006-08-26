//
//  ABSignaturesViewController.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABSignaturesViewController.h"
#import <MacGPGME/MacGPGME.h>
#import "GPGKeySignature extensions.h"


@implementation ABSignaturesViewController

-(void)awakeFromNib
{
  //register to receive kvo calls when the keyController selection changes
  [keyController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:NULL];
  
  selection=nil;
  
  //grab the initial key sigs
  [self updateDatasourceCache:[[keyController selectedObjects] objectAtIndex:0]];
}

-(void)dealloc
{
  [keySignatures release];
  [super dealloc];
}


-(id)selection
{return selection;}



-(void)updateDatasourceCache:(GPGKey *)newSourceKey
{
  NSMutableArray *newSignatures=[NSMutableArray array];
  NSEnumerator *uidEnumerator=[[newSourceKey userIDs] objectEnumerator];
  GPGUserID *currentUID;
  
  while((currentUID=[uidEnumerator nextObject]))
	[newSignatures addObject:[NSArray arrayWithObjects:[currentUID userID],[currentUID signatures],nil]];
	
  
  [newSignatures retain];
  [keySignatures autorelease];
  keySignatures=newSignatures;
  
  [outlineView reloadData];
}



//key-value-observing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  //update the datasource cache for the sigs
  [self updateDatasourceCache:[[object selectedObjects] objectAtIndex:0]];
}


//outline view delegate methods
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  [self willChangeValueForKey:@"selection"];
  selection=[outlineView itemAtRow:[outlineView selectedRow]];
  if(![selection isKindOfClass:[GPGKeySignature class]])
	selection=nil;
  [self didChangeValueForKey:@"selection"];
}



//Outline view datasource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(int)childIndex ofItem:(id)item
{
  if(item==nil)
	return [keySignatures objectAtIndex:childIndex];
  else
	return [[item objectAtIndex:1] objectAtIndex:childIndex];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{return ![item isMemberOfClass:[GPGKeySignature class]];}


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if(item==nil)
	return [keySignatures count];
  else
	return [[item objectAtIndex:1] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  NSString *result;
  
  if(![item isKindOfClass:[GPGKeySignature class]])
	return [item objectAtIndex:0];
  else
  {
	if([[item name] isEqualToString:@""])
	  result=[[[NSAttributedString alloc] initWithString:[item shortSignerKeyID] attributes:[NSDictionary dictionaryWithObject:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName]] autorelease];
	else
	result=[item name];
	
	if([item isRevocationSignature])
	  return [[[NSAttributedString alloc] initWithString:result attributes:[NSDictionary dictionaryWithObject:[NSColor colorWithCalibratedRed:0.7 green:0.0 blue:0.0 alpha:1] forKey:NSForegroundColorAttributeName]] autorelease];
	
	if([item hasSignatureExpired])
	  return [[[NSAttributedString alloc] initWithString:result attributes:[NSDictionary dictionaryWithObject:[NSColor colorWithCalibratedWhite:0.7 alpha:1] forKey:NSForegroundColorAttributeName]] autorelease];

	  return result;
  }
}


@end
