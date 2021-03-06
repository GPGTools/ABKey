//
//  ABKeyEmailSearchResultsController.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 20/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacGPGME/MacGPGME.h>

@interface ABKeyEmailSearchResultsController : NSObject
{
  ABPerson *person;
  GPGContext *context;
  NSMutableArray *keys;
  GPGRemoteKey *currentKey;
//  IBOutlet NSObjectController *currentSelectionController;
  IBOutlet NSOutlineView *outlineView;
  IBOutlet NSWindow *window;
  IBOutlet NSButton *importKeys;
  NSMutableSet *selectedKeys;
  
  IBOutlet NSView *contentView;
  IBOutlet NSView *importingView;
  IBOutlet NSProgressIndicator *importingProgress;
}

+(void)showEmailSearchResults:(GPGContext *)results forPerson:(ABPerson *)thePerson;


-(id)initWithReturnedContext:(GPGContext *)context forPerson:(ABPerson *)thePerson;

-(void)addKeyToSelected:(GPGRemoteKey *)newKey;
-(void)removeKeyFromSelected:(GPGRemoteKey *)newKey;

//bindings
-(GPGRemoteKey *)currentKey;
-(void)setCurrentKey:(GPGRemoteKey *)newKey;


  //window delegate methods
-(void)windowWillClose:(NSNotification *)aNotification;


//outline view delegate methods
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;

//Outline view datasource methods
- (id)outlineView:(NSOutlineView *)outlineView child:(int)childIndex ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
-(void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;


//button targets
-(IBAction)close:(id)sender;
-(IBAction)import:(id)sender;
-(IBAction)cancelImport:(id)sender;

-(void)emailKeyImportStatus:(NSNotification *)notification;

-(void)dealloc;
@end
