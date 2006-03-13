//
//  ABDetailedKeyInfoController.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 27/01/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import <GPGME/GPGME.h>

@interface ABDetailedKeyInfoController : NSObject
{
  ABPerson *person;
  NSArray *keys;
  GPGContext *context;

  IBOutlet NSWindow *infoSheet;
  IBOutlet NSTextField *personName;
  IBOutlet NSArrayController *keyController;
  IBOutlet NSProgressIndicator *refreshIndicator;
  IBOutlet NSButton *refreshButton;
}
 
+(void)displayDetailedKeyInfoSheetForPerson:(ABPerson *)newPerson identifier:(id)identifier inWindow:(NSWindow *)theWindow;

-(id)initWithPerson:(ABPerson *)newPerson;

-(NSArray *)keys;

-(IBAction)nextKey:(id)sender;
-(IBAction)previousKey:(id)sender;

-(IBAction)refresh:(id)sender;

//*******************************************************************
//Sheet controls
-(void)displayInfoSheetForIdentifier:(id)identifier inWindow:(NSWindow *)theWindow;
-(IBAction)infoSheetClose:(id)sender;
-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

//*******************************************************************
//Bindings
-(id)valueForUndefinedKey:(NSString *)key;

@end
