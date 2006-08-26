//
//  GPGMEController.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGMEController.h"
#import "ABKeyEmailSearchResultsController.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"


@implementation GPGMEController

id sharedGPGMEController=nil;

//convenience method to find all keys associated with an address book record
+(NSArray *)keysForRecord:(ABPerson *)person gpgContext:(GPGContext *)context
{
  unsigned int i;
  id emailMultiValue;
  NSMutableArray *emailAddresses=[NSMutableArray array];
  
  emailMultiValue=[person valueForProperty:kABEmailProperty];
  for(i=0;i<[emailMultiValue count];i++)
	[emailAddresses addObject:[emailMultiValue valueAtIndex:i]];
  
  if([emailAddresses count]>0)
	return [[context keyEnumeratorForSearchPatterns:emailAddresses secretKeysOnly:NO] allObjects];
  else
	return nil;
}

+(GPGMEController *)sharedController
{
  if(sharedGPGMEController==nil)
	sharedGPGMEController=[[GPGMEController alloc] init];
  return sharedGPGMEController;
}


-(id)init
{
  if([super init])
  {
	interestedParties=[[NSNotificationCenter alloc] init];
	activeAsyncOperations=[[NSMutableDictionary alloc] init];
  	activeDialogues=[[NSMutableDictionary alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncOperationReturned:) name:@"GPGAsynchronousOperationDidTerminateNotification" object:nil];
  }
  return self;
}


//async operation status syncing

//When an object is interested in a gpg activity that has an async state and that object wishes to display the 'in progress' state to the user (or use it some other way), the object registers it's interest, identifying the gpg context using a shared unique identifier (the gpg key fingerprint or email address, for instance). If the object registering is registering for an activity that is already underway, it will immediately be sent a notification.
-(void)add:(id)observer selector:(SEL)selector forAsyncGPGOperationsConcerningIdentifier:(NSString *)identifier
{
  //NSLog(@"Adding observer %@ for identifier: %@",[observer description],identifier);
  //register the observer for the identifier in the notificationCentre.
  [interestedParties addObserver:observer selector:selector name:identifier object:nil];
  
  //check to see if a gpg context is associated with the identifier
  //if it is, immediately notify the registering object
  GPGContext *activeContext;
  if((activeContext=[activeAsyncOperations objectForKey:identifier]))
  {
	//NSLog(@"observer registering for already active context. Sending notification");
	[observer performSelector:selector withObject:[NSNotification notificationWithName:identifier object:@"asyncOperationStarted"]];
  }
}


//When an object is about to be deallocated (at the very least) it needs to unregister itself.
-(void)removeObserver:(id)observer
{//NSLog(@"removing observer %@", [observer description]);
  [interestedParties removeObserver:observer];}


//When a gpg context async activity starts, the context is created and added to the active contexts dictionary with the key for the entry being the unique identifier. Then a notification is sent, informing all interested objects that the async operation has started.

-(void)refreshGPGKeyWithFingerprint:(NSString *)fingerprint
{
  //create a gpg context, search for the key based on key fingerprint.
  // NSLog(@"Creating gpg context for key refresh");
  GPGContext *context=[[[GPGContext alloc] init] autorelease];
  GPGKey *key;
  
  [context setUserInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"refresh",@"operation",nil]];
  
  //if the key is found, post a 'start' notification for the keyID (using it as the unique identifier)
  //then start the async gpg context download from key server
  if((key=[context keyFromFingerprint:fingerprint secretKey:NO]))
  {
//	NSLog(@"Key %@ found. Will try to refresh it.",[key shortKeyID]);
	[activeAsyncOperations setObject:context forKey:fingerprint];
	[interestedParties postNotificationName:fingerprint object:@"asyncOperationStarted"];
	[context asyncDownloadKeys:[NSArray arrayWithObject:key] serverOptions:nil];
  }
}


-(BOOL)searchKeyServerForMatchesWithPerson:(ABPerson *)person
{
  //create a gpg context, search the key server based on a person's email addresses
  //NSLog(@"Creating gpg context for key search");
  
  unsigned int i;
  GPGContext *context=nil;
  id emailMultiValue;
  NSMutableArray *emailAddresses=[NSMutableArray array];
  
  //check there is not already an open search dialogue
  //when started, a search results dialogue registers it's existence
  NSWindow *windowForActiveDialogue=[activeDialogues objectForKey:[person uniqueId]];
  if(windowForActiveDialogue!=nil)
  {
	[windowForActiveDialogue makeKeyAndOrderFront:self];
	return NO;
  }
  
  emailMultiValue=[person valueForProperty:kABEmailProperty];
  for(i=0;i<[emailMultiValue count];i++)
	[emailAddresses addObject:[NSString stringWithFormat:@"<%@>",[emailMultiValue valueAtIndex:i]]];
  
  if([emailAddresses count]>0)
  {
	context=[[[GPGContext alloc] init] autorelease];
	[context setUserInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"emailSearch",@"operation",person,@"person",nil]];
	[activeAsyncOperations setObject:context forKey:[person uniqueId]];
	[interestedParties postNotificationName:[person uniqueId] object:@"asyncOperationStarted"];
	[context asyncSearchForKeysMatchingPatterns:emailAddresses serverOptions:nil];
	return YES;
  }
  return NO;
}


//When a gpg context activity concludes, a notification is posted using the unique identifer as the name and with the status change info in the accompanying object. Then the context is removed from the active list. gpg contexts inform of their conclusion and return status using a notification themselves.
-(void)asyncOperationReturned:(NSNotification *)notification
{
  NSString *identifier;
  
  //NSLog(@"Notification received: %@",[notification description]);
  
  //Match the gpg context in the dictionary and retrieve the identifier for it, if it exists
  identifier=[[activeAsyncOperations allKeysForObject:[notification object]] lastObject];
  if(identifier!=nil)
  {
	//NSLog(@"async operation returned: %@",[[[notification object] operationResults] description]);
 
  
	//post a notification based on the received notification state and deal with any results
	if([[[notification userInfo]  objectForKey:@"GPGErrorKey"] intValue]==GPGErrorNoError)
	{
	  //NSLog(@"No error");
	  [interestedParties postNotificationName:identifier object:@"asyncOperationFinished"];
	  
	  //the async operation was an email based key search
	  if([[[[notification object] userInfo] objectForKey:@"operation"] isEqualToString:@"emailSearch"])
		[self showEmailSearchResultsForContext:[notification object]];	  
	}
	else
	{
	  //NSLog(@"async error");
	  [interestedParties postNotificationName:identifier object:@"asyncOperationError"];
	  
	  //the 'interrupted' entry is added if the user stops the async action (see method below)
	  //so, obviously, although an error happened, it was deliberate so no error should be shown
	  if(![[[notification object] userInfo] objectForKey:@"interrupted"])
	  {
		NSAlert *asyncErrorAlert=[[NSAlert alloc] init];
		[asyncErrorAlert setAlertStyle:NSInformationalAlertStyle];
		  
		[asyncErrorAlert setMessageText:KeyManagerLocalizedString(@"async problem message text",@"keyserver problems")]; 
		[asyncErrorAlert setInformativeText:KeyManagerLocalizedString(@"async problem informative text",@"keyserver problems")];
		[asyncErrorAlert addButtonWithTitle:@"OK"];
		[asyncErrorAlert setShowsHelp:NO];
		[asyncErrorAlert runModal];
		[asyncErrorAlert release];
	  }
	}
	
	//remove the gpg context from the active list
	[activeAsyncOperations removeObjectForKey:identifier];
  }
}

//If an object wishes to stop an active gpg context activity, it can do so, referring to the context by unique identifier. When terminated, the context will return and a notification will be sent out as if it had finished normally, but with a different return status.
-(void)interruptAsyncOperationForIdentifier:(NSString *)identifier
{
  //find the associated gpg context and send it an interruptAsyncOperation  
  GPGContext *activeContext;
  if((activeContext=[activeAsyncOperations objectForKey:identifier]))
  {
	//NSLog(@"Interrupting operation!");
	
	//record the fact that the operation was interrupted
	[[activeContext userInfo] setObject:@"interrupted" forKey:@"interrupted"];
	
	//check whether we are actually still in an async operation (as we certainly think we are)
	if([activeContext isPerformingAsyncOperation])
	  [activeContext interruptAsyncOperation];
	else
	{
	  //post a fake notification to synchronise the various gui elements and remove the context
	  [interestedParties postNotificationName:identifier object:@"asyncOperationError"];
	  [activeAsyncOperations removeObjectForKey:identifier];
	}
  }
}



-(void)showEmailSearchResultsForContext:(GPGContext *)context
{
  if([[[context operationResults] objectForKey:@"keys"] count]>0)
  {
	[ABKeyEmailSearchResultsController showEmailSearchResults:context forPerson:[[context userInfo] objectForKey:@"person"]];
  } 
}


-(void)addEmailSearchDialogue:(NSWindow *)dialogue forPerson:(ABPerson *)person
{[activeDialogues setObject:dialogue forKey:[person uniqueId]];}

-(void)removeEmailSearchDialogueForPerson:(ABPerson *)person
{[activeDialogues removeObjectForKey:[person uniqueId]];}


-(void)dealloc
{
  [interestedParties release];
  [activeAsyncOperations release];
  [super dealloc];
}

@end
