//
//  ABSignaturesViewController.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacGPGME/MacGPGME.h>

@interface ABSignaturesViewController : NSObject
{
  NSMutableArray *keySignatures;
  IBOutlet NSArrayController *keyController;
  IBOutlet NSObjectController *selectionController;
  IBOutlet NSOutlineView *outlineView;
  id selection;
}

-(void)awakeFromNib;

-(void)updateDatasourceCache:(GPGKey *)newSourceKey;

-(id)selection;

//key-value-observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

//outline view delegate methods
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;


//Outline view data source
- (id)outlineView:(NSOutlineView *)outlineView child:(int)childIndex ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
@end
