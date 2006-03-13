//
//  GPGMEController.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <GPGME/GPGME.h>
#import <Cocoa/Cocoa.h>

@interface GPGMEController : NSObject
{
  NSNotificationCenter *interestedParties;
  NSMutableDictionary *activeAsyncOperations;
  NSMutableDictionary *activeDialogues;
}

+(NSArray *)keysForRecord:(ABPerson *)person gpgContext:(GPGContext *)context;

+(GPGMEController *)sharedController;

  //async operation status syncing

  //When an object is interested in a gpg activity that has an async state and that object wishes to display the 'in progress' state to the user (or use it some other way), the object registers it's interest, identifying the gpg context using a shared unique identifier (the gpg key fingerprint or email address, for instance). If the object registering is registering for an activity that is already underway, it will immediately be sent a notification.
-(void)add:(id)observer selector:(SEL)selector forAsyncGPGOperationsConcerningIdentifier:(NSString *)identifier;


//When an object is about to be deallocated (at the very least) it needs to unregister itself.
-(void)removeObserver:(id)observer;

  //When a gpg context async activity starts, the context is created and added to the active contexts dictionary with the key for the entry being the unique identifier. Then a notification is sent, informing all interested objects that the async opperation has started.

-(void)refreshGPGKeyWithFingerprint:(NSString *)fingerprint;
-(BOOL)searchKeyServerForMatchesWithPerson:(ABPerson *)person;


//When a gpg context activity concludes, a notification is posted using the unique identifer as the name and with the status change info in the accompanying object. Then the context is removed from the active list. gpg contexts inform of their conclusion and return status using a notification themselves.
-(void)asyncOperationReturned:(NSNotification *)notification;

//If an object wishes to stop an active gpg context activity, it can do so, referring to the context by unique identifier. When terminated, the context will return and a notification will be sent out as if it had finished normally, but with a different return status.
-(void)interruptAsyncOperationForIdentifier:(NSString *)identifier;


//an async key search on a key server was done so, if any keys were found, hand the context off to a dialog to allow the user to select and import keys.
-(void)showEmailSearchResultsForContext:(GPGContext *)context;


//when an email search dialogue opens it registers so a second search can't be done for
//the same person. The dialogue unregisters when it has been closed
-(void)addEmailSearchDialogue:(NSWindow *)dialogue forPerson:(ABPerson *)person;

-(void)removeEmailSearchDialogueForPerson:(ABPerson *)person;


@end
