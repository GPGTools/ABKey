//
//  ABKeyWindowAugmentationsManager.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ABKeyWindowAugmentationsManager : NSObject 
{
  NSMutableDictionary *augmentations;
}

+(id)sharedAugmentationsManager;

+(void)augmentWindow:(NSWindow *)window controller:(id)controller;
+(void)removeWindow:(NSWindow *)window;
+(void)adjustAugmentationsInWindow:(NSWindow *)window forLayout:(int)layout;
+(void)setAugmentationsEnabled:(BOOL)state forWindow:(NSWindow *)window;

+(id)gpgSearchButtonForWindow:(NSWindow *)window;
+(id)gpgSearchSpinnerForWindow:(NSWindow *)window;


-(id)init;

-(void)augmentWindow:(NSWindow *)window controller:(id)controller;
-(void)undressWindowWithIdentifier:(id)identifier;
-(void)removeWindow:(NSWindow *)window;
-(void)removeAllWindows;
-(void)adjustAugmentationsInWindow:(NSWindow *)window forLayout:(int)layout;

-(id)augmentationItemWithKey:(NSString *)key forWindow:(NSWindow *)window;

-(void)checkAugmentationPreference:(NSNotification *)notification;

@end
