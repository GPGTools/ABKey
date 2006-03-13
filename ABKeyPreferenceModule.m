//
//  ABKeyPreferenceModule.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyPreferenceModule.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

@class NSPreferences;

id sharedABKeyPreferenceModule;

@implementation ABKeyPreferenceModule

-(void)dealloc
{
  [preferenceImage release];
  [super dealloc];
}

-(IBAction)gotoWebsite:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
}

+(id)sharedInstance
{
  if(sharedABKeyPreferenceModule==nil)
	sharedABKeyPreferenceModule=[[self alloc] init];
  return sharedABKeyPreferenceModule;
}

// Image to display in the preferences toolbar
-(NSImage *)imageForPreferenceNamed:(NSString *)name
{
//  NSLog(@"image for named pref: %@",name);
  if(preferenceImage==nil)
	preferenceImage=[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"ABKeyPreferences", @"tiff")];
  return preferenceImage;
}

-(NSView *)viewForPreferenceNamed:(NSString *)name
{
  if(preferenceView==nil)
	[NSBundle loadNibNamed:@"ABKeyPreferences" owner:self];
  return preferenceBox;
}

- (BOOL)isResizable
{return NO;}

-(NSSize)minSize
{return [preferenceBox bounds].size;}

//Called when switching preference panels.
-(void)willBeDisplayed
{//NSLog(@"Preference pane will be displayed");
}

-(BOOL)preferencesWindowShouldClose
{//NSLog(@"module window should close");
  return YES;}

-(BOOL)moduleCanBeRemoved
{//NSLog(@"module can be removed");
  return YES;}

-(void)moduleWasInstalled
{//NSLog(@"Module was installed");
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferenceChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

-(void)moduleWillBeRemoved
{//NSLog(@"Module will be removed");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
  }

-(void)didChange
{//NSLog(@"Module did change");
}

-(void)saveChanges
{//NSLog(@"Save changes");
}

-(BOOL)hasChangesPending
{//NSLog(@"Module has changes pending");
  return NO;}

-(void)initializeFromDefaults
{//NSLog(@"Init from defaults");
}


//Notifications
-(void)preferenceChanged:(NSNotification *)notification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ABTemplateLayoutHasChanged" object:nil userInfo:nil];
}

@end
