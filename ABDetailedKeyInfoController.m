//
//  ABDetailedKeyInfoController.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 27/01/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABDetailedKeyInfoController.h"
#import "GPGMEController.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"
#import "GPGKey extensions.h"


@implementation ABDetailedKeyInfoController


+(void)displayDetailedKeyInfoSheetForPerson:(ABPerson *)newPerson identifier:(id)identifier inWindow:(NSWindow *)theWindow
{
  id sheetController=[[self alloc] initWithPerson:newPerson];
  
  if(sheetController!=nil)
	[sheetController displayInfoSheetForIdentifier:identifier inWindow:theWindow];
  
}


-(id)initWithPerson:(ABPerson *)newPerson
{
  if([super init])
  {
	person=[newPerson retain];
	context=[[GPGContext alloc] init];
	[context setKeyListMode:([context keyListMode] | GPGKeyListModeSignatures)];

	keys=[[GPGMEController keysForRecord:person gpgContext:context] retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKey:) name:@"GPGKeyringChangedNotification" object:nil];
	
	if(keys!=nil && [keys count]!=0)
	{
	  [NSBundle loadNibNamed:@"keyInfo" owner:self];
	}
	else
	{
	  [self release];
	  return nil;
	}
  }
  return self;
}

-(void)awakeFromNib
{
  [personName setStringValue:[[NSString alloc] initWithFormat:@"%@ %@",[person valueForProperty:kABFirstNameProperty],[person valueForProperty:kABLastNameProperty]]];
}


-(NSArray *)keys
{return keys;}


-(IBAction)nextKey:(id)sender
{
  [[GPGMEController sharedController] removeObserver:self];

  [keyController selectNext:sender];
  
  [[GPGMEController sharedController] add:self selector:@selector(asyncStateChange:) forAsyncGPGOperationsConcerningIdentifier:[[[keyController selectedObjects] lastObject] fingerprint]];
}


-(IBAction)previousKey:(id)sender
{
  [[GPGMEController sharedController] removeObserver:self];
  
  [keyController selectPrevious:sender];
  
  [[GPGMEController sharedController] add:self selector:@selector(asyncStateChange:) forAsyncGPGOperationsConcerningIdentifier:[[[keyController selectedObjects] lastObject] fingerprint]];
}


-(void)updateKey:(NSNotification *)notification
{
  [self willChangeValueForKey:@"keys"];
  
  [keys autorelease];
  keys=[[GPGMEController keysForRecord:person gpgContext:context] retain];
  
  [self didChangeValueForKey:@"keys"];
}


-(void)asyncStateChange:(NSNotification *)notification
{
  if([[notification object] isEqualToString:@"asyncOperationStarted"])
  {
	[refreshIndicator startAnimation:self];
	[refreshButton setTitle:@"Cancel"];
  }
  else
  {
	[refreshIndicator stopAnimation:self];
	[refreshButton setTitle:@"Refresh"];

  }
}


-(IBAction)refresh:(id)sender
{
  if([[sender title] isEqualToString:@"Cancel"])
	[[GPGMEController sharedController] interruptAsyncOperationForIdentifier:[[[keyController selectedObjects] lastObject] fingerprint]];
  else
	[[GPGMEController sharedController] refreshGPGKeyWithFingerprint:[[[keyController selectedObjects] lastObject] fingerprint]];  
}


//Sheet controls
//********************************

-(void)displayInfoSheetForIdentifier:(id)identifier inWindow:(NSWindow *)theWindow
{
  int i=0;
  while(i<[keys count] && ![[[keys objectAtIndex:i] formattedShortKeyID] isEqualToString:identifier]) 
	i++;
  
  if(i<[keys count])
	[keyController setSelectionIndex:i];
  
  [refreshIndicator stopAnimation:self];
  [refreshButton setTitle:@"Refresh"];
  
  [[GPGMEController sharedController] add:self selector:@selector(asyncStateChange:) forAsyncGPGOperationsConcerningIdentifier:[[keys objectAtIndex:i] fingerprint]];
  
  [NSApp beginSheet:infoSheet modalForWindow:theWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

-(IBAction)infoSheetClose:(id)sender
{[NSApp endSheet:infoSheet];}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{[sheet orderOut:self]; [self release];}

//Bindings stuff
//*********************************************************
-(id)valueForUndefinedKey:(NSString *)key
{
  NSLog(@"ABDetailedKeyInfoController: Could not bind '%@'",key);
  return [NSNumber numberWithInt:0];
}


-(void)dealloc
{
  NSLog(@"wOOt!");
  [[GPGMEController sharedController] removeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [keys release];
  [context release];
  [person release];
  [super dealloc];
}


@end
