//
//  ABKeyManager.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on Sun Mar 07 2004.
//  Copyright (c) 2004 Far-Blue. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import <Cocoa/Cocoa.h>

#import "ABKeyManager.h"
#import "ABDetailedKeyInfoController.h"
#import "ABKeyStatusColourTransformer.h"
#import "ABKeyAlgorithmTypeImageTransformer.h"
#import "ABKeyPreferenceModule.h"
#import "PatchingFunctions.h"

@class NSPreferences;

@class ABInputControllerPatches;
@class ABTextViewPatches;
@class ABTemplatePrefsPatches;
@class NSPreferencesPatches;
@class ABCardWindowControllerPatches;
@class ABMainWindowControllerPatches;
@class ABUIControllerPatches;

//global function to provide localised strings from the plugin bundle
NSBundle *ABKeyPluginBundle;
int ABSystemVersion;

NSString *KeyManagerLocalizedString(NSString *key, NSString *comment)
{return [ABKeyPluginBundle localizedStringForKey:key value:nil table:nil];}

NSString *pathToPluginBundleResource(NSString *resourceName, NSString *resourceType)
{return [ABKeyPluginBundle pathForResource:resourceName ofType:resourceType];}


//******* ABKeyManager *************

@implementation ABKeyManager

+(void)initialize
{
  ABKeyPluginBundle=[NSBundle bundleForClass:[self class]];

  //Hack to load the gpgme framework from the plugin bundle
  // because dyld looks in the app bundle by default
  // note: this only works if you weak-bind the gpgme library

  NSString *frameworkPath=[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/MacGPGME.framework"];
  NSBundle *framework=[NSBundle bundleWithPath:frameworkPath];

  if([framework load])
	NSLog(KeyManagerLocalizedString(@"MacGPGME framework loaded",@"framework loading"));
  else
  {
	NSLog(KeyManagerLocalizedString(@"Error, MacGPGME framework failed to load\nAborting.",@"framework loading"));
	exit(1);
  }

  NSLog(KeyManagerLocalizedString(@"ABKey Plugin loaded",@"plugin loading"));

//cause the relevent patch classes to be initialized
  [ABTextViewPatches class];
  [ABInputControllerPatches class];
  [ABTemplatePrefsPatches class];
  [NSPreferencesPatches class];
  [ABCardWindowControllerPatches class];
  [ABMainWindowControllerPatches class];
  [[NSClassFromString(@"ABMainWindowController") mainWindowController] registerForRefreshNotifications];
  [ABUIControllerPatches class];

//find the 'Add Field' submenu in the card menu
  NSArray *cardMenuItems=[[[[NSApp mainMenu] itemWithTag:42] submenu] itemArray];
  NSEnumerator *cardMenuItemEnumerator=[cardMenuItems objectEnumerator];
  id currentItem;
  do
	currentItem=[cardMenuItemEnumerator nextObject];
  while(currentItem!=nil && ![currentItem hasSubmenu]);

  if(currentItem!=nil)
  {

	NSMenu *fieldsMenu=[currentItem submenu];
	NSMenuItem *gpgMailOptionsMenu=[[[NSMenuItem alloc] initWithTitle:KeyManagerLocalizedString(@"GPGMail Options",@"template preferences menu item") action:@selector(addFieldWithNoPopup:) keyEquivalent:@""] autorelease];
	[gpgMailOptionsMenu setTag:255];
	[fieldsMenu insertItem:gpgMailOptionsMenu atIndex:[fieldsMenu numberOfItems]-2];
  }


  //setup default User Preferences by reading in the defaults dictionary from the bundle and
  //registering it with the shared usr defaults instance
  [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:pathToPluginBundleResource(@"ABKey",@"defaults")]];


  //add the gpg mail preferences field to the address book database, if it doesn't already exist
  [ABPerson addPropertiesAndTypes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kABDictionaryProperty],@"GPGOptions",nil]];


  //inform Address Book about the additional preference pane. This only works
  //because of the NSPreferences patch that catches the class name and
  //converts it to the preference name. If you change this, you must change the
  //NSPreferencesPatches method as well, so that the pane is actually displayed
  [[NSPreferences sharedPreferences] addPreferenceNamed:@"PGP" owner:[ABKeyPreferenceModule sharedInstance]];


  //register the valueTransformers used by the GUI
  if(![NSValueTransformer valueTransformerForName:@"ABKeyStatusColourTransformer"])
	[NSValueTransformer setValueTransformer:[[[ABKeyStatusColourTransformer alloc] init] autorelease] forName:@"ABKeyStatusColourTransformer"];

  if(![NSValueTransformer valueTransformerForName:@"ABKeyAlgorithmTypeImageTransformer"])
	[NSValueTransformer setValueTransformer:[[[ABKeyAlgorithmTypeImageTransformer alloc] init] autorelease] forName:@"ABKeyAlgorithmTypeImageTransformer"];


  //post a notification to cause a redraw
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ABTemplateLayoutHasChanged" object:nil userInfo:nil];

  //Work out what system we are running on
  int mib[2];
  size_t len;
  char *p;

  mib[0] = CTL_KERN;
  mib[1] = KERN_OSRELEASE;
  sysctl(mib, 2, NULL, &len, NULL, 0);
  p = malloc(len);
  sysctl(mib, 2, p, &len, NULL, 0);

  ABSystemVersion=[[NSString stringWithCString:p] intValue];

  free(p);


//hack stuff
//  listMethodsForClassNamed(@"ABPerson");
//  listMethodsForClassNamed(@"ABLDAPPrefsModule");
//  listMethodsForClassNamed(@"NSPreferencesModule");
//  listInstanceVariablesForClassNamed(@"ABPerson");
//  listInheritanceStackForClassNamed(@"ABPerson");

//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNotifications:) name:nil object:nil];

}

//+(void)allNotifications:(NSNotification *)notification
//{NSLog(@"Notification: %@",[notification name]);}

//AddressBook interface stuff
//*********************************************************

// This action works with email addresses.
- (NSString *)actionProperty
{return @"GPGKey";}
//{return @"GPGOptions";}
//{return @"Email";}

// The menu title
- (NSString *)titleForPerson:(ABPerson *)person identifier:(NSString *)identifier
{return KeyManagerLocalizedString(@"Manage GPG Key(s)",@"popup menu text");}

// This method is called when the user selects your action. As above, this method
// is passed information about the data item rolled over.
- (void)performActionForPerson:(ABPerson *)newPerson identifier:(NSString *)identifier
{
  [ABDetailedKeyInfoController displayDetailedKeyInfoSheetForPerson:newPerson identifier:identifier inWindow:[NSApp keyWindow]];
}

// Optional. Your action will always be enabled in the absence of this method. As
// above, this method is passed information about the data item rolled over.
- (BOOL)shouldEnableActionForPerson:(ABPerson *)selectedPerson identifier:(NSString *)identifier
{return YES;}

@end
