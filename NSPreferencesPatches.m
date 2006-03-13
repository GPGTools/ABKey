//
//  NSPreferencesPatches.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 14/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "NSPreferencesPatches.h"
#import "PatchingFunctions.h"

@implementation NSPreferencesPatches

+(void)initialize
{    
  registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass(@"NSPreferencesPatches", @selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:), @"NSPreferences", @"originalToolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:");  
}


//hack to fix a problem whereby although you give the preference pane a name
//when you add it to the preferences, something somewhere still uses the class name
//and everything gets screwed and the pane doesn't display. Catching the
//class name identifier here and changing it for the name by which the pane was
//registered in the ABKeyManager initialize method allows everything to work

-(id)toolbar:(id)toolbar itemForItemIdentifier:(id)itemIdentifier willBeInsertedIntoToolbar:(BOOL)insert
{
  if([itemIdentifier isEqualToString:@"ABGPGPreferenceModule"])
	itemIdentifier=@"PGP";
  return [self originalToolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:insert];
}

@end
