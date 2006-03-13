//
//  ABKeyPreferenceModule.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPreferencesModuleProtocol.h"

@interface ABKeyPreferenceModule : NSObject <NSPreferencesModule>
{
  NSImage *preferenceImage;
  IBOutlet NSView *preferenceView;
  IBOutlet NSBox *preferenceBox;
}

-(IBAction)gotoWebsite:(id)sender;

/* NSPreferencesModule protocol methods */
+(id)sharedInstance;

-(NSImage *)imageForPreferenceNamed:(NSString *)name;
-(NSView *) viewForPreferenceNamed:(NSString *) name;
-(NSString *)titleForIdentifier:(NSString *)identifier;
-(void)willBeDisplayed;
- (BOOL)isResizable;

- (BOOL) preferencesWindowShouldClose;
- (BOOL) moduleCanBeRemoved;
- (void) moduleWasInstalled;
- (void) moduleWillBeRemoved;
- (void) didChange;
- (void) initializeFromDefaults;
- (void) saveChanges;
- (BOOL) hasChangesPending;
- (NSView *) viewForPreferenceNamed:(NSString *) name;

//Notifications
-(void)preferenceChanged:(NSNotification *)notification;
@end
