/*
 *  NSPreferencesModuleProtocol.h
 *  ABKeyManager
 *
 *  Created by Robert Goldsmith on 12/02/2005.
 *  Copyright 2005 Far-Blue. All rights reserved.
 *
 */

#include <Cocoa/Cocoa.h>

@protocol NSPreferencesModule
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
- (BOOL) preferencesWindowShouldClose;
- (BOOL) moduleCanBeRemoved;
- (void) moduleWasInstalled;
- (void) moduleWillBeRemoved;
#endif
- (void) didChange;
- (void) initializeFromDefaults;
- (void) willBeDisplayed;
- (void) saveChanges;
- (BOOL) hasChangesPending;
- (NSImage *) imageForPreferenceNamed:(NSString *) name;
- (NSView *) viewForPreferenceNamed:(NSString *) name;
@end
